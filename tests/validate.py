#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["tomli==2.2.1; python_version < '3.11'"]
# ///
"""Exercise renders and migration boundaries using temporary homes only."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
try:
    import tomllib
except ModuleNotFoundError:
    try:
        import tomli as tomllib
    except ModuleNotFoundError:
        raise SystemExit('Python 3.10: run `uv run tests/validate.py` to load the isolated TOML test dependency.')

ROOT = Path(__file__).resolve().parent.parent

def run(args, **kwargs):
    return subprocess.run(args, check=True, capture_output=True, text=True, **kwargs)

with tempfile.TemporaryDirectory(prefix='dotfiles-validation-') as directory:
    base = Path(directory)
    for platform in ['darwin', 'linux']:
        for work in [True, False]:
            name = platform + ('-work' if work else '-personal')
            dest = base / name
            dest.mkdir()
            config = base / (name + '.toml')
            config.write_text('[data]\nworkMachine = ' + str(work).lower() + '\n')
            command = ['chezmoi', '--source', str(ROOT), '--destination', str(dest), '--config', str(config), '--persistent-state', str(base / (name + '.db')), '--cache', str(base / 'cache'), '--override-data', json.dumps({'chezmoi': {'os': platform}})]
            run(command + ['apply'])
            assert not run(command + ['diff']).stdout, name + ': nonempty post-apply diff'
            assert not any(p.is_symlink() for p in dest.rglob('*'))
            assert not (dest / '.config/hunk/state.json').exists()
            assert not (dest / '.zshrc.local').exists()
            assert (dest / '.config/lazygit/config.yml').exists() == (platform == 'linux')
            assert (dest / 'Library/Application Support/lazygit/config.yml').exists() == (platform == 'darwin')
            assert ('source "$HOME/.config/zsh/work.zsh"' in (dest / '.zshrc').read_text()) == work
            assert ('macos-titlebar-style' in (dest / '.config/ghostty/config').read_text()) == (platform == 'darwin')
            for file in dest.rglob('*'):
                if file.is_file() and (file.suffix == '.zsh' or file.name in ['.zshenv', '.zprofile', '.zshrc']):
                    run(['zsh', '-n', str(file)])
            env = os.environ.copy()
            env.update(HOME=str(dest), ZDOTDIR=str(dest))
            assert run(['zsh', '-d', '-lc', 'print -r -- quiet-startup'], env=env).stdout == 'quiet-startup\n'
            expected_prefix = '$HOME/.local/bin:$HOME/bin:$HOME/.local/share/mise/shims' if platform == 'linux' else '$HOME/.local/bin:$HOME/.local/share/mise/shims:/opt/homebrew/bin'
            shell = '[[ "$PATH" == ' + expected_prefix + ':* && "$EDITOR" == nvim && "$BAT_THEME" == "Catppuccin Mocha" ]]'
            run(['zsh', '-d', '-lc', shell], env=env)

            # GPFS mode must follow symlinks and restore normal aliases on exit.
            (dest / 'ci-gpfs').mkdir()
            (dest / 'gpfs-link').symlink_to(dest / 'ci-gpfs')
            shell = 'source "$HOME/.config/zsh/functions.zsh"; cd "$HOME/gpfs-link"; [[ "$STARSHIP_CONFIG" == "$HOME/.config/starship-gpfs.toml" && "$aliases[ls]" == "command ls" ]] || exit 1; cd "$HOME"; [[ -z "$STARSHIP_CONFIG" && "$aliases[ls]" == "eza --icons=auto" ]]'
            run(['zsh', '-dfc', shell], env=env)
            # Root-mounted and home-mounted shares both select the lightweight prompt.
            for mount in ['/ci-gpfs', '/qs-gpfs', '/gpfs']:
                shell = 'source "$HOME/.config/zsh/functions.zsh"; PWD=' + mount + '; _set_gpfs_shell_mode; [[ "$STARSHIP_CONFIG" == "$HOME/.config/starship-gpfs.toml" && "$aliases[ls]" == "command ls" ]]'
                run(['zsh', '-dfc', shell], env=env)
            if platform == 'linux':
                shell = 'source "$HOME/.config/zsh/platform/linux.zsh"; [[ "$path[1]" == "$HOME/.local/bin" && "$path[2]" == "$HOME/bin" && "$path[3]" == "$HOME/.local/share/mise/shims" ]]'
                run(['zsh', '-dfc', shell], env=env)
            print(name + ': render, empty diff, ordinary files, syntax, quiet shell and GPFS switching passed')
    # Named group application must preserve the release boundary and install children.
    group_home = base / 'group-test'
    group_config = group_home / '.config/chezmoi'
    group_config.mkdir(parents=True)
    (group_config / 'chezmoi.toml').write_text('[data]\nworkMachine = false\n')
    env = os.environ.copy()
    env.update(HOME=str(group_home), XDG_CONFIG_HOME=str(group_home / '.config'), XDG_CACHE_HOME=str(group_home / '.cache'), XDG_DATA_HOME=str(group_home / '.local/share'))
    sentinel = group_home / 'legacy-bat'
    sentinel.mkdir()
    (sentinel / 'untouched').write_text('legacy state')
    (group_home / '.config/bat').symlink_to(sentinel)
    refused = subprocess.run([str(ROOT / 'scripts/cutover'), 'apply', 'readonly'], env=env, capture_output=True, text=True)
    assert refused.returncode != 0 and 'Still linked:' in refused.stderr
    assert (sentinel / 'untouched').read_text() == 'legacy state'
    (group_home / '.config/bat').unlink()
    run([str(ROOT / 'scripts/cutover'), 'apply', 'readonly'], env=env)
    for target in ['bat/config', 'btop/btop.conf', 'tig/config', 'diffnav/config.yml', 'gh-dash/config.yml']:
        path = group_home / '.config' / target
        assert path.is_file() and not path.is_symlink(), target
    assert not (group_home / '.config/nvim/init.lua').exists()
    assert not run([str(ROOT / 'scripts/cutover'), 'preview', 'readonly'], env=env).stdout
    print('Named group: refuses legacy links, recursively installs only the released group, leaves empty diff')
    # Interactive leaf targets must create missing parents and preserve runtime files.
    hunk_state = group_home / '.config/hunk/state.json'
    hunk_state.parent.mkdir(parents=True)
    hunk_state.write_text('{"fixture": "keep"}\n')
    lazy_state = group_home / ('Library/Application Support/lazygit/state.yml' if os.uname().sysname == 'Darwin' else '.config/lazygit/state.yml')
    lazy_state.parent.mkdir(parents=True, exist_ok=True)
    lazy_state.write_text('fixture: keep\n')
    run([str(ROOT / 'scripts/cutover'), 'apply', 'interactive'], env=env)
    assert (group_home / '.config/herdr/plugins/config/jhochenbaum.hunkdiff/config.toml').is_file()
    assert hunk_state.read_text() == '{"fixture": "keep"}\n'
    assert lazy_state.read_text() == 'fixture: keep\n'
    assert not run([str(ROOT / 'scripts/cutover'), 'preview', 'interactive'], env=env).stdout
    print('Interactive group: creates nested parents, preserves Hunk/Lazygit runtime state, leaves empty diff')
    # The front-config migration must preserve employer fields across repeated runs.
    home = base / 'git-test'
    git = home / '.config/git'
    git.mkdir(parents=True)
    (git / 'portable.gitconfig').write_text('[pull]\n ff = only\n')
    old = home / 'old-config'
    old.write_text('[user]\n name = employer-value\n[include]\n path = ~/.config/git/home-manager.gitconfig\n[employer]\n marker = preserve\n[pull]\n ff = false\n')
    (git / 'config').symlink_to(old)
    env = os.environ.copy()
    env.update(HOME=str(home), GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=str(home / '.gitconfig'))
    for _ in range(2):
        run([str(ROOT / 'scripts/setup-git-front')], env=env)
    content = (git / 'config').read_text()
    assert not (git / 'config').is_symlink() and old.exists()
    assert content.count('portable.gitconfig') == 1 and 'home-manager.gitconfig' not in content
    assert 'employer-value' in content and 'preserve' in content
    assert run(['git', 'config', '--file', str(git / 'config'), '--includes', '--get', 'pull.ff'], env=env).stdout.strip() == 'false'
    # A front without the former include must also keep its local overrides.
    (git / 'config').write_text('[pull]\n ff = false\n')
    run([str(ROOT / 'scripts/setup-git-front')], env=env)
    assert run(['git', 'config', '--file', str(git / 'config'), '--includes', '--get', 'pull.ff'], env=env).stdout.strip() == 'false'

    print('Git front migration: preserves employer fields, materializes symlink, runs idempotently')
for parent in ['dot_config', 'packages']:
    for file in (ROOT / parent).rglob('*.toml'):
        with file.open('rb') as stream:
            tomllib.load(stream)
assert (ROOT / 'packages/mise.toml').read_bytes() == (ROOT / 'dot_config/mise/config.toml').read_bytes()
run([str(ROOT / 'scripts/secret-scan')])
print('TOML, manifest synchronization and source secret scan passed')

preview = run([str(ROOT / 'scripts/bootstrap-ubuntu'), '--plan'])
assert '22.04' in preview.stdout and 'Plan only:' in preview.stdout
assert 'build-essential' in preview.stdout and 'sshfs' in preview.stdout
print('Ubuntu bootstrap supports read-only planning without sudo or network access')

#!/usr/bin/env python3
"""Exercise renders and migration boundaries using temporary homes only."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import tomllib

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
                if file.is_file() and (file.suffix == '.zsh' or file.name == '.zshrc'):
                    run(['zsh', '-n', str(file)])
            env = os.environ.copy()
            env.update(HOME=str(dest), ZDOTDIR=str(dest))
            assert run(['zsh', '-d', '-lc', 'print -r -- quiet-startup'], env=env).stdout == 'quiet-startup\n'
            # GPFS mode must follow symlinks and restore normal aliases on exit.
            (dest / 'ci-gpfs').mkdir()
            (dest / 'gpfs-link').symlink_to(dest / 'ci-gpfs')
            shell = 'source "$HOME/.config/zsh/functions.zsh"; cd "$HOME/gpfs-link"; [[ "$STARSHIP_CONFIG" == "$HOME/.config/starship-gpfs.toml" && "$aliases[ls]" == "command ls" ]] || exit 1; cd "$HOME"; [[ -z "$STARSHIP_CONFIG" && "$aliases[ls]" == "eza --icons=auto" ]]'
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
    # The front-config migration must preserve employer fields across repeated runs.
    home = base / 'git-test'
    git = home / '.config/git'
    git.mkdir(parents=True)
    (git / 'portable.gitconfig').write_text('[pull]\n ff = only\n')
    old = home / 'old-config'
    old.write_text('[user]\n name = employer-value\n[include]\n path = ~/.config/git/home-manager.gitconfig\n[employer]\n marker = preserve\n')
    (git / 'config').symlink_to(old)
    env = os.environ.copy()
    env.update(HOME=str(home), GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=str(home / '.gitconfig'))
    for _ in range(2):
        run([str(ROOT / 'scripts/setup-git-front')], env=env)
    content = (git / 'config').read_text()
    assert not (git / 'config').is_symlink() and old.exists()
    assert content.count('portable.gitconfig') == 1 and 'home-manager.gitconfig' not in content
    assert 'employer-value' in content and 'preserve' in content
    print('Git front migration: preserves employer fields, materializes symlink, runs idempotently')
for parent in ['dot_config', 'packages']:
    for file in (ROOT / parent).rglob('*.toml'):
        with file.open('rb') as stream:
            tomllib.load(stream)
assert (ROOT / 'packages/mise.toml').read_bytes() == (ROOT / 'dot_config/mise/config.toml').read_bytes()
run([str(ROOT / 'scripts/secret-scan')])
print('TOML, manifest synchronization and source secret scan passed')

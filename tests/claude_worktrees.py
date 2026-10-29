#!/usr/bin/env python3
"""Exercise Claude hooks with temporary repositories and a fake CMake only."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent
wt = subprocess.check_output(['mise', 'which', 'wt'], text=True).strip()
with tempfile.TemporaryDirectory(prefix='claude-worktree-test-') as temporary:
    base = Path(temporary)
    home = base / 'home'
    dev = home / '.config/dev'
    dev.mkdir(parents=True)
    for source, target in [('executable_claude-worktree.py', 'claude-worktree.py'),
                           ('executable_setup-pwin-worktree.sh', 'setup-pwin-worktree.sh')]:
        shutil.copyfile(ROOT / 'private_dot_config/dev' / source, dev / target)
    config = home / '.config/worktrunk/config.toml'
    config.parent.mkdir()
    shutil.copyfile(ROOT / 'private_dot_config/worktrunk/config.toml', config)
    binaries = base / 'bin'
    binaries.mkdir()
    cmake = binaries / 'cmake'
    cmake.write_text('#!/bin/sh\nmkdir -p pwin/build/editor\nprintf "[]\\n" > pwin/build/editor/compile_commands.json\n')
    cmake.chmod(0o700)
    env = dict(os.environ, HOME=str(home), PATH=str(binaries) + os.pathsep + str(Path(wt).parent) + os.pathsep + os.environ['PATH'],
               XDG_CONFIG_HOME=str(home / '.config'), XDG_CACHE_HOME=str(home / '.cache'),
               XDG_STATE_HOME=str(home / '.local/state'), CLAUDE_CONFIG_DIR=str(home / '.claude'),
               WORKTRUNK_CONFIG_PATH=str(config), WORKTRUNK_SYSTEM_CONFIG_PATH=str(base / 'absent-system'),
               WORKTRUNK_PROJECT_CONFIG_PATH=str(base / 'absent-project'),
               GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=os.devnull)
    env.pop('WORKTRUNK_WORKTREE_PATH', None)

    def run(args, **kwargs):
        return subprocess.run(args, env=env, text=True, capture_output=True, check=True, **kwargs)

    def git(repo, *args):
        return run(['git', '-C', str(repo), '-c', 'user.name=Hook Test', '-c', 'user.email=test@example.invalid',
                    '-c', 'commit.gpgsign=false', '-c', 'core.hooksPath=/dev/null', *args]).stdout.strip()

    settings = home / '.claude/settings.json'
    settings.parent.mkdir()
    original = {'env': {'PRESERVE_ME': 'fixture'}, 'hooks': {'SessionStart': [{'hooks': []}]},
                'enabledPlugins': {'existing@example': True}}
    settings.write_text(json.dumps(original))
    installer = ['python3', str(ROOT / 'scripts/setup-claude-worktrees')]
    run(installer)
    merged = json.loads(settings.read_text())
    assert merged['env'] == original['env'] and merged['enabledPlugins'] == original['enabledPlugins']
    assert merged['hooks']['SessionStart'] == original['hooks']['SessionStart']
    content = settings.read_bytes()
    run(installer)
    assert settings.read_bytes() == content
    backups = list((home / '.local/state/dotfiles-migration').glob('claude-settings-*/settings.json'))
    assert len(backups) == 1 and backups[0].stat().st_mode & 0o777 == 0o600
    print('Installer preserves unrelated settings, keeps a private backup, and is idempotent.')

    for name, remote, folder in [('ordinary', None, 'ordinary'),
                                  ('sptk-fixture', 'sputnik', 'sptk'),
                                  ('ml-fixture', 'pytorch_models', 'ml')]:
        repo = base / name
        run(['git', 'init', '-q', '-b', 'main', str(repo)])
        (repo / 'pwin').mkdir()
        (repo / 'pwin/CMakeLists.txt').write_text('# synthetic fixture only\n')
        (repo / '.gitignore').write_text('pwin/build/\npwin/compile_commands.json\n')
        git(repo, 'add', '.')
        git(repo, 'commit', '-qm', 'Fixture')
        git(repo, 'switch', '-qc', 'source-branch')
        git(repo, 'commit', '-q', '--allow-empty', '-m', 'Source branch tip')
        if remote:
            git(repo, 'remote', 'add', 'origin', f'git@github.geo.apple.com:geo-flyover/{remote}.git')
        payload = {'cwd': str(repo), 'name': 'test-run'}
        adapter = ['python3', str(dev / 'claude-worktree.py')]
        result = run(adapter + ['create'], input=json.dumps(payload))
        path = Path(result.stdout.strip())
        assert path == (home / 'trees' / folder / 'claude-test-run').resolve()
        assert git(path, 'rev-parse', 'HEAD') == git(repo, 'rev-parse', 'HEAD')
        if remote == 'sputnik':
            assert (path / 'pwin/build/editor/compile_commands.json').is_file()
            assert (path / 'pwin/build/debug').is_dir() and (path / 'pwin/build/release').is_dir()
        collision = subprocess.run(adapter + ['create'], input=json.dumps(payload), env=env, text=True, capture_output=True)
        assert collision.returncode != 0
        dirty = path / 'keep-me.txt'
        dirty.write_text('Uncommitted work')
        removal = {'cwd': str(repo), 'worktree_path': str(path)}
        refused = subprocess.run(adapter + ['remove'], input=json.dumps(removal), env=env, text=True, capture_output=True)
        assert refused.returncode != 0 and dirty.is_file()
        dirty.unlink()
        run(adapter + ['remove'], input=json.dumps(removal))
        assert not path.exists()
        git(repo, 'show-ref', '--verify', 'refs/heads/claude/test-run')
        print(f'{name}: path, source HEAD, collision refusal, dirty protection, clean removal and branch retention passed.')

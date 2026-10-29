#!/usr/bin/env python3
"""Claude worktree lifecycle adapter; Worktrunk owns paths and project setup."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys


def run(args, cwd):
    return subprocess.run(args, cwd=cwd, stdin=subprocess.DEVNULL,
                          stdout=subprocess.PIPE, text=True, check=True).stdout


def main():
    event = json.load(sys.stdin)
    cwd = Path(event['cwd']).resolve(strict=True)
    wt = shutil.which('wt')
    if not wt:
        shim = Path.home() / '.local/share/mise/shims/wt'
        if shim.is_file() and os.access(shim, os.X_OK):
            wt = str(shim)
    if not wt:
        raise ValueError('wt is unavailable; install the dotfiles Worktrunk provider first')
    if sys.argv[1] == 'create':
        name = event['name']
        if not isinstance(name, str) or not name or any(c in name for c in '\r\n\x00'):
            raise ValueError('invalid worktree name')
        branch = 'claude/' + name
        # Fail on name collisions instead of reusing another session's checkout.
        result = json.loads(run([wt, 'switch', '--create', branch, '--base', 'HEAD',
                                 '--no-cd', '--format', 'json'], cwd))
        path = Path(result['path']).resolve(strict=True)
        if not (path / '.git').is_file():
            raise ValueError('Worktrunk did not return a linked Git worktree')
        print(path)
    elif sys.argv[1] == 'remove':
        path = Path(event['worktree_path']).resolve(strict=True)
        branch = run(['git', 'symbolic-ref', '--quiet', '--short', 'HEAD'], path).strip()
        if not branch.startswith('claude/') or not (path / '.git').is_file():
            raise ValueError('refusing to remove a checkout not on a claude/ branch')
        source_git = run(['git', 'rev-parse', '--path-format=absolute', '--git-common-dir'], cwd).strip()
        target_git = run(['git', 'rev-parse', '--path-format=absolute', '--git-common-dir'], path).strip()
        if Path(source_git).resolve() != Path(target_git).resolve():
            raise ValueError('worktree belongs to another repository')
        # No force: preserve dirty checkouts and retain branches for recovery.
        run([wt, 'remove', '--foreground', '--no-delete-branch', str(path)], cwd)
    else:
        raise ValueError('expected create or remove')


if __name__ == '__main__':
    try:
        main()
    except (KeyError, ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f'Claude worktree hook: {error}', file=sys.stderr)
        sys.exit(1)

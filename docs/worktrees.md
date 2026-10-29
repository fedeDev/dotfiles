# Worktree layout and Claude Code

Worktrunk owns new checkout locations for Herdr, direct `wt` commands and Claude's
built-in worktree isolation:

| Repository | New checkout path |
| --- | --- |
| Sputnik | `~/trees/sptk/<branch>` |
| pytorch_models | `~/trees/ml/<branch>` |
| Other repositories | `~/trees/<repo>/<branch>` |

Branch names are sanitized for paths. Existing worktrees are not moved.

## Claude setup

After applying the dotfiles, run:

```sh
./scripts/setup-claude-worktrees
```

This explicitly merges `WorktreeCreate` and `WorktreeRemove` command hooks into
`~/.claude/settings.json` (or `$CLAUDE_CONFIG_DIR/settings.json`). Other settings,
plugins and hooks are preserved. An existing different handler for either event
requires an explicit merge instead of overwriting it. Changed settings are backed
up privately under `~/.local/state/dotfiles-migration/claude-settings-*`.
The local settings file and its backup never enter Git.

Restart Claude after installation. Its `--worktree`, `EnterWorktree` and agent
worktree isolation use the settings hook to call `wt switch --create`, based on
the invoking checkout's committed HEAD. Branches use `claude/<name>`; for example,
a Sputnik task named `fix-index` appears at `~/trees/sptk/claude-fix-index`.
A name collision fails rather than reusing another session's checkout.

Sputnik's `pre-start` hook runs the existing Pwin setup synchronously, creating
`pwin/build/editor`, `pwin/build/debug`, `pwin/build/release` and configuring the
editor CMake build before the new checkout is returned. This configures the build;
it does not compile the project or copy an existing build directory. Other repos
run only their own configured Worktrunk hooks; no Pwin setup is added to ML repos.
Project hooks still use Worktrunk's normal approval handling.

Cleanup uses `wt remove` without force and retains the branch. Dirty checkouts
are preserved. Existing worktrees under `.claude` are not automatically relocated
or configured by this change.

These lifecycle hooks do not intercept arbitrary `git worktree add` shell commands
Claude chooses to run. Ask Claude to use its built-in worktree tools or `wt switch
--create`, rather than creating worktrees through Git directly. The hook is in user
settings so it does not depend on a plugin being loaded early enough at startup.

References: [Claude worktree hooks](https://code.claude.com/docs/en/hooks#worktreecreate),
[Worktrunk agent integration](https://worktrunk.dev/claude-code/).

Run the fixture checks with `python3 tests/claude_worktrees.py`. They exercise
creation, configuration readiness, branch collisions, settings preservation and
cleanup using temporary repos and a fake CMake; no private project is inspected.

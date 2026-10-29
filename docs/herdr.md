# Agent restore in Herdr

The managed config explicitly enables `[session] resume_agents_on_restore = true`.
On restore, eligible agent panes resume their native conversations instead of
opening plain shells. A current official integration must have reported a valid
session reference; old panes without one cannot be recovered by this setting.

Install or refresh integrations for agents you use on each machine:

```sh
herdr integration status
herdr integration install claude
herdr integration install codex
herdr integration install opencode
```

Restart the affected agents after updating integrations so they can report their
session references. These commands update local agent settings/hooks, outside
Chezmoi source; do not commit their runtime state or private settings to dotfiles.

On this Mac, Claude v10, Codex v8 and OpenCode v13 integrations were verified
current. Herdr accepted the config and reloaded it without diagnostics. Existing
Claude settings and Worktrunk lifecycle hooks were preserved. No running agent
or Herdr server was stopped to test restore.

See [Herdr configuration](https://herdr.dev/tui/docs/configuration/) and
[session restore](https://herdr.dev/tui/docs/session-state/).

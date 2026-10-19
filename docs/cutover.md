# Incremental cutover runbook

## Current checkpoint

Phases 0–2 are implemented, with the open decisions below. Source preparation and isolated validation are complete. Phase 3 group 1 is applied and checked after the user rebuild. Group 2 (interactive apps) is prepared in `migration.nix` and awaits its own user rebuild. The agent applied only group 1 after the user ran the Nix rebuild. No package cutover, macOS preference change, agent-run Nix rebuild, or Nix removal has occurred.

The user must run Nix rebuilds. `MIGRATION_PLAN.md`, phase 3 step 3, explicitly says “ask the user to run the Nix rebuild—an agent must not run it.” Ubuntu runtime acceptance, graphical terminal checks, and external token rotation also require work outside this session.

## First group: completed

`migration.nix` lists Bat, btop, Diffnav and gh-dash Home Manager targets, plus the next prepared interactive group. Tig was already unmanaged. `home.nix` filters only these targets and disables Nix's Bat cache activation for this group. No package is removed. The `76a8950` baseline commit preserves the original Nix configuration.

The following first-group sequence has completed. Do not repeat its rebuild while the next group is prepared without reviewing the current releasedTargets. Runbook commands from `~/dotfiles`:

```sh
./scripts/backup-live
./rebuild.sh                 # USER runs this; requires sudo
./scripts/cutover preview readonly
./scripts/cutover apply readonly
```

The apply command refuses existing symlinks, including parent-directory symlinks, until Home Manager has released them. It previews and applies only the named group, checks for an empty post-apply diff, and rebuilds Bat's theme cache. Preview output is local terminal output and may contain configuration details; do not paste sensitive Git front configs into issue trackers.

Smoke-test `bat --list-themes`, `btop --version`, `tig --version`, `diffnav --help`, `gh-dash --version`; launch the interactive applications in Ghostty. Check `realpath` and `test ! -L` for each target. Ordinary `chezmoi apply` never installs/upgrades packages or changes preferences.

## Next checkpoint: interactive group ready

A private snapshot was taken with `scripts/backup-live` immediately before preparing group 2. The next user action is `./rebuild.sh`, followed by `./scripts/cutover preview interactive` and `./scripts/cutover apply interactive`. Restore any individual backed-up runtime state files after the new directories exist. Keep installed Herdr plugin payloads and sessions unmanaged. Confirm the four existing plugins remain wanted before applying integration configuration.

## Remaining groups

Only release the next group after the preceding one passes runtime checks. Extend `migration.nix.releasedTargets` with exactly the relevant existing Home Manager names below, preserving already released targets. Back up before each rebuild. Run the rebuild yourself, then preview/apply the group with `scripts/cutover`. A release requires changing declarations AND rebuilding; adding a name alone does not alter the running generation.

| Apply group | Home Manager names to release | Additional validation |
| --- | --- | --- |
| interactive | `.config/yazi`, `.config/lazygit`, `Library/Application Support/lazygit/config.yml`, `.config/hunk`, `.config/herdr/config.toml`, `.config/herdr/plugins/config/jhochenbaum.hunkdiff/config.toml`, `.config/worktrunk` | Preserve mutable state before release; `lazygit --print-config-dir` on both OSes; `ya pkg install`; verify previews, Herdr plugins and Hunk. |
| ghostty | `.config/ghostty` | Launch a new Ghostty window; no Downloads access required. |
| nvim | `.config/nvim` | Headless startup/checkhealth, then interactive Neovim; preserve lazy-lock.json. |
| git | `.config/git/home-manager.gitconfig`, `.config/git/ignore` | Apply portable file/ignore, then `scripts/setup-git-front`. Check origins and behavior from Ghostty and another terminal; confirm employer signing tool can still modify the front config. |
| shell | `.zshrc` (marker), `.config/starship-gpfs.toml`, `.config/dev` | Marker disables Nix Zsh/Starship/Zoxide/FZF/Tealdeer modules together; see shell prerequisites below. |

All names are relative to HOME. The `.zshrc` marker affects generated program modules rather than a `home.file` entry. The Git marker also disables the old front-config seeding activation. For groups with directory ownership, back up mutable state while the symlink still resolves, then restore ONLY runtime files to their new ordinary directories after apply. Never restore old config symlinks on top of applied files.

`backup-live` stores known configs and Hunk/Lazygit state privately under `~/.local/state/dotfiles-migration/live-*`. If `state.yml` existed, copy that individual file from the appropriate private backup into the active Lazygit directory after config apply. Do not copy state into source or the repository. Herdr runtime sessions/plugin state stay unmanaged; the cutover names only authored config files. No private project setup script is executed by bootstrap.

## Shell prerequisites

1. Revoke/rotate the exposed Splunk token externally. Do not reuse the old value.
2. Verify migrated work helper names in `dot_config/zsh/work.zsh`. They are sourced only when local Chezmoi `workMachine = true`; the old generic local shell file is never sourced by the new configuration.
3. Configure Keychain / Linux Secret Service, or the documented temporary private bridge. Test the `with-splunk-token` wrapper with the actual consumer without logging its environment. This is lazy per-process retrieval.
4. Install the pinned Antidote checkout and required CLI providers explicitly. Do not remove existing packages yet. `scripts/install-packages` creates user-space tool installations without changing the active global manifest or PATH. On this Mac uv must be installed before this step (`brew install uv`), or use the reviewed native manifest in phase 4.
5. Archive `.zshrc.local` privately outside source after verifying helper migration and token rotation. Initial untouched backup is at `~/.local/state/dotfiles-migration/20261019-093836/.zshrc.local`; it contains the exposed token and must remain private. Archive the original without printing it, then ensure it is absent before `scripts/cutover apply shell`.
6. After shell apply, test a fresh interactive shell in a real terminal and `zsh -lc 'true'`; verify widgets, completion, GPFS switching, prompt and Zoxide warning absence. The first Antidote load may download plugins. Follow with a second clean startup.

The active Nix-managed shell still sources `.zshrc.local` until this group is rebuilt. Do not remove it early without accounting for active Nix shell behavior.

## Package cutover

Keep this separate from Git/Zsh configuration changes. Explicit installers are `scripts/bootstrap-macos`, `scripts/bootstrap-ubuntu` and `scripts/install-packages`. Brew uses `--no-upgrade`; dependencies may still require upgrades, so review output. There are no cleanup, autoremove or Nix uninstall operations.

After installation and independent command/version tests, use `scripts/cutover preview packages` and `scripts/cutover apply packages` to deploy the global mise manifest. The new shell orders `~/.local/bin`, mise shims, native package paths, then remaining system/Nix paths; on Linux employer helpers in `~/bin` are retained between `~/.local/bin` and the shims. `scripts/doctor` reports missing commands, duplicates, legacy paths and version mismatches without changing them. Remove the corresponding `home.packages` entries only after their replacements pass runtime checks, then ask the user to rebuild each batch. Check linked libraries before removing Nix libraries.

BeautifulSoup/lxml consumers are unresolved; their existing Nix provider must remain. macOS SSHFS/system extensions remain employer-owned. GUI Linux font/Ghostty installation requires desktop-specific setup. These are acceptance prerequisites, not completed steps.

## Rollback

Stop at the first failed group. Remove ONLY that group's names from `migration.nix` (keep prior successful groups), or restore its declarations from baseline commit `76a8950`. Archive the just-applied ordinary files privately so they do not conflict with Home Manager; do not delete runtime state. The user rebuilds the prior Nix configuration and restores mutable front configs from the private backup if needed. The generation and pre-cutover paths are recorded in `docs/current-state.md`. Keep this checkout and its legacy `home/` files while Nix uses the `~/.dotfiles` compatibility link.

Do not retire nix-darwin/Home Manager until BOTH Mac and Ubuntu pass every acceptance check in MIGRATION_PLAN.md. Nix removal is a separate user-approved operation.

## Known state loss during implementation

The implementing agent mistakenly deleted the pre-existing, untracked `home/.config/hunk/state.json` while excluding runtime files. That path also backed the live Home Manager symlink. It was not in Git or the initial private backup, and was not recovered. Hunk state may need restoring from an independent backup or may regenerate; its prior contents are unknown. No fabricated replacement state was written. New source excludes runtime state, and backup-live now explicitly preserves existing Hunk/Lazygit state before future cutovers.

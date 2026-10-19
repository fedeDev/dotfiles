# Incremental cutover runbook

## Current checkpoint

Phases 0–2 are implemented, with the open decisions below. Source preparation and isolated validation are complete. All six phase-3 configuration groups are applied and checked after their user rebuilds. The old local shell file is privately archived and no longer sourced. No configuration-release rebuild remains. Package ownership cleanup, Ubuntu runtime acceptance and Nix retirement remain separate. No agent-run Nix rebuild, macOS preference change or Nix removal has occurred.

The user must run Nix rebuilds. `MIGRATION_PLAN.md`, phase 3 step 3, explicitly says “ask the user to run the Nix rebuild—an agent must not run it.” Ubuntu runtime acceptance, graphical terminal checks, and external token rotation also require work outside this session.

## First group: completed

`migration.nix` lists Bat, btop, Diffnav and gh-dash Home Manager targets, the applied interactive/Ghostty/Neovim/Git groups. Tig was already unmanaged. `home.nix` filters only these targets and disables Nix's Bat cache activation for this group. No package is removed. The `76a8950` baseline commit preserves the original Nix configuration.

The following first-group sequence has completed. Do not repeat its rebuild while the next group is prepared without reviewing the current releasedTargets. Runbook commands from `~/dotfiles`:

```sh
./scripts/backup-live
./rebuild.sh                 # USER runs this; requires sudo
./scripts/cutover preview readonly
./scripts/cutover apply readonly
```

The apply command refuses existing symlinks, including parent-directory symlinks, until Home Manager has released them. It previews and applies only the named group, checks for an empty post-apply diff, and rebuilds Bat's theme cache. Preview output is local terminal output and may contain configuration details; do not paste sensitive Git front configs into issue trackers.

Smoke-test `bat --list-themes`, `btop --version`, `tig --version`, `diffnav --help`, `gh-dash --version`; launch the interactive applications in Ghostty. Check `realpath` and `test ! -L` for each target. Ordinary `chezmoi apply` never installs/upgrades packages or changes preferences.

## Configuration cutover completed

Groups 1–5 are applied. Git's front config, portable include and ignore are ordinary writable files; active Git origins avoid Downloads and Nix paths. The helper replaced the old include in place, preserving all other XDG front values and the byte-identical primary `~/.gitconfig`. Status, log, blame, global ignore and Difftastic comparison checks pass. Employer signing-tool behavior and effective configuration from a real Ghostty window remain user checks; no signing tool or credentials were modified during testing.

Neovim starts headlessly/interactively, and all 19 plugin revisions match the lockfile. Native FFF/FZF modules load. The FFF binary was downloaded for the same locked commit without Nix; unused LuaRocks integration is disabled. Health has no errors and retains package-directory/log-size warnings. Ghostty's validator passes. Real Ghostty/Yazi visual/TCC checks remain user validation tasks. The original Hunk state loss documented below remains unrecovered.

The user completed the sixth configuration rebuild. `.zshenv`, `.zprofile`, `.zshrc`, plugin manifest, prompt configs, modules and worktree setup script are ordinary writable files. All six named groups have empty managed diffs after startup tests. Fresh interactive login Zsh loads the expected helpers/widgets and keybindings without errors or Zoxide warnings; non-interactive login startup is silent. The retired token is not loaded in clean child environments. Existing parent terminals may still carry their old environment; enter the new shell with `exec env -u SPLUNK_TOKEN_IAG /bin/zsh -l`.

`.zshrc.local` was archived privately at `~/.local/state/dotfiles-migration/retired-shell-0431y4re/.zshrc.local` (0600 file inside a 0700 directory). Its helpers were matched to the migrated work module before archival. The user confirmed external revocation/rotation. No old token is copied into the new configuration. Optional replacement-token usage remains lazy through the wrapper; no real replacement provider/consumer test is claimed.

Independent Antidote is pinned. Starship's original Nix CLI is retained explicitly until package replacement checks pass. The newly active cmake-format and latex2text wrappers were verified against pinned dependencies in the dedicated `~/.local/share/dotfiles-python` environment, created using Homebrew Python without global pip installs. No private project setup script was run.

Package replacement/ownership cleanup is a later phase and may require additional user rebuilds. Their count is not yet established; the completed shell cutover does not imply that full migration, Ubuntu acceptance or Nix retirement have passed.

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
3. The revoked old token is retired rather than migrated. If a replacement is needed, configure Keychain / Linux Secret Service, or the documented temporary private bridge, then test `with-splunk-token` with its actual consumer without logging its environment. The shell does not retrieve/export a token on startup.
4. Install the pinned Antidote checkout and required CLI providers explicitly. Do not remove existing packages yet. `scripts/install-packages` creates user-space tool installations without changing the active global manifest or PATH. On this Mac uv must be installed before this step (`brew install uv`), or use the reviewed native manifest in phase 4.
5. After the final user rebuild, archive `.zshrc.local` privately outside source before applying shell files; helper migration and token rotation are already verified/confirmed. Initial untouched backup is at `~/.local/state/dotfiles-migration/20261019-093836/.zshrc.local`; it contains the exposed token and must remain private. Archive the original without printing it, then ensure it is absent before `scripts/cutover apply shell`.
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

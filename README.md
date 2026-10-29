# dotfiles

Portable Chezmoi configuration for macOS and Ubuntu, with pinned CLI tools in mise and explicit native package installers. The existing Nix setup remains available while configuration is migrated one group at a time.

The checkout is `~/dotfiles`. On this Mac, `~/.local/share/chezmoi` and the legacy `~/.dotfiles` compatibility path point here. Applied Chezmoi targets are ordinary files, independent of the checkout. Source uses `private_dot_config/` and private macOS Library ancestors to retain private directory permissions. Chezmoi supports a [custom source directory](https://www.chezmoi.io/user-guide/advanced/customize-your-source-directory/).

**Existing Nix machine:** start with [the cutover runbook](docs/cutover.md). All six configuration groups are applied and verified on this Mac. No configuration-release rebuilds remain. Package-provider cleanup and Ubuntu runtime acceptance remain separate steps. Do not run an unrestricted live apply while Home Manager owns these files.

**Fresh machine:** complete employer provisioning first where applicable; Ubuntu users should follow [docs/ubuntu.md](docs/ubuntu.md). Clone this migration branch, review package manifests and run explicit bootstrap:

```sh
git clone --branch migration/chezmoi https://github.com/fedeDev/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/bootstrap --packages    # explicit native/mise installs; Ubuntu uses sudo
./scripts/bootstrap               # configure Chezmoi; choose workMachine locally
chezmoi diff
chezmoi apply                    # only on a fresh home with no Nix ownership
ya pkg install                   # fetch Yazi plugins/flavor from package.toml
./scripts/install-herdr-plugins   # optional explicit plugin installation at saved revisions
./scripts/setup-git-front         # retain writable machine-local Git front config
./scripts/setup-claude-worktrees  # optional: route Claude isolation through Worktrunk
./scripts/doctor
```

Use the migration branch until the cutover is complete and merged. Ubuntu 22.04 LTS is the intended Linux baseline; actual Ubuntu runtime validation is pending. Linux GUI users must install Ghostty and FiraCode Nerd Font according to their desktop setup. Homebrew must already exist on macOS; the employer installation stays independent of Nix. No package installer runs during an ordinary `chezmoi apply`.

`packages/mise.toml` and `private_dot_config/mise/config.toml` intentionally match. Update both and run `python3 tests/validate.py`. Exact owners, exceptions, Python environments and credential-provider choices are in [docs/packages.md](docs/packages.md). `scripts/macos-defaults` is an explicit optional action; it prints changes, never touches the menu bar/Dock and does not restart Finder automatically.

Worktree paths, Claude lifecycle hooks and per-project setup are documented in [docs/worktrees.md](docs/worktrees.md).

## Persisting changes to personal GitHub

This checkout is connected to `https://github.com/fedeDev/dotfiles.git`, on `migration/chezmoi`, based on the remote's default `nix` branch. A baseline commit preserves the downloaded configuration before the migration implementation.

The commit identity `fedeDev <fede.camposeco@gmail.com>` is set with `git config --local`; global Apple identity/signing settings remain unchanged. This checkout disables automatic commit signing and inherited hooks so employer tooling is not invoked for personal commits. Authentication is separate from commit identity. Public fetches work anonymously; publishing requires a personal GitHub.com login.

```sh
gh auth login --hostname github.com --git-protocol https --web
# Sign in as fedeDev. Your github.geo.apple.com login stays on its separate host.
git push -u origin migration/chezmoi
```

The checkout's GitHub.com credential helper uses gh locally; do not run `gh auth setup-git` globally. No token is stored in this repository. If work is saved as a private bundle before authentication is available, restore it with `git clone PATH-TO-BUNDLE ~/dotfiles-restored`.

On work machines, the interactive `gh` helper defaults to `github.geo.apple.com`. Run `git config --local gh.host github.com` in this personal checkout to select its personal host; repeat this after a fresh clone. An explicit `GH_HOST` overrides either default. The helper does not change stored credentials or global Git settings.

## Verification and remaining work

```sh
uv run tests/validate.py          # isolated tomli dependency on Python 3.10
shellcheck scripts/bootstrap scripts/bootstrap-macos scripts/bootstrap-ubuntu scripts/install-packages scripts/install-herdr-plugins scripts/macos-defaults
nix flake check --no-build
./scripts/secret-scan
```

Tests render all four OS/work combinations into temporary homes, assert empty post-apply diffs and ordinary files, check Zsh syntax/non-interactive startup/GPFS switching, and exercise Git front-config migration without touching real employer settings. Mac mise installs and Neovim startup were also tested in isolation. See [docs/validation.md](docs/validation.md) for observed results and incomplete acceptance checks.

The complete migration is **not finished**: native package replacement/ownership cleanup, Ubuntu runtime acceptance, unresolved Python consumers and eventual Nix retirement remain. All six Mac configuration groups and the 20 pinned mise providers are active; token revocation/rotation is confirmed. See the original [MIGRATION_PLAN.md](MIGRATION_PLAN.md), sanitized [inventory](docs/current-state.md), and the runbook's documented Hunk runtime-state deletion incident.

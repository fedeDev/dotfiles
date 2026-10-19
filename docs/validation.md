# Validation record

Recorded on macOS arm64, 2026-10-19. This records completed checks, not full workstation acceptance.

| Check | Result |
| --- | --- |
| `python3 tests/validate.py` | PASS: Darwin/Linux × work/personal temporary renders; empty post-apply diffs; no symlinks/state/local shell file; per-OS Lazygit/Ghostty selection; Zsh syntax and quiet non-interactive startup; resolved GPFS symlinks and restored aliases; Git front materialization/idempotence/employer-field preservation; TOML parsing and synchronized manifests; source secret scan. |
| Lazy token wrapper | PASS: fixture provider retrieval, refusal of 0644 bridge, accepted 0600 bridge, no emitted values; no real credential provider was queried. |
| ShellCheck on all new Bash scripts | PASS. |
| `nix flake check --no-build` | PASS, Darwin configuration evaluated. No rebuild was run. |
| Home Manager `home.file` evaluation | PASS: Bat/btop/Diffnav/gh-dash declarations excluded; Neovim/Ghostty/Hunk/Git remain owned. This is source evaluation, not a live generation switch. |
| Isolated mise install | PASS: all 20 Mac-applicable tools downloaded/extracted in `/tmp/dotfiles-mise.*`, with separate data/cache/state. No global PATH or manifest changed. |
| Independent command resolution | PASS: all 20 commands resolved inside the isolated mise installation and ran version checks. Diffnav/gh-dash use their own version output formats; all executables were present. |
| Independent Neovim startup | PASS: mise Neovim 0.12.4 started headlessly with rendered config and existing installed plugin data; no private project was opened. This does not prove a fresh plugin-download/compilation environment or replace full post-cutover health checks. |
| Interactive Zsh in PTY | PASS: rendered config starts with Antidote and all five plugins, Alt-J/Alt-. bindings, autosuggestion/history/fzf-tab widgets; clean second startup without Zoxide warning. First startup downloads plugins. |
| First-group preview | PASS: named readonly group diff generated successfully. |
| Premature live group apply | PASS: refused on `.config/bat` Home Manager symlink before any apply. |
| `brew bundle check --verbose` | Expected pending dependencies: font cask, git, gh, btop, eza, cmake, llvm, node, uv, imagemagick, herdr. No batch install/upgrade was performed. |
| `scripts/doctor` on current live environment | Expected failure: 33 warnings before cutover, including missing native providers, duplicates, Nix paths, absent portable Git file and legacy local shell file. No modifications. |
| GitHub persistence | Personal identity scoped to repository; public history fetched from `origin/nix`; publishing uses personal `github.com` authentication alongside employer host. |
| Global Git preservation | PASS: `~/.gitconfig` and `~/.config/git/config` byte-identical to initial private backups after GitHub.com authentication. |

## Live first-group result

User confirmed successful Nix rebuild. Bat, btop, Tig, Diffnav and gh-dash configs were applied as seven ordinary writable files; realpaths are outside the checkout, Downloads and Nix store. Post-apply and post-smoke-test diffs are empty. Bat theme-cache/rendering passed, btop and Tig opened and exited in a PTY, and Diffnav/gh-dash YAML parses. gh-dash has no active provider yet; its installed isolated binary was verified earlier. This live GUI check remains pending package cutover.

## Outstanding acceptance

- Next user-run Nix rebuild and interactive-app group cutover. First group is complete; gh-dash live interactive startup awaits its active package provider.
- Subsequent group cutovers, including actual Ghostty/TCC checks, interactive applications, full Neovim health/plugin bootstrap, Git employer-signing behavior and shell keystroke checks in a normal terminal.
- Confirm the existing four Herdr plugins remain wanted and work at recorded revisions.
- External exposed-token revocation/rotation and credential-provider setup, then archive/remove legacy `.zshrc.local`.
- Identify external BeautifulSoup/lxml consumers without inspecting private project source.
- Full Ubuntu bootstrap/runtime/clipboard/font/GUI acceptance; Linux rendering on Mac does not establish Linux runtime compatibility.
- Install native replacements, validate command paths and library dependencies, then remove Nix package ownership in batches with user rebuilds.
- Retire nix-darwin/Home Manager only after both platforms pass, followed by separately approved Nix removal if desired.
- Hunk runtime state was mistakenly deleted and was not recovered; see docs/cutover.md. This prevents claiming lossless state preservation.

The migration remains incomplete until these checks pass. Existing live Nix ownership remains the rollback path.

## Ubuntu onboarding compatibility update

The provided onboarding text requires Ubuntu 22.04 LTS. The earlier 24.04 minimum has been corrected. Employer provisioning order is recorded generically in docs/ubuntu.md; the internal guides, certificates and scripts were not copied into this public source. Bootstrap now supports a read-only --plan, checks the 22.04 release on installation, preserves ~/bin, checks package candidates and passes --no-upgrade for existing requested apt packages. Linux Node is left to the employer/project runtime rather than the Jammy Node 12 default.

Validation on Mac passed for root/home GPFS mount detection, Linux PATH order, all four render combinations, and the no-install Ubuntu plan. The original 32-package list was verified against Canonical's Jammy amd64 main/universe indexes; all existed. Removing Node/npm leaves 30 previously verified packages. Jammy versions observed include CMake 3.22.1, clangd 14 and Python 3.10, so approved project toolchains must remain authoritative. The Python validation entry point supports uv's isolated tomli dependency for Python 3.10. No live Ubuntu runtime test was available; the configured Docker engine was unreachable, and no VM/driver/network settings were changed.

Additional binary metadata check: the pinned Linux x86-64 Neovim executable references GLIBC up to 2.34, Hunk up to 2.17, and the inspected Herdr executable has no GLIBC version references. This checks only those executables, not all bundled libraries or other tools, and is not a runtime test. Jammy ships GLIBC 2.35 ([package reference](https://packages.ubuntu.com/jammy/libc6)). Operational Python scripts also parse with Python 3.10 grammar; the pinned tomli 2.2.1 test dependency exists on PyPI and supports Python >=3.8.

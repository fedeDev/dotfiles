# Validation record

Recorded on macOS arm64, 2026-10-19. This records completed checks, not full workstation acceptance.

| Check | Result |
| --- | --- |
| `python3 tests/validate.py` | PASS: Darwin/Linux × work/personal temporary renders; empty post-apply diffs; no symlinks/state/local shell file; per-OS Lazygit/Ghostty selection; Zsh syntax and quiet non-interactive startup; resolved GPFS symlinks and restored aliases; Git front materialization/idempotence/employer-field preservation; TOML parsing and synchronized manifests; source secret scan. |
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

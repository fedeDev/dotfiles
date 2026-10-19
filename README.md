# dotfiles

Reproducible macOS development setup for `fede`, managed by Nix, nix-darwin,
and home-manager. The employer-managed Homebrew installation stays outside
this configuration.

## First run

Review `configuration.nix` before applying.

```sh
./bootstrap.sh
```

`bootstrap.sh` installs Determinate Nix when needed, symlinks this repository to
`~/.dotfiles`, checks the configured macOS user, locks flake inputs, then applies
the `mac` nix-darwin configuration.

## Daily updates

```sh
./rebuild.sh
```

## Validation

After Nix is installed:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

## Notes

- Homebrew is not managed by nix-darwin (this machine uses an
  employer-managed Homebrew at `/opt/homebrew`). Install Ghostty and herdr
  yourself: `brew install --cask ghostty && brew install herdr`. Both are
  Homebrew-managed, not pinned via flake.lock.
- Most CLI tools are managed by home-manager.
- Neovim's clangd/CMake tooling (`clangd`, `cmake`, `ninja`) is provided via
  home-manager, not Mason, to keep tool versions declared in one place.
- Neovim expects CMake's compilation database at `build/compile_commands.json`.
  `,sw` and `,sb` search clangd's workspace and buffer symbols, and
  `:ClangTidy` checks the current file using the project's compilation database
  and `.clang-tidy` configuration.
- `,d` deletes the current buffer without closing its window and `,cb` lists
  its diagnostics. In normal mode, `,f` applies git-clang-format to changed
  lines in the current file; over a visual range it applies clang-format
  directly to that selection.
- In Neovim, `-` opens Yazi at the current file. FFF powers `tt` file search,
  `tg` live project grep, and `tw` grep for the word under the cursor or visual
  selection; `tb` retains Telescope for open-buffer search.
- Neovim's Herdr integration uses `,af` to place the current file in an
  agent's prompt and visual `,as` to place the selected range there. The
  target agent is focused, but the prompt is not submitted. `,yp` copies the
  current path; visual `,yr` copies a portable `path:start-end` source
  reference.
- Herdr's reviewr plugin is installed separately with
  `herdr plugin install persiyanov/herdr-reviewr`. `Ctrl-A Shift-V` toggles
  its on-demand review overlay. Its PR tab uses `github.geo.apple.com` and
  requires a valid `gh` login for that host.
- `mdterm` is provided as a small wrapper around `glow`, so the markdown viewer
  command is reproducible even though a package named `mdterm` was not available.
- Neovim also includes `render-markdown.nvim` with Markdown, inline Markdown,
  and LaTeX Treesitter parsers for terminal-native Markdown/math rendering.
- Config directories under `home/.config` are symlinked into `~/.config`.

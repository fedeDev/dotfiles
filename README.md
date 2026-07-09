# dotfiles

Reproducible macOS development setup for `fede`, managed by Nix, nix-darwin,
home-manager, and nix-homebrew.

## First run

Review `configuration.nix` before applying. Homebrew cleanup is set to `zap`,
which removes Homebrew packages and casks that are not declared here.

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

- Ghostty, herdr, and omp are managed by Homebrew through nix-darwin.
- Most CLI tools are managed by home-manager.
- `mdterm` is provided as a small wrapper around `glow`, so the markdown viewer
  command is reproducible even though a package named `mdterm` was not available.
- Neovim also includes `render-markdown.nvim` with Markdown, inline Markdown,
  and LaTeX Treesitter parsers for terminal-native Markdown/math rendering.
- Config directories under `home/.config` are symlinked into `~/.config`.

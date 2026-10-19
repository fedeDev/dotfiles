# Configuration Context

This document records the intent and non-obvious decisions behind this
configuration. Read it with `README.md` and, for Neovim performance work,
`NEOVIM_TROUBLESHOOTING.md`.

## Scope and safety

- This repository is the writable source for a Nix, nix-darwin, and Home
  Manager macOS development environment.
- `~/sputnik` and its projects (especially `~/sputnik/pwin`) are private. Do
  not modify them. Only read project configuration files explicitly needed for
  editor integration, such as `.clang-format`, `.clang-tidy`, CMake presets, or
  compilation-database metadata.
- Do not run `./rebuild.sh`; it requires user-controlled `sudo`. Report when a
  rebuild is required and let the user run it.
- Do not reload Herdr while it is being used for critical work.
- Preserve unrelated changes. Verify the active configuration before assuming
  that editing a source file changed a running application.

## Configuration model

Home Manager creates out-of-store symlinks for the configuration directories
under `home/.config`. Consequently, edits to Neovim, Herdr, Ghostty, Yazi, and
similar files are normally visible to a newly started application without a
Nix rebuild. Existing processes may retain mappings or settings created at
startup and still need to be restarted.

`configuration.nix` deliberately leaves the employer-managed Homebrew at
`/opt/homebrew` alone. It does not import nix-homebrew and sets
`homebrew.enable = false`. The macOS menu bar and Dock use normal macOS behavior;
this configuration must not enable their automatic hiding.

The primary Git config must remain writable for internal tools such as
`ac-sign`. Home Manager writes portable settings to
`~/.config/git/home-manager.gitconfig`, while activation bootstraps a writable
primary config that includes it. Do not restore an immutable Home Manager Git
config symlink.

The visual theme is Catppuccin Mocha across the environment. New UI should be
compact and avoid unnecessary icons, especially in Neovim's tabline.

## Neovim design

The main source is `home/.config/nvim/init.lua`; Lazy's resolved plugin versions
are in `home/.config/nvim/lazy-lock.json`.

Neovim is optimized for large C/CMake projects:

- clangd uses `build/editor` as its compilation-database directory.
- `cmake-tools.nvim` also builds in `build/editor`, leaving the project's normal
  execution build directory untouched.
- CMake Tools is loaded automatically for CMake projects so target information
  remains visible. Its Plenary loading workaround is explained in
  `NEOVIM_TROUBLESHOOTING.md`.
- `:ClangTidy` uses the project's compilation database and `.clang-tidy`.
- Normal `,f` formats Git-changed lines through pwin's formatting script.
  Visual `,f` formats the selected range without Git awareness.
- `,h` switches between a C/C++ source and header using LSP first and a file
  search fallback.

### Search, navigation, and editing

- `-`: open Yazi at the current file.
- `tt`: FFF file search.
- `tg`: FFF live grep.
- `tw`: FFF grep for the word or visual selection.
- `to`: Telescope open-buffer picker.
- `,sw`: workspace symbols.
- `,sb`: buffer symbols.
- `,cb`: diagnostics for the current buffer.
- `,d`: delete the current buffer; close Neovim when it is the last buffer.
- `,1` through `,9`: select the corresponding listed buffer. Mini's tabline
  displays compact subscript ordinals and no file icons.
- Visual `Alt-j` / `Alt-k`: move the selected lines down/up.
- `Tab`: accept completion; `Ctrl-j`/`Ctrl-n` and `Ctrl-k`/`Ctrl-p` move through
  completion candidates.
- Yanked text is highlighted briefly. Search matches clear after unrelated
  cursor movement; the current match uses Catppuccin lavender rather than red.

### Git responsibilities

Gitsigns is the lightweight in-buffer layer:

- `,go`: line provenance popup enriched with a linked GitHub PR when available.
- `,gb`: full-file blame split.
- `,gB`: browser blame at the current line, using the current branch's tracked
  remote repository and branch; default branch is the fallback.
- `,gj` / `,gk`: next/previous hunk.
- `,gp`: hunk preview.
- `,gi`: inline hunk preview.
- `,gs`: stage or unstage the current hunk; visual mode stages the range.
- `,gr`: reset the current hunk; visual mode resets the range.
- `,gS`: stage the buffer.
- `,gU`: unstage the buffer.
- `,gd`: diff the current buffer against `HEAD`.
- `,gq`: put repository changes in the quickfix list.

`diffview-plus.nvim` (the maintained fork, not the abandoned original
Diffview) owns multi-file review and history:

- `,gv`: toggle the repository changes review.
- `,gh`: current-file history with rename following.
- Visual `,gh`: history for the selected line range. Git's `-L` history cannot
  be combined with `--follow` across renames.
- `,gH`: repository-wide history.
- In a Diffview history panel, `gx` queries GitHub for pull requests associated
  with the selected commit. One PR opens directly, multiple PRs produce a
  selector, and no PR falls back to the commit page.
- `,gP`: perform the same PR lookup for a commit hash under the cursor.
- In Diffview diff panes, `,gs` stages the current hunk and `,gu` unstages it.
  These update the actual index buffer and write it; they were tested in a
  temporary Git repository.
- `q` or `Esc` closes the complete Diffview tab from its main diff, file panel,
  or history panel. These are explicit mappings: Diffview+ v0.37 did not ship
  them for its primary views.
- `,ge` / `,gE` focus/toggle the Diffview file panel.
- `y` in history copies the selected commit hash.

GitHub helpers resolve the current branch's tracking remote and preserve its
hostname, including self-hosted GitHub. `gh auth login` must have been completed
for that host. The commit-to-PR relationship comes from GitHub's associated-PR
API, not from Git metadata; direct or cherry-picked commits may have no result.

### AI integration

- `,af`: send the current file to a Herdr agent prompt.
- Visual `,as`: send the selected range.
- `,yp`: copy the current file path.
- Visual `,yr`: copy a portable `path:start-end` reference.

`herdr-context.nvim` is intentionally lean. Claude remains in a Herdr pane so
Herdr can track its state. Review/accept workflows belong in Herdr Reviewr or
Diffview rather than an embedded Claude terminal inside Neovim.

## Herdr

The source is `home/.config/herdr/config.toml`.

- Prefix: `Ctrl-a`.
- `Ctrl-a a` and `Ctrl-a Ctrl-a`: return to the previous pane.
- `Ctrl-a m` and `Ctrl-a Shift-s`: toggle the Reviewr review pane.
- The top tab bar remains at the top.
- Its right side shows the `ZOOM` pill when zoomed and the time in 12-hour
  AM/PM format. A redundant plain `Z` indicator is intentionally absent.
- Reviewr is installed separately from Home Manager and needs authenticated
  `gh` access to `github.geo.apple.com`.

When diagnosing terminal link handling, distinguish Ghostty from Herdr. Ghostty
can receive Command-click directly; a terminal multiplexer may enable mouse
reporting and consume the event first.

## Shell and terminal behavior

Zsh is declared in `home.nix`; the generated `~/.zshrc` is read-only by design.
Add functions and bindings to `programs.zsh.initContent`, not to the generated
file.

- Zsh uses vi editing mode.
- `Alt-j` / `Alt-k` invoke the exact same history-substring widgets as
  Down/Up in insert and command modes.
- `Alt-.` inserts the last argument; repeated presses walk older commands.
- In fzf-tab, `Ctrl-n`/`Ctrl-p` and `Alt-j`/`Alt-k` move selection, while Tab
  accepts it.
- `nuke` interactively confirms before deleting all visible and hidden entries
  in the current directory. It is deliberately destructive; do not invoke it
  during testing.

Yazi binds `-` to move to the parent directory. Ghostty hides the mouse cursor
while typing and uses its normal macOS titlebar/window decorations.

## Verification discipline

For Neovim regressions, reproduce the exact working directory and real file,
then use `--startuptime` or Neovim's built-in profiler before changing plugins.
Do not attribute latency from wall-clock timing alone. Read
`NEOVIM_TROUBLESHOOTING.md` before performance work.

Useful proportional checks include:

```sh
nvim -i NONE --headless "+lua assert(loadfile('home/.config/nvim/init.lua'))" +qa
nixfmt --check home.nix configuration.nix
nix flake check --no-build
```

Some checks write under `~/.cache`, `~/.local/state`, or Lazy's plugin directory.
In restricted environments, redirect cache/state to `/tmp` or request the
required permission rather than treating the permission error as a plugin bug.


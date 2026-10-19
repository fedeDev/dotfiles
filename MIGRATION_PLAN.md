# Dotfiles Migration Plan: Nix/Home Manager to Chezmoi

## Objective

Replace the current nix-darwin/Home Manager setup with a portable configuration
that works on both macOS and Ubuntu while keeping responsibilities separate:

- **chezmoi** manages dotfiles as ordinary writable files.
- **mise** manages pinned, fast-moving, and nightly command-line tools where its
  backends are a good fit.
- **Homebrew/Brewfile** manages macOS applications and stable native packages.
- **apt** manages Ubuntu system libraries and packages that should integrate
  with the OS.
- Explicit bootstrap scripts coordinate installation. `chezmoi apply` must not
  unexpectedly upgrade the workstation.

The migration must be incremental. The current Nix setup remains the rollback
path until both the Mac and Ubuntu workstation pass the acceptance checklist.

## Non-goals

- Do not modify or inspect private source repositories such as `~/sputnik` or
  `~/pwin`. Existing dotfile scripts may refer to them, but migration work must
  operate only on the dotfiles repository and installed configuration files.
- Do not run `./rebuild.sh`; it requires the user to provide `sudo` access.
- Do not uninstall Nix, nix-darwin, or Home Manager during the initial phases.
- Do not turn chezmoi into a replacement monolithic package manager.
- Do not use chezmoi's symlink mode. Applied configuration should be ordinary
  files under `$HOME`.
- Do not commit credentials, host tokens, generated state, caches, or shell
  history.

## Desired repository layout

Use chezmoi's standard source directory, outside macOS's TCC-protected
`~/Downloads` directory:

```text
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl
├── .chezmoiignore
├── .chezmoidata/
│   ├── packages.yaml
│   └── theme.yaml
├── dot_config/
│   ├── bat/
│   ├── btop/
│   ├── dev/
│   ├── diffnav/
│   ├── gh-dash/
│   ├── ghostty/
│   ├── git/
│   ├── herdr/
│   ├── hunk/
│   ├── lazygit/
│   ├── nvim/
│   ├── starship.toml
│   ├── tig/
│   ├── worktrunk/
│   ├── yazi/
│   └── zsh/
├── dot_zshrc.tmpl
├── dot_zsh_plugins.txt
├── packages/
│   ├── Brewfile
│   ├── mise.toml
│   └── ubuntu.txt
├── scripts/
│   ├── bootstrap
│   ├── bootstrap-macos
│   ├── bootstrap-ubuntu
│   ├── install-packages
│   └── macos-defaults
└── README.md
```

Chezmoi source names may use `executable_`, `private_`, and `.tmpl` attributes
where appropriate. Avoid `exact_` directories initially because these can
delete application-created files that are not in the source state.

## Responsibility boundaries

### Chezmoi

Chezmoi owns stable user-authored configuration and scripts. Its destination
files are normal files, not links into the source checkout.

Manage:

- Neovim configuration and `lazy-lock.json`
- Ghostty, Yazi, Herdr, Hunk, Worktrunk, Lazygit, gh-dash, Diffnav, Tig, Bat,
  and btop configuration
- Starship configuration, including the lightweight GPFS variant
- Git's portable include and global ignore file
- Zsh configuration, aliases, functions, key bindings, and plugin manifest
- `~/.config/dev/setup-pwin-worktree.sh`
- User scripts currently kept in the dotfiles repository

Do not manage:

- `~/.config/hunk/state.json` or other runtime state
- Neovim plugin downloads, caches, sessions, undo files, or generated parsers
- Herdr sessions or plugin runtime state
- Lazygit `state.yml`
- shell history
- `compile_commands.json`, build directories, or anything in private repos
- credentials or authentication state (`gh`, employer GitHub, Claude, Splunk,
  signing tools, and similar)

### Mise

Use mise for user-space CLI tools when at least one of these applies:

- an exact version must be pinned;
- prerelease/nightly releases are wanted;
- releases come directly from GitHub or another supported backend;
- the same version should be installed on macOS and Ubuntu.

Evaluate at minimum: Neovim, Yazi, fzf, ripgrep, fd, bat, eza, zoxide, stylua,
tree-sitter CLI, scc, glow, delta, difftastic, Diffnav, Hunk, Worktrunk, gh-dash,
and Herdr. Do not force a tool into mise if its release assets or runtime
integration are poor; record the exception in the package manifest.

Commit resolved explicit versions. Use `latest` or nightly channels only for
tools where automatic movement is intentional and documented.

### Homebrew on macOS

Use a Brewfile for:

- GUI applications and casks;
- fonts;
- native libraries and build tools that should integrate with macOS;
- tools distributed or supported substantially better through Homebrew;
- employer-managed packages that must remain in `/opt/homebrew`.

Likely candidates include CMake, Ninja, LLVM/clang tools, Python or `uv`, Node
when it is needed as a runtime, ImageMagick, SSHFS dependencies, and the Fira
Code Nerd Font. Confirm each choice rather than copying the entire Nix package
list into the Brewfile.

Do not assume Brewfile provides exact historical version locking. Pinned tools
belong in mise or a documented direct installer.

### Apt on Ubuntu

Keep `packages/ubuntu.txt` limited to OS integration and native build/runtime
dependencies: compilers, CMake/Ninja if not handled elsewhere, filesystem
libraries, SSHFS, certificates, archive tools, and similar packages.

The Ubuntu bootstrap script should:

1. show the package list before using `sudo`;
2. perform `apt update` and `apt install` only when explicitly invoked;
3. never run from an ordinary `chezmoi apply`;
4. install user-space tools through mise afterward.

## Zsh design and removal of `~/.zshrc.local`

Home Manager currently generates Zsh configuration containing history options,
Antidote plugins, vi mode, key bindings, FZF settings, aliases, functions,
GPFS-specific prompt/alias switching, Herdr completion, Starship, and Zoxide.
Preserve the ordering semantics when translating it.

Use:

```text
~/.zshrc
~/.zsh_plugins.txt
~/.config/zsh/
├── options.zsh
├── aliases.zsh
├── functions.zsh
├── keybindings.zsh
├── completion.zsh
├── integrations.zsh
└── platform/
    ├── darwin.zsh
    └── linux.zsh
```

`~/.zshrc` should be short and source these modules in a documented order.
Important behavior to retain:

- million-entry shared history and existing duplicate/space rules;
- vi editing mode and cursor-shape changes;
- Alt-J/K substring-history movement and Alt-. last-argument cycling;
- FZF completion bindings and Tab acceptance;
- `nuke`, `gsl`, `gfm`, `gits`, and the existing convenience aliases;
- GPFS detection through resolved paths and its lightweight Starship/`ls` mode;
- Herdr completion when Herdr is installed;
- Starship initialization after its prerequisites;
- Zoxide initialization at the end of interactive shell initialization to
  avoid its doctor warning;
- syntax highlighting late enough to work correctly.

Use `.zsh_plugins.txt` as the Antidote manifest unless evaluation shows that a
simpler plugin manager is preferable. Keep the current plugins initially:

- `zsh-users/zsh-completions`
- `zsh-users/zsh-autosuggestions`
- `zsh-users/zsh-syntax-highlighting`
- `zsh-users/zsh-history-substring-search`
- `Aloxaf/fzf-tab`

Do not retain or source `~/.zshrc.local`. Before removing it:

1. enumerate its variable **names**, aliases, and function names without
   printing secret values;
2. move ordinary functions and aliases into the appropriate modules;
3. express OS differences with `.chezmoi.os` templates;
4. express work-machine differences using a boolean such as
   `.workMachine` in the local chezmoi configuration;
5. migrate secrets to a credential provider;
6. verify a fresh interactive and non-interactive shell;
7. archive the old file outside the repository until validation is complete.

The Splunk token previously placed in `~/.zshrc.local` has been shared in a
conversation and should be considered exposed. Revoke/rotate it. Never copy it
into chezmoi source, generated dotfiles, shell scripts, or command output.
Prefer lazy retrieval from macOS Keychain and an equivalent secret provider on
Ubuntu rather than exporting it into every shell. If no cross-platform provider
is available initially, use a private file outside chezmoi with mode `0600` as
a temporary, explicitly documented bridge—but do not restore the generic
`zshrc.local` mechanism.

## Git configuration design

Retain the current requirement that employer tooling such as `ac-sign` can
modify the primary global Git configuration.

Recommended layout:

```text
~/.config/git/config              # writable, machine-local front config
~/.config/git/portable.gitconfig  # managed by chezmoi
~/.config/git/ignore              # managed by chezmoi
```

The writable front config includes the portable file. Chezmoi should create it
only if absent, or a migration script should add the include idempotently. It
must never overwrite settings written by employer tools. The portable include
contains Delta/Diffnav/Difftastic, merge, pager, and pull behavior.

All three files must be ordinary local files. Validate with `realpath` and
`git config --show-origin --list` from both Ghostty and a non-Ghostty terminal.
No active Git configuration path may resolve into `~/Downloads`, a Nix store
generation, or the chezmoi source tree.

## macOS preferences

Translate the small current `system.defaults` set into an explicit,
idempotent `scripts/macos-defaults` script:

- show filename extensions;
- key repeat and initial repeat values;
- Finder hidden files, column view, path bar, status bar, and desktop behavior;
- tap-to-click.

The script must print proposed changes and require an explicit invocation. It
must not hide or otherwise modify the macOS menu bar or Dock. Document which
changes require restarting Finder or logging out. Do not run the script during
ordinary dotfile application.

## Application-specific cautions

- **Lazygit:** determine the active config directory with Lazygit's own
  diagnostic command on each OS. Manage one authoritative config if possible;
  do not manage `state.yml`. Avoid duplicating the same file into both XDG and
  `~/Library/Application Support` without proving it is necessary.
- **Hunk:** exclude `state.json` and other mutable state.
- **Herdr:** inventory installed plugins and their pinned revisions separately
  from `config.toml`. Preserve Hunk integration, agents picker, focus notify,
  and Worktrunk integration only after confirming each plugin is still wanted.
- **Yazi:** preserve `package.toml` and plugin declarations, but let Yazi fetch
  plugin payloads. Confirm configs are readable from Ghostty without macOS TCC
  permissions.
- **Neovim:** retain `lazy-lock.json`; bootstrap plugin manager normally. Run
  headless health/startup checks after migration. Do not inspect project source
  to test it.
- **Bat:** rebuild its theme cache after configuration changes. This can be a
  narrowly scoped `run_onchange_` chezmoi script because it derives only a
  cache from managed configuration.
- **Worktree setup:** preserve the shared setup script as a normal executable
  configuration file. Do not run it as part of workstation bootstrap.
- **Python libraries:** identify why BeautifulSoup, lxml, and pylatexenc are
  installed before choosing a replacement. Use a dedicated `uv` environment
  or application tool installation rather than contaminating system Python.

## Migration phases

### Phase 0: Record and protect the current state

No ownership changes.

1. Create a sanitized inventory containing:
   - Nix/Home Manager packages;
   - Homebrew formulae/casks;
   - commands installed in `~/.local/bin`;
   - Herdr/Yazi/Neovim plugin manifests;
   - live config path, file type, and resolved path for every managed target;
   - macOS defaults currently controlled by nix-darwin.
2. Record command resolution and versions for important tools on the Mac.
3. Detect credentials by **filename and variable name only**. Do not print or
   copy values into logs.
4. Back up mutable front configs such as Git configuration and the current
   generated `.zshrc` to a private local migration backup.
5. Document the current Home Manager generation so it can be selected for
   rollback.

Deliverable: `docs/current-state.md`, sanitized and safe to commit.

### Phase 1: Build the chezmoi source without applying it

1. Install chezmoi independently of Nix.
2. Initialize `~/.local/share/chezmoi` as the new repository.
3. Import the user-authored files from this repository into chezmoi source.
4. Translate generated Home Manager configuration—especially Zsh and
   Starship—into explicit files.
5. Add OS/work-machine templates sparingly.
6. Add `.chezmoiignore` exclusions and verify that state/secrets are absent.
7. Use `chezmoi execute-template` and `chezmoi diff` against a temporary
   destination. Do not apply to `$HOME` yet.

Deliverable: a reviewable chezmoi repository whose rendered output matches the
intended live configuration.

### Phase 2: Establish package manifests

1. Classify every item currently in `home.packages` into mise, Brewfile, apt,
   language-specific tooling, or intentional removal.
2. Capture currently desired versions before changing `PATH`.
3. Write the global mise configuration with explicit versions.
4. Write and check the Brewfile without cleanup/removal operations.
5. Write the Ubuntu list and bootstrap script.
6. Add a `doctor` command that reports missing tools, duplicate command
   providers, unexpected resolution paths, and version mismatches without
   modifying anything.

Deliverable: `docs/packages.md` with one owner and rationale for every tool.

### Phase 3: Cut over configuration in small groups

Cut over one group at a time in this order:

1. read-only application configs (Bat, btop, Tig, Diffnav, gh-dash);
2. interactive applications (Yazi, Lazygit, Hunk, Herdr, Worktrunk);
3. Ghostty;
4. Neovim;
5. Git;
6. Starship and Zsh last.

For each group:

1. ensure the chezmoi source and rendered target are correct;
2. remove only that group's ownership declarations from `home.nix`;
3. ask the user to run the Nix rebuild—an agent must not run it;
4. verify Home Manager released the paths and preserve any live writable data;
5. run `chezmoi diff`, then apply only the named targets;
6. confirm targets are ordinary files and no longer resolve through
   `~/Downloads` or `/nix/store`;
7. run application-specific smoke tests;
8. stop and roll back that group if validation fails.

Do not combine the Zsh/Git cutover with unrelated package upgrades.

### Phase 4: Cut over packages

1. Put mise shims on `PATH` in a documented position.
2. Install mise-managed tools and confirm command resolution.
3. Install/check the Brewfile on macOS without cleanup.
4. Bootstrap Ubuntu packages explicitly.
5. Remove packages from `home.packages` in batches only after their replacement
   has passed version and runtime checks.
6. Ask the user to rebuild after each Nix ownership batch.
7. Check for ABI/runtime dependencies before removing Nix-provided libraries.

### Phase 5: Retire nix-darwin/Home Manager

Only begin when the Mac and Ubuntu acceptance checks pass.

1. Confirm no shell, config file, shebang, launch agent, or command path still
   depends on a Nix store path.
2. Confirm macOS settings have an explicit replacement or are intentionally
   left unmanaged.
3. Archive the old Nix repository and final generation reference.
4. Disable nix-darwin/Home Manager using their documented uninstall procedure.
5. Keep Nix itself temporarily if any unrelated workflow still uses it.
6. Remove Nix only as a separate, user-approved final operation.

## Validation checklist

### Files and security

- `chezmoi diff` is empty immediately after apply.
- Managed destination files are ordinary writable files where appropriate.
- No active config resolves into `~/Downloads` or `/nix/store`.
- Repository secret scan passes.
- No runtime state or cache is tracked.
- The exposed Splunk token has been rotated.

### Shell

- Interactive Zsh starts without errors or Zoxide warnings.
- Non-interactive `zsh -lc` does not emit prompt/plugin noise.
- Completion, autosuggestions, syntax highlighting, and fzf-tab work.
- Tab, Ctrl-N/P, Alt-J/K, and Alt-. retain their intended behavior.
- GPFS mount paths and symlinked `/gpfs` paths select the lightweight prompt
  and BSD `ls`, then restore normal aliases after leaving.
- `gsl`, `gfm`, `gits`, `nuke`, Herdr completion, and Starship work.
- `~/.zshrc.local` is neither present nor sourced.

### Git

- `git status`, log, diff, blame, and difftool work in Ghostty.
- `ac-sign` can modify the machine-local front config.
- Delta/Diffnav/Difftastic settings have the intended owners.
- Global ignore works without permission warnings.

### Applications

- Neovim starts headlessly and interactively without errors.
- Neovim plugins resolve according to `lazy-lock.json`.
- Yazi previews/plugins work in Ghostty.
- Herdr starts and expected plugins/key bindings load.
- Lazygit uses the intended config and preserves state.
- Hunk, Worktrunk, gh-dash, Diffnav, Tig, Bat, and btop start successfully.
- Ghostty uses the intended config without needing Downloads-folder access.

### Cross-platform

- A clean Ubuntu user can run bootstrap, apply chezmoi, and start Zsh/Neovim.
- macOS-only paths and commands are absent or guarded on Ubuntu.
- Linux-specific package and clipboard behavior is documented and tested.
- The same source repository renders predictably on both systems.

## Rollback strategy

During Phases 1–4, rollback is per configuration group:

1. stop applying the affected chezmoi target;
2. restore that group's Home Manager declarations;
3. ask the user to rebuild the previous Nix configuration;
4. restore mutable front files from the private migration backup if necessary;
5. verify command resolution and application startup before continuing.

Never use broad destructive commands against `$HOME`, the chezmoi source, or
the dotfiles repository. Never use `brew bundle cleanup`, package autoremove,
or Nix uninstallation as part of routine migration.

## Decisions the implementing agent must document

Before making the first ownership change, record answers to these questions:

1. Which exact tools are owned by mise, Brewfile, apt, or a direct installer?
2. Which tools intentionally track nightly/latest instead of a fixed release?
3. Which secret provider works on both machines, or what temporary private-file
   bridge will be used?
4. Does Lazygit need its macOS-native config path, or can XDG be authoritative?
5. Which Herdr plugins remain installed, and how are their revisions pinned?
6. Why are the current Python libraries needed, and what isolated environment
   owns them?
7. Is Antidote retained, and how is its installation bootstrapped?
8. Which Nix features, if any, remain useful outside dotfile management?

## Definition of done

The migration is complete when both machines can be bootstrapped from the new
repository; all acceptance checks pass; the live shell and application configs
are normal files managed by chezmoi; package ownership is explicit; credentials
and state are excluded; `~/.zshrc.local` is gone; and nix-darwin/Home Manager no
longer owns any part of the interactive development environment.

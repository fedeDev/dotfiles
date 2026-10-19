# Package ownership and decisions

These are target owners. Existing Nix packages remain installed until each replacement passes version and runtime checks in phase 4. No live PATH cutover or batch removal has occurred.

Exact mise versions are committed in `packages/mise.toml`, deployed identically as `~/.config/mise/config.toml`. The explicit installer uses the former without depending on a live config change. None tracks latest/nightly. Existing versions were retained where known; gh-dash 4.26.2 is an intentional new addition. The Mac install of all 20 applicable tools succeeded in an isolated mise data/cache/state directory.

| Current package / tool | macOS owner | Ubuntu owner | Reason |
| --- | --- | --- | --- |
| antidote | pinned Git checkout | pinned Git checkout | User-owned bootstrap at `~/.local/share/antidote`; revision in `packages/antidote-revision` (v1.9.9). Existing five plugins retained. |
| bat | mise 0.26.1 | mise 0.26.1 | Same exact CLI and theme behavior. Existing Homebrew duplicate is reported, never removed automatically. |
| btop | Homebrew | apt | Native process/OS integration. |
| cmake | Homebrew | apt | Native compiler and SDK integration; release version follows platform. |
| cmake-format | dedicated uv venv | dedicated uv venv | `cmakelang` provides conform.nvim's formatter. Explicit requirement in `packages/python-requirements.txt`. |
| clang-tools | Homebrew llvm | apt clangd/clang-format/clang-tidy | Match native toolchains and SDKs; Mac shell adds `/opt/homebrew/opt/llvm/bin` after mise shims. |
| delta | mise 0.19.2 | mise 0.19.2 | Git pager with consistent rendering. |
| diffnav | mise 0.11.0 | mise 0.11.0 | Existing Nix derivation version, upstream GitHub binary. |
| difftastic | mise 0.69.0 | mise 0.69.0 | Same difftool behavior. |
| eza | Homebrew | mise 0.23.4 | Upstream has Linux binaries but no macOS release binary; explicit native-package exception on Mac. |
| fd | mise 10.4.2 | mise 10.4.2 | Shared search behavior. |
| fzf | mise 0.72.0 | mise 0.72.0 | Shared shell integration and flags. |
| gh | employer Homebrew | apt | Host authentication remains machine-local; no auth state in Chezmoi. |
| glow | mise 2.1.2 | mise 2.1.2 | Shared markdown viewer. |
| lazygit | mise 0.61.1 | mise 0.61.1 | Retain current configuration compatibility. |
| mdterm | Chezmoi wrapper | Chezmoi wrapper | Runs glow; no separate package. |
| neovim | mise 0.12.4 | mise 0.12.4 | Retains observed version and lazy-lock.json. |
| nerd-fonts.fira-code | Homebrew Nerd Font cask | manual Nerd Font installation; apt Fira Code fallback | Linux terminal may use an existing local/remote client font. Plain Fira Code lacks Nerd glyphs; install FiraCode Nerd Font on GUI Linux before visual acceptance. |
| ninja | Homebrew | apt | Native build dependency. |
| nixfmt | retained Nix during rollback | omitted unless editing Nix | Only needed for the legacy configuration, no replacement forced. |
| nodejs | Homebrew | employer/project runtime when needed | No committed Node-based LSP requires a global Linux runtime. Avoid adding Jammy Node 12 beside the approved runtime; Node is omitted from the personal Ubuntu apt baseline. |
| python3 | Homebrew/uv infrastructure | apt | Dedicated venv owns application dependencies; no global pip installs. |
| beautifulsoup4 | retain Nix pending investigation | deferred | No consumer found in dotfiles. Private project source was not inspected. Do not remove until user identifies its external consumer. |
| lxml | retain Nix pending investigation | deferred | Same unresolved external consumer; do not assume a replacement environment. |
| pylatexenc | dedicated uv venv | dedicated uv venv | render-markdown.nvim invokes `latex2text`; managed wrapper selects that venv. |
| ripgrep | mise 15.2.0 | mise 15.2.0 | Consistent editor search. |
| scc | mise 3.7.0 | mise 3.7.0 | Upstream binary, retained version. |
| stylua | mise 2.5.2 | mise 2.5.2 | Shared formatter. |
| tealdeer | mise 1.8.1 | mise 1.8.1 | Shared `tldr` CLI, existing auto-update preference retained. |
| tree-sitter | mise 0.26.8 | mise 0.26.8 | Shared parser CLI. |
| hunk | mise 0.22.0 | mise 0.22.0 | Existing version; Herdr now finds it on PATH. |
| imagemagick | Homebrew | apt | Native preview dependencies. |
| worktrunk | mise 0.77.0 | mise 0.77.0 | Retains flake release and Herdr plugin minimum compatibility. |
| yazi | mise 26.5.6 | mise 26.5.6 | Retains plugin/config compatibility; `ya pkg install` fetches pinned upstream payloads. |
| zoxide | mise 0.9.9 | mise 0.9.9 | Hook initialization stays last. |
| starship | mise 1.25.1 | mise 1.25.1 | Preserve generated prompt and lightweight GPFS variant. |
| gh-dash | mise 4.26.2 | mise 4.26.2 | Previously configured without a command provider. |
| herdr | employer Homebrew | mise 0.9.3 | Respect existing employer prefix; pin observed version on Linux. |
| chezmoi/mise | Homebrew | explicit upstream installer | Bootstrap independent of Nix. |
| uv | Homebrew | explicit upstream installer | Creates isolated Python environment. |
| Ghostty | Homebrew cask | manual distribution/upstream install | Linux GUI install depends on desktop; not needed on headless workstation. |
| SSHFS | existing employer setup | apt | Do not install a macOS system extension automatically. |
| Tig | Homebrew | apt | Stable native Git browser; existing Mac command is in ~/.local/bin until package cutover. |
| Git | native Apple Git / Homebrew | apt | No personal identity or employer signing settings in portable include. |

Ubuntu baseline is Ubuntu 22.04 LTS, following the supplied workstation onboarding requirement. Complete employer provisioning before personal packages; see [docs/ubuntu.md](ubuntu.md). Its native package versions may differ from macOS; full runtime acceptance must be performed there. Ubuntu preview dependencies include ffmpeg/poppler and Wayland/X11 clipboard tools. Native package manifests intentionally do not copy all employer Homebrew packages from the inventory.

## Decisions before the first ownership change

1. Owners and exact user-space versions appear above. No nightly or latest channels are used. OS package and bootstrap versions follow their supported platform distribution.
2. Secrets use macOS Keychain or Linux Secret Service (`secret-tool`). `with-splunk-token COMMAND ...` retrieves the token only for that child process. On headless Linux, a temporary `0600` file owned by the user at `~/.local/state/dotfiles-secrets/SPLUNK_TOKEN_IAG` is the explicit bridge; never source it. Rotate/revoke the exposed old token externally. Populate the replacement through the provider UI or a private input workflow, never command history or this repo. No old token is copied automatically.
3. `lazygit --print-config-dir` returned `~/Library/Application Support/lazygit` on this Mac. Manage only that config.yml on Darwin and the XDG config.yml on Linux; confirm the diagnostic on Ubuntu. State is excluded. The two source copies are intentional OS alternatives, never two applied copies on one machine.
4. Preserve the existing four Herdr plugins as the initial compatibility choice; their full revisions are in `packages/herdr-plugins.tsv`. `scripts/install-herdr-plugins` is explicit and uses `--ref`. No plugins were reinstalled or executed during migration. Interactive confirmation that all four remain wanted is still pending.
5. Python formatter and LaTeX consumers are identified above. BeautifulSoup/lxml remain unresolved; keeping their existing provider is required until resolved.
6. Antidote is retained and its bootstrap revision is pinned. Upstream Zsh plugin revisions were not previously pinned; their manifest is retained, with highlighting last. New plugin downloads happen on first interactive initialization, outside Chezmoi apply.
7. Nix remains the rollback provider and the owner of unconverted packages. No unrelated Nix workflow was inspected. Retirement must wait for both machines to pass acceptance and for unresolved Python use to be identified.

Mise backend details: [aqua backend](https://mise.jdx.dev/dev-tools/backends/aqua.html), [GitHub backend](https://mise.jdx.dev/dev-tools/backends/github.html). These manifests were tested with mise 2026.10.15.

Onboarding compatibility update: Ubuntu scripts preserve `~/bin`, do not upgrade already-installed requested apt packages, and never configure employer authentication, corporate trust, VPN/DNS, GPU drivers, Docker access or private project libraries. Optional Tk support must match the application interpreter.

Yazi keeps the upstream zoom plugin at revision `7200d73` as a reference for the authored zoom-fit variant. Keep explanatory comments outside package.toml because `ya pkg install` rewrites that manifest and removes comments.

Neovim's FFF plugin build uses the upstream downloader from its locked revision rather than `nix run`. For the current lock it selected release `0.10.7-nightly.d84c0a1`, tied to that same fixed commit; this is not a moving nightly channel. If a platform lacks a usable prebuilt binary, upstream falls back to Cargo and requires a sufficiently recent Rust toolchain from the approved toolchain setup. No Rust toolchain was installed automatically. LuaRocks is disabled because all current dependencies are supplied by Git and none has a required rockspec build.

Final shell cutover retains Starship explicitly in home.packages at the existing Nix version; disabling programs.starship would otherwise drop its implicit command package. This retention ends only after the separate mise provider/runtime checks and package-ownership cleanup. Startup PATH/EDITOR/BAT settings also live in ordinary .zshenv/.zprofile so non-interactive/login shells keep their environment without initializing plugins.

# Current state (before cutover)

Recorded 2026-10-19. No ownership changes have been made.

## Rollback

System profile: `/nix/store/5xd97ac74jidw5vl8lzm899msz3qdi7x-darwin-system-26.05.adda04f`.
Home Manager generation: `/nix/store/6894b1vxlm76qg2sx59y0gk3zx8awc8x-home-manager-generation` (gcroot: `~/.local/state/home-manager/gcroots/current-home`).
Private file backups: `~/.local/state/dotfiles-migration/20261019-093836` (0600 files, 0700 directory).
User can select a prior nix-darwin generation and rebuild; the agent must not run rebuild.sh.

## Live paths

| Target | Type | Resolved path |
| --- | --- | --- |
| `.config/bat/config` | file | `/Users/f_camposeco/dotfiles/home/.config/bat/config` |
| `.config/bat/themes/Catppuccin Mocha.tmTheme` | file | `/Users/f_camposeco/dotfiles/home/.config/bat/themes/Catppuccin Mocha.tmTheme` |
| `.config/btop/btop.conf` | file | `/Users/f_camposeco/dotfiles/home/.config/btop/btop.conf` |
| `.config/btop/themes/catppuccin_mocha.theme` | file | `/Users/f_camposeco/dotfiles/home/.config/btop/themes/catppuccin_mocha.theme` |
| `.config/dev/setup-pwin-worktree.sh` | file | `/Users/f_camposeco/dotfiles/home/.config/dev/setup-pwin-worktree.sh` |
| `.config/diffnav/config.yml` | symlink | `/Users/f_camposeco/dotfiles/home/.config/diffnav/config.yml` |
| `.config/gh-dash/config.yml` | symlink | `/Users/f_camposeco/dotfiles/home/.config/gh-dash/config.yml` |
| `.config/ghostty/config` | file | `/Users/f_camposeco/dotfiles/home/.config/ghostty/config` |
| `.config/git/catppuccin-delta.gitconfig` | symlink | `/Users/f_camposeco/dotfiles/home/.config/git/catppuccin-delta.gitconfig` |
| `.config/git/config` | file | `/Users/f_camposeco/.config/git/config` |
| `.config/git/home-manager.gitconfig` | file | `/Users/f_camposeco/.config/git/home-manager.gitconfig` |
| `.config/git/ignore` | file | `/Users/f_camposeco/.config/git/ignore` |
| `.config/herdr/config.toml` | symlink | `/Users/f_camposeco/dotfiles/home/.config/herdr/config.toml` |
| `.config/herdr/hunkdiff.toml` | absent | `/Users/f_camposeco/.config/herdr/hunkdiff.toml` |
| `.config/hunk/config.toml` | file | `/Users/f_camposeco/dotfiles/home/.config/hunk/config.toml` |
| `.config/hunk/state.json` | file | `/Users/f_camposeco/dotfiles/home/.config/hunk/state.json` |
| `.config/lazygit/config.yml` | file | `/Users/f_camposeco/dotfiles/home/.config/lazygit/config.yml` |
| `.config/nvim/init.lua` | file | `/Users/f_camposeco/dotfiles/home/.config/nvim/init.lua` |
| `.config/nvim/lazy-lock.json` | file | `/Users/f_camposeco/dotfiles/home/.config/nvim/lazy-lock.json` |
| `.config/starship-gpfs.toml` | symlink | `/Users/f_camposeco/dotfiles/home/.config/starship-gpfs.toml` |
| `.config/starship.toml` | symlink | `/nix/store/25316lcxhkxda8lw9k5s7wjz1mv0i3vb-starship-config` |
| `.config/tig/config` | symlink | `/Users/f_camposeco/Downloads/dotfiles-nix/home/.config/tig/config` |
| `.config/worktrunk/config.toml` | file | `/Users/f_camposeco/dotfiles/home/.config/worktrunk/config.toml` |
| `.config/yazi/init.lua` | file | `/Users/f_camposeco/dotfiles/home/.config/yazi/init.lua` |
| `.config/yazi/keymap.toml` | file | `/Users/f_camposeco/dotfiles/home/.config/yazi/keymap.toml` |
| `.config/yazi/package.toml` | file | `/Users/f_camposeco/dotfiles/home/.config/yazi/package.toml` |
| `.config/yazi/theme.claude.toml` | file | `/Users/f_camposeco/dotfiles/home/.config/yazi/theme.claude.toml` |
| `.config/yazi/theme.toml` | file | `/Users/f_camposeco/dotfiles/home/.config/yazi/theme.toml` |
| `.config/yazi/yazi.toml` | file | `/Users/f_camposeco/dotfiles/home/.config/yazi/yazi.toml` |
| `.gitconfig` | file | `/Users/f_camposeco/.gitconfig` |
| `.zshrc` | symlink | `/nix/store/5bbw7vp9q38ryqkcx7da7gnk5slfaqcl-hm_..zshrc` |
| `.zshrc.local` | file | `/Users/f_camposeco/.zshrc.local` |

## Home Manager package declarations

```nix
antidote
    bat
    btop
    cmake
    cmake-format
    clang-tools
    delta
    diffnav
    difftastic
    eza
    fd
    fzf
    gh
    glow
    lazygit
    mdterm
    neovim
    nerd-fonts.fira-code
    ninja
    nixfmt
    nodejs
    (python3.withPackages (
      pythonPackages: with pythonPackages; [
        beautifulsoup4
        lxml
      ]
    ))
    python3Packages.pylatexenc
    ripgrep
    scc
    stylua
    tealdeer
    tree-sitter
    hunk.packages.${pkgs.stdenv.hostPlatform.system}.default
    imagemagick
    worktrunk.packages.${pkgs.stdenv.hostPlatform.system}.default
    yazi
    zoxide
```

## Homebrew formulae and casks

Installed after adding independent chezmoi/mise bootstrappers. Employer packages are inventory only.

```
abseil
alerter
aom
apache-arrow
at-spi2-core
auth-cli
avro-c
aws-c-auth
aws-c-cal
aws-c-common
aws-c-compression
aws-c-event-stream
aws-c-http
aws-c-io
aws-c-mqtt
aws-c-s3
aws-c-sdkutils
aws-checksums
aws-crt-cpp
aws-sdk-cpp
awscli
bat
blake3
boost
brotli
c-ares
c-blosc
ca-certificates
cairo
ccache
ceres-solver
certifi
cfitsio
cgal
chezmoi
cmake
conan
coreutils
cunit
curl
dav1d
dbus
docker
docker-buildx
docker-compose
docker-credential-helper
eigen
epsilon
expat
faac
faad2
ffmpeg
flac
flann
fmt
fontconfig
freetype
freexl
fribidi
gcc
gdal
gdb
gdk-pixbuf
geos
gettext
gflags
gh
giflib
git-absorb
glew
glfw
glib
glib-networking
glog
gmp
gnupg
gnutls
gobject-introspection
googletest
gpgme
gpgmepp
graphene
graphite2
grpc
gsettings-desktop-schemas
gstreamer
gtk+3
gtk4
harfbuzz
hdf5
herdr
hicolor-icon-theme
highway
hiredis
hwloc
icu4c@78
imath
isl
jansson
jpeg
jpeg-turbo
jpeg-xl
jq
json-c
json-glib
krb5
lame
lapack
libaec
libarchive
libass
libassuan
libavif
libb2
libcuefile
libdatrie
libde265
libdeflate
libepoxy
libexif
libgcrypt
libgeotiff
libgit2
libgpg-error
libheif
libidn2
libimagequant
libkml
libksba
liblerc
libmpc
libnghttp2
libnghttp3
libngtcp2
libnice
libogg
libomp
libpng
libpq
libpsl
libraqm
libreplaygain
librsvg
librttopo
libshout
libsndfile
libsodium
libsoup
libspatialite
libssh2
libtasn1
libthai
libtiff
libtool
libunibreak
libunistring
libusb
libusrsctp
libuv
libvmaf
libvorbis
libvpx
libx11
libxau
libxcb
libxdmcp
libxext
libxfixes
libxi
libxml2
libxrender
libxtst
libyaml
little-cms2
llhttp
llvm@22
lz4
lzlib
lzo
m4
metis
minizip
mise
mongo-c-driver@1
mpdecimal
mpfr
mpg123
musepack
ncurses
netcdf
nettle
ninja
nlohmann-json
npth
nspr
nss
numpy
oniguruma
onnx
openblas
opencore-amr
openexr
openjpeg
openjph
openssl@3
opus
orc
p11-kit
pango
pcre2
pik
pillow
pinentry
pixman
pkgconf
poppler
popt
proj
protobuf
protobuf-c
py3cairo
pybind11
pygobject3
python@3.14
pytorch
qhull
re2
readline
rtmpdump
rust
s2n
sdl2-compat
sdl3
sfcgal
shellcheck
simdjson
sleef
snappy
speex
sprox
sqlite
srt
srtp
sse2neon
suite-sparse
svt-av1
taglib
tbb
theora
thrift
torchvision
unixodbc
uriparser
utf8cpp
utf8proc
vault
webp
whisperctl
x264
x265
xcbeautify
xerces-c
xorgproto
xxhash
xz
zellij
zstd

apple-vessel
codex
ghostty
```

## Local commands (filenames only)

```
apple-claude-code
cc-statusline
claude
debug.sh
etc
lime
mdv
rerun
splunk-cli
tig
uv
uvx
vl-dashboard
```

## Command resolution

| Command | Provider before cutover | Version |
| --- | --- | --- |
| nvim | `/etc/profiles/per-user/f_camposeco/bin/nvim` | NVIM v0.12.4 |
| yazi | `/etc/profiles/per-user/f_camposeco/bin/yazi` | Yazi 26.5.6 (Nixpkgs 2026-05-05) |
| fzf | `/etc/profiles/per-user/f_camposeco/bin/fzf` | 0.72.0 (refs/tags/v0.72.0) |
| rg | `/Users/f_camposeco/.codex/packages/app-server-daemon/releases/0.163.0-aarch64-apple-darwin/codex-path/rg` | ripgrep 15.2.0 (rev e89fff89ac) |
| fd | `/etc/profiles/per-user/f_camposeco/bin/fd` | fd 10.4.2 |
| bat | `/opt/homebrew/bin/bat` | bat 0.26.1 |
| eza | `/etc/profiles/per-user/f_camposeco/bin/eza` | eza - A modern, maintained replacement for ls |
| zoxide | `/etc/profiles/per-user/f_camposeco/bin/zoxide` | zoxide 0.9.9 |
| stylua | `/etc/profiles/per-user/f_camposeco/bin/stylua` | stylua 2.5.2 |
| tree-sitter | `/etc/profiles/per-user/f_camposeco/bin/tree-sitter` | tree-sitter 0.26.8 |
| scc | `/etc/profiles/per-user/f_camposeco/bin/scc` | scc version 3.7.0 |
| glow | `/etc/profiles/per-user/f_camposeco/bin/glow` | glow version 2.1.2 |
| delta | `/etc/profiles/per-user/f_camposeco/bin/delta` | delta 0.19.2 |
| difft | `/etc/profiles/per-user/f_camposeco/bin/difft` | Difftastic 0.69.0 |
| diffnav | `/etc/profiles/per-user/f_camposeco/bin/diffnav` | ▜▔▚ ▌▐▔▔▐▔▔▐▚ ▌▐▔▌▐ ▞ |
| hunk | `/etc/profiles/per-user/f_camposeco/bin/hunk` | 0.22.0 |
| wt | `/etc/profiles/per-user/f_camposeco/bin/wt` | wt 0683ad8 |
| gh-dash | `missing` | unavailable |
| herdr | `/opt/homebrew/bin/herdr` | herdr 0.9.3 |
| starship | `/etc/profiles/per-user/f_camposeco/bin/starship` | starship 1.25.1 |
| lazygit | `/etc/profiles/per-user/f_camposeco/bin/lazygit` | commit=, build date=, build source=nix, version=0.61.1, os=darwin, arch=arm64, git version=2.54.0 (Apple Git-157) |
| tldr | `/etc/profiles/per-user/f_camposeco/bin/tldr` | tealdeer 1.8.1 |
| btop | `/etc/profiles/per-user/f_camposeco/bin/btop` | btop version: 1.4.7 |
| cmake | `/opt/homebrew/bin/cmake` | cmake version 4.4.3 |
| ninja | `/opt/homebrew/bin/ninja` | 1.13.2 |
| clangd | `/etc/profiles/per-user/f_camposeco/bin/clangd` | clangd version 21.1.8 |
| gh | `/opt/homebrew/bin/gh` | gh version 2.100.0 (2026-09-03) |

## Credential inventory (names only)

Local shell variable names: `SPLUNK_TOKEN_IAG`, `bin`, `d`, `mode`, `root`.
Local function names: `_pwin_warn`, `_pwin_root`, `_pwin_run`, `p`, `p.gl`, `psan`, `psan.gl`, `pdeb`, `pdeb.gl`.
No aliases detected. Credential locations excluded from source: `.zshrc.local`, `.config/gh/hosts.yml`, `.ssh/`, `.git-credentials`, employer authentication and signing state. No values were inventoried.
The exposed `SPLUNK_TOKEN_IAG` must be revoked/rotated externally before shell cutover.

## Plugins

Herdr inventory (retain all four pending interactive validation; no installers run):

```
4 plugins installed:
- herdr-focus-notify (Herdr Focus Notify) enabled [github:yankewei/herdr-focus-notify@ed73afc2af6a943ee1f2b205d8df671dd042d3de]
  config: /Users/f_camposeco/.config/herdr/plugins/config/herdr-focus-notify
- jhochenbaum.hunkdiff (hunk) enabled [github:jhochenbaum/herdr-hunk-diff@b063856e85436668a165e511ed16a503ea729752]
  config: /Users/f_camposeco/.config/herdr/plugins/config/jhochenbaum.hunkdiff
- worktrunk (Worktrunk) enabled [github:devashish2203/herdr-worktrunk@4be9bbbaab1dfbecc81b298d30624052d0c432d1]
  config: /Users/f_camposeco/.config/herdr/plugins/config/worktrunk
- yxhta.agents-picker (Agents Picker) enabled [github:yxhta/herdr-agents-picker@354063dddb20f70b8c3c6f225a631c9f0ef24a2f]
  config: /Users/f_camposeco/.config/herdr/plugins/config/yxhta.agents-picker
```

Yazi pins: `home/.config/yazi/package.toml`. Local authored variant: `plugins/zoom-fit.yazi`. Upstream payloads will be fetched with `ya pkg install`. Neovim pins: `home/.config/nvim/lazy-lock.json`.

## macOS defaults

Source of truth before cutover: `configuration.nix`, `system.defaults`. Actual recorded values:

```
NSGlobalDomain AppleShowAllExtensions: 1
NSGlobalDomain InitialKeyRepeat: 15
NSGlobalDomain KeyRepeat: 2
com.apple.finder AppleShowAllFiles: 1
com.apple.finder CreateDesktop: 0
com.apple.finder FXPreferredViewStyle: clmv
com.apple.finder ShowPathbar: 1
com.apple.finder ShowStatusBar: 1
com.apple.AppleMultitouchTrackpad Clicking: 1
```

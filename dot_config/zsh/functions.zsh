nuke() {
  print -Pn "%F{yellow}⚠️  WARNING: This will permanently delete all contents inside: %F{cyan}%d%f\n"
  read -q "reply?Are you absolutely sure you want to proceed? (y/N): "
  echo "" # Move to a new line after pressing a key

  if [[ "$reply" =~ ^[Yy]$ ]]; then
    # Nuke all files and hidden files, ignoring warnings for . and ..
    command rm -rf -- *(DN)
    print -Pn "%F{green}✨ Build directory successfully wiped clean!%f\n"
  else
    print -Pn "%F{red}❌ Operation cancelled.%f\n"
  fi
}

# GitHub-flow smart log: compare the current HEAD with the long-lived
# master line, regardless of the feature branch's upstream. A nested
# experiment branch is already part of HEAD's ancestry, so its full path
# back toward master appears naturally. The symmetric range shows work
# on both sides and --boundary adds their merge base when reached.
gsl() {
  local base="$1"

  if [[ -z "$base" ]]; then
    if git rev-parse --verify --quiet "origin/master^{commit}" >/dev/null; then
      base=origin/master
    elif git rev-parse --verify --quiet "master^{commit}" >/dev/null; then
      base=master
    fi
  fi

  if [[ -z "$base" ]]; then
    print -u2 "gsl: master not found; fetch it or use gsl <master-ref>"
    return 1
  fi

  git log --graph --decorate --oneline --left-right --boundary \
    --topo-order --max-count=16 "$base...HEAD"
}

autoload -Uz add-zsh-hook
_set_gpfs_shell_mode() {
  local ci_root="$HOME/ci-gpfs" qs_root="$HOME/qs-gpfs"
  local ci_system=/ci-gpfs qs_system=/qs-gpfs gpfs_root=/gpfs
  case "${PWD:A}/" in
    "${ci_root:A}/"*|"${qs_root:A}/"*|"${ci_system:A}/"*|"${qs_system:A}/"*|"${gpfs_root:A}/"*)
      export STARSHIP_CONFIG="$HOME/.config/starship-gpfs.toml"
      alias ls='command ls'
      alias ll='command ls -la'
      ;;
    *)
      unset STARSHIP_CONFIG
      alias ls='eza --icons=auto'
      alias ll='eza -lah --git --icons=auto'
      ;;
  esac
}
add-zsh-hook chpwd _set_gpfs_shell_mode

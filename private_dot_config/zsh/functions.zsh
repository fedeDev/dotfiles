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
  local -a roots link_target
  roots=("$HOME/ci-gpfs" "$HOME/qs-gpfs" "$HOME/gpfs" /ci-gpfs /qs-gpfs /gpfs)
  local root here="${PWD:a}/" gpfs=false
  local -i hops
  # Known mount paths need no filesystem access, even on a disconnected share.
  for root in "${roots[@]}"; do
    [[ $here == "$root/"* ]] && { gpfs=true; break; }
  done
  if [[ $gpfs == false ]]; then
    here="${PWD:A}/"
    # HOME itself can have a symlinked parent (for example /var on macOS).
    local physical_home=${HOME:A}
    roots+=("$physical_home/ci-gpfs" "$physical_home/qs-gpfs" "$physical_home/gpfs")
    # realpath (:A) of every mount root costs hundreds of milliseconds on
    # macOS SSHFS. Read symlink targets without walking the mounted filesystem.
    zmodload -F zsh/stat b:zstat
    for root in "${roots[@]}"; do
      for (( hops=0; hops<16; hops++ )); do
        [[ $here == "$root/"* ]] && { gpfs=true; break 2; }
        [[ -L $root ]] || break
        builtin zstat -L -A link_target +link "$root" 2>/dev/null || break
        if [[ $link_target[1] == /* ]]; then
          root=$link_target[1]
        else
          root="${root:h}/$link_target[1]"
        fi
        root=${root:a}
        root="${root:h:A}/${root:t}"
      done
    done
  fi
  if [[ $gpfs == true ]]; then
    export STARSHIP_CONFIG="$HOME/.config/starship-gpfs.toml"
    alias ls='command ls'
    alias ll='command ls -la'
  else
    unset STARSHIP_CONFIG
    alias ls='eza --icons=auto'
    alias ll='eza -lah --git --icons=auto'
  fi
}
add-zsh-hook chpwd _set_gpfs_shell_mode

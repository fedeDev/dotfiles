# Add completion definitions before compinit. Plugin widgets load afterward.
if [[ -r "$HOME/.local/share/antidote/antidote.zsh" ]]; then
  source "$HOME/.local/share/antidote/antidote.zsh"
  # Ensure definitions exist on the first shell, before compinit scans fpath.
  antidote bundle zsh-users/zsh-completions >/dev/null
  local_completions="$(antidote path zsh-users/zsh-completions)/src"
  [[ -d "$local_completions" ]] && fpath=("$local_completions" $fpath)
  unset local_completions
fi
autoload -Uz compinit
mkdir -p "$HOME/.cache/zsh"
compinit -d "$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
(( $+commands[fzf] )) && source <(fzf --zsh)
(( $+commands[herdr] )) && eval "$(herdr completion zsh)"
source "$HOME/.config/zsh/keybindings.zsh"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-n:down' 'ctrl-p:up' 'alt-j:down' 'alt-k:up' 'tab:accept'
zstyle ':fzf-tab:*' switch-group ',' '.'
# Syntax highlighting is the last plugin, after widget and binding setup.
(( $+functions[antidote] )) && antidote load "$HOME/.zsh_plugins.txt"
return 0

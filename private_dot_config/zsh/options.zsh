HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt autocd append_history extended_history hist_expire_dups_first
setopt hist_find_no_dups hist_ignore_all_dups hist_ignore_dups hist_ignore_space
setopt hist_reduce_blanks hist_save_no_dups inc_append_history share_history
export EDITOR=nvim BAT_THEME='Catppuccin Mocha'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --color=bg:#1e1e2e,bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4 --color=hl:#cba6f7,hl+:#cba6f7,info:#f9e2af,prompt:#89b4fa --color=pointer:#fab387,marker:#a6e3a1,spinner:#f5e0dc,header:#a6adc8 --bind=ctrl-n:down,ctrl-p:up,alt-j:down,alt-k:up,tab:accept'
typeset -U path
path=("$HOME/.local/bin" "$HOME/.local/share/mise/shims" $path)

#!/bin/zsh
# Change default zim location
export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Start zim
[[ -s ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh

# Enable vi-mode for zsh.
bindkey -v
# Use alt + . to insert last word if in vi-mode.
bindkey -M viins '\e.' insert-last-word
# Re-enable home-end keys.
bindkey -M viins '^[[H' beginning-of-line
bindkey -M viins '^[[4~' end-of-line
# Delete char.
bindkey -M viins '^[[3~' delete-char
export KEYTIMEOUT=1 # Don't take 0.4s to change modes
function zle-keymap-select() {
  zle reset-prompt
  zle -R
}
zle -N zle-keymap-select  # When vi mode changes
# Fix backspace not working after returning from cmd mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char 
# Re-enable incremental search from emacs mode (it's useful)
bindkey '^r' history-incremental-search-backward

alias open="xdg-open"
alias cal="cal -3"
alias gits="git status"

calc () { bc -l <<< "$@" }

# Bind ctrl-j and ctr-k for up and down
bindkey "^J" down-line-or-search
bindkey "" up-line-or-search

# have ranger cd to the pwd when exit
if hash ranger 2>/dev/null; then
  source $HOME/.config/ranger/plugins/bash_automatic_cd.sh
  alias ranger="ranger-cd"
  cd "$AUTOCD"
fi

# if hash exa 2>/dev/null; then
# fi
# Uses ls++ for fancier ls
if hash ls++ 2>/dev/null; then
  alias ll="ls++ -A"
  alias l="ls++"
  alias lo="ls++ --potsf"
fi

# NCurses 'du'
if hash ncdu 2>/dev/null; then
  alias ncdu="ncdu -x"
fi

# export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -RiMX'

# This turns off zsh's "helpful" autocorrect feature
unsetopt correct_all

# Autocomplete arguments of aliased commands.
setopt completealiases

export LANG=en_US.UTF-8

export PATH=$HOME/bin:$PATH

if [ -n "$TMUX" ]; then
    function refresh {
        sshauth=$(tmux show-environment | grep "^SSH_AUTH_SOCK")
        if [ $sshauth ]; then
            export $sshauth
        fi
        display=$(tmux show-environment | grep "^DISPLAY")
        if [ $display ]; then
            export $display
        fi
    }
else
    function refresh { }
fi

# Refresh environment if inside tmux
function preexec {
    refresh
}

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
  # fe [FUZZY PATTERN] - Open the selected file with the default editor
  #   - Bypass fuzzy finder if there's only one match (--select-1)
  #   - Exit if there's no match (--exit-0)
  fe() {
    local file
    file=$(fzf --query="$1" --select-1 --exit-0 --preview 'head -100 {}')
    [ -n "$file" ] && nvim "$file"
  }
fi

if [ -f ~/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source ~/zsh-autosuggestions/zsh-autosuggestions.zsh
  bindkey -M viins '^@' autosuggest-execute
fi

# On SSH we haven't yet sourced profiles.
if [[ -n "$SSH_CLIENT" ]]; then
  source /etc/profile
  source ~/.profile
fi

export PATH="/home/fede/.cargo/bin:$PATH"
export PATH="/usr/local/cuda-8.0/bin:$PATH"

eval "$(dircolors ~/.dir_colors)"

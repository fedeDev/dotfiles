
# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

ZSH_THEME="fede"

alias pumount="pumount -D"
alias open="xdg-open"
alias cal="cal -3"
# TODO!
alias ldap="noglob ldap"

gitcd() {
	git rev-parse --show-cdup > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		cd `git rev-parse --show-cdup`
	else
		echo "Error: Not in a git repo!"
	fi
}

COMPLETION_WAITING_DOTS="true"

##  oh-my-zsh plugins!
# git-extras: autocomplete for the git extras functions
# web-search: adds a bunch of web tools such as google-search to open on chromium from console
# cp:         adds the 'cpv' alias which provides a progess bar for big transfers
# gitignore:  access from the zshell a bunch of gitignores from github
# extract:    adds the 'extract' command to untar, unzip, unrar, etc. files
plugins=(cmake fasd git-extras web-search cp gitignore extract)

source $ZSH/oh-my-zsh.sh

# Autocomplete with up and down arrow keys
[[ -n "${key[PageUp]}" ]] && bindkey "${key[PageUp]}" history-beginning-search-backward
[[ -n "${key[PageDown]}" ]] && bindkey "${key[PageDown]}" history-beginning-search-forward

# Bind ctrl-del and ctrl-backspace -- xterm specific TODO
# bindkey "[3;5~" kill-word
# bindkey "" backward-kill-word
# Bind ctrl-j and ctr-k for up and down
bindkey "^J" down-line-or-search
bindkey "" up-line-or-search

# have ranger cd to the pwd when exit
if hash ranger 2>/dev/null; then
  source /usr/local/share/doc/ranger/examples/bash_automatic_cd.sh
  alias ranger="ranger-cd"
  cd "$AUTOCD"
fi

# Uses ls++ for fancier ls
if hash ls++ 2>/dev/null; then
  alias l="ls++ -a"
  alias ll="ls++"
fi

# Uses vimpager for fancier less
export PAGER=vimpager
alias less=$PAGER
alias zless=$PAGER

# This turns off zsh's "helpful" autocorrect feature
unsetopt correct_all

# https://bbs.archlinux.org/viewtopic.php?id=93683
# list all pacman packages
if hash pacman 2>/dev/null; then
  paclist-all() {
    sudo pacman -Qei $(pacman -Qu|cut -d" " -f 1)|awk ' BEGIN {FS=":"}/^Name/{printf("\033[1;36m%s\033[1;37m", $2)}/^Description/{print $2}'
}
fi

# Load variables and path
if [[ -f $HOME/'.profile' ]]; then
  source $HOME/'.profile'
fi

export LANG=en_US.UTF-8

# Load the repo managment software
source "$HOME/.homesick/repos/homeshick/homeshick.sh"

fpath=($HOME/.homesick/repos/homeshick/completions $fpath)


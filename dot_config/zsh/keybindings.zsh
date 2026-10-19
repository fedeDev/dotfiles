# Vi mode: Esc or Ctrl-[ (same keystroke, ASCII 0x1B) enters normal
# mode for editing the command line. KEYTIMEOUT lowers the default
# escape-sequence wait (in hundredths of a second) so switching modes
# feels instant rather than laggy.
bindkey -v
KEYTIMEOUT=1

bindkey '^f' autosuggest-accept
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# Option/Alt-j and -k arrive as Esc+j and Esc+k. Bind them to the
# exact same widgets as Down and Up in both vi keymaps.
bindkey -M viins '^[j' history-substring-search-down
bindkey -M viins '^[k' history-substring-search-up
bindkey -M vicmd '^[j' history-substring-search-down
bindkey -M vicmd '^[k' history-substring-search-up
# Insert the previous command's last argument. Repeating Option-. walks
# backward through older commands, matching the standard shell behavior.
bindkey -M viins '^[.' insert-last-word
bindkey -M vicmd '^[.' insert-last-word

# Cursor shape follows vi mode, matching vim itself: bar while
# inserting text, block in normal mode. DECSCUSR escape sequences.
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    printf '\e[2 q'
  else
    printf '\e[6 q'
  fi
}
zle -N zle-keymap-select
function zle-line-init {
  printf '\e[6 q'
}
zle -N zle-line-init


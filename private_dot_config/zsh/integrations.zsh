_set_gpfs_shell_mode
(( $+commands[starship] )) && eval "$(starship init zsh)"
# No hooks may be installed after this initialization.
(( $+commands[zoxide] )) && eval "$(zoxide init zsh --cmd cd)"
return 0

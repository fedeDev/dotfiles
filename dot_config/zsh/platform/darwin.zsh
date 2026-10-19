# Employer Homebrew stays independent of Nix. Mise shims retain precedence.
path=("$HOME/.local/bin" "$HOME/.local/share/mise/shims" /opt/homebrew/bin /opt/homebrew/sbin /opt/homebrew/opt/llvm/bin $path)

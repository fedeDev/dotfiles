# Keep employer-provided helpers in ~/bin available alongside personal CLIs.
# Preserve the inherited PATH, including project/native toolchains.
path=("$HOME/.local/bin" "$HOME/bin" "$HOME/.local/share/mise/shims" $path)

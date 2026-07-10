#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOST="mac"
NIX_PROFILE="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

if [ -f "$NIX_PROFILE" ]; then
  # shellcheck disable=SC1090
  . "$NIX_PROFILE"
fi

ln -sfn "$DIR" "$HOME/.dotfiles"
exec sudo -H "$(command -v nix)" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake "$HOME/.dotfiles#$HOST"

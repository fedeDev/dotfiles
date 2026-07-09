#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HOST="mac"

ln -sfn "$DIR" "$HOME/.dotfiles"
exec sudo darwin-rebuild switch --flake "$HOME/.dotfiles#$HOST"

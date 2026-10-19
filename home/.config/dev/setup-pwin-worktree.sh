#!/usr/bin/env bash
set -euo pipefail

# Run from a newly created Sputnik worktree root, regardless of whether the
# checkout was created by Worktrunk/Herdr, Zed, or another integration.
if [[ ! -d pwin ]]; then
  printf 'Pwin setup: expected pwin/ under %s\n' "$PWD" >&2
  exit 1
fi

# Do not follow old build-directory symlinks into a different configuration.
for build_kind in editor debug release; do
  if [[ -L "pwin/build/$build_kind" ]]; then
    printf 'Pwin setup: refusing symlink pwin/build/%s\n' "$build_kind" >&2
    exit 1
  fi
done

mkdir -p pwin/build/editor pwin/build/debug pwin/build/release

# Mirror the main checkout: publish the database at pwin/compile_commands.json.
# Keep the link relative so every worktree remains self-contained.
database_link="pwin/compile_commands.json"
database_target="build/editor/compile_commands.json"
if [[ -L "$database_link" ]]; then
  if [[ "$(readlink "$database_link")" != "$database_target" ]]; then
    printf 'Pwin setup: pwin/compile_commands.json points elsewhere; leaving it untouched.\n' >&2
    exit 1
  fi
elif [[ -e "$database_link" ]]; then
  printf 'Pwin setup: refusing to overwrite pwin/compile_commands.json.\n' >&2
  exit 1
else
  ln -s "$database_target" "$database_link"
fi

printf 'Pwin setup: configuring editor (Debug); debug/release left unconfigured.\n'
cmake -S pwin -B pwin/build/editor -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
printf 'Pwin setup: editor configuration ready.\n'

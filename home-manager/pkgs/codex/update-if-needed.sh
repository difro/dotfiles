#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/package.nix"

LOCAL_VERSION="$(sed -n 's/^[[:space:]]*version = "\(.*\)";$/\1/p' "$PACKAGE_NIX")"
REMOTE_VERSION="$(
  curl -fsSL https://api.github.com/repos/openai/codex/releases/latest |
    jq -r '.tag_name | sub("^rust-v"; "")'
)"

if [[ -z "$LOCAL_VERSION" ]]; then
  printf 'failed to read local version from %s\n' "$PACKAGE_NIX" >&2
  exit 1
fi

printf 'local version:  %s\n' "$LOCAL_VERSION"
printf 'remote version: %s\n' "$REMOTE_VERSION"

if [[ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]]; then
  printf 'already up to date\n'
  exit 0
fi

printf 'updating package.nix to %s\n' "$REMOTE_VERSION"
"$SCRIPT_DIR/update.sh" "$REMOTE_VERSION"

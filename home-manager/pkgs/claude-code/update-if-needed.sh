#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BASE_URL="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
MANIFEST_PATH="$SCRIPT_DIR/manifest.json"

LOCAL_VERSION="$(sed -n 's/^  "version": "\(.*\)",$/\1/p' "$MANIFEST_PATH")"
REMOTE_VERSION="$(curl -fsSL "$BASE_URL/latest")"

if [[ -z "$LOCAL_VERSION" ]]; then
  printf 'failed to read local version from %s\n' "$MANIFEST_PATH" >&2
  exit 1
fi

printf 'local version:  %s\n' "$LOCAL_VERSION"
printf 'remote version: %s\n' "$REMOTE_VERSION"

if [[ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]]; then
  printf 'already up to date\n'
  exit 0
fi

printf 'updating manifest.json to %s\n' "$REMOTE_VERSION"
"$SCRIPT_DIR/update.sh"

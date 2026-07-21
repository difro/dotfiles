#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BASE_URL="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

VERSION="$(curl -fsSL "$BASE_URL/latest")"
curl -fsSL "$BASE_URL/$VERSION/manifest.json" --output "$SCRIPT_DIR/manifest.json"

printf 'updated manifest.json to %s\n' "$VERSION"

# Fully build the updated package so that manifest or upstream layout changes
# that break the recipe are caught here instead of on the machines that pull
# the update.
printf 'verifying claude-code %s build\n' "$VERSION"
nix build --no-write-lock-file "$SCRIPT_DIR#claude-code" --no-link

printf 'verified claude-code %s build\n' "$VERSION"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BASE_URL="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

VERSION="$(curl -fsSL "$BASE_URL/latest")"
curl -fsSL "$BASE_URL/$VERSION/manifest.json" --output "$SCRIPT_DIR/manifest.json"

printf 'updated manifest.json to %s\n' "$VERSION"

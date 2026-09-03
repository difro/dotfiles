#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C
export LANG=C

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/package.nix"
FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

github_api() {
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    curl -fsSL \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "$1"
  else
    curl -fsSL "$1"
  fi
}

latest_version() {
  github_api https://api.github.com/repos/openai/codex/releases/latest |
    jq -r '.tag_name | sub("^rust-v"; "")'
}

VERSION="${1:-$(latest_version)}"
TAG="rust-v$VERSION"

SOURCE_HASH="$(
  nix-prefetch-url --unpack "https://github.com/openai/codex/archive/refs/tags/$TAG.tar.gz" |
    tail -n 1 |
    xargs nix hash convert --hash-algo sha256 --to sri
)"

VERSION="$VERSION" SOURCE_HASH="$SOURCE_HASH" FAKE_HASH="$FAKE_HASH" perl -0pi -e '
  s/version = "[^"]+";/version = "$ENV{VERSION}";/;
  s/hash = "sha256-[^"]+";/hash = "$ENV{SOURCE_HASH}";/;
  s/cargoHash = "sha256-[^"]+";/cargoHash = "$ENV{FAKE_HASH}";/;
' "$PACKAGE_NIX"

"$SCRIPT_DIR/update-librusty.sh" "$VERSION"

set +e
BUILD_OUTPUT="$(nix build --no-write-lock-file "$SCRIPT_DIR#codex" --no-link 2>&1)"
BUILD_STATUS=$?
set -e

if [[ "$BUILD_STATUS" -eq 0 ]]; then
  printf 'expected cargoHash mismatch while updating codex to %s\n' "$VERSION" >&2
  exit 1
fi

CARGO_HASH="$(printf '%s\n' "$BUILD_OUTPUT" | sed -n 's/^[[:space:]]*got:[[:space:]]*\(sha256-[A-Za-z0-9+/=]*\)$/\1/p' | tail -n 1)"

if [[ -z "$CARGO_HASH" ]]; then
  printf '%s\n' "$BUILD_OUTPUT" >&2
  printf 'failed to extract cargoHash while updating codex to %s\n' "$VERSION" >&2
  exit 1
fi

CARGO_HASH="$CARGO_HASH" perl -0pi -e '
  s/cargoHash = "sha256-[^"]+";/cargoHash = "$ENV{CARGO_HASH}";/;
' "$PACKAGE_NIX"

printf 'updated codex to %s\n' "$VERSION"

# Fully build the updated package so that upstream source changes that break
# the recipe (e.g. a patched file disappearing) are caught here instead of on
# the machines that pull the update.
printf 'verifying codex %s build\n' "$VERSION"
nix build --no-write-lock-file "$SCRIPT_DIR#codex" --no-link

printf 'verified codex %s build\n' "$VERSION"

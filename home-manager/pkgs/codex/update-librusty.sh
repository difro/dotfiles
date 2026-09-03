#!/usr/bin/env bash
# Adapted from nixpkgs' pkgs/by-name/co/codex/update-librusty.sh. Writes the
# same two files, but downloads openai/codex's rusty-v8 release instead of
# denoland's (see fetchers.nix for why).
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

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

echo "librusty_v8: UPDATING"

if [[ $# -ge 1 ]]; then
  CODEX_TAG="rust-v$1"
else
  CODEX_TAG="$(github_api https://api.github.com/repos/openai/codex/releases/latest | jq -r .tag_name)"
fi
CARGO_LOCK="$(curl -fsSL "https://raw.githubusercontent.com/openai/codex/$CODEX_TAG/codex-rs/Cargo.lock")"

OUTPUT_FILE="$SCRIPT_DIR/librusty_v8.nix"
NEW_VERSION="$(echo "$CARGO_LOCK" | grep --after-context 5 'name = "v8"' | grep 'version =' | sed -E 's/version = "//;s/"//')"

if [[ -z "$NEW_VERSION" ]]; then
  echo "librusty_v8: failed to read v8 version from $CODEX_TAG Cargo.lock" >&2
  exit 1
fi

CURRENT_VERSION=""
if [ -f "$OUTPUT_FILE" ]; then
  CURRENT_VERSION="$(sed -n 's/^[[:space:]]*version = "\(.*\)";$/\1/p' "$OUTPUT_FILE")"
fi

if [ "$CURRENT_VERSION" == "$NEW_VERSION" ]; then
  echo "No update needed, $CURRENT_VERSION is already latest"
  exit 0
fi

# Keep this profile in sync with fetchers.nix; the archive and the src binding
# must come from the same one.
PROFILE="ptrcomp_sandbox_release"
BASE_URL="https://github.com/openai/codex/releases/download/rusty-v8-v$NEW_VERSION"

TEMP_FILE="$OUTPUT_FILE.tmp"
cat >"$TEMP_FILE" <<EOT
# auto-generated file -- DO NOT EDIT!
{ fetchLibrustyV8 }:

fetchLibrustyV8 {
  version = "$NEW_VERSION";
  shas = {
    x86_64-linux = "$(nix-prefetch-url --type sha256 "$BASE_URL/librusty_v8_${PROFILE}_x86_64-unknown-linux-gnu.a.gz")";
    aarch64-linux = "$(nix-prefetch-url --type sha256 "$BASE_URL/librusty_v8_${PROFILE}_aarch64-unknown-linux-gnu.a.gz")";
    aarch64-darwin = "$(nix-prefetch-url --type sha256 "$BASE_URL/librusty_v8_${PROFILE}_aarch64-apple-darwin.a.gz")";
  };
}
EOT

mv "$TEMP_FILE" "$OUTPUT_FILE"

OUTPUT_FILE="$SCRIPT_DIR/librusty_v8_src_binding.nix"
TEMP_FILE="$OUTPUT_FILE.tmp"
cat >"$TEMP_FILE" <<EOT
# auto-generated file -- DO NOT EDIT!
{ fetchLibrustyV8SrcBinding }:

fetchLibrustyV8SrcBinding {
  version = "$NEW_VERSION";
  shas = {
    x86_64-linux = "$(nix-prefetch-url --type sha256 "$BASE_URL/src_binding_${PROFILE}_x86_64-unknown-linux-gnu.rs")";
    aarch64-linux = "$(nix-prefetch-url --type sha256 "$BASE_URL/src_binding_${PROFILE}_aarch64-unknown-linux-gnu.rs")";
    aarch64-darwin = "$(nix-prefetch-url --type sha256 "$BASE_URL/src_binding_${PROFILE}_aarch64-apple-darwin.rs")";
  };
}
EOT

mv "$TEMP_FILE" "$OUTPUT_FILE"

echo "librusty_v8: UPDATE DONE"

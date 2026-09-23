#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/package.nix"
# Non-empty holds codex at the version in package.nix. Clear it once a release
# fixes the issue.
PIN_REASON="0.156's Linux sandbox rejects nix-user-chroot's /nix layout (openai/codex#47455)"

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

LOCAL_VERSION="$(sed -n 's/^[[:space:]]*version = "\(.*\)";$/\1/p' "$PACKAGE_NIX")"
REMOTE_VERSION="$(
  github_api https://api.github.com/repos/openai/codex/releases/latest |
    jq -r '.tag_name | sub("^rust-v"; "")'
)"

if [[ -z "$LOCAL_VERSION" ]]; then
  printf 'failed to read local version from %s\n' "$PACKAGE_NIX" >&2
  exit 1
fi

printf 'local version:  %s\n' "$LOCAL_VERSION"
printf 'remote version: %s\n' "$REMOTE_VERSION"

if [[ -n "$PIN_REASON" ]]; then
  printf 'pinned: %s\n' "$PIN_REASON"
  exit 0
fi

if [[ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]]; then
  printf 'already up to date\n'
  exit 0
fi

printf 'updating package.nix to %s\n' "$REMOTE_VERSION"
"$SCRIPT_DIR/update.sh" "$REMOTE_VERSION"

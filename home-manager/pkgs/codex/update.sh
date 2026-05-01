#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C
export LANG=C

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/package.nix"
LIBRUSTY_V8_NIX="$SCRIPT_DIR/librusty_v8.nix"
FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

latest_version() {
  curl -fsSL https://api.github.com/repos/openai/codex/releases/latest |
    jq -r '.tag_name | sub("^rust-v"; "")'
}

VERSION="${1:-$(latest_version)}"
TAG="rust-v$VERSION"
CARGO_LOCK_URL="https://raw.githubusercontent.com/openai/codex/$TAG/codex-rs/Cargo.lock"

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

V8_VERSION="$(
  curl -fsSL "$CARGO_LOCK_URL" |
    awk '
      $0 == "[[package]]" { in_package = 1; name = ""; version = ""; next }
      in_package && $1 == "name" && $3 == "\"v8\"" { name = "v8"; next }
      in_package && name == "v8" && $1 == "version" {
        gsub(/"/, "", $3);
        print $3;
        exit
      }
    '
)"
CURRENT_V8_VERSION="$(sed -n 's/^[[:space:]]*version = "\(.*\)";$/\1/p' "$LIBRUSTY_V8_NIX")"

if [[ -z "$V8_VERSION" ]]; then
  printf 'failed to read v8 version from %s\n' "$CARGO_LOCK_URL" >&2
  exit 1
fi

prefetch_v8_hash() {
  local target="$1"
  nix-prefetch-url "https://github.com/denoland/rusty_v8/releases/download/v$V8_VERSION/librusty_v8_release_$target.a.gz" |
    tail -n 1 |
    xargs nix hash convert --hash-algo sha256 --to sri
}

if [[ "$CURRENT_V8_VERSION" != "$V8_VERSION" ]]; then
  X86_64_LINUX_HASH="$(prefetch_v8_hash x86_64-unknown-linux-gnu)"
  AARCH64_LINUX_HASH="$(prefetch_v8_hash aarch64-unknown-linux-gnu)"
  X86_64_DARWIN_HASH="$(prefetch_v8_hash x86_64-apple-darwin)"
  AARCH64_DARWIN_HASH="$(prefetch_v8_hash aarch64-apple-darwin)"

  {
    printf '# auto-generated file -- DO NOT EDIT!\n'
    printf '{ fetchLibrustyV8 }:\n\n'
    printf 'fetchLibrustyV8 {\n'
    printf '  version = "%s";\n' "$V8_VERSION"
    printf '  shas = {\n'
    printf '    x86_64-linux = "%s";\n' "$X86_64_LINUX_HASH"
    printf '    aarch64-linux = "%s";\n' "$AARCH64_LINUX_HASH"
    printf '    x86_64-darwin = "%s";\n' "$X86_64_DARWIN_HASH"
    printf '    aarch64-darwin = "%s";\n' "$AARCH64_DARWIN_HASH"
    printf '  };\n'
    printf '}\n'
  } > "$LIBRUSTY_V8_NIX"
fi

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

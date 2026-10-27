#!/bin/bash
# Installs what taylr needs to build, test and lint in a Claude Code cloud session:
# the Swift toolchain pinned in .swift-version (it ships swift-format) and the static
# SwiftLint pinned in .mise.toml, then resolves and builds the root package so the
# cached container starts warm. Local sessions are left alone.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
SWIFT_VERSION=$(tr -d '[:space:]' < "$PROJECT_DIR/.swift-version")
SWIFTLINT_VERSION=$(sed -n 's/^"aqua:realm\/SwiftLint" = "\(.*\)"$/\1/p' "$PROJECT_DIR/.mise.toml")
SWIFT_DIR="/opt/swift-$SWIFT_VERSION"
SWIFTLINT_DIR="/opt/swiftlint-$SWIFTLINT_VERSION"

# Swift, from swift.org's Ubuntu builds.
if [ ! -x "$SWIFT_DIR/usr/bin/swift" ]; then
  . /etc/os-release
  case "$(uname -m)" in
    x86_64) ARCH_SUFFIX="" ;;
    aarch64) ARCH_SUFFIX="-aarch64" ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac
  PLATFORM="ubuntu${VERSION_ID//./}"
  RELEASE="swift-$SWIFT_VERSION-RELEASE"
  URL="https://download.swift.org/swift-$SWIFT_VERSION-release/$PLATFORM$ARCH_SUFFIX/$RELEASE/$RELEASE-ubuntu$VERSION_ID$ARCH_SUFFIX.tar.gz"
  echo "Installing Swift $SWIFT_VERSION from $URL"
  mkdir -p "$SWIFT_DIR.partial"
  curl -sSfL "$URL" | tar xz --strip-components=1 -C "$SWIFT_DIR.partial"
  mv "$SWIFT_DIR.partial" "$SWIFT_DIR"
fi

# SwiftLint: the release's static binary runs on any Linux.
if [ ! -x "$SWIFTLINT_DIR/swiftlint-static" ]; then
  case "$(uname -m)" in
    x86_64) ZIP="swiftlint_linux_amd64.zip" ;;
    aarch64) ZIP="swiftlint_linux_arm64.zip" ;;
  esac
  echo "Installing SwiftLint $SWIFTLINT_VERSION"
  TMP_ZIP=$(mktemp --suffix=.zip)
  curl -sSfL -o "$TMP_ZIP" \
    "https://github.com/realm/SwiftLint/releases/download/$SWIFTLINT_VERSION/$ZIP"
  mkdir -p "$SWIFTLINT_DIR"
  unzip -o -q "$TMP_ZIP" -d "$SWIFTLINT_DIR"
  rm -f "$TMP_ZIP"
fi

export PATH="$SWIFT_DIR/usr/bin:$SWIFTLINT_DIR:$PATH"
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$SWIFT_DIR/usr/bin:$SWIFTLINT_DIR:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# Warm the build: resolve dependencies and compile the root with its tests.
cd "$PROJECT_DIR"
swift package resolve
swift build --build-tests

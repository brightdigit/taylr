#!/bin/bash

# Lints this package with swift-format and SwiftLint, and writes the file
# header to every Swift file under Sources.
#
# Outside CI the script first auto-fixes (header, swift-format format,
# swiftlint --fix), then lints in strict mode so any remaining finding fails.
# In CI (CI is set) it only lints. Tool versions are pinned in .mise.toml.
#
# Environment:
#   LINT_MODE=NONE   skip linting entirely
#   FORMAT_ONLY=1    fix only, skip the strict lint pass
#
# Exit code is non-zero when any step fails.

ERRORS=0

run_command() {
	"$@" || ERRORS=$((ERRORS + 1))
}

if [ "$LINT_MODE" = "NONE" ]; then
	exit 0
fi

# More portable way to get script directory
if [ -z "$SRCROOT" ]; then
	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	PACKAGE_DIR="${SCRIPT_DIR}/.."
else
	PACKAGE_DIR="${SRCROOT}"
fi

PACKAGE_NAME="ScaffoldKit"

# Ensure mise-managed tools are on PATH outside CI (CI uses jdx/mise-action).
# Skipped in Claude Code web sessions: mise resolves its `spm:`/`aqua:` tools
# through api.github.com, which those sessions cannot reach.
if command -v mise >/dev/null 2>&1 && [ -z "$CI" ] \
	&& [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
	eval "$(mise -C "$PACKAGE_DIR" env -s bash)"
fi

# On Linux SwiftLint loads libsourcekitdInProc.so from the toolchain. Point it
# at the active one, since a toolchain manager's `swift` shim hides the path.
if [ "$(uname -s)" = "Linux" ] && [ -z "$LINUX_SOURCEKIT_LIB_PATH" ] \
	&& command -v swift >/dev/null 2>&1; then
	SWIFT_RESOURCE_DIR=$(swift -print-target-info 2>/dev/null \
		| sed -n 's/.*"runtimeResourcePath": "\(.*\)".*/\1/p')
	if [ -n "$SWIFT_RESOURCE_DIR" ]; then
		export LINUX_SOURCEKIT_LIB_PATH="$(dirname "$SWIFT_RESOURCE_DIR")"
	fi
fi

# SwiftLint is required everywhere except Claude Code web sessions, where it
# runs only if it was installed by hand. swift-format ships with the toolchain.
# The release's swiftlint-static runs on any Linux; the dynamic swiftlint needs
# libxml2.so.2, which Ubuntu 26.04 no longer ships.
SWIFTLINT=swiftlint
if command -v swiftlint-static >/dev/null 2>&1; then
	SWIFTLINT=swiftlint-static
fi
if command -v "$SWIFTLINT" >/dev/null 2>&1; then
	RUN_SWIFTLINT=1
elif [ "${CLAUDE_CODE_REMOTE:-}" = "true" ]; then
	RUN_SWIFTLINT=0
	echo "Skipping SwiftLint (not installed in this Claude Code web session)."
else
	echo "error: swiftlint not found; run 'mise install'." >&2
	exit 1
fi

SWIFTFORMAT_FORMAT_OPTIONS="--configuration .swift-format"
SWIFTFORMAT_LINT_OPTIONS="--configuration .swift-format --strict"
SWIFTLINT_OPTIONS="--strict"

pushd "$PACKAGE_DIR" >/dev/null || exit 1

if [ -z "$CI" ]; then
	run_command ./Scripts/header.sh -d Sources -c "Leo Dion" -o "BrightDigit" -p "$PACKAGE_NAME"
	run_command swift-format format $SWIFTFORMAT_FORMAT_OPTIONS --recursive --parallel --in-place Sources Tests
	if [ "$RUN_SWIFTLINT" -eq 1 ]; then
		run_command "$SWIFTLINT" --fix --quiet
	fi
fi

if [ -z "$FORMAT_ONLY" ]; then
	run_command swift-format lint --recursive --parallel $SWIFTFORMAT_LINT_OPTIONS Sources Tests
	if [ "$RUN_SWIFTLINT" -eq 1 ]; then
		run_command "$SWIFTLINT" lint $SWIFTLINT_OPTIONS
	fi
fi

popd >/dev/null || exit 1

# Exit with error code if any errors occurred
if [ $ERRORS -gt 0 ]; then
	echo "Linting completed with $ERRORS error(s)"
	exit 1
else
	echo "Linting completed successfully"
	exit 0
fi

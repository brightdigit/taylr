#!/bin/bash
# Update version numbers in Config/Version.xcconfig
#
# The beta scheme is encoded by the presence of a single BETA_BASE_BUILD line:
#   present => beta  (display "MARKETING_VERSION-beta.{CURRENT_PROJECT_VERSION - BETA_BASE_BUILD}")
#   absent  => release (display "MARKETING_VERSION")
# This script is the ONLY writer of the file (Fastlane/CI only read it), so it must
# PRESERVE the current BETA_BASE_BUILD line across build bumps and expose explicit
# --beta/--release controls to add or drop it.
#
# Usage:
#   ./Scripts/update-version.sh <version> [build]   # Set version (+ optional build); preserves beta state
#   ./Scripts/update-version.sh 1.2.0               # Sets version to 1.2.0, build to 1
#   ./Scripts/update-version.sh 1.2.0 5             # Sets version to 1.2.0, build to 5
#   ./Scripts/update-version.sh --increment         # Increments build number; preserves beta state
#   ./Scripts/update-version.sh --beta [BASE]        # Mark build as beta (default BASE=0), keep version/build
#   ./Scripts/update-version.sh --release            # Drop the beta line (production), keep version/build

set -euo pipefail

XCCONFIG_FILE="Config/Version.xcconfig"

# Check if xcconfig file exists
if [[ ! -f "$XCCONFIG_FILE" ]]; then
    echo "Error: $XCCONFIG_FILE not found"
    exit 1
fi

# Function to get current version
get_current_version() {
    grep "MARKETING_VERSION" "$XCCONFIG_FILE" | cut -d'=' -f2 | tr -d ' '
}

# Function to get current build
get_current_build() {
    grep "CURRENT_PROJECT_VERSION" "$XCCONFIG_FILE" | cut -d'=' -f2 | tr -d ' '
}

# Function to get the current BETA_BASE_BUILD value.
# Echoes the numeric base when the line is present, or nothing when absent (release).
# Ignores commented-out (`// ...`) lines.
get_current_beta_base() {
    grep -E "^[[:space:]]*BETA_BASE_BUILD[[:space:]]*=" "$XCCONFIG_FILE" 2>/dev/null \
        | head -n1 | cut -d'=' -f2 | tr -d ' ' || true
}

# Function to update xcconfig file.
# Args: <version> <build> <beta_base>
# When <beta_base> is empty the beta line is omitted (release); otherwise it is written (beta).
update_xcconfig() {
    local new_version=$1
    local new_build=$2
    local beta_base=$3

    {
        echo "MARKETING_VERSION = $new_version"
        echo "CURRENT_PROJECT_VERSION = $new_build"
        if [[ -n "$beta_base" ]]; then
            echo "// BETA_BASE_BUILD present => beta; remove the line => release"
            echo "BETA_BASE_BUILD = $beta_base"
        fi
    } > "$XCCONFIG_FILE"

    if [[ -n "$beta_base" ]]; then
        local beta_number=$((new_build - beta_base))
        echo "✅ Updated version to $new_version ($new_build) — beta (base $beta_base => ${new_version}-beta.${beta_number})"
    else
        echo "✅ Updated version to $new_version ($new_build) — release"
    fi
    echo "📝 File: $XCCONFIG_FILE"
}

# Handle --beta [BASE]: mark beta, preserving current version/build.
if [[ "${1:-}" == "--beta" ]]; then
    beta_base="${2:-0}"
    if ! [[ "$beta_base" =~ ^[0-9]+$ ]]; then
        echo "Error: beta base must be an integer"
        exit 1
    fi
    update_xcconfig "$(get_current_version)" "$(get_current_build)" "$beta_base"
    exit 0
fi

# Handle --release: drop the beta line, preserving current version/build.
if [[ "${1:-}" == "--release" ]]; then
    update_xcconfig "$(get_current_version)" "$(get_current_build)" ""
    exit 0
fi

# Handle increment flag (preserves beta state)
if [[ "${1:-}" == "--increment" ]]; then
    current_version=$(get_current_version)
    current_build=$(get_current_build)
    current_beta_base=$(get_current_beta_base)
    new_build=$((current_build + 1))

    echo "Incrementing build number: $current_build → $new_build"
    update_xcconfig "$current_version" "$new_build" "$current_beta_base"
    exit 0
fi

# Validate arguments
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <version> [build]"
    echo "   or: $0 --increment"
    echo "   or: $0 --beta [BASE]"
    echo "   or: $0 --release"
    echo ""
    echo "Examples:"
    echo "  $0 1.2.0        # Set version to 1.2.0, build to 1 (preserves beta state)"
    echo "  $0 1.2.0 5      # Set version to 1.2.0, build to 5 (preserves beta state)"
    echo "  $0 --increment  # Increment build number (preserves beta state)"
    echo "  $0 --beta 0     # Mark as beta with base 0"
    echo "  $0 --release    # Drop the beta line (production)"
    exit 1
fi

new_version=$1
new_build=${2:-1}

# Validate version format (basic semver check)
if ! [[ "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g., 1.2.0)"
    exit 1
fi

# Validate build number
if ! [[ "$new_build" =~ ^[0-9]+$ ]]; then
    echo "Error: Build number must be an integer"
    exit 1
fi

# Preserve the current beta state across an explicit version set.
update_xcconfig "$new_version" "$new_build" "$(get_current_beta_base)"

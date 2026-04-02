#!/bin/bash
# Update version numbers in Config/Version.xcconfig
#
# Usage:
#   ./Scripts/update-version.sh <version> [build]
#   ./Scripts/update-version.sh 1.2.0        # Sets version to 1.2.0, build to 1
#   ./Scripts/update-version.sh 1.2.0 5      # Sets version to 1.2.0, build to 5
#   ./Scripts/update-version.sh --increment  # Increments build number

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

# Function to update xcconfig file
update_xcconfig() {
    local new_version=$1
    local new_build=$2

    cat > "$XCCONFIG_FILE" <<EOF
MARKETING_VERSION = $new_version
CURRENT_PROJECT_VERSION = $new_build
EOF

    echo "✅ Updated version to $new_version ($new_build)"
    echo "📝 File: $XCCONFIG_FILE"
}

# Handle increment flag
if [[ "${1:-}" == "--increment" ]]; then
    current_version=$(get_current_version)
    current_build=$(get_current_build)
    new_build=$((current_build + 1))

    echo "Incrementing build number: $current_build → $new_build"
    update_xcconfig "$current_version" "$new_build"
    exit 0
fi

# Validate arguments
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <version> [build]"
    echo "   or: $0 --increment"
    echo ""
    echo "Examples:"
    echo "  $0 1.2.0        # Set version to 1.2.0, build to 1"
    echo "  $0 1.2.0 5      # Set version to 1.2.0, build to 5"
    echo "  $0 --increment  # Increment build number"
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

update_xcconfig "$new_version" "$new_build"

#!/bin/bash

set -e  # Exit on any error

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ERRORS=0

run_command() {
	"$@" || ERRORS=$((ERRORS + 1))
}

if [ "$ACTION" == "install" ]; then
	if [ -n "$SRCROOT" ]; then
		exit
	fi
fi

# Check if mise is available and set up tool execution
# Only check for mise when running from Xcode build phase (SRCROOT is set)
if [ -n "$SRCROOT" ]; then
    # Running from Xcode build phase
    MISE_PATH=""

    # Check if mise is in PATH
    if command -v mise >/dev/null 2>&1; then
        MISE_PATH=""
        echo "Using mise for tool management"
    else
        # Check common mise installation paths
        if [ -f "$HOME/.local/bin/mise" ]; then
            MISE_PATH="$HOME/.local/bin"
            echo "Found mise in $MISE_PATH"
        elif [ -f "/opt/homebrew/bin/mise" ]; then
            MISE_PATH="/opt/homebrew/bin"
            echo "Found mise in $MISE_PATH"
        elif [ -f "/usr/local/bin/mise" ]; then
            MISE_PATH="/usr/local/bin"
            echo "Found mise in $MISE_PATH"
        else
            echo "mise not available in Xcode build environment"
            echo "To install mise, run: make install-mise"
            echo "Linting failed: mise is required for Xcode build phases"
            exit 1
        fi
    fi

    # Set up MISE_EXEC with path if needed
    if [ -n "$MISE_PATH" ]; then
        MISE_EXEC="$MISE_PATH/mise exec --"
    else
        MISE_EXEC="mise exec --"
    fi

    # Install tools if mise is available
    if [ -n "$MISE_PATH" ]; then
        run_command "$MISE_PATH/mise" install
    else
        run_command mise install
    fi
else
    # Running from development environment - assume mise is available
    echo "Using mise for tool management"
    MISE_EXEC="mise exec --"
    # Install tools if mise is available
    run_command mise install
fi

function run_tool() {
	local tool="$1"
	shift
	if [ -n "$MISE_EXEC" ]; then
		$MISE_EXEC "$tool" "$@"
	else
		"$tool" "$@"
	fi
}

function lint_swift_package() {
	local package_path="$1"
	local config_path="$(dirname "$package_path")/../.swiftlint.yml"

	echo "$package_path"
	echo "$(dirname "$package_path")"

	# Format and fix (non-CI only)
	if [ -z "$CI" ]; then
		run_command run_tool swift-format format $SWIFTFORMAT_OPTIONS --recursive --parallel --in-place "$package_path/Sources" "$package_path/Tests"
		run_command run_tool swiftlint "$package_path" --fix --config "$config_path"

		# Update headers
		echo "Updating headers in $package_path..."
		run_command "$SCRIPT_DIR/header.sh" -d "$package_path" -c "{{TEMPLATE_ORG_NAME}}" -p "{{TEMPLATE_APP_NAME}}"
	fi

	# Lint (always run)
	run_command run_tool swiftlint lint "$package_path" --strict --config "$config_path"
	run_command run_tool swift-format lint --recursive --parallel $SWIFTFORMAT_OPTIONS "$package_path/Sources" "$package_path/Tests"
}

function is_package_excluded() {
	local package_path="$1"
	local config_file="$2"
	local package_name=$(basename "$package_path")

	# Check if the package is explicitly excluded in the SwiftLint config
	if [ -f "$config_file" ]; then
		# Look for exact match "- Packages/$package_name" in the excluded section
		if grep -q "^  - Packages/$package_name$" "$config_file"; then
			return 0  # Package is excluded
		fi
	fi
	return 1  # Package is not excluded
}

function lint_tuist_files() {
    local project_root="$1"
    local config_path="$project_root/.swiftlint.yml"
    echo "Linting Tuist files..."

    # Lint Project.swift
    if [ -f "$project_root/Project.swift" ]; then
        # Format and fix (non-CI only)
        if [ -z "$CI" ]; then
            run_command run_tool swift-format format $SWIFTFORMAT_OPTIONS --in-place "$project_root/Project.swift"
            run_command run_tool swiftlint "$project_root/Project.swift" --fix --config "$config_path"

            # Update headers for Project.swift
            echo "Updating headers in Project.swift..."
            run_command "$SCRIPT_DIR/header.sh" -d "$project_root" -c "{{TEMPLATE_ORG_NAME}}" -p "{{TEMPLATE_APP_NAME}}"
        fi
        # Lint (always run)
        run_command run_tool swiftlint "$project_root/Project.swift" --strict --config "$config_path"
        run_command run_tool swift-format lint $SWIFTFORMAT_OPTIONS "$project_root/Project.swift"
    fi

    # Lint Tuist directory
    if [ -d "$project_root/Tuist" ]; then
        # Format and fix (non-CI only)
        if [ -z "$CI" ]; then
            run_command run_tool swift-format format $SWIFTFORMAT_OPTIONS --recursive --parallel --in-place "$project_root/Tuist"
            run_command run_tool swiftlint "$project_root/Tuist" --fix --config "$config_path"

            # Update headers for Tuist directory
            echo "Updating headers in Tuist directory..."
            run_command "$SCRIPT_DIR/header.sh" -d "$project_root/Tuist" -c "{{TEMPLATE_ORG_NAME}}" -p "{{TEMPLATE_APP_NAME}}"
        fi
        # Lint (always run)
        run_command run_tool swiftlint "$project_root/Tuist" --strict --config "$config_path"
        run_command run_tool swift-format lint --recursive --parallel $SWIFTFORMAT_OPTIONS "$project_root/Tuist"
    fi
}

echo "LintMode: $LINT_MODE"

if [ "$LINT_MODE" == "NONE" ]; then
	exit
elif [ "$LINT_MODE" == "STRICT" ]; then
	SWIFTFORMAT_OPTIONS=""
	SWIFTLINT_OPTIONS="--strict"
	STRINGSLINT_OPTIONS="--config .strict.stringslint.yml"
else
	SWIFTFORMAT_OPTIONS=""
	SWIFTLINT_OPTIONS=""
	STRINGSLINT_OPTIONS="--config .stringslint.yml"
fi

if [ -z "$SRCROOT" ]; then
	PACKAGE_PARENT_DIR="${SCRIPT_DIR}/../Packages"
	PROJECT_ROOT="${SCRIPT_DIR}/.."
else
	PACKAGE_PARENT_DIR="${SRCROOT}/Packages"
	PROJECT_ROOT="${SRCROOT}"
fi

# Lint Tuist files
lint_tuist_files "$PROJECT_ROOT"

# Only continue with package linting if LINT_TUIST_ONLY is not set
if [ -z "$LINT_TUIST_ONLY" ]; then
    for packageDirectory in "$PACKAGE_PARENT_DIR"/*; do
        DIR_NAME=$(basename "$packageDirectory")

        # Only lint packages starting with "{{TEMPLATE_APP_NAME}}"
        if [[ ! "$DIR_NAME" == {{TEMPLATE_APP_NAME}}* ]]; then
            echo "Skipping non-{{TEMPLATE_APP_NAME}} package: $DIR_NAME"
            continue
        fi

        # Check if this package is excluded from linting
        if is_package_excluded "$packageDirectory" "$PROJECT_ROOT/.swiftlint.yml"; then
            echo "Skipping excluded package: $DIR_NAME"
            continue
        fi

        lint_swift_package "$packageDirectory"
    done
fi

if [ $ERRORS -gt 0 ]; then
	echo "Linting failed with $ERRORS error(s)"
	exit 1
fi

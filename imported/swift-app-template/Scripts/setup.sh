#!/usr/bin/env bash
set -euo pipefail

# ══════════════════════════════════════════════════════════════════════════════
# Swift App Template Setup Script
# ══════════════════════════════════════════════════════════════════════════════
#
# Transforms this template repository into a fully configured Swift app project.
#
# Usage:
#   Interactive mode:  ./Scripts/setup.sh
#   Automated mode:    ./Scripts/setup.sh --app-name MyApp --team-id ABC123 ...
#
# What this script does:
#   1. Collects project configuration (app name, Team ID, etc.)
#   2. Replaces all {{TEMPLATE_*}} tokens in target files
#   3. Renames package directories
#   4. Generates Swift source files via TemplateGenerator
#   5. Activates GitHub workflow (moves app.workflow.yml → workflows/app.yml)
#   6. Removes or keeps server package based on full-stack flag
#   7. Removes TemplateGenerator package
#   8. Renames template documentation files
#   9. Removes _reference/ directory
#   10. Updates git configuration
#
# ══════════════════════════════════════════════════════════════════════════════

# ── Terminal Colors ───────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  BOLD=$(tput bold)
  BLUE=$(tput setaf 4)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  RED=$(tput setaf 1)
  RESET=$(tput sgr0)
else
  BOLD="" BLUE="" GREEN="" YELLOW="" RED="" RESET=""
fi

info()  { echo "${BLUE}${BOLD}→${RESET} $*"; }
ok()    { echo "${GREEN}${BOLD}✓${RESET} $*"; }
warn()  { echo "${YELLOW}${BOLD}!${RESET} $*" >&2; }
error() { echo "${RED}${BOLD}✗${RESET} $*" >&2; exit 1; }

# ── Detect sed Variant (BSD vs GNU) ───────────────────────────────────────────
if sed --version 2>/dev/null | grep -q GNU; then
  SED_INPLACE=(-i)
else
  SED_INPLACE=(-i '')  # BSD sed (macOS)
fi

# ── Parse Command-Line Flags ──────────────────────────────────────────────────
APP_NAME=""
TEAM_ID=""
APPLE_ID=""
ITC_TEAM_ID=""
ORG_NAME=""
GITHUB_ORG=""
CERTS_REPO=""
PACKAGE_NAME=""
YEAR=""
SERVER_PORT=""
MARKETING_URL=""
PRIVACY_URL=""
SUPPORT_URL=""
PLATFORM=""
INCLUDE_SERVER="n"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-name)       APP_NAME="$2"; shift 2 ;;
    --team-id)        TEAM_ID="$2"; shift 2 ;;
    --apple-id)       APPLE_ID="$2"; shift 2 ;;
    --itc-team-id)    ITC_TEAM_ID="$2"; shift 2 ;;
    --org-name)       ORG_NAME="$2"; shift 2 ;;
    --github-org)     GITHUB_ORG="$2"; shift 2 ;;
    --certs-repo)     CERTS_REPO="$2"; shift 2 ;;
    --package-name)   PACKAGE_NAME="$2"; shift 2 ;;
    --year)           YEAR="$2"; shift 2 ;;
    --server-port)    SERVER_PORT="$2"; shift 2 ;;
    --marketing-url)  MARKETING_URL="$2"; shift 2 ;;
    --privacy-url)    PRIVACY_URL="$2"; shift 2 ;;
    --support-url)    SUPPORT_URL="$2"; shift 2 ;;
    --platform)       PLATFORM="$2"; shift 2 ;;
    --server)         INCLUDE_SERVER="y"; shift ;;
    -h|--help)
      cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --app-name NAME           Application name (e.g., WeatherBar)
  --team-id ID              Apple Team ID (10-character alphanumeric)
  --apple-id EMAIL          Apple ID email address
  --itc-team-id ID          App Store Connect Team ID
  --org-name NAME           Organization name (e.g., "Acme Corp")
  --github-org ORG          GitHub organization/username
  --certs-repo REPO         Git URL for certificate repository
  --package-name NAME       Swift package name (e.g., WeatherBarKit)
  --year YEAR               Copyright year (default: current year)
  --server-port PORT        Server port number (full-stack only)
  --marketing-url URL       Marketing website URL
  --privacy-url URL         Privacy policy URL (default: <marketing-url>/privacy-policy.html)
  --support-url URL         Support page URL (default: <marketing-url>/support)
  --platform PLATFORM       Target platform: ios (default), mac, tvos, watchos, visionos
  --server                  Include server package (full-stack mode)
  -h, --help                Show this help message

Interactive mode (no flags):
  ./Scripts/setup.sh

Automated mode (all required flags):
  ./Scripts/setup.sh --app-name MyApp --team-id ABC123 ... <<< "y"
EOF
      exit 0
      ;;
    *)
      error "Unknown option: $1 (use --help for usage)"
      ;;
  esac
done

# ── Interactive Prompts ───────────────────────────────────────────────────────
ask() {
  local var_name="$1"
  local prompt="$2"
  local default="${3:-}"
  local current="${!var_name}"

  [[ -n "$current" ]] && return  # skip if already set via flag

  local input
  if [[ -n "$default" ]]; then
    read -r -p "${BOLD}${prompt}${RESET} [${default}]: " input
    input="${input:-$default}"
  else
    read -r -p "${BOLD}${prompt}${RESET}: " input
  fi

  printf -v "$var_name" '%s' "$input"
}

echo
echo "${BOLD}═══════════════════════════════════════════════════════════════════${RESET}"
echo "${BOLD}  Swift App Template Setup${RESET}"
echo "${BOLD}═══════════════════════════════════════════════════════════════════${RESET}"
echo

ask APP_NAME      "App name (e.g., WeatherBar)"
ask TEAM_ID       "Apple Team ID (10-char alphanumeric)"
ask APPLE_ID      "Apple ID email"
ask ITC_TEAM_ID   "App Store Connect Team ID"
ask ORG_NAME      "Organization name (e.g., Acme Corp)"
ask GITHUB_ORG    "GitHub organization/username"
ask CERTS_REPO    "Certificate repository URL (git@github.com:org/Certs.git)"
ask PACKAGE_NAME  "Swift package name" "${APP_NAME}Kit"
ask YEAR          "Copyright year" "$(date +%Y)"
ask MARKETING_URL "Marketing website URL" "https://example.com/"
ask PLATFORM      "Platform (ios, mac, tvos, watchos, visionos)" "ios"

# Server package (full-stack)
if [[ "$INCLUDE_SERVER" != "y" ]] && [[ -t 0 ]]; then
  read -r -p "${BOLD}Include server package (Hummingbird)?${RESET} [y/N]: " server_choice
  INCLUDE_SERVER="${server_choice:-n}"
fi

if [[ "$INCLUDE_SERVER" =~ ^[Yy]$ ]]; then
  INCLUDE_SERVER="y"
  ask SERVER_PORT "Server port number" "8080"
else
  INCLUDE_SERVER="n"
  SERVER_PORT="8080"  # unused but needed for token substitution
fi

# ── Validate Required Fields ──────────────────────────────────────────────────
for field in APP_NAME TEAM_ID APPLE_ID ITC_TEAM_ID ORG_NAME GITHUB_ORG CERTS_REPO; do
  [[ -n "${!field}" ]] || error "Required field $field is empty."
done

# ── Derive defaults ───────────────────────────────────────────────────────────
[[ -z "$PACKAGE_NAME" ]] && PACKAGE_NAME="${APP_NAME}Kit"

ORG_SLUG=$(echo "$ORG_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
[[ -n "$ORG_SLUG" ]] || error "Organization name '$ORG_NAME' contains no alphanumeric characters."
BUNDLE_ID="com.${ORG_SLUG}.${APP_NAME}"
APP_GROUP_ID="group.${BUNDLE_ID}"

# Derive URLs from marketing URL if not explicitly provided
BASE_URL="${MARKETING_URL%/}"
[[ -z "$PRIVACY_URL" ]] && PRIVACY_URL="${BASE_URL}/privacy-policy.html"
[[ -z "$SUPPORT_URL" ]] && SUPPORT_URL="${BASE_URL}/support"

# Derive platform tokens from --platform
[[ -z "$PLATFORM" ]] && PLATFORM="ios"
case "$PLATFORM" in
  ios)
    FASTLANE_PLATFORM="ios"
    PRODUCE_PLATFORM="ios"
    TEST_DESTINATION="platform=iOS Simulator,name=iPhone 17"
    BUILD_ARTIFACT_EXT="ipa"
    DESTINATIONS="[.iPhone, .iPad]"
    DEPLOYMENT_TARGET=".iOS(\"26.0\")"
    ;;
  mac)
    FASTLANE_PLATFORM="mac"
    PRODUCE_PLATFORM="osx"
    TEST_DESTINATION="platform=macOS"
    BUILD_ARTIFACT_EXT="pkg"
    DESTINATIONS="[.mac]"
    DEPLOYMENT_TARGET=".macOS(\"26.0\")"
    ;;
  tvos)
    FASTLANE_PLATFORM="ios"
    PRODUCE_PLATFORM="appletvos"
    TEST_DESTINATION="platform=tvOS Simulator,name=Apple TV"
    BUILD_ARTIFACT_EXT="ipa"
    DESTINATIONS="[.appleTV]"
    DEPLOYMENT_TARGET=".tvOS(\"26.0\")"
    ;;
  watchos)
    FASTLANE_PLATFORM="ios"
    PRODUCE_PLATFORM="watchos"
    TEST_DESTINATION="platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)"
    BUILD_ARTIFACT_EXT="ipa"
    DESTINATIONS="[.watch]"
    DEPLOYMENT_TARGET=".watchOS(\"11.0\")"
    ;;
  visionos)
    FASTLANE_PLATFORM="ios"
    PRODUCE_PLATFORM="xros"
    TEST_DESTINATION="platform=visionOS Simulator,name=Apple Vision Pro"
    BUILD_ARTIFACT_EXT="ipa"
    DESTINATIONS="[.visionOS]"
    DEPLOYMENT_TARGET=".visionOS(\"2.0\")"
    ;;
  *)
    error "Unknown platform '$PLATFORM'. Valid values: ios, mac, tvos, watchos, visionos"
    ;;
esac

# ── Confirmation ──────────────────────────────────────────────────────────────
echo
echo "${BOLD}Configuration Preview:${RESET}"
echo "  APP_NAME       = $APP_NAME"
echo "  TEAM_ID        = $TEAM_ID"
echo "  BUNDLE_ID      = $BUNDLE_ID (derived)"
echo "  APP_GROUP_ID   = $APP_GROUP_ID (derived)"
echo "  APPLE_ID       = $APPLE_ID"
echo "  ITC_TEAM_ID    = $ITC_TEAM_ID"
echo "  ORG_NAME       = $ORG_NAME"
echo "  GITHUB_ORG     = $GITHUB_ORG"
echo "  CERTS_REPO     = $CERTS_REPO"
echo "  PACKAGE_NAME   = $PACKAGE_NAME"
echo "  YEAR           = $YEAR"
echo "  PLATFORM       = $PLATFORM"
echo "  MARKETING_URL  = $MARKETING_URL"
echo "  PRIVACY_URL    = $PRIVACY_URL"
echo "  SUPPORT_URL    = $SUPPORT_URL"
echo "  INCLUDE_SERVER = $INCLUDE_SERVER"
[[ "$INCLUDE_SERVER" == "y" ]] && echo "  SERVER_PORT    = $SERVER_PORT"
echo

read -r -p "${BOLD}Proceed with setup?${RESET} [y/N]: " confirm
[[ ! "$confirm" =~ ^[Yy]$ ]] && error "Setup cancelled."

# ══════════════════════════════════════════════════════════════════════════════
# Token Substitution
# ══════════════════════════════════════════════════════════════════════════════

substitute() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  sed "${SED_INPLACE[@]}" \
    -e "s|{{TEMPLATE_APP_NAME}}|${APP_NAME}|g" \
    -e "s|{{TEMPLATE_TEAM_ID}}|${TEAM_ID}|g" \
    -e "s|{{TEMPLATE_BUNDLE_ID}}|${BUNDLE_ID}|g" \
    -e "s|{{TEMPLATE_APP_GROUP_ID}}|${APP_GROUP_ID}|g" \
    -e "s|{{TEMPLATE_APPLE_ID}}|${APPLE_ID}|g" \
    -e "s|{{TEMPLATE_ITC_TEAM_ID}}|${ITC_TEAM_ID}|g" \
    -e "s|{{TEMPLATE_ORG_NAME}}|${ORG_NAME}|g" \
    -e "s|{{TEMPLATE_GITHUB_ORG}}|${GITHUB_ORG}|g" \
    -e "s|{{TEMPLATE_CERTS_REPO}}|${CERTS_REPO}|g" \
    -e "s|{{TEMPLATE_PACKAGE_NAME}}|${PACKAGE_NAME}|g" \
    -e "s|{{TEMPLATE_YEAR}}|${YEAR}|g" \
    -e "s|{{TEMPLATE_SERVER_PORT}}|${SERVER_PORT}|g" \
    -e "s|{{TEMPLATE_MARKETING_URL}}|${MARKETING_URL}|g" \
    -e "s|{{TEMPLATE_PRIVACY_URL}}|${PRIVACY_URL}|g" \
    -e "s|{{TEMPLATE_SUPPORT_URL}}|${SUPPORT_URL}|g" \
    -e "s|{{TEMPLATE_FASTLANE_PLATFORM}}|${FASTLANE_PLATFORM}|g" \
    -e "s|{{TEMPLATE_PRODUCE_PLATFORM}}|${PRODUCE_PLATFORM}|g" \
    -e "s|{{TEMPLATE_TEST_DESTINATION}}|${TEST_DESTINATION}|g" \
    -e "s|{{TEMPLATE_BUILD_ARTIFACT_EXT}}|${BUILD_ARTIFACT_EXT}|g" \
    -e "s|{{TEMPLATE_DESTINATIONS}}|${DESTINATIONS}|g" \
    -e "s|{{TEMPLATE_DEPLOYMENT_TARGET}}|${DEPLOYMENT_TARGET}|g" \
    "$file"
}

# ── Target Files (known files with tokens) ───────────────────────────────────
TARGET_FILES=(
  Project.swift
  Sources/Main.swift
  Makefile
  Dockerfile
  .codecov.yml
  .env.example
  .gitattributes
  .mise.toml
  Scripts/lint.sh
  fastlane/Appfile
  fastlane/.env.default
  fastlane/Fastfile
  fastlane/Matchfile
  .github/app.workflow.yml
)

info "Replacing tokens in target files..."
for file in "${TARGET_FILES[@]}"; do
  substitute "$file"
done

# ── Substitute in Tuist Helpers ───────────────────────────────────────────────
info "Replacing tokens in Tuist helpers..."
find Tuist/ProjectDescriptionHelpers -type f -name "*.swift" 2>/dev/null | while read -r file; do
  substitute "$file"
done

# ── Substitute in All fastlane Metadata ───────────────────────────────────────
info "Replacing tokens in fastlane metadata..."
find fastlane/metadata -type f -name "*.txt" 2>/dev/null | while read -r file; do
  substitute "$file"
done

# ── Substitute in Package Manifests ───────────────────────────────────────────
info "Replacing tokens in package manifests..."
find Packages -type f -name "Package.swift" 2>/dev/null | while read -r file; do
  substitute "$file"
done

# ── Substitute in Template Package Sources ────────────────────────────────────
info "Replacing tokens in template package sources..."
find "Packages/{{TEMPLATE_APP_NAME}}Kit" -type f \( -name "*.swift" -o -name "*.yaml" -o -name "*.yml" \) 2>/dev/null | while read -r file; do
  substitute "$file"
done

find "Packages/{{TEMPLATE_APP_NAME}}App" -type f \( -name "*.swift" -o -name "*.yaml" -o -name "*.yml" \) 2>/dev/null | while read -r file; do
  substitute "$file"
done

find "Packages/{{TEMPLATE_APP_NAME}}Server" -type f \( -name "*.swift" -o -name "*.yaml" -o -name "*.yml" \) 2>/dev/null | while read -r file; do
  substitute "$file"
done

# ── Substitute in Template Documentation ──────────────────────────────────────
info "Replacing tokens in template documentation..."
substitute README.template.md
substitute CLAUDE.template.md

# ══════════════════════════════════════════════════════════════════════════════
# Generate Swift Source Files
# ══════════════════════════════════════════════════════════════════════════════

info "Generating Swift source files..."

command -v swift >/dev/null 2>&1 || error "swift is not on PATH. Install Swift from swift.org or run: mise install"

# Build TemplateGenerator executable
swift build --package-path Packages/TemplateGenerator -c release

GENERATOR="Packages/TemplateGenerator/.build/release/TemplateGenerator"

if [[ ! -x "$GENERATOR" ]]; then
  error "TemplateGenerator executable not found at $GENERATOR"
fi

# Generate files into the template-token directories (pre-rename paths).
# Must use token paths here because mv later renames these directories;
# if we use the final names, mv would move the old dir *inside* the new one.
TEMPLATE_TOKEN="{{TEMPLATE_APP_NAME}}"

if [[ "$INCLUDE_SERVER" == "y" ]]; then
  # Full-stack: App lives in its own separate package
  "$GENERATOR" \
    --app-name "$APP_NAME" \
    --kit-dir "Packages/${TEMPLATE_TOKEN}Kit/Sources" \
    --app-dir "Packages/${TEMPLATE_TOKEN}App/Sources" \
    --server-dir "Packages/${TEMPLATE_TOKEN}Server/Sources"
else
  # Non-full-stack: App target is merged into the Kit package (see Kit/Package.swift).
  # Both kit-dir and app-dir point to the same Sources folder so App sources land
  # alongside Kit sources, which is where Kit/Package.swift expects them.
  "$GENERATOR" \
    --app-name "$APP_NAME" \
    --kit-dir "Packages/${TEMPLATE_TOKEN}Kit/Sources" \
    --app-dir "Packages/${TEMPLATE_TOKEN}Kit/Sources"
fi

ok "Swift source files generated."

# Merge pre-existing Sources/{{TEMPLATE_APP_NAME}}Kit/ into the generated Sources/${PACKAGE_NAME}/
# The template ships UserDefaults.swift inside that dir; TemplateGenerator creates
# a fresh ${PACKAGE_NAME}/ dir with AppModel.swift, so we move any remaining files across.
OLD_KIT_SOURCES="Packages/${TEMPLATE_TOKEN}Kit/Sources/${TEMPLATE_TOKEN}Kit"
NEW_KIT_SOURCES="Packages/${TEMPLATE_TOKEN}Kit/Sources/${PACKAGE_NAME}"
if [[ -d "$OLD_KIT_SOURCES" ]]; then
  if [[ -n "$(ls -A "$OLD_KIT_SOURCES" 2>/dev/null)" ]]; then
    mv "$OLD_KIT_SOURCES"/* "$NEW_KIT_SOURCES"/
  fi
  rm -rf "$OLD_KIT_SOURCES"
fi

# Same merge for tests: the template ships VersionInfoTests.swift in
# Tests/{{TEMPLATE_APP_NAME}}KitTests/; TemplateGenerator writes Tests/${APP_NAME}KitTests/.
OLD_KIT_TESTS="Packages/${TEMPLATE_TOKEN}Kit/Tests/${TEMPLATE_TOKEN}KitTests"
NEW_KIT_TESTS="Packages/${TEMPLATE_TOKEN}Kit/Tests/${APP_NAME}KitTests"
if [[ -d "$OLD_KIT_TESTS" ]]; then
  mkdir -p "$NEW_KIT_TESTS"
  if [[ -n "$(ls -A "$OLD_KIT_TESTS" 2>/dev/null)" ]]; then
    mv "$OLD_KIT_TESTS"/* "$NEW_KIT_TESTS"/
  fi
  rm -rf "$OLD_KIT_TESTS"
fi

# ══════════════════════════════════════════════════════════════════════════════
# Activate app.yml Workflow
# ══════════════════════════════════════════════════════════════════════════════

info "Activating GitHub workflow..."
mv .github/app.workflow.yml .github/workflows/app.yml

# ══════════════════════════════════════════════════════════════════════════════
# Full-Stack: Keep or Remove Server Package
# ══════════════════════════════════════════════════════════════════════════════

if [[ "$INCLUDE_SERVER" == "y" ]]; then
  info "Keeping server package (full-stack mode)..."

  # Rename server package directory
  mv "Packages/${TEMPLATE_TOKEN}Server" "Packages/${APP_NAME}Server"
  mv "Packages/${APP_NAME}Server/Sources/${TEMPLATE_TOKEN}Server" \
     "Packages/${APP_NAME}Server/Sources/${APP_NAME}Server" 2>/dev/null || true
  mv "Packages/${APP_NAME}Server/Sources/${TEMPLATE_TOKEN}serverd" \
     "Packages/${APP_NAME}Server/Sources/${APP_NAME,,}d" 2>/dev/null || true
else
  info "Removing server and standalone app packages (client-only mode)..."
  rm -rf "Packages/${TEMPLATE_TOKEN}Server"
  rm -rf "Packages/${TEMPLATE_TOKEN}App"
  rm -f Dockerfile
fi

# ══════════════════════════════════════════════════════════════════════════════
# Rename Package Directories
# ══════════════════════════════════════════════════════════════════════════════

info "Renaming package directories..."

# Rename Kit package
mv "Packages/${TEMPLATE_TOKEN}Kit" "Packages/${PACKAGE_NAME}"

# Rename App package (full-stack only — non-full-stack removes it above)
if [[ "$INCLUDE_SERVER" == "y" ]]; then
  mv "Packages/${TEMPLATE_TOKEN}App" "Packages/${APP_NAME}App"
fi

ok "Package directories renamed."

# ══════════════════════════════════════════════════════════════════════════════
# Rename Template Documentation
# ══════════════════════════════════════════════════════════════════════════════

info "Finalizing documentation..."

mv README.template.md README.md
mv CLAUDE.template.md CLAUDE.md

ok "Documentation finalized."

# ══════════════════════════════════════════════════════════════════════════════
# Cleanup
# ══════════════════════════════════════════════════════════════════════════════

info "Removing template-only files..."

# Remove TemplateGenerator package
rm -rf Packages/TemplateGenerator

# Remove SyntaxKit (used only by TemplateGenerator)
rm -rf SyntaxKit

# Remove reference projects
rm -rf _reference

# Remove .claude directory (implementation plans)
rm -rf .claude

# Remove template-only docs
rm -rf docs

ok "Cleanup complete."

# ══════════════════════════════════════════════════════════════════════════════
# Success Summary
# ══════════════════════════════════════════════════════════════════════════════

echo
echo "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════════${RESET}"
echo "${GREEN}${BOLD}  Setup Complete!${RESET}"
echo "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════════${RESET}"
echo
echo "Your ${BOLD}${APP_NAME}${RESET} project is ready."
echo
echo "${BOLD}Next steps:${RESET}"
echo "  1. Review the changes:"
echo "     ${BLUE}git status${RESET}"
echo
echo "  2. Generate the Xcode project:"
echo "     ${BLUE}mise exec -- tuist generate${RESET}"
echo
echo "  3. Open in Xcode:"
echo "     ${BLUE}open ${APP_NAME}.xcodeproj${RESET}"
echo
echo "  4. Set up GitHub repository:"
echo "     ${BLUE}git remote add origin <your-repo-url>${RESET}"
echo "     ${BLUE}git push -u origin main${RESET}"
echo
echo "  5. Create the app in App Store Connect and set up certificates:"
echo "     a) Create the app record (run once):"
echo "        ${BLUE}bundle exec fastlane produce${RESET}"
echo "     b) Create and store certificates in your certs repo:"
echo "        ${BLUE}bundle exec fastlane match development${RESET}"
echo "        ${BLUE}bundle exec fastlane match appstore${RESET}"
echo "     c) Or sync existing certificates:"
echo "        ${BLUE}make certs${RESET}"
echo "     (Requires App Store Connect API key in .env — see .env.example)"
echo
echo "  6. Configure GitHub secrets (required for CI/CD):"
echo "     - CODECOV_TOKEN"
echo "     - MATCH_PASSWORD"
echo "     - FASTLANE_KEYCHAIN_PASSWORD"
echo "     - APP_STORE_CONNECT_API_KEY_ID"
echo "     - APP_STORE_CONNECT_API_ISSUER_ID"
echo "     - APP_STORE_CONNECT_API_KEY_CONTENT (base64)"
echo "     - TUIST_CONFIG_TOKEN"
echo
echo "${BOLD}Documentation:${RESET}"
echo "  - ${BLUE}README.md${RESET}  — Project overview and commands"
echo "  - ${BLUE}CLAUDE.md${RESET}  — Development guidelines for Claude Code"
echo
echo "${GREEN}Happy coding! 🚀${RESET}"
echo

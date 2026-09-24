#!/bin/bash
# Requires: bash, Xcode with Icon Composer, mise, uv (via .mise.toml)
#
# Exports app icon renditions from Resources/AppIcon.icon into Marketing/icons/:
#   <platform>/icon[-dark|-tinted-light|-tinted-dark]-{1024,512}.png
#   submission/icon-1024.png  ← 1024×1024 opaque PNG for the App Store listing
#   apple-touch-icon.png, favicon-32x32.png, favicon-16x16.png, og-image.png
#
# Usage:
#   ./Scripts/generate-icons.sh                      # iOS renditions
#   ICON_PLATFORMS="iOS watchOS" ./Scripts/generate-icons.sh
#   ICON_PLATFORMS="macOS" ./Scripts/generate-icons.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

ICON_COMPOSER="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}/../Applications/Icon Composer.app"
ICTOOL="$ICON_COMPOSER/Contents/Executables/ictool"
ICON_SOURCE="$PROJECT_ROOT/Resources/AppIcon.icon"
ICON_OUTPUT_DIR="$PROJECT_ROOT/Marketing/icons"

read -r -a PLATFORMS <<< "${ICON_PLATFORMS:-iOS}"

# Rendition → filename-suffix mapping
RENDITIONS=(
  "Default:icon"
  "Dark:icon-dark"
  "TintedLight:icon-tinted-light"
  "TintedDark:icon-tinted-dark"
)

# Run Python with Pillow via uv (version pinned in .mise.toml)
run_pillow() {
  mise exec -- uv run --with Pillow python3 "$@"
}

echo "1. Validating..."
if [ ! -f "$ICTOOL" ]; then
  echo "   Error: ictool not found at $ICTOOL (install Xcode with Icon Composer)"
  exit 1
fi
if [ ! -d "$ICON_SOURCE" ]; then
  echo "   Error: icon source not found at $ICON_SOURCE"
  exit 1
fi

echo "2. Exporting app icons..."
rm -rf "$ICON_OUTPUT_DIR"
for platform in "${PLATFORMS[@]}"; do
  platform_dir="$ICON_OUTPUT_DIR/$(echo "$platform" | tr '[:upper:]' '[:lower:]')"
  mkdir -p "$platform_dir"
  for entry in "${RENDITIONS[@]}"; do
    rendition="${entry%%:*}"
    suffix="${entry##*:}"
    # watchOS has no dark or tinted icon appearances
    if [ "$platform" = "watchOS" ] && [ "$rendition" != "Default" ]; then
      continue
    fi
    for size in 1024 512; do
      "$ICTOOL" "$ICON_SOURCE" --export-image --output-file "$platform_dir/${suffix}-${size}.png" \
        --platform "$platform" --rendition "$rendition" \
        --width "$size" --height "$size" --scale 1
      echo "   $(basename "$platform_dir")/${suffix}-${size}.png"
    done
  done
done

# ictool always exports RGBA, and App Store Connect rejects an icon with an
# alpha channel — flatten over white, then verify so a bad icon fails here
# rather than at upload.
PRIMARY_ICON="$ICON_OUTPUT_DIR/$(echo "${PLATFORMS[0]}" | tr '[:upper:]' '[:lower:]')/icon-1024.png"

echo "3. Exporting the 1024×1024 submission icon..."
mkdir -p "$ICON_OUTPUT_DIR/submission"
run_pillow "$SCRIPT_DIR/icons_helper.py" submission-icon "$PRIMARY_ICON" "$ICON_OUTPUT_DIR/submission/icon-1024.png" 1024
run_pillow "$SCRIPT_DIR/icons_helper.py" verify-submission-icon "$ICON_OUTPUT_DIR/submission/icon-1024.png" 1024

echo "4. Generating favicons and OG image..."
run_pillow "$SCRIPT_DIR/icons_helper.py" resize "$PRIMARY_ICON" "$ICON_OUTPUT_DIR/apple-touch-icon.png" 180 180
run_pillow "$SCRIPT_DIR/icons_helper.py" resize "$PRIMARY_ICON" "$ICON_OUTPUT_DIR/favicon-32x32.png" 32 32
run_pillow "$SCRIPT_DIR/icons_helper.py" resize "$PRIMARY_ICON" "$ICON_OUTPUT_DIR/favicon-16x16.png" 16 16
run_pillow "$SCRIPT_DIR/icons_helper.py" og-image "$PRIMARY_ICON" "$ICON_OUTPUT_DIR/og-image.png"

echo ""
echo "Done. Icons written to Marketing/icons/"

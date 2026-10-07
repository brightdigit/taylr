#!/usr/bin/env bash
# Prepare App Store Connect In-App Purchase *App Review Screenshot* uploads.
#
# ASC's IAP uploader often rejects:
#   - RGBA / alpha-channel PNGs
#   - Newer framebuffer sizes (e.g. iPhone 17/18 Pro 1206×2622)
#
# This script flattens to JPEG (no alpha) and, by default, also emits the legacy
# sizes that the IAP validator reliably accepts (640×920 and 1242×2208).
#
# Usage:
#   ./Scripts/prepare-iap-review-screenshots.sh              # fastlane/iap-review-screenshots/*.png
#   ./Scripts/prepare-iap-review-screenshots.sh --keep-size   # flatten only
#   ./Scripts/prepare-iap-review-screenshots.sh path/to/dir
#
# Requires: sips (macOS)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

KEEP_SIZE=0
SRC_DIR="$PROJECT_ROOT/fastlane/iap-review-screenshots"
OUT_DIR="$PROJECT_ROOT/fastlane/iap-review-screenshots/asc-ready"

usage() {
  sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage 0 ;;
    --keep-size) KEEP_SIZE=1; shift ;;
    -*)
      echo "Unknown option: $1" >&2
      usage 1
      ;;
    *)
      SRC_DIR="$1"
      shift
      ;;
  esac
done

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Source directory not found: $SRC_DIR" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# sips -z takes height then width.
flatten_jpeg() {
  local src="$1"
  local dest="$2"
  local height="${3:-}"
  local width="${4:-}"

  if [[ -n "$height" && -n "$width" ]]; then
    sips -s format jpeg -s formatOptions 92 \
      --deleteColorManagementProperties \
      -z "$height" "$width" \
      "$src" --out "$dest" >/dev/null
  else
    sips -s format jpeg -s formatOptions 92 \
      --deleteColorManagementProperties \
      "$src" --out "$dest" >/dev/null
  fi
}

shopt -s nullglob
sources=("$SRC_DIR"/*.{png,PNG,jpg,JPG,jpeg,JPEG})
if [[ ${#sources[@]} -eq 0 ]]; then
  echo "No images in $SRC_DIR" >&2
  exit 1
fi

for src in "${sources[@]}"; do
  base="$(basename "$src")"
  base="${base%.*}"

  if [[ "$KEEP_SIZE" -eq 1 ]]; then
    dest="$OUT_DIR/${base}.jpg"
    flatten_jpeg "$src" "$dest"
    echo "wrote $dest (same pixel size, no alpha)"
  else
    dest_keep="$OUT_DIR/${base}-noalpha.jpg"
    flatten_jpeg "$src" "$dest_keep"
    echo "wrote $dest_keep (same pixel size, no alpha)"

    dest_small="$OUT_DIR/${base}-640x920.jpg"
    flatten_jpeg "$src" "$dest_small" 920 640
    echo "wrote $dest_small"

    dest_mid="$OUT_DIR/${base}-1242x2208.jpg"
    flatten_jpeg "$src" "$dest_mid" 2208 1242
    echo "wrote $dest_mid"
  fi
done

echo
echo "Upload *-640x920.jpg into each product's App Review Screenshot field first."
echo "Do not use the 1024×1024 promotional Image field."

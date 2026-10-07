#!/usr/bin/env python3
"""Image helper for generate-icons.sh — used via: uv run --with Pillow python3 icons_helper.py <cmd> ..."""

import sys
from PIL import Image


def cmd_resize(src: str, dst: str, width: int, height: int) -> None:
    Image.open(src).resize((width, height), Image.LANCZOS).save(dst)


def cmd_submission_icon(src: str, dst: str, size: int) -> None:
    """Flatten an exported rendition into the App Store submission icon.

    App Store Connect requires a square PNG with NO alpha channel; ictool
    exports RGBA. Compositing over white rather than dropping the channel keeps
    any (fully or partially) transparent pixel from going black.
    """
    icon = Image.open(src)
    if icon.size != (size, size):
        icon = icon.resize((size, size), Image.LANCZOS)
    flattened = Image.new("RGB", (size, size), (255, 255, 255))
    icon = icon.convert("RGBA")
    flattened.paste(icon, (0, 0), icon)
    flattened.save(dst)


def cmd_verify_submission_icon(path: str, size: int) -> None:
    """Fail loudly unless `path` is a size×size PNG with no alpha channel."""
    icon = Image.open(path)
    problems = []
    if icon.format != "PNG":
        problems.append(f"format is {icon.format}, expected PNG")
    if icon.size != (size, size):
        problems.append(f"size is {icon.size[0]}x{icon.size[1]}, expected {size}x{size}")
    if icon.mode in ("RGBA", "LA", "PA") or "transparency" in icon.info:
        problems.append(f"has an alpha channel (mode {icon.mode}); submission icons must be opaque")
    if problems:
        print(f"{path}:", file=sys.stderr)
        for problem in problems:
            print(f"  - {problem}", file=sys.stderr)
        sys.exit(1)
    print(f"   verified {size}x{size} {icon.mode} PNG, no alpha")


def cmd_og_image(src: str, dst_png: str) -> None:
    icon = Image.open(src).resize((630, 630), Image.LANCZOS).convert("RGB")
    og = Image.new("RGB", (1200, 630), (255, 255, 255))
    og.paste(icon, ((1200 - 630) // 2, 0))
    og.save(dst_png)


def main() -> None:
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <cmd> [args...]", file=sys.stderr)
        print("Commands: resize <src> <dst> <width> <height>", file=sys.stderr)
        print("          og-image <src> <dst.png>", file=sys.stderr)
        print("          submission-icon <src> <dst.png> <size>", file=sys.stderr)
        print("          verify-submission-icon <path.png> <size>", file=sys.stderr)
        sys.exit(1)

    cmd = sys.argv[1]
    args = sys.argv[2:]

    if cmd == "resize" and len(args) == 4:
        cmd_resize(args[0], args[1], int(args[2]), int(args[3]))
    elif cmd == "og-image" and len(args) == 2:
        cmd_og_image(args[0], args[1])
    elif cmd == "submission-icon" and len(args) == 3:
        cmd_submission_icon(args[0], args[1], int(args[2]))
    elif cmd == "verify-submission-icon" and len(args) == 2:
        cmd_verify_submission_icon(args[0], int(args[1]))
    else:
        print(f"Unknown command or wrong number of args: {cmd}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

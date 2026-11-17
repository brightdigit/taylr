# Scripts

## mermaid-to-pptx.py

Converts every Mermaid diagram in the repo to a single-slide 16:9 `.pptx` file with **native editable shapes** — boxes, connectors, and text are all real PowerPoint objects you can click, move, and restyle.

### Dependencies

- **Node.js ≥18** with `npx` — invokes `@mermaid-js/mermaid-cli` (Puppeteer-based; downloads Chromium on first run, ~170 MB)
- **Python 3.11+** with `python-pptx`

Fastest setup — let [`uv`](https://docs.astral.sh/uv/) handle the Python dep automatically via the PEP 723 inline header:

```bash
uv run Scripts/mermaid-to-pptx.py
```

Or install manually and run with plain Python:

```bash
pip install python-pptx
python3 Scripts/mermaid-to-pptx.py
```

### Usage

```bash
# Process all diagrams in the repo
uv run Scripts/mermaid-to-pptx.py

# Dry-run: list what would be processed (no files written)
uv run Scripts/mermaid-to-pptx.py --list

# Process specific files or globs
uv run Scripts/mermaid-to-pptx.py docs/automation-guide/outlines/outline.md
uv run Scripts/mermaid-to-pptx.py 'docs/**/*.md'
```

### Output

Files land in `build/pptx/` (gitignored via the existing `build/` rule). Naming convention:

| Source | Output |
|---|---|
| `diagrams/architecture.mmd` | `build/pptx/architecture.pptx` |
| `docs/outline.md` (1st block) | `build/pptx/outline-01.pptx` |
| `docs/outline.md` (2nd block) | `build/pptx/outline-02.pptx` |

Each `.pptx` is one slide, 10″ × 5.625″ (16:9). The pipeline is: Mermaid source → SVG (via mmdc) → python-pptx shapes. Nodes become rectangles/rounded-rects/diamonds/ovals; edges become straight connectors with arrowheads; subgraph clusters become labelled background rectangles. Everything is individually selectable and editable in PowerPoint or Keynote.

> **Note:** if two different markdown files share the same filename (e.g. two `README.md` files with mermaid blocks), their outputs will overwrite each other. Pass explicit paths in that case.

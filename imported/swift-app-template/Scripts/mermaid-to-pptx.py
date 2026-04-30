#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["python-pptx"]
# ///
"""Convert Mermaid diagrams to .pptx with native editable shapes."""

import argparse
import glob
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

from lxml import etree as lxml_et
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_AUTO_SHAPE_TYPE, MSO_CONNECTOR_TYPE
from pptx.enum.text import PP_ALIGN
from pptx.util import Inches, Pt

EXCLUDE_DIRS = frozenset({'_reference', '_test-run', 'node_modules', '.build', 'Derived', '.git', 'build'})
SLIDE_W = Inches(10)
SLIDE_H = Inches(5.625)  # 16:9
SVG = 'http://www.w3.org/2000/svg'
S = f'{{{SVG}}}'

# Dark-theme colors
SLIDE_BG     = RGBColor(0x0D, 0x10, 0x20)
NODE_FILL    = RGBColor(0xFF, 0xFF, 0xFF)
NODE_LINE    = RGBColor(0xFF, 0xFF, 0xFF)
CLUSTER_FILL = RGBColor(0x16, 0x19, 0x2A)
CLUSTER_LINE = RGBColor(0xFF, 0xFF, 0xFF)
EDGE_COLOR   = RGBColor(0xFF, 0xFF, 0xFF)
NODE_TEXT    = RGBColor(0x11, 0x11, 0x22)
LABEL_TEXT   = RGBColor(0xFF, 0xFF, 0xFF)
FONT_NAME    = 'Produkt ExtraLight'
FONT_SIZE    = Pt(18)
EDGE_WIDTH   = Pt(2)


# ── helpers ───────────────────────────────────────────────────────────────────

def find_repo_root() -> Path:
    p = Path(__file__).resolve().parent
    while p != p.parent:
        if (p / '.git').exists():
            return p
        p = p.parent
    return Path.cwd()


def extract_md_diagrams(md_path: Path) -> list[tuple[str, str]]:
    content = md_path.read_text(encoding='utf-8')
    return [
        (f'{md_path.stem}-{i:02d}', m.group(1))
        for i, m in enumerate(re.finditer(r'```mermaid\n(.*?)\n```', content, re.DOTALL), 1)
    ]


def discover(paths: list[Path], repo_root: Path) -> list[tuple[str, str]]:
    diagrams: list[tuple[str, str]] = []
    if paths:
        for p in paths:
            if p.suffix == '.mmd':
                diagrams.append((p.stem, p.read_text(encoding='utf-8')))
            elif p.suffix == '.md':
                diagrams.extend(extract_md_diagrams(p))
        return diagrams
    for dirpath_str, dirnames, filenames in os.walk(repo_root):
        dirnames[:] = sorted(d for d in dirnames if d not in EXCLUDE_DIRS and not d.startswith('.'))
        for fname in sorted(filenames):
            fp = Path(dirpath_str) / fname
            if fp.suffix == '.mmd':
                diagrams.append((fp.stem, fp.read_text(encoding='utf-8')))
            elif fp.suffix == '.md':
                diagrams.extend(extract_md_diagrams(fp))
    return diagrams


def parse_translate(t: str) -> tuple[float, float]:
    m = re.search(r'translate\(([^,)]+)(?:,\s*([^)]+))?\)', t or '')
    if not m:
        return 0.0, 0.0
    return float(m.group(1)), float(m.group(2) or 0)


def get_text(g: lxml_et._Element) -> str:
    for fo in g.iter(f'{S}foreignObject'):
        text = ''.join(fo.itertext()).strip().replace('\xa0', ' ')
        if text:
            return text
    for t in g.iter(f'{S}text'):
        text = ''.join(t.itertext()).strip()
        if text:
            return text
    return ''


def get_parent_translate(elem) -> tuple[float, float]:
    """Sum translate() transforms from all ancestor elements."""
    tx, ty = 0.0, 0.0
    parent = elem.getparent()
    while parent is not None:
        t = parent.get('transform', '')
        if t:
            dx, dy = parse_translate(t)
            tx += dx
            ty += dy
        parent = parent.getparent()
    return tx, ty


def path_endpoints(d: str) -> tuple[float, float, float, float]:
    nums = [float(n) for n in re.findall(r'-?(?:\d+\.?\d*|\.\d+)', d)]
    return (nums[0], nums[1], nums[-2], nums[-1]) if len(nums) >= 4 else (0, 0, 0, 0)


def add_arrowhead(connector) -> None:
    """Add an arrowhead at the end of a connector via XML."""
    A = 'http://schemas.openxmlformats.org/drawingml/2006/main'
    P = 'http://schemas.openxmlformats.org/presentationml/2006/main'
    cxnSp = connector._element
    spPr = cxnSp.find(f'{{{P}}}spPr')
    if spPr is None:
        return
    ln = spPr.find(f'{{{A}}}ln')
    if ln is None:
        ln = lxml_et.SubElement(spPr, f'{{{A}}}ln')
    for old in ln.findall(f'{{{A}}}tailEnd'):
        ln.remove(old)
    tail = lxml_et.SubElement(ln, f'{{{A}}}tailEnd')
    tail.set('type', 'arrow')
    tail.set('w', 'med')
    tail.set('len', 'med')


# ── coordinate mapping ────────────────────────────────────────────────────────

class CoordMapper:
    def __init__(self, vx0: float, vy0: float, vw: float, vh: float, margin: float = 0.05):
        margin_w = SLIDE_W * margin
        margin_h = SLIDE_H * margin
        usable_w = SLIDE_W - 2 * margin_w
        usable_h = SLIDE_H - 2 * margin_h
        self.scale = min(usable_w / vw, usable_h / vh)
        self.ox = margin_w + (usable_w - vw * self.scale) / 2 - vx0 * self.scale
        self.oy = margin_h + (usable_h - vh * self.scale) / 2 - vy0 * self.scale

    def pt(self, x: float, y: float) -> tuple[int, int]:
        return int(x * self.scale + self.ox), int(y * self.scale + self.oy)

    def dim(self, d: float) -> int:
        return int(d * self.scale)


# ── rendering ─────────────────────────────────────────────────────────────────

def render_svg(content: str, out: Path) -> bool:
    with tempfile.NamedTemporaryFile(suffix='.mmd', mode='w', delete=False, encoding='utf-8') as f:
        f.write(content)
        tmp = Path(f.name)
    try:
        r = subprocess.run(
            ['npx', '--yes', '-p', '@mermaid-js/mermaid-cli', 'mmdc',
             '-i', str(tmp), '-o', str(out)],
            capture_output=True, text=True,
        )
        if r.returncode != 0:
            print(f'  mmdc: {r.stderr.strip()[:200]}', file=sys.stderr)
            return False
        return out.exists()
    finally:
        tmp.unlink(missing_ok=True)


# ── SVG → pptx ────────────────────────────────────────────────────────────────

def svg_to_pptx(svg_path: Path, out_pptx: Path) -> None:
    tree = lxml_et.parse(svg_path)
    root = tree.getroot()
    ns = {'svg': SVG}

    vb = (root.get('viewBox') or '').split()
    vx0, vy0, vw, vh = (float(v) for v in vb) if len(vb) == 4 else (0, 0, 800, 600)
    mapper = CoordMapper(vx0, vy0, vw, vh)

    prs = Presentation()
    prs.slide_width = SLIDE_W
    prs.slide_height = SLIDE_H
    blank = next((l for l in prs.slide_layouts if l.name == 'Blank'), prs.slide_layouts[6])
    slide = prs.slides.add_slide(blank)
    bg = slide.background
    bg.fill.solid()
    bg.fill.fore_color.rgb = SLIDE_BG

    # Collect cluster labels keyed by absolute x-center (include parent transforms)
    label_by_x: dict[int, str] = {}
    for g in root.xpath('.//svg:g[contains(@class,"cluster-label")]', namespaces=ns):
        tx, _ = parse_translate(g.get('transform', ''))
        ptx, _ = get_parent_translate(g)
        text = get_text(g)
        if text:
            label_by_x[round(tx + ptx)] = text

    def cluster_label(rect_x: float, rect_w: float) -> str:
        cx = rect_x + rect_w / 2
        if not label_by_x:
            return ''
        key = min(label_by_x, key=lambda k: abs(k - cx))
        return label_by_x[key] if abs(key - cx) < rect_w else ''

    cluster_label_boxes: list[tuple[int, int, int, str]] = []  # (px, py, pw, text)

    # 1. Cluster boxes (background) — no inline text; collect label positions for later
    for g in root.xpath('.//svg:g[contains(@class,"cluster") and not(contains(@class,"cluster-label"))]',
                        namespaces=ns):
        r = g.find(f'{S}rect')
        if r is None:
            continue
        ptx, pty = get_parent_translate(g)
        rx = float(r.get('x', 0)) + ptx
        ry = float(r.get('y', 0)) + pty
        rw = float(r.get('width', 100))
        rh = float(r.get('height', 50))
        px, py = mapper.pt(rx, ry)
        pw, ph = mapper.dim(rw), mapper.dim(rh)
        shape = slide.shapes.add_shape(MSO_AUTO_SHAPE_TYPE.ROUNDED_RECTANGLE, px, py, pw, ph)
        shape.fill.solid()
        shape.fill.fore_color.rgb = CLUSTER_FILL
        shape.line.color.rgb = CLUSTER_LINE
        shape.line.width = Pt(1.5)
        shape.text_frame.text = ''
        label = cluster_label(rx, rw)
        if label:
            cluster_label_boxes.append((px, py, pw, label))

    # 2. Edges (behind nodes)
    for path in root.xpath('.//svg:path[contains(@class,"flowchart-link")]', namespaces=ns):
        d = path.get('d', '')
        if not d:
            continue
        x1, y1, x2, y2 = path_endpoints(d)
        px1, py1 = mapper.pt(x1, y1)
        px2, py2 = mapper.pt(x2, y2)
        conn = slide.shapes.add_connector(MSO_CONNECTOR_TYPE.STRAIGHT, px1, py1, px2, py2)
        conn.line.color.rgb = EDGE_COLOR
        conn.line.width = EDGE_WIDTH
        add_arrowhead(conn)

    # 3. Nodes (foreground)
    for g in root.xpath('.//svg:g[contains(@class,"node") and contains(@class,"default")]',
                        namespaces=ns):
        transform = g.get('transform', '')
        cx, cy = parse_translate(transform)
        ptx, pty = get_parent_translate(g)
        cx += ptx
        cy += pty
        shape_type = MSO_AUTO_SHAPE_TYPE.ROUNDED_RECTANGLE
        w, h = 100.0, 40.0

        for child in g:
            tag = child.tag.replace(f'{{{SVG}}}', '')
            if tag == 'rect':
                w = float(child.get('width', 100))
                h = float(child.get('height', 40))
                shape_type = MSO_AUTO_SHAPE_TYPE.ROUNDED_RECTANGLE
                break
            elif tag == 'polygon':
                pts = [tuple(map(float, p.split(','))) for p in child.get('points', '').split() if ',' in p]
                if pts:
                    xs, ys = zip(*pts)
                    w, h = max(xs) - min(xs), max(ys) - min(ys)
                shape_type = MSO_AUTO_SHAPE_TYPE.DIAMOND
                break
            elif tag in ('circle', 'ellipse'):
                r = float(child.get('r', 20))
                w = float(child.get('rx', r)) * 2
                h = float(child.get('ry', r)) * 2
                shape_type = MSO_AUTO_SHAPE_TYPE.OVAL
                break

        px, py = mapper.pt(cx - w / 2, cy - h / 2)
        pw, ph = mapper.dim(w), mapper.dim(h)

        shape = slide.shapes.add_shape(shape_type, px, py, pw, ph)
        shape.fill.solid()
        shape.fill.fore_color.rgb = NODE_FILL
        shape.line.color.rgb = NODE_LINE
        shape.line.width = Pt(1.5)

        label = get_text(g)
        tf = shape.text_frame
        tf.word_wrap = True
        tf.text = label
        p = tf.paragraphs[0]
        p.alignment = PP_ALIGN.CENTER
        if p.runs:
            p.runs[0].font.name = FONT_NAME
            p.runs[0].font.size = FONT_SIZE
            p.runs[0].font.color.rgb = NODE_TEXT
            p.runs[0].font.bold = False

    # 4. Cluster labels — added last so they render above nodes
    label_h = int(Pt(20))
    for lpx, lpy, lpw, text in cluster_label_boxes:
        tb = slide.shapes.add_textbox(lpx, lpy, lpw, label_h)
        tf = tb.text_frame
        tf.word_wrap = False
        p = tf.paragraphs[0]
        p.alignment = PP_ALIGN.CENTER
        run = p.add_run()
        run.text = text
        run.font.name = FONT_NAME
        run.font.size = Pt(13)
        run.font.color.rgb = LABEL_TEXT
        run.font.bold = False

    out_pptx.parent.mkdir(parents=True, exist_ok=True)
    prs.save(str(out_pptx))


# ── main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('sources', nargs='*', help='Files or globs (default: whole repo)')
    ap.add_argument('--list', action='store_true', help='Dry-run: list diagrams only')
    args = ap.parse_args()

    repo_root = find_repo_root()
    out_dir = repo_root / 'build' / 'pptx'

    paths: list[Path] = []
    for s in args.sources:
        expanded = glob.glob(s, recursive=True)
        paths.extend(Path(p) for p in (expanded or [s]))

    diagrams = discover(paths, repo_root)
    if not diagrams:
        print('No Mermaid diagrams found.')
        return

    if args.list:
        print(f'Found {len(diagrams)} diagram(s):')
        for stem, _ in diagrams:
            print(f'  → {out_dir / stem}.pptx')
        return

    ok = 0
    with tempfile.TemporaryDirectory() as tmp_dir:
        for stem, content in diagrams:
            out_pptx = out_dir / f'{stem}.pptx'
            tmp_svg = Path(tmp_dir) / f'{stem}.svg'
            print(f'  {stem}', end=' ... ', flush=True)
            if render_svg(content, tmp_svg):
                try:
                    svg_to_pptx(tmp_svg, out_pptx)
                    print('✓')
                    ok += 1
                except Exception as e:
                    print(f'✗  ({e})')
            else:
                print('✗  (render failed)')

    print(f'\n{ok}/{len(diagrams)} files written to {out_dir}')


if __name__ == '__main__':
    main()

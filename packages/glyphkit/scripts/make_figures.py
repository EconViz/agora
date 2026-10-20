"""Generate manual figures from GlyphKit's real layout and outline values."""

from __future__ import annotations

import subprocess
from html import escape
from pathlib import Path

from glyphkit import FontLibrary, FontSource, Paragraph, TextSpan, TextStyle
from glyphkit.math import MathStyle, parse_math
from glyphkit.outlines import ClosePath, CubicTo, LineTo, MoveTo, QuadraticTo

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "figures"
INK = "#252525"
BLUE = "#356f9f"
MUTED = "#969696"


def font(name: str) -> Path:
    path = subprocess.check_output(["kpsewhich", name], text=True).strip()
    if not path:
        raise RuntimeError(f"TeX font not found: {name}")
    return Path(path)


def library() -> FontLibrary:
    return FontLibrary.from_sources(
        tuple(
            FontSource.path(font(name))
            for name in (
                "texgyrebonum-regular.otf",
                "texgyrebonum-italic.otf",
                "texgyrebonum-math.otf",
            )
        )
    )


def path_data(commands, scale: float, dx: float, dy: float) -> str:
    parts: list[str] = []
    for command in commands:
        def p(value):
            return f"{dx + value[0] * scale:.3f},{dy - value[1] * scale:.3f}"
        if isinstance(command, MoveTo):
            parts.append("M" + p(command.point))
        elif isinstance(command, LineTo):
            parts.append("L" + p(command.point))
        elif isinstance(command, QuadraticTo):
            parts.append("Q" + p(command.control) + " " + p(command.point))
        elif isinstance(command, CubicTo):
            parts.append("C" + p(command.control1) + " " + p(command.control2) + " " + p(command.point))
        elif isinstance(command, ClosePath):
            parts.append("Z")
    return " ".join(parts)


def svg_document(
    width: int,
    height: int,
    body: list[str],
    *,
    view_box: tuple[int, int, int, int] | None = None,
) -> str:
    x, y, view_width, view_height = view_box or (0, 0, width, height)
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{view_width}" height="{view_height}" '
        f'viewBox="{x} {y} {view_width} {view_height}">\n'
        '<rect width="100%" height="100%" fill="white"/>\n'
        + "\n".join(body)
        + "\n</svg>\n"
    )


def draw_layout(lib: FontLibrary, layout, *, dx: float, baseline: float) -> list[str]:
    body: list[str] = []
    for line in layout.lines:
        for run in line.runs:
            face = lib.face(run.face_id)
            scale = run.size / face.metrics.units_per_em
            for glyph in run.glyphs:
                outline = lib.outline(glyph)
                body.append(
                    f'<path d="{path_data(outline.commands, scale, dx + glyph.x + glyph.x_offset, baseline - glyph.y - glyph.y_offset)}" fill="{INK}"/>'
                )
    return body


def metrics_figure(lib: FontLibrary) -> None:
    family = lib.faces[0].family
    layout = lib.layout(
        Paragraph((TextSpan("GlyphKit  U(x)", TextStyle((family,), 52)),), max_width=520)
    )
    logical, ink = layout.logical_bounds, layout.ink_bounds
    dx, baseline = 45.0, 108.0
    body = draw_layout(lib, layout, dx=dx, baseline=baseline)
    body += [
        f'<line x1="{dx}" y1="{baseline}" x2="{dx + logical.width:.2f}" y2="{baseline}" stroke="{BLUE}" stroke-width="1.5"/>',
        f'<rect x="{dx + logical.x_min:.2f}" y="{baseline - logical.y_max:.2f}" width="{logical.width:.2f}" height="{logical.height:.2f}" fill="none" stroke="{BLUE}" stroke-width="1.5" stroke-dasharray="6 4"/>',
        f'<rect x="{dx + ink.x_min:.2f}" y="{baseline - ink.y_max:.2f}" width="{ink.width:.2f}" height="{ink.height:.2f}" fill="none" stroke="{MUTED}" stroke-width="1.2"/>',
        f'<text x="45" y="166" font-family="sans-serif" font-size="12" fill="{BLUE}">logical box and baseline</text>',
        f'<text x="255" y="166" font-family="sans-serif" font-size="12" fill="{MUTED}">ink box</text>',
    ]
    target = OUT / "layout" / "metrics.svg"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(svg_document(600, 185, body, view_box=(24, 31, 405, 145)))


def annotated_metrics_figures() -> None:
    """Generate the same font-metrics diagram for each manual language."""
    labels = {
        "en": {
            "ascender_line": "ascender line",
            "mean_line": "mean line",
            "baseline": "baseline",
            "descender_line": "descender line",
            "ascender": "ascender",
            "descender": "descender",
            "serif": "serif",
            "x_height": "x-height",
            "cap_height": "cap height",
            "depth": "depth",
            "width": "width",
        },
        "zh-CN": {
            "ascender_line": "上伸线",
            "mean_line": "中线",
            "baseline": "基线",
            "descender_line": "下伸线",
            "ascender": "上伸部",
            "descender": "下伸部",
            "serif": "衬线",
            "x_height": "x 高度",
            "cap_height": "大写高度",
            "depth": "深度",
            "width": "宽度",
        },
    }

    def text(x: float, y: float, value: str, *, anchor: str = "start", color: str = INK, size: int = 18, weight: int = 400) -> str:
        return (
            f'<text x="{x}" y="{y}" text-anchor="{anchor}" '
            f'font-family="Inter, Noto Sans CJK SC, Noto Sans, sans-serif" '
            f'font-size="{size}" font-weight="{weight}" fill="{color}">{escape(value)}</text>'
        )

    for locale, words in labels.items():
        body = [
            '<defs><marker id="arrow" markerWidth="7" markerHeight="7" refX="3.5" refY="3.5" orient="auto-start-reverse"><path d="M0,0 L7,3.5 L0,7 Z" fill="#252525"/></marker></defs>',
            '<rect x="325" y="38" width="112" height="202" fill="#d9d9d9"/>',
            '<g stroke="#252525" stroke-width="1.2">',
            '<line x1="145" y1="38" x2="705" y2="38" stroke-dasharray="6 4"/>',
            '<line x1="145" y1="103" x2="650" y2="103" stroke-dasharray="6 4"/>',
            '<line x1="145" y1="190" x2="705" y2="190"/>',
            '<line x1="145" y1="240" x2="705" y2="240" stroke-dasharray="6 4"/>',
            '</g>',
            '<g fill="#111" font-family="TeX Gyre Bonum, Times New Roman, serif">',
            '<text x="165" y="190" font-size="142">x</text>',
            '<text x="326" y="190" font-size="142">y</text>',
            '<text x="482" y="190" font-size="196">Z</text>',
            '</g>',
            '<g stroke="#252525" stroke-width="1.4" marker-start="url(#arrow)" marker-end="url(#arrow)">',
            '<line x1="112" y1="104" x2="112" y2="188"/>',
            '<line x1="664" y1="40" x2="664" y2="188"/>',
            '<line x1="460" y1="192" x2="460" y2="238"/>',
            '<line x1="326" y1="263" x2="437" y2="263"/>',
            '</g>',
            text(135, 45, words["ascender_line"], anchor="end"),
            text(135, 110, words["mean_line"], anchor="end"),
            text(135, 197, words["baseline"], anchor="end"),
            text(135, 247, words["descender_line"], anchor="end"),
            text(190, 78, words["ascender"], anchor="middle", color=BLUE, weight=600),
            text(190, 226, words["descender"], anchor="middle", color=BLUE, weight=600),
            text(206, 276, words["serif"], anchor="middle", color=BLUE, weight=600),
            text(112, 151, words["x_height"], anchor="middle", color=MUTED, size=16),
            text(665, 121, words["cap_height"], anchor="middle", color=MUTED, size=16),
            text(461, 220, words["depth"], color=MUTED, size=16),
            text(382, 286, words["width"], anchor="middle", color=MUTED, size=16),
            f'<circle cx="218" cy="183" r="3.2" fill="{BLUE}"/>',
            f'<path d="M218 183 C238 205, 234 239, 215 256" fill="none" stroke="{BLUE}" stroke-width="1.2"/>',
        ]
        target = OUT / "layout" / f"metrics-{locale}.svg"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(svg_document(760, 300, body))


def outline_figure(lib: FontLibrary) -> None:
    family = lib.faces[0].family
    layout = lib.layout(Paragraph((TextSpan("G", TextStyle((family,), 180)),)))
    glyph = layout.lines[0].runs[0].glyphs[0]
    outline = lib.outline(glyph)
    scale = 0.115
    dx, baseline = 92.0, 210.0
    body = [f'<path d="{path_data(outline.commands, scale, dx, baseline)}" fill="none" stroke="{INK}" stroke-width="2"/>']
    current = None
    highlighted = 0
    for command in outline.commands:
        if isinstance(command, MoveTo):
            current = command.point
        elif isinstance(command, (LineTo, QuadraticTo, CubicTo)):
            end = command.point
            controls = []
            if isinstance(command, QuadraticTo):
                controls = [command.control]
            elif isinstance(command, CubicTo):
                controls = [command.control1, command.control2]
            if controls and highlighted < 5 and current is not None:
                points = [current, *controls, end]
                xy = [(dx + x * scale, baseline - y * scale) for x, y in points]
                body.append('<polyline points="' + ' '.join(f'{x:.2f},{y:.2f}' for x, y in xy) + f'" fill="none" stroke="{MUTED}" stroke-width="1"/>')
                body.extend(f'<circle cx="{x:.2f}" cy="{y:.2f}" r="3" fill="white" stroke="{BLUE}" stroke-width="1.3"/>' for x, y in xy)
                highlighted += 1
            current = end
    target = OUT / "outlines" / "glyph-g.svg"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(svg_document(560, 250, body, view_box=(75, 60, 170, 180)))


def math_figure(lib: FontLibrary) -> None:
    math_face = next(face for face in lib.faces if "Math" in face.family)
    style = MathStyle(38, (math_face.family,), letter_slant="italic")
    # GlyphKit deliberately keeps parsing separate from higher-level math
    # spacing.  Compose the visible atoms explicitly so this example shows
    # the layout geometry without crowding binary operators or products.
    source_atoms = (
        (r"𝑈", 2),
        (r"(", 0),
        (r"𝑥_1", 2),
        (r",", 8),
        (r"𝑥_2", 2),
        (r")", 14),
        (r"=", 14),
        (r"𝑥_1^𝛼", 10),
        (r"𝑥_2^{1-𝛼}", 0),
    )
    atoms = [(lib.layout_math(parse_math(source), style=style), gap) for source, gap in source_atoms]
    body: list[str] = []

    def walk(node, ox: float, oy: float) -> None:
        x, y = ox + node.origin[0], oy - node.origin[1]
        if node.text_layout is not None:
            body.extend(draw_layout(lib, node.text_layout, dx=x, baseline=y))
        for rule in node.rules:
            body.append(
                f'<line x1="{x + rule.start[0]:.2f}" y1="{y - rule.start[1]:.2f}" x2="{x + rule.end[0]:.2f}" y2="{y - rule.end[1]:.2f}" stroke="{INK}" stroke-width="{max(rule.thickness, 1):.2f}"/>'
            )
        for child in node.children:
            walk(child, x, y)

    formula_width = sum(box.bounds.width + gap for box, gap in atoms)
    width = max(560, int(formula_width + 96))
    cursor = (width - formula_width) / 2
    baseline = 92
    for box, gap in atoms:
        walk(box, cursor - box.bounds.x_min, baseline)
        cursor += box.bounds.width + gap
    target = OUT / "math" / "utility.svg"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(svg_document(width, 160, body, view_box=(80, 40, width - 160, 80)))


def main() -> None:
    lib = library()
    metrics_figure(lib)
    annotated_metrics_figures()
    outline_figure(lib)
    math_figure(lib)
    print("generated 5 GlyphKit figures")


if __name__ == "__main__":
    main()

"""Generate the manual's figures as standalone TikZ pictures, compiled to PDF.

Run from the manual's directory (packages/bezierkit/):

    uv run python scripts/make_figures.py            # all figures
    uv run python scripts/make_figures.py fitting    # one group
    uv run python scripts/make_figures.py --list     # list figure groups
    uv run python scripts/make_figures.py --no-pdf   # write .tex only

Every curve in a figure is written by bezierkit's own TikZ exporter
(``bezierkit.export.tikz.to_tikz``), so each picture is the exporter's real
output. Each ``<name>.tex`` is kept beside its ``<name>.pdf`` for readers who
want the TikZ.

Figures are drawn at their final size (about 6 cm wide) with 8 pt labels and
are placed in the manual at that size, never scaled, so the text in every
figure is one size, the size of the captions.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import tomllib
from collections.abc import Callable, Iterable
from pathlib import Path

import numpy as np

from bezierkit import CubicBezierSegment, PiecewiseBezier, Point
from bezierkit.export.tikz import to_tikz
from bezierkit.fitting import fit_graph, fit_polyline
from bezierkit.implicit import trace_implicit
from bezierkit.interpolation import graph_hermite

ROOT = Path(__file__).resolve().parent.parent
AGORA = ROOT.parents[1]
sys.path.insert(0, str(AGORA))

import dataclasses
import subprocess
from collections.abc import Mapping
from typing import Any

FIGURE_STYLE = {'colors': {'ink': '#1a1a1a', 'dark': '#595959', 'curve': '#8c8c8c', 'light': '#b8b8b8', 'muted': '#ececec', 'white': '#ffffff'}, 'text': {'size': 8, 'note': 7}, 'fonts': {'latin': 'TeX Gyre Pagella', 'texmf_files': ['fonts/opentype/public/tex-gyre/texgyrepagella-regular.otf', 'fonts/opentype/public/tex-gyre/texgyrepagella-italic.otf', 'fonts/opentype/public/tex-gyre/texgyrepagella-bold.otf'], 'cjk': {'zh-TW': 'Noto Serif TC', 'zh-CN': 'Noto Serif SC'}, 'files': {'zh-TW': ['NotoSerifTC-Regular.otf', 'NotoSerifTC-Bold.otf'], 'zh-CN': ['NotoSerifSC-Regular.ttf', 'NotoSerifSC-Bold.ttf']}}}

def register_fonts() -> None:
    """Register the manual's bundled and TeX fonts with Matplotlib."""
    import matplotlib
    from matplotlib import font_manager

    try:
        texmf = subprocess.run(
            ["kpsewhich", "-var-value", "TEXMFDIST"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        texmf = ""

    candidates = [Path(texmf) / rel for rel in FIGURE_STYLE["fonts"]["texmf_files"]]
    font_roots = (ROOT / "fonts", ROOT.parents[1] / "fonts")
    candidates.extend(
        root / filename
        for root in font_roots
        for files in FIGURE_STYLE["fonts"]["files"].values()
        for filename in files
    )
    for path in candidates:
        if path.is_file():
            font_manager.fontManager.addfont(str(path))

    latin = FIGURE_STYLE["fonts"]["latin"]
    matplotlib.rcParams.update(
        {
            "font.family": [latin],
            "mathtext.fontset": "custom",
            "mathtext.rm": latin,
            "mathtext.it": f"{latin}:italic",
            "mathtext.bf": f"{latin}:bold",
            "mathtext.cal": f"{latin}:italic",
            "mathtext.sf": latin,
            "mathtext.tt": latin,
        }
    )

def font_family(edition: str = "en") -> str:
    return FIGURE_STYLE["fonts"]["cjk"].get(edition, FIGURE_STYLE["fonts"]["latin"])

def mosaickit_config(
    *,
    edition: str = "en",
    text_size: float | None = None,
    note_size: float | None = None,
    renderer: Any = "matplotlib",
):
    """Build a MosaicKit config without modifying its private theme defaults."""
    from mosaickit import Config, StyleBundle, TextStyle

    text_size = text_size if text_size is not None else FIGURE_STYLE["text"]["size"]
    note_size = note_size if note_size is not None else FIGURE_STYLE["text"]["note"]
    family = font_family(edition)
    ink = FIGURE_STYLE["colors"]["ink"]
    return Config(
        renderer=renderer,
        role_overrides={
            "text": StyleBundle(text=TextStyle(size=text_size, color=ink, family=family)),
            "axes.note": StyleBundle(text=TextStyle(size=note_size, color=ink, family=family)),
        },
    )

def scaled_mosaickit_config(
    theme,
    *,
    scale: float,
    edition: str = "en",
    renderer: Any = "matplotlib",
):
    """Scale a theme's text roles while retaining their relative sizes."""
    from mosaickit import Config, StyleBundle, TextStyle

    family = font_family(edition)
    ink = FIGURE_STYLE["colors"]["ink"]
    overrides = {
        "text": StyleBundle(text=TextStyle(size=12 * scale, color=ink, family=family)),
        "axes.note": StyleBundle(text=TextStyle(size=9 * scale, color=ink, family=family)),
    }
    for role, bundle in theme.roles.items():
        if bundle.text is not None and bundle.text.size is not None:
            overrides[role] = StyleBundle(
                text=dataclasses.replace(
                    bundle.text,
                    size=bundle.text.size * scale,
                    family=family,
                )
            )
    return Config(renderer=renderer, role_overrides=overrides)

def localize(value: Any, table: Mapping[str, str]) -> Any:
    """Recursively copy a render value, translating its strings."""
    if isinstance(value, str):
        return table.get(value, value)
    if dataclasses.is_dataclass(value) and not isinstance(value, type):
        changes = {
            field.name: translated
            for field in dataclasses.fields(value)
            if (translated := localize(getattr(value, field.name), table))
            != getattr(value, field.name)
        }
        return dataclasses.replace(value, **changes) if changes else value
    if isinstance(value, tuple):
        if hasattr(value, "_fields"):
            return type(value)(*(localize(item, table) for item in value))
        return tuple(localize(item, table) for item in value)
    if isinstance(value, list):
        return [localize(item, table) for item in value]
    if isinstance(value, dict):
        return {key: localize(item, table) for key, item in value.items()}
    return value

class LocalizedMatplotlibRenderer:
    """Translate render inputs through MosaicKit's public renderer protocol."""

    name = "localized-matplotlib"

    def __init__(
        self,
        labels: Mapping[str, str] | None = None,
        *,
        family: str | None = None,
    ) -> None:
        from mosaickit.rendering.matplotlib.renderer import MatplotlibRenderer

        self.labels = dict(labels or {})
        self.family = family
        self._renderer = MatplotlibRenderer()

    def render(self, scene, context):
        import matplotlib

        rc = {"font.family": [self.family]} if self.family else {}
        with matplotlib.rc_context(rc):
            return self._renderer.render(localize(scene, self.labels), localize(context, self.labels))

    def render_grid(self, grid, cache):
        from mosaickit import Canvas, CanvasGrid
        from mosaickit.canvas import Span

        starts: dict[tuple[int, int], Any] = {}
        covered: set[tuple[int, int]] = set()
        for placement in grid.placements:
            source = placement.canvas
            canvas = Canvas(
                localize(source.spec, self.labels),
                localize(source.theme, self.labels),
                localize(source.config, self.labels),
                renderer=self,
                role_overrides=localize(source.role_overrides, self.labels),
            ).extend(localize(source.snapshot().layers, self.labels))
            cell = Span(canvas, rows=placement.rows, cols=placement.cols)
            starts[(placement.row, placement.col)] = cell
            for row in range(placement.row, placement.row + placement.rows):
                for col in range(placement.col, placement.col + placement.cols):
                    if row != placement.row or col != placement.col:
                        covered.add((row, col))
        matrix = []
        for row in range(grid.rows):
            cells = []
            for col in range(grid.cols):
                if (row, col) in covered:
                    continue
                cells.append(starts.get((row, col)))
            matrix.append(cells)
        translated = CanvasGrid(matrix, links=localize(grid.links, self.labels))
        import matplotlib

        rc = {"font.family": [self.family]} if self.family else {}
        with matplotlib.rc_context(rc):
            return self._renderer.render_grid(translated, cache)

    def save(self, result, target, options):
        return self._renderer.save(result, target, options)


CONFIG = tomllib.loads((ROOT / "config" / "figures.toml").read_text())
OUT = ROOT / CONFIG["output"]["dir"]
PRECISION = CONFIG["output"]["precision"]
LATEXMK = CONFIG["output"]["latexmk"]
STYLE = {
    "curve": FIGURE_STYLE["colors"]["curve"],
    "accent": FIGURE_STYLE["colors"]["ink"],
    "polygon": FIGURE_STYLE["colors"]["curve"],
    "muted": FIGURE_STYLE["colors"]["muted"],
}

CUBIC = CubicBezierSegment(Point(0, 0), Point(1, 2), Point(3, 2), Point(4, 0))


# ---------------------------------------------------------------------------
# TikZ helpers
# ---------------------------------------------------------------------------


def c(point: Point | tuple[float, float]) -> str:
    """A TikZ coordinate."""
    x, y = (point.x, point.y) if isinstance(point, Point) else point
    return f"({x:.4g},{y:.4g})"


def path(geometry: CubicBezierSegment | PiecewiseBezier, options: str) -> str:
    """Draw a segment or path with bezierkit's exporter."""
    if isinstance(geometry, CubicBezierSegment):
        geometry = PiecewiseBezier([geometry])
    return to_tikz(geometry, precision=PRECISION, options=options)


def polyline(points: Iterable[Point | tuple[float, float]], options: str) -> str:
    return f"\\draw[{options}] " + " -- ".join(c(p) for p in points) + ";"


def control_polygon(points, *, labels=(), color: str = "polygon") -> list[str]:
    """Dashed polygon, open control points, and optional labels.

    ``labels`` holds one ``(text, anchor)`` pair per point (``None`` to skip).
    """
    lines = [polyline(points, f"polygon, draw={color}")]
    lines += [f"\\node[ctrl, draw={color}] at {c(p)} {{}};" for p in points]
    for point, label in zip(points, labels):
        if label:
            text, anchor = label
            lines.append(f"\\node[{anchor}] at {c(point)} {{{text}}};")
    return lines


def dot(point, *, color: str = "black", size: str = "1.8pt") -> str:
    return f"\\fill[{color}] {c(point)} circle ({size});"


def axes(x0: float, x1: float, y0: float, y1: float, *, xlabel="$x$", ylabel="$y$") -> list[str]:
    return [
        f"\\draw[axis, ->] {c((x0, y0))} -- {c((x1, y0))} node[right] {{{xlabel}}};",
        f"\\draw[axis, ->] {c((x0, y0))} -- {c((x0, y1))} node[above] {{{ylabel}}};",
    ]


def ticks(axis: str, values: Iterable[tuple[float, str]], at: float) -> list[str]:
    lines = []
    for value, text in values:
        if axis == "x":
            lines.append(f"\\draw[axis] {c((value, at))} -- ++(0,-2pt) node[below] {{{text}}};")
        else:
            lines.append(f"\\draw[axis] {c((at, value))} -- ++(-2pt,0) node[left] {{{text}}};")
    return lines


def document(body: list[str], *, unit_x: float, unit_y: float | None = None) -> str:
    colors = "\n".join(
        f"\\definecolor{{{name}}}{{HTML}}{{{STYLE[name].lstrip('#')}}}"
        for name in ("curve", "accent", "polygon", "muted")
    )
    unit_y = unit_x if unit_y is None else unit_y
    return rf"""\documentclass[tikz,border=2pt]{{standalone}}
\usepackage{{tgpagella}}
\usepackage{{newpxmath}}
{colors}
\begin{{document}}
\begin{{tikzpicture}}[
  x={unit_x:g}cm, y={unit_y:g}cm,
  line cap=round, line join=round,
  every node/.style={{font=\footnotesize, inner sep=1.5pt}},
  curve/.style={{draw=curve, line width=1.1pt}},
  second/.style={{draw=accent, line width=1.1pt}},
  polygon/.style={{line width=0.5pt, dash pattern=on 2.5pt off 2pt}},
  construction/.style={{draw=accent, line width=0.5pt}},
  axis/.style={{line width=0.45pt, draw=black!80, >=stealth}},
  ctrl/.style={{circle, fill=white, line width=0.6pt, minimum size=4pt, inner sep=0pt}},
]
{chr(10).join(body)}
\end{{tikzpicture}}
\end{{document}}
"""


def write(group: str, name: str, body: list[str], *, unit_x: float, unit_y: float | None = None,
          compile_pdf: bool) -> None:
    tex = OUT / group / f"{name}.tex"
    tex.parent.mkdir(parents=True, exist_ok=True)
    tex.write_text(document(body, unit_x=unit_x, unit_y=unit_y))
    if compile_pdf:
        subprocess.run(
            [LATEXMK, "-pdf", "-interaction=nonstopmode", "-halt-on-error", tex.name],
            cwd=tex.parent,
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            env={**os.environ, "SOURCE_DATE_EPOCH": "0"},
        )
        for suffix in (".aux", ".fdb_latexmk", ".fls", ".log"):
            tex.with_suffix(suffix).unlink(missing_ok=True)


# ---------------------------------------------------------------------------
# Figures, by chapter
# ---------------------------------------------------------------------------




CUBIC_LABELS = (("$P_0$", "below left"), ("$P_1$", "above"), ("$P_2$", "above"), ("$P_3$", "below right"))








def paths_bbox(*, compile_pdf: bool) -> None:
    segment = CubicBezierSegment(Point(0, 0), Point(0.5, 2.6), Point(3.5, -1.2), Point(4, 1))
    low, high = segment.bounding_box
    labels = (("$P_0$", "left"), ("$P_1$", "above"), ("$P_2$", "below"), ("$P_3$", "right"))
    body = [f"\\draw[accent, line width=0.6pt] {c(low)} rectangle {c(high)};"]
    body += control_polygon(segment.control_points, labels=labels)
    body.append(path(segment, "curve"))
    body += [f"\\node[ctrl, draw=black] at {c(p)} {{}};" for p in segment.control_points]
    write("paths", "bbox", body, unit_x=1.3, compile_pdf=compile_pdf)


if __name__ == "__main__":
    paths_bbox(compile_pdf=True)

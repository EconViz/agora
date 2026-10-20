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
CONFIG = tomllib.loads((ROOT / "config" / "figures.toml").read_text())
OUT = ROOT / CONFIG["output"]["dir"]
PRECISION = CONFIG["output"]["precision"]
LATEXMK = CONFIG["output"]["latexmk"]
STYLE = CONFIG["style"]

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
            cwd=tex.parent, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        for suffix in (".aux", ".fdb_latexmk", ".fls", ".log"):
            tex.with_suffix(suffix).unlink(missing_ok=True)


# ---------------------------------------------------------------------------
# Figures, by chapter
# ---------------------------------------------------------------------------




CUBIC_LABELS = (("$P_0$", "below left"), ("$P_1$", "above"), ("$P_2$", "above"), ("$P_3$", "below right"))
















def implicit_contours(*, compile_pdf: bool) -> None:
    contours = trace_implicit(
        lambda x, y: x**2 * y,
        levels=[1, 2, 4],
        viewport=(0.5, 4, 0, 6),
        resolution=(121, 121),
        tolerance=0.01,
        gradient=lambda x, y: (2 * x * y, x**2),
    )
    body = axes(0.5, 4.25, 0, 6.6)
    body += ticks("x", [(1, "$1$"), (2, "$2$"), (3, "$3$"), (4, "$4$")], 0)
    body += ticks("y", [(2, "$2$"), (4, "$4$"), (6, "$6$")], 0.5)
    for level in contours.contours:
        for traced in level.paths:
            body.append(path(traced, "curve"))
    write("implicit", "contours", body, unit_x=1.55, unit_y=0.62, compile_pdf=compile_pdf)


def implicit_saddle(*, compile_pdf: bool) -> None:
    body: list[str] = []
    mids = {"b": (0.5, 0), "r": (1, 0.5), "t": (0.5, 1), "l": (0, 0.5)}
    for offset, center_high, tag in ((0.0, True, "(a)"), (1.7, False, "(b)")):
        def at(p, dx=offset):
            return (p[0] + dx, p[1])
        body.append(f"\\draw[line width=0.5pt] {c(at((0, 0)))} rectangle {c(at((1, 1)))};")
        # Marching squares joins bottom-right and top-left when the centre is
        # on the same side of the level as the lower-left corner.
        pairs = (("b", "r"), ("t", "l")) if center_high else (("b", "l"), ("r", "t"))
        for a, b in pairs:
            segment = CubicBezierSegment.from_line(Point(*at(mids[a])), Point(*at(mids[b])))
            body.append(path(segment, "curve"))
        for corner in ((0, 0), (1, 1)):
            body.append(dot(at(corner), size="2.2pt"))
        for corner in ((1, 0), (0, 1)):
            body.append(f"\\node[ctrl, draw=black, minimum size=4.4pt] at {c(at(corner))} {{}};")
        body.append(f"\\node[below=3pt] at {c(at((0.5, 0)))} {{{tag}}};")
    write("implicit", "saddle", body, unit_x=1.6, compile_pdf=compile_pdf)


if __name__ == "__main__":
    implicit_contours(compile_pdf=True)
    implicit_saddle(compile_pdf=True)

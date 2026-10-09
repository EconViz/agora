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
\usepackage{{newpxtext,newpxmath}}
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


def curves_basis(*, compile_pdf: bool) -> None:
    # (t, b_{i,3}(t)) is itself a cubic Bezier curve with controls (j/3, delta_ij),
    # so every basis polynomial is drawn exactly by the exporter.
    styles = ("", "dash pattern=on 4pt off 1.5pt", "dash pattern=on 1pt off 1.5pt",
              "dash pattern=on 4pt off 1.5pt on 1pt off 1.5pt")
    body = axes(0, 1.08, 0, 1.12, xlabel="$t$", ylabel="")
    body += ticks("x", [(0, "$0$"), (1 / 3, "$\\frac13$"), (2 / 3, "$\\frac23$"), (1, "$1$")], 0)
    body += ticks("y", [(1, "$1$")], 0)
    peaks = ((0.0, 1.0, "right"), (1 / 3, 4 / 9, "above"), (2 / 3, 4 / 9, "above"), (1.0, 1.0, "left"))
    for i in range(4):
        controls = [Point(j / 3, 1.0 if i == j else 0.0) for j in range(4)]
        body.append(path(CubicBezierSegment(*controls), f"draw=black, line width=0.8pt, {styles[i]}"))
        x, y, anchor = peaks[i]
        body.append(f"\\node[{anchor}] at {c((x, y))} {{$b_{{{i},3}}$}};")
    write("curves", "basis", body, unit_x=5.2, unit_y=2.6, compile_pdf=compile_pdf)


CUBIC_LABELS = (("$P_0$", "below left"), ("$P_1$", "above"), ("$P_2$", "above"), ("$P_3$", "below right"))


def curves_cubic(*, compile_pdf: bool) -> None:
    hull = " -- ".join(c(p) for p in CUBIC.control_points)
    body = [f"\\fill[muted] {hull} -- cycle;"]
    body += control_polygon(CUBIC.control_points, labels=CUBIC_LABELS)
    body.append(path(CUBIC, "curve"))
    body += [f"\\node[ctrl, draw=black] at {c(p)} {{}};" for p in CUBIC.control_points]
    write("curves", "cubic", body, unit_x=1.4, compile_pdf=compile_pdf)


def curves_casteljau(*, compile_pdf: bool) -> None:
    t = 0.4
    points = np.asarray([p.coords for p in CUBIC.control_points])
    body = [path(CUBIC, "curve")]
    body += control_polygon(CUBIC.control_points, labels=CUBIC_LABELS)
    level = points
    for _ in range(3):
        level = (1 - t) * level[:-1] + t * level[1:]
        if len(level) > 1:
            body.append(polyline([tuple(p) for p in level], "construction"))
            body += [dot(tuple(p), color="accent", size="1.3pt") for p in level]
    final = tuple(level[0])
    body.append(dot(final, size="2pt"))
    body.append(f"\\node[below right=1pt] at {c(final)} {{$B(0.4)$}};")
    write("curves", "casteljau", body, unit_x=1.4, compile_pdf=compile_pdf)


def curves_split(*, compile_pdf: bool) -> None:
    left, right = CUBIC.split(0.4)
    body = [path(left, "curve"), path(right, "second")]
    body += control_polygon(left.control_points, color="curve")
    body += control_polygon(right.control_points, color="accent")
    joint = left.p3
    body.append(dot((joint.x, joint.y), size="2pt"))
    body.append(f"\\node[below right=1pt] at {c(joint)} {{$B(0.4)$}};")
    write("curves", "split", body, unit_x=1.4, compile_pdf=compile_pdf)


def paths_bbox(*, compile_pdf: bool) -> None:
    segment = CubicBezierSegment(Point(0, 0), Point(0.5, 2.6), Point(3.5, -1.2), Point(4, 1))
    low, high = segment.bounding_box
    labels = (("$P_0$", "left"), ("$P_1$", "above"), ("$P_2$", "below"), ("$P_3$", "right"))
    body = [f"\\draw[accent, line width=0.6pt] {c(low)} rectangle {c(high)};"]
    body += control_polygon(segment.control_points, labels=labels)
    body.append(path(segment, "curve"))
    body += [f"\\node[ctrl, draw=black] at {c(p)} {{}};" for p in segment.control_points]
    write("paths", "bbox", body, unit_x=1.3, compile_pdf=compile_pdf)


def construction_hermite(*, compile_pdf: bool) -> None:
    # f(x) = 4 / x^2 on [1, 1.5]: f(1) = 4, f'(1) = -8, f(1.5) = 16/9, f'(1.5) = -64/27.
    reference = fit_graph(lambda x: 4 / x**2, lambda x: -8 / x**3, x0=0.97, x1=1.6, tolerance=1e-4)
    segment = graph_hermite(x0=1, x1=1.5, y0=4, y1=16 / 9, m0=-8, m1=-64 / 27)
    body = axes(0.8, 1.72, 1.2, 4.6)
    body += ticks("x", [(1.0, "$1$"), (1.5, "$1.5$")], 1.2)
    body += ticks("y", [(4.0, "$4$"), (16 / 9, "$\\frac{16}{9}$")], 0.8)
    body.append(path(reference, "draw=muted, line width=3.2pt"))
    body.append(path(segment, "curve"))
    labels = (("$P_0$", "right"), ("$P_1$", "left"), ("$P_2$", "below left"), ("$P_3$", "above right"))
    body += control_polygon(segment.control_points, labels=labels)
    write("construction", "hermite", body, unit_x=6.0, unit_y=1.25, compile_pdf=compile_pdf)


def fitting_adaptive(*, compile_pdf: bool) -> None:
    fitted = fit_graph(lambda x: 4 / x**2, lambda x: -8 / x**3, x0=0.8, x1=3, tolerance=1e-3)
    body = axes(0.6, 3.25, 0, 6.8)
    body += ticks("x", [(1, "$1$"), (2, "$2$"), (3, "$3$")], 0)
    body += ticks("y", [(2, "$2$"), (4, "$4$"), (6, "$6$")], 0.6)
    for index, segment in enumerate(fitted):
        body.append(path(segment, "curve" if index % 2 == 0 else "second"))
    joints = [s.p0 for s in fitted] + [fitted.segments[-1].p3]
    body += [dot(p, size="1.4pt") for p in joints]
    write("fitting", "adaptive", body, unit_x=2.1, unit_y=0.62, compile_pdf=compile_pdf)


def fitting_polyline(*, compile_pdf: bool) -> None:
    rng = np.random.default_rng(3)
    xs = np.linspace(0, 4, 41)
    ys = np.sin(xs * 1.4) * 0.8 + rng.normal(0, 0.035, xs.size)
    samples = [Point(float(a), float(b)) for a, b in zip(xs, ys)]
    simplified = fit_polyline(samples, tolerance=0.08)
    body = [polyline(samples, "draw=polygon!60, line width=0.4pt")]
    body += [dot(p, color="polygon", size="0.8pt") for p in samples]
    body.append(path(simplified, "curve"))
    anchors = [s.p0 for s in simplified] + [simplified.segments[-1].p3]
    body += [f"\\node[ctrl, draw=black] at {c(p)} {{}};" for p in anchors]
    write("fitting", "polyline", body, unit_x=1.45, unit_y=1.45, compile_pdf=compile_pdf)


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


FIGURES: dict[str, list[Callable[..., None]]] = {
    "curves": [curves_basis, curves_cubic, curves_casteljau, curves_split],
    "paths": [paths_bbox],
    "construction": [construction_hermite],
    "fitting": [fitting_adaptive, fitting_polyline],
    "implicit": [implicit_contours, implicit_saddle],
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("groups", nargs="*", help="figure groups to draw (default: all)")
    parser.add_argument("--list", action="store_true", help="list figure groups and exit")
    parser.add_argument("--no-pdf", action="store_true", help="write .tex without compiling")
    args = parser.parse_args()
    if args.list:
        for group, funcs in FIGURES.items():
            print(group + ": " + ", ".join(f.__name__ for f in funcs))
        return 0
    unknown = set(args.groups) - set(FIGURES)
    if unknown:
        parser.error(f"unknown group(s): {', '.join(sorted(unknown))}")
    for group in args.groups or FIGURES:
        for func in FIGURES[group]:
            func(compile_pdf=not args.no_pdf)
            print(f"{group}: {func.__name__}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

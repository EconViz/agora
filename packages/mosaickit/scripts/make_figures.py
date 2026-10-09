"""Generate the manual's figures with mosaickit itself.

Run from the manual's directory (packages/mosaickit/):

    uv run python scripts/make_figures.py            # all figures
    uv run python scripts/make_figures.py labels     # one group
    uv run python scripts/make_figures.py --list     # list figure names

Every figure is a mosaickit canvas or grid saved as PDF by the built-in
Matplotlib renderer, so each picture is the package's real output. Figures are
drawn at their final size (config/figures.toml) with 8 pt text and are placed
in the manual at that size, never scaled, so the text in every figure is one
size, the size of the captions. They carry no titles, so the same files serve
every language edition; the captions are written in Typst.
"""

from __future__ import annotations

import argparse
import math
import os
import sys
import tomllib
from collections.abc import Callable
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
# A fixed creation date keeps regenerated PDFs byte-identical.
os.environ.setdefault("SOURCE_DATE_EPOCH", "0")

from mosaickit import (
    ArrowLayer,
    AxisMarkLayer,
    AxisNoteLayer,
    BraceLayer,
    Canvas,
    CanvasGrid,
    CanvasSpec,
    Config,
    DashStyle,
    Fill,
    FillLayer,
    GridLink,
    Marker,
    MarkerLayer,
    Parameter,
    PathLayer,
    PointLabelLayer,
    RegionLabelLayer,
    SpanBraceLayer,
    Stroke,
    StyleBundle,
    TextLayer,
    TextStyle,
    quadrant_axes,
)
from mosaickit.layout.geometry import brace_outline, distance_to_boundary, polylabel
from mosaickit.layout.placement.point import ORDER
from mosaickit.layout.stack1d import spread

ROOT = Path(__file__).resolve().parent.parent
CONFIG = tomllib.loads((ROOT / "config" / "figures.toml").read_text())
OUT = ROOT / CONFIG["output"]["dir"]
SIZE = CONFIG["size"]
TEXT = CONFIG["text"]

# Every figure shares one configuration: the default theme with its text set to
# the caption size. Overrides apply after the theme, so the general "text" role
# would otherwise beat the theme's smaller axes.note; each text role is listed.
FIGURES_CONFIG = Config(
    role_overrides={
        "text": StyleBundle(text=TextStyle(size=TEXT["size"])),
        "title": StyleBundle(text=TextStyle(size=TEXT["size"])),
        "axes": StyleBundle(text=TextStyle(size=TEXT["size"]), stroke=Stroke(width=0.8)),
        "axes.note": StyleBundle(text=TextStyle(size=TEXT["note"])),
        "point": StyleBundle(marker=Marker(size=16)),
    }
)


def canvas(x: float = 10, y: float = 10, *, width: float | None = None, height: float | None = None) -> Canvas:
    spec = CanvasSpec(
        x_range=(0, x),
        y_range=(0, y),
        width=width or SIZE["width"],
        height=height or SIZE["height"],
        dpi=SIZE["dpi"],
    )
    return Canvas(spec, config=FIGURES_CONFIG)


def save(target: Canvas | CanvasGrid, name: str) -> None:
    path = OUT / f"{name}.{CONFIG['output']['format']}"
    path.parent.mkdir(parents=True, exist_ok=True)
    target.save(path)
    print(f"  {path.relative_to(ROOT)}")


def circle(center: tuple[float, float], radius: float, samples: int = 72) -> list[tuple[float, float]]:
    cx, cy = center
    return [
        (cx + radius * math.cos(2 * math.pi * k / samples), cy + radius * math.sin(2 * math.pi * k / samples))
        for k in range(samples + 1)
    ]


# ---------------------------------------------------------------------------
# Figures
# ---------------------------------------------------------------------------


def quickstart_diagram() -> None:
    """The README example: axes, a shaded region, a curve, a marked point."""
    c = canvas().extend(quadrant_axes(10, 10))
    c.add(FillLayer([(1, 1), (1, 7), (8, 1)], fill=Fill(color="#377EB8", opacity=0.12), z_index=-1))
    c.add(PathLayer([(1, 8), (2, 5), (4, 3), (7, 1.5), (9, 1)], stroke=Stroke(color="#984EA3", width=2), id="curve"))
    c.add(MarkerLayer([(4, 3)], id="point"))
    c.add(TextLayer((4, 3), "A", offset=(6, 6)))
    save(c, "quickstart/diagram")


def annotations_gutter() -> None:
    """Axis marks, notes and an outside brace in the y gutter."""
    c = canvas().extend(quadrant_axes(10, 10))
    c.add(PathLayer([(0, 7), (9, 7)], role="guide"))
    c.add(PathLayer([(0, 5), (9, 5)], role="guide"))
    for value, symbol, note in [(7, "a_1", "Upper\nvalue"), (5, "a_0", "Lower\nvalue")]:
        c.add(AxisMarkLayer("y", value, symbol, math=True))
        c.add(AxisNoteLayer("y", value, note))
    c.add(BraceLayer("y", 5, 7, "Span", side="outside"))
    c.add(AxisMarkLayer("x", 6, "b", math=True))
    save(c, "annotations/gutter")


def annotations_span() -> None:
    """A span brace between two points inside the plot."""
    c = canvas().extend(quadrant_axes(10, 10))
    c.add(PathLayer([(1, 8.5), (3, 5), (5, 3.6), (8, 2.6)], role="primary"))
    c.add(PathLayer([(1, 1.5), (4, 3.2), (8, 6)], role="secondary"))
    c.add(MarkerLayer([(3, 5), (3, 2.7)]))
    c.add(SpanBraceLayer((3, 2.7), (3, 5), "gap", side="left"))
    save(c, "annotations/span")


def labels_regions() -> None:
    """A region labelled inside, and a thin one labelled by a callout."""
    c = canvas().extend(quadrant_axes(10, 10))
    c.add(FillLayer([(0, 0), (0, 8), (6, 0)], id="wide", fill=Fill(color="blue", opacity=0.18), z_index=-1))
    c.add(FillLayer([(6, 0), (0, 8), (0, 8.8), (6.6, 0)], id="thin", fill=Fill(color="red", opacity=0.35), z_index=-1))
    c.add(PathLayer([(0, 8), (6, 0)], role="primary"))
    c.add(PathLayer([(0, 8.8), (6.6, 0)], role="secondary"))
    c.add(RegionLabelLayer("wide", "Feasible"))
    c.add(RegionLabelLayer("thin", "Slack"))
    save(c, "labels/regions")


def labels_points() -> None:
    """Point labels placed beside their points, covering nothing."""
    c = canvas().extend(quadrant_axes(10, 10))
    c.add(PathLayer([(1, 9), (2, 5.5), (4, 3), (7, 1.8), (9.5, 1.4)], role="primary"))
    c.add(PathLayer([(1, 1), (9, 9)], role="secondary"))
    points = {"A": (2, 5.5), "B": (3.45, 3.45), "C": (7, 1.8)}
    c.add(MarkerLayer(list(points.values())))
    for text, point in points.items():
        c.add(PointLabelLayer(point, text))
    save(c, "labels/points")


def grids_sweep() -> None:
    """A parameter sweep laid out as a grid, with a link between two cells."""
    shift = Parameter("shift", value_type=float)
    cell = SIZE["grid-cell"]
    template = canvas(width=cell, height=cell).extend(quadrant_axes(10, 10))
    template.add(PathLayer([(1, 9), (9, 1)], role="guide"))
    template.add(PathLayer([(1, 1 + shift), (9, 4 + shift)], role="primary"))
    template.add(MarkerLayer([(5, 2.5 + shift)]))
    values = shift.values([0.0, 2.0, 4.0])
    cells = [template.bind(values.parameter, value) for value in values.values]
    link = GridLink(0, (5, 2.5), 2, (5, 6.5), stroke=Stroke(color="red", width=0.8, dash=DashStyle.DASHED))
    save(CanvasGrid(cells, cols=3, links=[link]), "grids/sweep")


def geometry_polylabel() -> None:
    """The pole of inaccessibility of a U-shaped region, against its centroid."""
    u = [(1, 1), (9, 1), (9, 9), (6.5, 9), (6.5, 3.5), (3.5, 3.5), (3.5, 9), (1, 9)]
    # polylabel's precision is in the polygon's units; scale up so 1 unit is fine.
    pole = polylabel([(10 * x, 10 * y) for x, y in u])
    pole = (pole[0] / 10, pole[1] / 10)
    radius = distance_to_boundary(pole, u)
    area, cx, cy = 0.0, 0.0, 0.0
    for (x0, y0), (x1, y1) in zip(u, u[1:] + u[:1], strict=True):
        cross = x0 * y1 - x1 * y0
        area += cross / 2
        cx += (x0 + x1) * cross
        cy += (y0 + y1) * cross
    centroid = (cx / (6 * area), cy / (6 * area))
    c = canvas(10, 10, width=SIZE["height"], height=SIZE["height"])
    c.add(FillLayer(u, fill=Fill(color="blue", opacity=0.15), stroke=Stroke(color="grey-600", width=0.8), z_index=-1))
    c.add(PathLayer(circle(pole, radius), role="guide"))
    c.add(MarkerLayer([pole], marker=Marker(color="blue")))
    c.add(MarkerLayer([centroid], marker=Marker(color="red", shape="X", size=30)))
    c.add(TextLayer(pole, "pole", anchor="left", offset=(4, 0)))
    c.add(TextLayer(centroid, "centroid", anchor="bottom", offset=(0, 4)))
    save(c, "geometry/polylabel")


def geometry_brace() -> None:
    """Brace outlines over a long span and over one shorter than twice the depth."""
    c = canvas(10, 4, height=1.1)
    for start, end in ((0.5, 6.5), (7.5, 9.0)):
        brace = brace_outline(start, end, base=1, depth=1.6, direction=1, axis="x")
        c.add(PathLayer([(start, 1), (end, 1)], role="guide"))
        c.add(PathLayer(list(brace.points), role="primary"))
        c.add(MarkerLayer([brace.tip], marker=Marker(color="red")))
    save(c, "geometry/brace")


def geometry_spread() -> None:
    """Items before and after spread(): overlapping runs merge and centre."""
    centers = (1.6, 2.4, 3.0, 6.2, 8.4)
    sizes = (1.2, 1.2, 1.2, 1.4, 1.0)
    placed = spread(centers, sizes, gap=0.2)
    c = canvas(10, 3, height=0.9)
    for row, values in ((2, centers), (1, placed)):
        for k, (center, size) in enumerate(zip(values, sizes, strict=True)):
            role = "primary" if k % 2 == 0 else "secondary"
            c.add(PathLayer([(center - size / 2, row), (center + size / 2, row)], role=role, stroke=Stroke(width=5)))
    for before, after in zip(centers, placed, strict=True):
        c.add(ArrowLayer((before, 1.8), (after, 1.2), stroke=Stroke(color="grey-400", width=0.6)))
    save(c, "geometry/spread")


def geometry_candidates() -> None:
    """The order in which point labels try the 16 directions."""
    side = SIZE["height"]
    spec = CanvasSpec((-1.3, 1.3), (-1.3, 1.3), width=side, height=side, dpi=SIZE["dpi"])
    c = Canvas(spec, config=FIGURES_CONFIG)
    for rank, k in enumerate(ORDER, start=1):
        angle = 2 * math.pi * k / 16
        unit = (math.cos(angle), math.sin(angle))
        c.add(PathLayer([(0.18 * unit[0], 0.18 * unit[1]), (0.85 * unit[0], 0.85 * unit[1])], role="guide"))
        c.add(TextLayer((1.05 * unit[0], 1.05 * unit[1]), str(rank)))
    c.add(MarkerLayer([(0, 0)], marker=Marker(color="blue", size=36)))
    save(c, "geometry/candidates")


FIGURES: dict[str, Callable[[], None]] = {
    "quickstart/diagram": quickstart_diagram,
    "annotations/gutter": annotations_gutter,
    "annotations/span": annotations_span,
    "labels/regions": labels_regions,
    "labels/points": labels_points,
    "grids/sweep": grids_sweep,
    "geometry/polylabel": geometry_polylabel,
    "geometry/brace": geometry_brace,
    "geometry/spread": geometry_spread,
    "geometry/candidates": geometry_candidates,
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("groups", nargs="*", help="figure groups or names (default: all)")
    parser.add_argument("--list", action="store_true", help="list figure names and exit")
    args = parser.parse_args()
    if args.list:
        print("\n".join(FIGURES))
        return 0
    selected = [
        name for name in FIGURES if not args.groups or any(name == g or name.startswith(g + "/") for g in args.groups)
    ]
    if not selected:
        print(f"no figure matches {args.groups}", file=sys.stderr)
        return 1
    for name in selected:
        FIGURES[name]()
    return 0


if __name__ == "__main__":
    sys.exit(main())

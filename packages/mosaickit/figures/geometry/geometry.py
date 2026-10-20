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
SIZE = CONFIG["size"]
TEXT = CONFIG["text"]

# Every figure shares one configuration: the default theme with its text set to
# the caption size. Overrides apply after the theme, so the general "text" role
# would otherwise beat the theme's smaller axes.note; each text role is listed.
# The look is the EconViz one: grey curves, black axes, guides and points, a white page, set in
# TeX Gyre Pagella when the TeX distribution has it.
INK = FIGURE_STYLE["colors"]["ink"]
GREY = FIGURE_STYLE["colors"]["curve"]
LIGHT = FIGURE_STYLE["colors"]["light"]


def figures_config(edition: str) -> Config:
    text_config = mosaickit_config(
        edition=edition,
        text_size=TEXT["size"],
        note_size=TEXT["note"],
    )
    return Config(
        role_overrides={
            **text_config.role_overrides,
            "title": StyleBundle(text=TextStyle(size=TEXT["size"], color=INK, family=font_family(edition))),
            "axes": StyleBundle(text=TextStyle(size=TEXT["size"], color=INK, family=font_family(edition)), stroke=Stroke(color=INK, width=0.8)),
            "point": StyleBundle(marker=Marker(color=INK, size=16)),
            "primary": StyleBundle(stroke=Stroke(color=GREY, width=2)),
            "secondary": StyleBundle(stroke=Stroke(color=INK, width=1.2)),
            "guide": StyleBundle(stroke=Stroke(color=INK, width=0.6, dash=DashStyle.DASHED)),
        }
    )


FIGURES_CONFIG = figures_config("en")
EDITIONS = ("en", "zh-TW", "zh-CN")
EDITION = "en"  # the language the figures are drawn in; see set_edition()


def set_edition(edition: str) -> None:
    """Draw the following figures in this language: their words come from config/figures.toml, set in a CJK face."""
    global EDITION, FIGURES_CONFIG
    EDITION = edition
    FIGURES_CONFIG = figures_config(edition)


def tr(text: str) -> str:
    """The word in the current edition's language (English words are the table's keys)."""
    return CONFIG.get("labels", {}).get(EDITION, {}).get(text, text)


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
    path = OUT / f"{name}{'' if EDITION == 'en' else '.' + EDITION}.{CONFIG['output']['format']}"
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
    c.add(FillLayer(u, fill=Fill(color=GREY, opacity=0.15), stroke=Stroke(color=INK, width=0.8), z_index=-1))
    c.add(PathLayer(circle(pole, radius), role="guide"))
    c.add(MarkerLayer([pole], marker=Marker(color=INK)))
    c.add(MarkerLayer([centroid], marker=Marker(color=INK, shape="X", size=30)))
    c.add(TextLayer(pole, tr("pole"), anchor="left", offset=(4, 0)))
    c.add(TextLayer(centroid, tr("centroid"), anchor="bottom", offset=(0, 4)))
    save(c, "geometry/polylabel")


def geometry_brace() -> None:
    """Brace outlines over a long span and over one shorter than twice the depth."""
    c = canvas(10, 4, height=1.1)
    for start, end in ((0.5, 6.5), (7.5, 9.0)):
        brace = brace_outline(start, end, base=1, depth=1.6, direction=1, axis="x")
        c.add(PathLayer([(start, 1), (end, 1)], role="guide"))
        c.add(PathLayer(list(brace.points), role="primary"))
        c.add(MarkerLayer([brace.tip], marker=Marker(color=INK)))
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
        c.add(ArrowLayer((before, 1.8), (after, 1.2), stroke=Stroke(color=LIGHT, width=0.6)))
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
    c.add(MarkerLayer([(0, 0)], marker=Marker(color=INK, size=36)))
    save(c, "geometry/candidates")


if __name__ == "__main__":
    register_fonts()
    for edition in EDITIONS:
        set_edition(edition)
        geometry_polylabel()
        geometry_brace()
        geometry_spread()
        geometry_candidates()

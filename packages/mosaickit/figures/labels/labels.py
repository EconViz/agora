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


def register_font() -> str | None:
    """TeX Gyre Pagella from the TeX distribution, or None to keep the default typeface."""
    import subprocess

    from matplotlib import font_manager

    try:
        texmf = subprocess.run(
            ["kpsewhich", "-var-value", "TEXMFDIST"], capture_output=True, text=True, check=True
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return None
    found = False
    for style in ("regular", "italic", "bold"):
        path = Path(texmf) / "fonts/opentype/public/tex-gyre" / f"texgyrepagella-{style}.otf"
        if path.exists():
            font_manager.fontManager.addfont(str(path))
            found = True
    if not found:
        return None
    matplotlib.rcParams.update({"mathtext.fontset": "custom", "mathtext.rm": "TeX Gyre Pagella",
                                "mathtext.it": "TeX Gyre Pagella:italic", "mathtext.bf": "TeX Gyre Pagella:bold"})
    return "TeX Gyre Pagella"


CONFIG = tomllib.loads((ROOT / "config" / "figures.toml").read_text())
OUT = ROOT / CONFIG["output"]["dir"]
SIZE = CONFIG["size"]
TEXT = CONFIG["text"]

# Every figure shares one configuration: the default theme with its text set to
# the caption size. Overrides apply after the theme, so the general "text" role
# would otherwise beat the theme's smaller axes.note; each text role is listed.
# The look is the EconViz one: grey curves, black axes, guides and points, a white page, set in
# TeX Gyre Pagella when the TeX distribution has it.
INK, GREY, LIGHT = "#1a1a1a", "#8c8c8c", "#b8b8b8"
FONT = register_font()
def figures_config(family: str | None) -> Config:
    return Config(
        role_overrides={
            "text": StyleBundle(text=TextStyle(size=TEXT["size"], color=INK, family=family)),
            "title": StyleBundle(text=TextStyle(size=TEXT["size"], color=INK, family=family)),
            "axes": StyleBundle(text=TextStyle(size=TEXT["size"], color=INK, family=family), stroke=Stroke(color=INK, width=0.8)),
            "axes.note": StyleBundle(text=TextStyle(size=TEXT["note"], color=INK, family=family)),
            "point": StyleBundle(marker=Marker(color=INK, size=16)),
            "primary": StyleBundle(stroke=Stroke(color=GREY, width=2)),
            "secondary": StyleBundle(stroke=Stroke(color=INK, width=1.2)),
            "guide": StyleBundle(stroke=Stroke(color=INK, width=0.6, dash=DashStyle.DASHED)),
        }
    )


FIGURES_CONFIG = figures_config(FONT)
EDITIONS = ("en", "zh-TW", "zh-CN")
EDITION = "en"  # the language the figures are drawn in; see set_edition()


def set_edition(edition: str) -> None:
    """Draw the following figures in this language: their words come from config/figures.toml, set in a CJK face."""
    global EDITION, FIGURES_CONFIG
    EDITION = edition
    FIGURES_CONFIG = figures_config(CONFIG["fonts"].get("cjk", {}).get(edition, FONT))


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








def labels_regions() -> None:
    """A region labelled inside, and a thin one labelled by a callout."""
    c = canvas().extend(quadrant_axes(10, 10))
    c.add(FillLayer([(0, 0), (0, 8), (6, 0)], id="wide", fill=Fill(color=GREY, opacity=0.18), z_index=-1))
    c.add(FillLayer([(6, 0), (0, 8), (0, 8.8), (6.6, 0)], id="thin", fill=Fill(color=INK, opacity=0.25), z_index=-1))
    c.add(PathLayer([(0, 8), (6, 0)], role="primary"))
    c.add(PathLayer([(0, 8.8), (6.6, 0)], role="secondary"))
    c.add(RegionLabelLayer("wide", tr("Feasible")))
    c.add(RegionLabelLayer("thin", tr("Slack")))
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


if __name__ == "__main__":
    for edition in EDITIONS:
        set_edition(edition)
        labels_regions()
        labels_points()

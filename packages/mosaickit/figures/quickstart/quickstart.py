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


def font_file(name: str) -> Path:
    """A font file of agora/fonts or of the TeX distribution."""
    import subprocess

    dirs = [ROOT.parent.parent / "fonts"]
    try:
        texmf = subprocess.run(
            ["kpsewhich", "-var-value", "TEXMFDIST"], capture_output=True, text=True, check=True
        ).stdout.strip()
        dirs.extend(Path(texmf) / rel for rel in CONFIG["fonts"]["texmf_dirs"])
    except (OSError, subprocess.CalledProcessError):
        pass
    found = next((d / name for d in dirs if (d / name).exists()), None)
    if found is None:
        raise SystemExit(f"font file {name} not found")
    return found


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


def figures_config(edition: str) -> Config:
    """The figures' configuration: the sans slot holds the edition's font files (Pagella, or Noto Serif)."""
    from matplotlib import font_manager
    from mosaickit import MathFont, TextFonts

    names = CONFIG["fonts"]["text"].get(edition, CONFIG["fonts"]["text"]["en"])
    faces = [font_file(name) for name in names]
    # Matplotlib still sets titles, legends and words mixed with $math$; give it the same faces
    for path in faces:
        font_manager.fontManager.addfont(str(path))
    latin = font_manager.FontProperties(fname=str(font_file(CONFIG["fonts"]["text"]["en"][0]))).get_name()
    matplotlib.rcParams.update({
        "font.family": [font_manager.FontProperties(fname=str(faces[0])).get_name()],
        "mathtext.fontset": "custom", "mathtext.rm": latin,
        "mathtext.it": f"{latin}:italic", "mathtext.bf": f"{latin}:bold",
    })
    return Config(
        fonts=TextFonts(sans=faces),
        math_font=MathFont(font_file(CONFIG["fonts"]["math"])),
        role_overrides={
            "text": StyleBundle(text=TextStyle(size=TEXT["size"], color=INK)),
            "title": StyleBundle(text=TextStyle(size=TEXT["size"], color=INK)),
            "axes": StyleBundle(text=TextStyle(size=TEXT["size"], color=INK), stroke=Stroke(color=INK, width=0.8)),
            "axes.note": StyleBundle(text=TextStyle(size=TEXT["note"], color=INK)),
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


def quickstart_diagram() -> None:
    """The README example: axes, a shaded region, a curve, a marked point."""
    c = canvas().extend(quadrant_axes(10, 10))
    c.add(FillLayer([(1, 1), (1, 7), (8, 1)], fill=Fill(color=GREY, opacity=0.12), z_index=-1))
    c.add(PathLayer([(1, 8), (2, 5), (4, 3), (7, 1.5), (9, 1)], stroke=Stroke(color=GREY, width=2), id="curve"))
    c.add(MarkerLayer([(4, 3)], id="point"))
    c.add(TextLayer((4, 3), "A", offset=(6, 6)))
    save(c, "quickstart/diagram")


if __name__ == "__main__":
    for edition in EDITIONS:
        set_edition(edition)
        quickstart_diagram()

"""Generate the figures used by the manual, in the EconViz house style.

Run from the manual's directory (principle-viz/):

    uv run python scripts/make_figures.py            # all figures
    uv run python scripts/make_figures.py taxes      # one group
    uv run python scripts/make_figures.py --list     # list figure names

Figures carry no titles, so the same files serve every language edition; the
captions are written in Typst. Words inside a figure ("Shortage", "Consumer
surplus", ...) are principle-viz's built-in labels, left as users get them.
"""

from __future__ import annotations

import argparse
import dataclasses
import subprocess
import sys
import tomllib
from collections.abc import Callable
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

from mosaickit import CanvasGrid

from principle_viz import (
    DiscreteDemand,
    DiscreteSupply,
    ExternalityScenario,
    IndividualBenefit,
    Label,
    LoanableFundsScenario,
    MarketFigure,
    PlotTheme,
    PPFGrowthScenario,
    ProductionPossibilitiesFrontier,
    SubsidyScenario,
    SubsidyTo,
    TradeScenario,
    analyze_common_resource,
    analyze_externality,
    analyze_loanable_funds,
    analyze_minimum_wage,
    analyze_ppf,
    analyze_ppf_growth,
    analyze_public_good,
    analyze_trade,
    compare_subsidy_scenario,
    compare_tax_scenario,
    comparative_statics,
    compute_surplus,
    demand_aggregation_figure,
    discrete_demand_aggregation_figure,
    elasticity_revenue_schedule,
    evaluate_price_control,
    line_from_inverse,
    solve_discrete_equilibrium,
    solve_equilibrium,
    solve_tax_equilibrium,
)
from principle_viz.core.controls import PriceControlScenario, PriceControlType
from principle_viz.core.shifts import ShiftScenario, ShiftSpec
from principle_viz.policy.tax import TaxOn, TaxScenario, TaxType
from principle_viz.visuals.market_failures import public_good_canvas
from principle_viz.visuals.ppf import ppf_canvas, ppf_growth_canvas
from principle_viz.visuals.revenue import elasticity_revenue_canvases
from principle_viz.welfare.surplus import (
    compare_surplus,
    outcome_from_control,
    outcome_from_equilibrium,
    outcome_from_subsidy,
    outcome_from_tax,
)

ROOT = Path(__file__).resolve().parent.parent
CONFIG = tomllib.loads((ROOT / "config" / "principle-viz.toml").read_text())
OUT = ROOT / CONFIG["output"]["dir"]
FMT = CONFIG["output"]["format"]
EDITIONS = ("en", "zh-TW", "zh-CN")
EDITION = "en"  # the language the figures are drawn in; see set_edition()


# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------


def font_dirs() -> list[Path]:
    """Where the manual's font files live: agora/fonts and the TeX distribution."""
    dirs = [ROOT.parent.parent / "fonts"]
    try:
        texmf = subprocess.run(
            ["kpsewhich", "-var-value", "TEXMFDIST"],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
        dirs.extend(Path(texmf) / rel for rel in CONFIG["fonts"]["texmf_dirs"])
    except (OSError, subprocess.CalledProcessError):
        pass
    return dirs


def font_file(name: str) -> Path:
    found = next((d / name for d in font_dirs() if (d / name).exists()), None)
    if found is None:
        raise SystemExit(f"font file {name} not found")
    return found


_font_scope = None


def use_manual_fonts(edition: str = "en") -> None:
    """Set the figures in the manual's face: Pagella, or Noto Serif in Chinese, with Pagella Math.

    MosaicKit's `sans` slot, the font of every text style here, is replaced by the files; the
    configuration stays active for the figures drawn after this call.
    """
    global _font_scope
    from mosaickit import MathFont, TextFonts
    from mosaickit.config import current_config, use_config

    names = CONFIG["fonts"]["text"].get(edition, CONFIG["fonts"]["text"]["en"])
    if _font_scope is not None:
        _font_scope.__exit__(None, None, None)
    _font_scope = use_config(
        dataclasses.replace(
            current_config(),
            fonts=TextFonts(sans=[font_file(name) for name in names]),
            math_font=MathFont(font_file(CONFIG["fonts"]["math"])),
        )
    )
    _font_scope.__enter__()
    # Titles, legends and text that mixes words with $math$ are still set by Matplotlib.
    from matplotlib import font_manager

    faces = [font_file(name) for name in names]
    for path in faces:
        font_manager.fontManager.addfont(str(path))
    family = font_manager.FontProperties(fname=str(faces[0])).get_name()
    latin = font_manager.FontProperties(fname=str(font_file(CONFIG["fonts"]["text"]["en"][0]))).get_name()
    matplotlib.rcParams.update({
        "font.family": [family],
        "mathtext.fontset": "custom",
        "mathtext.rm": latin,
        "mathtext.it": f"{latin}:italic",
        "mathtext.bf": f"{latin}:bold",
    })


def scale_text() -> None:
    """Scale every resolved text size by `text_scale`, so labels stay legible at half the text width.

    Line widths are unchanged. Placement measures text through the same styles, so labels still
    avoid each other at the larger size.
    """
    from mosaickit.themes import resolution

    scale = CONFIG["fonts"].get("text_scale", 1.0)
    original = resolution.resolve

    def resolve(*args, **kwargs):
        bundle = original(*args, **kwargs)
        if bundle.text is None or bundle.text.size is None:
            return bundle
        text = dataclasses.replace(bundle.text, size=bundle.text.size * scale)
        return dataclasses.replace(bundle, text=text)

    for name, module in list(sys.modules.items()):
        if name.startswith("mosaickit") and getattr(module, "resolve", None) is original:
            module.resolve = resolve


def localize(value, table):
    """The same value with every string found in *table* replaced; dataclasses, tuples and dicts are rebuilt."""
    if isinstance(value, str):
        return table.get(value, value)
    if dataclasses.is_dataclass(value) and not isinstance(value, type):
        changes = {}
        for field in dataclasses.fields(value):
            old = getattr(value, field.name)
            new = localize(old, table)
            if new is not old and new != old:
                changes[field.name] = new
        return dataclasses.replace(value, **changes) if changes else value
    if isinstance(value, tuple):
        return type(value)(localize(v, table) for v in value) if not hasattr(value, "_fields") else value
    if isinstance(value, list):
        return [localize(v, table) for v in value]
    if isinstance(value, dict):
        return {k: localize(v, table) for k, v in value.items()}
    return value


_original_render = None


def set_edition(edition: str) -> None:
    """Draw the following figures in this language: the words in them are translated and set in a CJK face.

    principle-viz's built-in labels ("Shortage", "Consumer surplus", ...) are English; the table in
    config/principle-viz.toml gives their translations, applied to a figure just before it is drawn.
    """
    global EDITION, _original_render
    from mosaickit.rendering.matplotlib.renderer import MatplotlibRenderer

    EDITION = edition
    table = CONFIG.get("labels", {}).get(edition, {})
    if _original_render is None:
        _original_render = MatplotlibRenderer._draw
        draw = _original_render

        def translated_draw(self, ax, scene, context):  # canvases and grid cells both come through here
            table = CONFIG.get("labels", {}).get(EDITION, {})
            return draw(self, ax, localize(scene, table), localize(context, table))  # the context holds the titles

        MatplotlibRenderer._draw = translated_draw
    use_manual_fonts(edition)


def use_house_colours() -> None:
    """Grey curves, black axes and arrows, grey fills: the EconViz look instead of the colour palette."""
    from principle_viz.visuals import theme

    house = theme.ColorModel(
        name="house",
        axis_color="#1a1a1a",
        label_color="#1a1a1a",
        demand_color="#8c8c8c",
        supply_color="#1a1a1a",
        baseline_color="#1a1a1a",
        shifted_color="#6e6e6e",
        tax_color="#595959",
        control_color="#595959",
        cs_color="#b8b8b8",
        ps_color="#8c8c8c",
        tax_revenue_color="#d9d9d9",
        dwl_color="#595959",
        arrow_color="#1a1a1a",
    )
    theme.DEFAULT_COLOR_MODEL = house  # every PlotTheme() created from here on starts from it
    theme.BUILTIN_COLOR_MODELS["default"] = house  # and so does the "default" palette by name


def out(group: str, name: str) -> Path:
    path = OUT / group / f"{name}{'' if EDITION == 'en' else '.' + EDITION}.{FMT}"
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def market(**kwargs) -> MarketFigure:
    """A MarketFigure without a title (captions are written in Typst)."""
    kwargs.setdefault("title", "")
    return MarketFigure(**kwargs)


# The market used throughout the manual: p = 10 - Q and p = 2 + Q.
DEMAND = line_from_inverse(10.0, -1.0)
SUPPLY = line_from_inverse(2.0, 1.0)


# ---------------------------------------------------------------------------
# Figures, by chapter
# ---------------------------------------------------------------------------










def elasticity_revenue() -> None:
    demand = line_from_inverse(12.0, -1.0)
    schedule = elasticity_revenue_schedule(demand)
    CanvasGrid(elasticity_revenue_canvases(demand, schedule, theme=PlotTheme()), rows=1).save(
        out("elasticity", "revenue")
    )


if __name__ == "__main__":
    for edition in EDITIONS:
        set_edition(edition)
        elasticity_revenue()

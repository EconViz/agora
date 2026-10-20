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

from matplotlib import font_manager
from mosaickit import CanvasGrid, TextStyle
from mosaickit.rendering.matplotlib import fonts as mpl_fonts
from mosaickit.themes import resolution

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
CONFIG = tomllib.loads((ROOT / "config" / "figures.toml").read_text())
OUT = ROOT / CONFIG["output"]["dir"]
FMT = CONFIG["output"]["format"]
FONT = CONFIG["fonts"]["family"]
EDITIONS = ("en", "zh-TW", "zh-CN")
EDITION = "en"  # the language the figures are drawn in; see set_edition()


# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------


def use_manual_fonts() -> None:
    """Set text and math in TeX Gyre Pagella, the manual's body face."""
    try:
        texmf = subprocess.run(
            ["kpsewhich", "-var-value", "TEXMFDIST"],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        texmf = ""
    for rel in CONFIG["fonts"]["texmf_files"]:
        path = Path(texmf) / rel
        if path.exists():
            font_manager.fontManager.addfont(str(path))
    matplotlib.rcParams.update({
        "font.family": [FONT],
        "mathtext.fontset": "custom",
        "mathtext.rm": FONT,
        "mathtext.it": f"{FONT}:italic",
        "mathtext.bf": f"{FONT}:bold",
    })
    # MosaicKit falls back to DejaVu Sans for every text layer whose theme
    # role sets no family (the primitive default every style resolves over);
    # use the manual's face there instead.
    base = resolution.PRIMITIVE_DEFAULT
    resolution.PRIMITIVE_DEFAULT = dataclasses.replace(
        base, text=dataclasses.replace(base.text or TextStyle(), family=FONT)
    )
    # Every label, axis mark and brace text is set through MosaicKit's
    # font_properties(); scale its size there, in each module that imported it
    # (placement measures text through the same function, so labels still
    # avoid each other at the larger size).
    scale = CONFIG["fonts"].get("text_scale", 1.0)
    original = mpl_fonts.font_properties

    def font_properties(style):
        props = original(style)
        props.set_size(props.get_size_in_points() * scale)
        return props

    for name, module in list(sys.modules.items()):
        if name.startswith("mosaickit") and getattr(module, "font_properties", None) is original:
            module.font_properties = font_properties


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
    config/figures.toml gives their translations, applied to a figure just before it is drawn.
    """
    global EDITION, _original_render
    from mosaickit.rendering.matplotlib.renderer import MatplotlibRenderer

    EDITION = edition
    table = CONFIG.get("labels", {}).get(edition, {})
    if _original_render is None:
        _original_render = MatplotlibRenderer.render, MatplotlibRenderer.render_grid
        render, render_grid = _original_render

        def translated_render(self, scene, context):
            return render(self, localize(scene, CONFIG.get("labels", {}).get(EDITION, {})), context)

        def translated_grid(self, grid, cache):
            return render_grid(self, localize(grid, CONFIG.get("labels", {}).get(EDITION, {})), cache)

        MatplotlibRenderer.render, MatplotlibRenderer.render_grid = translated_render, translated_grid
    family = CONFIG["fonts"].get("cjk", {}).get(edition, FONT)
    matplotlib.rcParams["font.family"] = [family]
    base = resolution.PRIMITIVE_DEFAULT
    resolution.PRIMITIVE_DEFAULT = dataclasses.replace(
        base, text=dataclasses.replace(base.text or TextStyle(), family=family)
    )


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


















def price_controls() -> None:
    for name, kind, price in (("ceiling", PriceControlType.CEILING, 4.0), ("floor", PriceControlType.FLOOR, 8.0)):
        result = evaluate_price_control(DEMAND, SUPPLY, PriceControlScenario(kind, price))
        fig = market(x_max=12, y_max=12)
        fig.add_curves(DEMAND, SUPPLY, q_max=10)
        fig.add_price_control(result)
        fig.finalize()
        fig.save(out("controls", name))

    result = evaluate_price_control(DEMAND, SUPPLY, PriceControlScenario(PriceControlType.CEILING, 3.5))
    baseline = outcome_from_equilibrium(solve_equilibrium(DEMAND, SUPPLY))
    delta = compare_surplus(DEMAND, SUPPLY, baseline, outcome_from_control(result))
    fig = market(x_max=12, y_max=12)
    fig.add_curves(DEMAND, SUPPLY, q_max=10)
    fig.add_price_control(result)
    fig.add_welfare(delta.policy)
    fig.finalize()
    fig.save(out("controls", "ceiling_welfare"))


if __name__ == "__main__":
    for edition in EDITIONS:
        set_edition(edition)
        price_controls()

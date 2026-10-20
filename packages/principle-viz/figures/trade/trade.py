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
    path = OUT / group / f"{name}.{FMT}"
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




















def trade() -> None:
    demand = line_from_inverse(12.0, -1.0)
    for name, scenario in (
        ("free_trade_import", TradeScenario(world_price=4)),
        ("tariff", TradeScenario(world_price=4, tariff=2)),
        ("quota", TradeScenario(world_price=4, import_quota=2)),
    ):
        fig = market(x_max=12, y_max=13)
        fig.add_curves(demand, SUPPLY, q_max=11)
        fig.add_trade(analyze_trade(demand, SUPPLY, scenario))
        fig.finalize()
        fig.save(out("trade", name))


if __name__ == "__main__":
    trade()

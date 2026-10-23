"""Generate the figures used by the manual, in the EconViz house style.

Run from the manual's directory (principle-viz/):

    uv run python scripts/make_figures.py            # all figures
    uv run python scripts/make_figures.py taxes      # one group
    uv run python scripts/make_figures.py --list     # list figure names

Figures carry no titles; the captions are written in Typst. Every figure is
drawn once per edition with principle-viz's "manual" palette (the EconViz
greys) and its built-in words ("Shortage", "Consumer surplus", ...) in that
edition's language, through PlotTheme(language=...).
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

from mosaickit import CanvasGrid, TextFonts

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
from principle_viz.i18n import translate
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
EDITION = "en"  # the language the figures are drawn in; see set_edition() and theme()


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


def scale_text() -> None:
    """Scale every resolved text size by `text_scale`, so labels stay legible at half the text width.

    Line widths are unchanged. Placement measures text through the same styles, so labels still
    avoid each other at the larger size. Calling it again does nothing.
    """
    from mosaickit.themes import resolution

    scale = CONFIG["fonts"].get("text_scale", 1.0)
    original = resolution.resolve
    if getattr(original, "scaled", False):
        return

    def resolve(*args, **kwargs):
        bundle = original(*args, **kwargs)
        if bundle.text is None or bundle.text.size is None:
            return bundle
        text = dataclasses.replace(bundle.text, size=bundle.text.size * scale)
        return dataclasses.replace(bundle, text=text)

    resolve.scaled = True
    for name, module in list(sys.modules.items()):
        if name.startswith("mosaickit") and getattr(module, "resolve", None) is original:
            module.resolve = resolve


def theme(palette: str = "manual") -> PlotTheme:
    """The manual's look in the current edition: the house greys, the built-in words translated.

    Text is set in Pagella, or Noto Serif in the Chinese editions, and math in Pagella Math.
    """
    names = CONFIG["fonts"]["text"].get(EDITION, CONFIG["fonts"]["text"]["en"])
    return PlotTheme.from_palette(
        palette,
        language=EDITION,
        font="serif",
        fonts=TextFonts(serif=[font_file(name) for name in names]),
        math_font=font_file(CONFIG["fonts"]["math"]),
    )


def use_math_font() -> None:
    """Pagella for the $math$ in text that mixes words and math, which Matplotlib still sets."""
    from matplotlib import font_manager

    faces = [font_file(name) for name in CONFIG["fonts"]["text"]["en"]]  # regular, italic, bold
    for path in faces:
        font_manager.fontManager.addfont(str(path))
    latin = font_manager.FontProperties(fname=str(faces[0])).get_name()
    matplotlib.rcParams.update({
        "mathtext.fontset": "custom",
        "mathtext.rm": latin,
        "mathtext.it": f"{latin}:italic",
        "mathtext.bf": f"{latin}:bold",
    })


def set_edition(edition: str) -> None:
    """Draw the following figures in this language (see theme())."""
    global EDITION
    EDITION = edition
    scale_text()
    use_math_font()


def text(english: str) -> str:
    """A label the script sets itself, in the current edition; principle-viz translates only its own."""
    return translate(english, EDITION)


def out(group: str, name: str) -> Path:
    path = OUT / group / f"{name}{'' if EDITION == 'en' else '.' + EDITION}.{FMT}"
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def market(**kwargs) -> MarketFigure:
    """A MarketFigure without a title (captions are written in Typst), in the manual's theme."""
    kwargs.setdefault("title", "")
    kwargs.setdefault("theme", theme(kwargs.pop("palette", "manual")))
    return MarketFigure(**kwargs)


# The market used throughout the manual: p = 10 - Q and p = 2 + Q.
DEMAND = line_from_inverse(10.0, -1.0)
SUPPLY = line_from_inverse(2.0, 1.0)


# ---------------------------------------------------------------------------
# Figures, by chapter
# ---------------------------------------------------------------------------
























def factor_markets() -> None:
    labor_demand = line_from_inverse(12, -1)
    labor = analyze_minimum_wage(labor_demand, SUPPLY, minimum_wage=9)
    fig = market(x_max=11, y_max=14, x_label="L", y_label="w")
    fig.add_curves(labor_demand, SUPPLY, q_max=10, demand_label="$D_L$", supply_label="$S_L$")
    fig.add_minimum_wage(labor)
    fig.finalize()
    fig.save(out("factor", "minimum_wage"))

    savings = line_from_inverse(2, 0.5)
    investment = line_from_inverse(12, -0.5)
    funds = analyze_loanable_funds(savings, investment, LoanableFundsScenario(government_borrowing=4))
    fig = market(x_max=18, y_max=14, y_label="r")
    fig.add_curves(investment, savings, q_max=17, demand_label="$D_0$", supply_label="$S_0$")
    fig.add_loanable_funds(funds)
    fig.finalize()
    fig.save(out("factor", "loanable_funds"))


if __name__ == "__main__":
    for edition in EDITIONS:
        set_edition(edition)
        factor_markets()

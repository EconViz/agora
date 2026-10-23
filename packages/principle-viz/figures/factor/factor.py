"""Generate the figures used by the manual, in the EconViz house style.

Run from the manual's directory (principle-viz/):

    uv run python scripts/make_figures.py            # all figures
    uv run python scripts/make_figures.py taxes      # one group
    uv run python scripts/make_figures.py --list     # list figure names

Figures carry no titles; the captions are written in Typst. Every figure is
drawn once per edition from that edition's settings file, config/econ-viz.toml,
econ-viz.zh-TW.toml or econ-viz.zh-CN.toml, which principle-viz loads itself
(Config.load(...).use()): the shared "manual" theme (the EconViz greys), the
edition's fonts and principle-viz's built-in words ("Shortage", "Consumer
surplus", ...) in the edition's language.
"""

from __future__ import annotations

import argparse
import dataclasses
import shutil
import subprocess
import sys
import tempfile
from collections.abc import Callable
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

from mosaickit import CanvasGrid

from principle_viz import (
    Config,
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
    default_theme,
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
OUT = ROOT / "figures"
FMT = "svg"  # vector; Typst embeds SVG directly
EDITIONS = ("en", "zh-TW", "zh-CN")
EDITION = "en"  # the edition the figures are drawn for; see set_edition()
# A figure is drawn at 6 x 6 in and set at about half the text width, which shrinks its
# 10-11 pt labels; every text size is scaled by this factor (line widths are unchanged).
TEXT_SCALE = 1.5
# Where the font files named in config/econ-viz*.toml live besides agora/fonts (relative to TEXMFDIST).
TEXMF_DIRS = ["fonts/opentype/public/tex-gyre", "fonts/opentype/public/tex-gyre-math"]


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
        dirs.extend(Path(texmf) / rel for rel in TEXMF_DIRS)
    except (OSError, subprocess.CalledProcessError):
        pass
    return dirs


# The settings files name their fonts relative to themselves, so they are read from this directory,
# which links every font file of agora/fonts and the TeX directories; it lasts while figures are drawn.
SETTINGS_DIR = tempfile.TemporaryDirectory(prefix="principle-viz-manual-")


def settings(edition: str) -> Config:
    """The edition's settings file, config/econ-viz[.<edition>].toml, read by principle-viz."""
    tmp = Path(SETTINGS_DIR.name)
    if not any(tmp.iterdir()):
        for directory in font_dirs():
            for font in directory.glob("*.[ot]t[fc]"):
                if not (tmp / font.name).exists():
                    (tmp / font.name).symlink_to(font)
    name = "econ-viz.toml" if edition == "en" else f"econ-viz.{edition}.toml"
    shutil.copy(ROOT / "config" / name, tmp / name)
    return Config.load(tmp / name)


def scale_text() -> None:
    """Scale every resolved text size by TEXT_SCALE, so labels stay legible at half the text width.

    Line widths are unchanged. Placement measures text through the same styles, so labels still
    avoid each other at the larger size. Calling it again does nothing.
    """
    from mosaickit.themes import resolution


    original = resolution.resolve
    if getattr(original, "scaled", False):
        return

    def resolve(*args, **kwargs):
        bundle = original(*args, **kwargs)
        if bundle.text is None or bundle.text.size is None:
            return bundle
        text = dataclasses.replace(bundle.text, size=bundle.text.size * TEXT_SCALE)
        return dataclasses.replace(bundle, text=text)

    resolve.scaled = True
    for name, module in list(sys.modules.items()):
        if name.startswith("mosaickit") and getattr(module, "resolve", None) is original:
            module.resolve = resolve


def theme(palette: str | None = None) -> PlotTheme:
    """The manual's look in the current edition, as loaded by set_edition().

    `palette` swaps in another built-in colour model and keeps the edition's fonts and language.
    """
    loaded = default_theme()
    if palette is None:
        return loaded
    return PlotTheme.from_palette(
        palette, language=loaded.language, font=loaded.font, fonts=loaded.fonts, math_font=loaded.math_font
    )


def use_math_font() -> None:
    """Pagella for the $math$ in text that mixes words and math, which Matplotlib still sets."""
    from matplotlib import font_manager

    faces = settings("en").theme.fonts.serif  # Pagella regular, italic, bold, bold italic
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
    """Draw the following figures with this edition's settings file (see theme())."""
    global EDITION
    EDITION = edition
    settings(edition).use()
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
    kwargs.setdefault("theme", theme(kwargs.pop("palette", None)))
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

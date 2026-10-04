"""Generate the figures used by the manual, in principle-viz's default style.

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


def quickstart_equilibrium() -> None:
    eq = solve_equilibrium(DEMAND, SUPPLY)
    fig = market(x_max=12, y_max=12)
    fig.add_curves(DEMAND, SUPPLY, q_max=10)
    fig.add_equilibrium(eq)
    fig.finalize()
    fig.save(out("quickstart", "equilibrium"))


def markets_shifts() -> None:
    for name, scenario in (
        ("demand_increase", ShiftScenario(demand_shift=ShiftSpec(delta_intercept=3.0))),
        ("supply_decrease", ShiftScenario(supply_shift=ShiftSpec(delta_intercept=3.0))),
    ):
        result = comparative_statics(DEMAND, SUPPLY, scenario)
        fig = market(x_max=12, y_max=14)
        fig.add_curves(DEMAND, SUPPLY, q_max=10, demand_label="$D_0$", supply_label="$S_0$")
        fig.add_comparative_statics(result, q_max=10)
        fig.finalize()
        fig.save(out("markets", f"shift_{name}"))


def discrete_market() -> None:
    demand = DiscreteDemand((11, 9, 7, 5, 3))
    supply = DiscreteSupply((1, 3, 5, 8, 10))
    eq = solve_discrete_equilibrium(demand, supply)
    fig = market(x_max=5.5, y_max=12)
    fig.add_discrete_curves(demand, supply)
    fig.add_discrete_equilibrium(eq)
    fig.finalize()
    fig.save(out("discrete", "market"))


def aggregation_figures() -> None:
    demands = {"A": line_from_inverse(10.0, -2.0), "B": line_from_inverse(6.0, -0.5)}
    demand_aggregation_figure(demands, price=4.0, link_price=True).save(
        out("aggregation", "market_demand")
    )
    discrete_demand_aggregation_figure(
        {"A": DiscreteDemand((10, 7, 4)), "B": DiscreteDemand((8, 5, 2))}, price=6.0
    ).save(out("aggregation", "discrete_market_demand"))


def elasticity_revenue() -> None:
    demand = line_from_inverse(12.0, -1.0)
    schedule = elasticity_revenue_schedule(demand)
    CanvasGrid(elasticity_revenue_canvases(demand, schedule, theme=PlotTheme()), rows=1).save(
        out("elasticity", "revenue")
    )


def welfare_equilibrium() -> None:
    eq = solve_equilibrium(DEMAND, SUPPLY)
    surplus = compute_surplus(DEMAND, SUPPLY, outcome_from_equilibrium(eq))
    fig = market(x_max=12, y_max=12)
    fig.add_curves(DEMAND, SUPPLY, q_max=10)
    fig.add_welfare(surplus)
    fig.add_equilibrium(eq)
    fig.finalize()
    fig.save(out("welfare", "equilibrium"))


def taxes() -> None:
    supply0 = line_from_inverse(0.0, 1.0)
    for name, scenario in (
        ("per_unit_producer", TaxScenario(TaxType.PER_UNIT_TAX, 2.5, TaxOn.PRODUCER)),
        ("ad_valorem_consumer", TaxScenario(TaxType.AD_VALOREM_TAX, 0.35, TaxOn.CONSUMER)),
    ):
        fig = market(x_max=12, y_max=13)
        fig.add_curves(DEMAND, supply0, q_max=10)
        fig.add_tax_transform(DEMAND, supply0, scenario, q_max=10)
        fig.finalize()
        fig.save(out("taxes", name))

    scenario = TaxScenario(TaxType.PER_UNIT_TAX, 3.0, TaxOn.PRODUCER)
    baseline = outcome_from_equilibrium(solve_equilibrium(DEMAND, SUPPLY))
    taxed = outcome_from_tax(solve_tax_equilibrium(DEMAND, SUPPLY, scenario))
    delta = compare_surplus(DEMAND, SUPPLY, baseline, taxed)
    fig = market(x_max=12, y_max=12)
    fig.add_curves(DEMAND, SUPPLY, q_max=10)
    fig.add_welfare(delta.policy)
    fig.add_tax_comparison(compare_tax_scenario(DEMAND, SUPPLY, scenario))
    fig.finalize()
    fig.save(out("taxes", "welfare"))


def subsidy() -> None:
    demand = line_from_inverse(12.0, -1.0)
    comparison = compare_subsidy_scenario(demand, SUPPLY, SubsidyScenario(3.0, SubsidyTo.PRODUCER))
    baseline = outcome_from_equilibrium(solve_equilibrium(demand, SUPPLY))
    welfare = compare_surplus(demand, SUPPLY, baseline, outcome_from_subsidy(comparison.post_subsidy))
    fig = market(
        x_max=12,
        y_max=13,
        visibility={
            "market.subsidy.expenditure.label": False,
            "market.subsidy.wedge.label": False,
            "market.subsidy.wedge.mark.p_0": False,
            "market.subsidy.wedge.brace": False,
        },
    )
    fig.add_curves(demand, SUPPLY, q_max=11)
    fig.add_welfare(welfare.policy, regions=("dwl",))
    fig.add_subsidy_comparison(comparison)
    fig.finalize()
    fig.save(out("taxes", "subsidy"))


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


def market_failures() -> None:
    demand = line_from_inverse(12.0, -1.0)
    for name, scenario in (
        ("negative_externality", ExternalityScenario(marginal_external_cost=2)),
        ("positive_externality", ExternalityScenario(marginal_external_benefit=2)),
    ):
        fig = market(x_max=11, y_max=14)
        fig.add_curves(demand, SUPPLY, q_max=10)
        fig.add_externality(analyze_externality(demand, SUPPLY, scenario))
        fig.finalize()
        fig.save(out("failures", name))

    common = analyze_common_resource(demand, SUPPLY, marginal_congestion_cost=3)
    fig = market(x_max=11, y_max=14)
    fig.add_curves(demand, SUPPLY, q_max=10, demand_label="$MB$", supply_label="$MPC$")
    fig.add_common_resource(common)
    fig.finalize()
    fig.save(out("failures", "common_resource"))

    public = analyze_public_good(
        (
            IndividualBenefit("$MB_A$", line_from_inverse(8, -1)),
            IndividualBenefit("$MB_B$", line_from_inverse(6, -1)),
        ),
        line_from_inverse(5, 0),
    )
    public_good_canvas(public, theme=PlotTheme()).save(out("failures", "public_good"))


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


def ppf() -> None:
    frontier = ProductionPossibilitiesFrontier(
        x_intercept=10, y_intercept=8, curvature=2,
        x_good="Consumer goods", y_good="Capital goods",
    )
    analysis = analyze_ppf(
        frontier,
        points=((6, frontier.y_at(6), "A"), (4, 3, "B"), (7, 6, "C")),
    )
    ppf_canvas(analysis, theme=PlotTheme()).save(out("ppf", "points"))
    growth = analyze_ppf_growth(frontier, PPFGrowthScenario(x_growth_rate=0.2, y_growth_rate=0.1))
    ppf_growth_canvas(growth, theme=PlotTheme()).save(out("ppf", "growth"))


def figure_options() -> None:
    eq = solve_equilibrium(DEMAND, SUPPLY)
    fig = market(
        x_max=12,
        y_max=12,
        labels={"market.demand.label": Label(text="Demand"), "market.supply.label": Label(text="Supply")},
    )
    fig.add_curves(DEMAND, SUPPLY, q_max=10)
    fig.add_equilibrium(eq)
    fig.configure_label("market.equilibrium.label", text="$E$")
    fig.hide("axes.origin.label")
    fig.finalize()
    fig.save(out("figures", "labels"))

    fig = market(x_max=12, y_max=12, palette="monochrome")
    surplus = compute_surplus(DEMAND, SUPPLY, outcome_from_equilibrium(eq))
    fig.add_curves(DEMAND, SUPPLY, q_max=10)
    fig.add_welfare(surplus)
    fig.add_equilibrium(eq)
    fig.finalize()
    fig.save(out("figures", "monochrome"))


FIGURES: dict[str, list[Callable[[], None]]] = {
    "quickstart": [quickstart_equilibrium],
    "markets": [markets_shifts],
    "discrete": [discrete_market],
    "aggregation": [aggregation_figures],
    "elasticity": [elasticity_revenue],
    "welfare": [welfare_equilibrium],
    "taxes": [taxes, subsidy],
    "controls": [price_controls],
    "trade": [trade],
    "failures": [market_failures],
    "factor": [factor_markets],
    "ppf": [ppf],
    "figures": [figure_options],
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("groups", nargs="*", help="figure groups to draw (default: all)")
    parser.add_argument("--list", action="store_true", help="list figure groups and exit")
    args = parser.parse_args()
    if args.list:
        for group, funcs in FIGURES.items():
            print(group + ": " + ", ".join(f.__name__ for f in funcs))
        return 0
    unknown = set(args.groups) - set(FIGURES)
    if unknown:
        parser.error(f"unknown group(s): {', '.join(sorted(unknown))}")
    use_manual_fonts()
    for group in args.groups or FIGURES:
        for func in FIGURES[group]:
            func()
            print(f"{group}: {func.__name__}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

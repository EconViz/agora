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
import sys
import tomllib
from collections.abc import Callable
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

from mosaickit import CanvasGrid, use_config

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

def normalize_svg(path: str | Path) -> None:
    """Remove renderer-only line-end spaces while preserving SVG content."""
    path = Path(path)
    lines = path.read_text().splitlines()
    path.write_text("\n".join(line.rstrip() for line in lines) + "\n")

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
FMT = CONFIG["output"]["format"]
EDITIONS = ("en", "zh-TW", "zh-CN")
EDITION = "en"  # the language the figures are drawn in; see set_edition()


# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------


def set_edition(edition: str):
    """Draw the following figures in this language: the words in them are translated and set in a CJK face.

    principle-viz's built-in labels ("Shortage", "Consumer surplus", ...) are English; the table in
    config/figures.toml gives their translations, applied to a figure just before it is drawn.
    """
    global EDITION
    EDITION = edition
    table = CONFIG.get("labels", {}).get(edition, {})
    renderer = LocalizedMatplotlibRenderer(table, family=font_family(edition))
    return scaled_mosaickit_config(
        PlotTheme().to_mosaickit(),
        scale=CONFIG["text"]["scale"],
        edition=edition,
        renderer=renderer,
    )


def use_house_colours() -> None:
    """Grey curves, black axes and arrows, grey fills: the EconViz look instead of the colour palette."""
    from principle_viz.visuals import theme

    colors = FIGURE_STYLE["colors"]
    house = theme.ColorModel(
        name="house",
        axis_color=colors["ink"],
        label_color=colors["ink"],
        demand_color=colors["curve"],
        supply_color=colors["ink"],
        baseline_color=colors["ink"],
        shifted_color="#6e6e6e",
        tax_color=colors["dark"],
        control_color=colors["dark"],
        cs_color=colors["light"],
        ps_color=colors["curve"],
        tax_revenue_color="#d9d9d9",
        dwl_color=colors["dark"],
        arrow_color=colors["ink"],
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


if __name__ == "__main__":
    register_fonts()
    use_house_colours()
    for edition in EDITIONS:
        with use_config(set_edition(edition)):
            ppf()
    for path in OUT.rglob("*.svg"):
        normalize_svg(path)

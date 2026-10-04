"""Generate the figures used by the manual, in utility-viz's default theme.

Run from the project root:

    uv run python scripts/make_figures.py            # all figures
    uv run python scripts/make_figures.py models     # one group
    uv run python scripts/make_figures.py --list     # list figure names

Fonts and sizes come from config/figures.toml. Figures carry no titles, legends or
other prose, so the same files serve every language edition; captions are
written in Typst.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
import tomllib
from collections.abc import Callable
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
# Negative utility levels (e.g. Satiation) must not switch to dashed contours.
matplotlib.rcParams["contour.negative_linestyle"] = "solid"

import matplotlib.pyplot as plt
import numpy as np
from matplotlib import font_manager

from utility_viz import (
    ArrowStyle,
    Canvas,
    DecompositionMethod,
    DemandDiagram,
    EdgeworthBox,
    Figure,
    IncomePath,
    Label,
    Layout,
    LinearBudget,
    LineStyle,
    PricePath,
    themes,
    levels,
    parse_latex,
    solve,
)
from utility_viz.models import (
    CES,
    CobbDouglas,
    CustomUtility,
    Haagsma,
    Leontief,
    MultiGoodCD,
    PerfectSubstitutes,
    QuasiLinear,
    Satiation,
    StoneGeary,
    Translog,
)
from utility_viz import decompose_price_effect

ROOT = Path(__file__).resolve().parent.parent
CONFIG = tomllib.loads((ROOT / "config" / "figures.toml").read_text())

OUT = ROOT / CONFIG["output"]["dir"]
FMT = CONFIG["output"]["format"]
SIZE = tuple(CONFIG["canvas"]["size"])
FONT = CONFIG["canvas"]["font"]
# utility-viz's own default theme, so the manual shows what users get.
THEME = themes.default

# Since econ-viz 1.8, Label(fontsize=...) overrides the theme's fixed 12pt point
# labels (add_equilibrium's "x^*", add_point's text) without touching their
# default position, offset or text. Size set in config/figures.toml; the
# equilibrium "x^*" always sits to the right of its point.
LABEL_SIZE = CONFIG["canvas"]["label_fontsize"]
EQ_LABEL_OFFSET = 10  # points from the equilibrium dot
EQ_LABEL = Label(fontsize=LABEL_SIZE, position="right", offset=EQ_LABEL_OFFSET)


# ---------------------------------------------------------------------------
# Setup helpers
# ---------------------------------------------------------------------------


def register_fonts() -> None:
    """Make the TeX Gyre fonts from the TeX distribution visible to matplotlib."""
    try:
        texmf = subprocess.run(
            ["kpsewhich", "-var-value", "TEXMFDIST"],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return
    for rel in CONFIG["fonts"]["texmf_files"]:
        path = Path(texmf) / rel
        if path.exists():
            font_manager.fontManager.addfont(str(path))
    # Canvas only applies font/math_font to figures it creates itself; every
    # figure here passes its own fig/ax, so set the fonts globally instead.
    matplotlib.rcParams["font.family"] = FONT
    # mathtext has no Pagella Math, but its "custom" set can take Pagella's
    # own upright/italic/bold cuts, so x, y and x^* match the text face.
    matplotlib.rcParams["mathtext.fontset"] = "custom"
    matplotlib.rcParams["mathtext.rm"] = "TeX Gyre Pagella"
    matplotlib.rcParams["mathtext.it"] = "TeX Gyre Pagella:italic"
    matplotlib.rcParams["mathtext.bf"] = "TeX Gyre Pagella:bold"


def canvas(**kwargs) -> Canvas:
    """A Canvas on a figure of the configured size, in the manual's style."""
    fig, ax = plt.subplots(figsize=kwargs.pop("figsize", SIZE))
    kwargs.setdefault("x_label", "x")
    kwargs.setdefault("y_label", "y")
    return Canvas(fig=fig, ax=ax, theme=THEME, font=FONT, **kwargs)


def panels(
    n: int, width: float = 2.6, height: float = 2.8, *, wspace: float | None = None, **kwargs
) -> list[Canvas]:
    """A row of small Canvas panels with enough room for axis-end labels."""
    fig, axes = plt.subplots(1, n, figsize=(width * n, height))
    # Canvas puts x/y labels just outside the axis arrowheads.  With four
    # panels in one row, Matplotlib's default spacing lets one panel's `x`
    # run into the next panel's origin or `y`.  Give dense rows more air; the
    # manual scales the whole SVG down afterwards, so the final figure stays
    # within the text block.
    if wspace is None:
        wspace = 0.62 if n >= 4 else 0.38
    fig.subplots_adjust(wspace=wspace)
    kwargs.setdefault("x_label", "x")
    kwargs.setdefault("y_label", "y")
    return [
        Canvas(fig=fig, ax=ax, theme=THEME, font=FONT,
               **{k: (v[i] if isinstance(v, list) else v) for k, v in kwargs.items()})
        for i, ax in enumerate(axes)
    ]


def save(fig: plt.Figure, name: str) -> None:
    path = OUT / f"{name}.{FMT}"
    path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(
        path,
        format=FMT,
        bbox_inches="tight",
        pad_inches=0.04,
        transparent=True,
        metadata={"Date": None},
    )
    plt.close(fig)
    print(f"  {path.relative_to(ROOT)}")


# ---------------------------------------------------------------------------
# Shared example state (matches the examples printed in the manual)
# ---------------------------------------------------------------------------

CD = CobbDouglas(alpha=0.5, beta=0.5)
CD_EQ = solve(CD, px=2.0, py=3.0, income=30.0)

FIGURES: dict[str, Callable[[], None]] = {}


def figure(name: str):
    def register(fn: Callable[[], None]) -> Callable[[], None]:
        FIGURES[name] = fn
        return fn
    return register


# ---------------------------------------------------------------------------
# Canvas
# ---------------------------------------------------------------------------

_CANVAS_STEPS = {
    "add_utility": lambda c: c,
    "add_budget": lambda c: c.add_budget(2.0, 3.0, 30.0, fill=True),
    "add_equilibrium": lambda c: (
        c.add_budget(2.0, 3.0, 30.0, fill=True).add_equilibrium(CD_EQ, label=EQ_LABEL)
    ),
    "add_ray": lambda c: (
        c.add_budget(2.0, 3.0, 30.0)
        .add_equilibrium(CD_EQ, label=EQ_LABEL)
        .add_ray(CD_EQ.y / CD_EQ.x)
    ),
    "add_point": lambda c: (
        c.add_budget(2.0, 3.0, 30.0)
        .add_point(12.0, 2.0, label=Label(text="A", fontsize=LABEL_SIZE))
    ),
    "show_save": lambda c: (
        c.add_budget(2.0, 3.0, 30.0, fill=True)
        .add_equilibrium(CD_EQ, show_ray=True, label=EQ_LABEL)
    ),
}

for _name, _step in _CANVAS_STEPS.items():
    def _draw(step=_step, name=_name) -> None:
        c = canvas(x_max=20, y_max=15)
        step(c.add_utility(CD, levels=levels.around(CD_EQ.utility, n=3)))
        save(c.fig, f"canvas/{name}")
    figure(f"canvas/{_name}")(_draw)


@figure("canvas/ic_hierarchy")
def _() -> None:
    lvls = levels.around(CD_EQ.utility, n=5)
    cs = panels(2, width=3.0, height=2.8, x_max=20, y_max=15)

    cs[0].add_utility(CD, levels=lvls)
    cs[0].add_budget(2.0, 3.0, 30.0).add_equilibrium(CD_EQ, label=EQ_LABEL)

    cs[1].add_utility(
        CD,
        levels=lvls,
        highlight_level=CD_EQ.utility,
        show_ic_labels=True,
        label_style="ordinal",
    )
    cs[1].add_budget(2.0, 3.0, 30.0).add_equilibrium(CD_EQ, label=EQ_LABEL)

    save(cs[0].fig, "canvas/ic_hierarchy")


@figure("canvas/line_styles")
def _() -> None:
    styles = [LineStyle.SOLID, LineStyle.DASHED, LineStyle.DOTTED, LineStyle.DASHDOT]
    cs = panels(4, width=1.9, height=2.0, title=[s.value for s in styles],
                x_line_style=styles, y_line_style=styles)
    save(cs[0].fig, "canvas/line_styles")


@figure("canvas/arrow_styles")
def _() -> None:
    styles = [ArrowStyle.SIMPLE, ArrowStyle.TRIANGLE, ArrowStyle.FANCY, ArrowStyle.WEDGE]
    cs = panels(4, width=1.9, height=2.0, title=[s.name for s in styles],
                x_arrow_style=styles, y_arrow_style=styles)
    save(cs[0].fig, "canvas/arrow_styles")


# ---------------------------------------------------------------------------
# Figures & demand diagrams
# ---------------------------------------------------------------------------


@figure("consumer/side_by_side")
def _() -> None:
    fig = Figure(
        Layout.SIDE_BY_SIDE, x_max=20, y_max=15, x_label="x", y_label="y",
        shared_y=True, theme=THEME, font=FONT,
        figsize=(2 * SIZE[0], SIZE[1] * 0.85),
    )
    cases = [
        (CobbDouglas(alpha=0.5, beta=0.5), 2.0, 3.0, 30.0, r"$p_x=2$"),
        (CobbDouglas(alpha=0.3, beta=0.7), 4.0, 3.0, 30.0, r"$p_x=4$"),
    ]
    for idx, (model, px, py, income, title) in enumerate(cases):
        eq = solve(model, px=px, py=py, income=income)
        panel = fig[idx]
        panel.ax.set_title(title)
        panel.add_utility(model, levels=levels.around(eq.utility, n=5))
        panel.add_budget(px, py, income, fill=True)
        panel.add_equilibrium(eq, show_ray=True, label=EQ_LABEL)
    save(fig.fig, "consumer/side_by_side")


def _price_path() -> PricePath:
    budget = LinearBudget(px=2.0, py=2.0, income=40.0)
    return PricePath(CD, budget=budget, price="px", price_range=(0.8, 6.0), n=40)


@figure("consumer/demand")
def _() -> None:
    fig = DemandDiagram(
        _price_path(), theme=THEME, font=FONT,
        figsize=(SIZE[0], 2 * SIZE[1]),
    )
    fig.add_marshallian_panel(price_markers=[1.5, 4.0], show_legend=False)
    save(fig.fig, "consumer/demand")


@figure("consumer/hicks")
def _() -> None:
    result = decompose_price_effect(
        CD, px=(2.0, 4.0), py=3.0, income=60.0, method=DecompositionMethod.HICKS,
    )
    c = canvas(x_max=25, y_max=25)
    c.add_utility(CD, levels=sorted({result.A.utility, result.C.utility}))
    c.add_decomposition(result, show_arrows=True, label_effects=False, show_x_projections=True)
    save(c.fig, "consumer/hicks")


@figure("consumer/edgeworth")
def _() -> None:
    box = EdgeworthBox(
        CobbDouglas(alpha=0.8, beta=0.2),
        CobbDouglas(alpha=0.2, beta=0.8),
        total_x=12.0, total_y=10.0, theme=THEME,
    )
    (
        box.add_endowment(5.0, 4.0)
        .add_contract_curve(n=100, method="mrs")
        .add_core()
        .add_price_line(px=1.2, py=1.0)
        .add_walrasian_equilibrium(px=1.2, py=1.0)
    )
    box.fig.set_size_inches(SIZE[0] * 1.1, SIZE[1] * 0.95)
    save(box.fig, "consumer/edgeworth")


@figure("consumer/price_path")
def _() -> None:
    path = _price_path()
    eq = path.equilibria[len(path.equilibria) // 2]
    c = canvas(x_max=25, y_max=20)
    c.add_utility(CD, levels=levels.around(eq.utility, n=5)).add_path(path)
    save(c.fig, "consumer/price_path")


# ---------------------------------------------------------------------------
# Animation: a few frames of each sweep, side by side
# ---------------------------------------------------------------------------


def _sweep(values, draw, titles) -> plt.Figure:
    cs = panels(len(values), x_max=14, y_max=12, x_label="x_1", y_label="x_2", title=titles)
    for c, v in zip(cs, values):
        draw(c, v)
    return cs[0].fig


@figure("animation/price_sweep")
def _() -> None:
    fixed = levels.around(solve(CD, px=2.0, py=2.0, income=20.0).utility, n=5)

    def draw(c: Canvas, px: float) -> None:
        eq = solve(CD, px=px, py=2.0, income=20.0)
        c.add_utility(CD, levels=fixed).add_budget(px, 2.0, 20.0, fill=True)
        c.add_equilibrium(eq, show_ray=True, label=EQ_LABEL)

    vals = [1.0, 2.0, 4.0, 6.0]
    save(_sweep(vals, draw, [rf"$p_x={v:g}$" for v in vals]), "animation/price_sweep")


@figure("animation/income_sweep")
def _() -> None:
    fixed = levels.around(solve(CD, px=2.0, py=2.0, income=20.0).utility, n=5)

    def draw(c: Canvas, income: float) -> None:
        eq = solve(CD, px=2.0, py=2.0, income=income)
        c.add_utility(CD, levels=fixed).add_budget(2.0, 2.0, income, fill=True)
        c.add_equilibrium(eq, show_ray=True, label=EQ_LABEL)

    vals = [8.0, 14.0, 20.0, 26.0]
    save(_sweep(vals, draw, [rf"$I={v:g}$" for v in vals]), "animation/income_sweep")


@figure("animation/parameter_sweep")
def _() -> None:
    def draw(c: Canvas, alpha: float) -> None:
        model = CobbDouglas(alpha=alpha, beta=1.0 - alpha)
        eq = solve(model, px=2.0, py=2.0, income=20.0)
        c.add_utility(model, levels=levels.around(eq.utility, n=5))
        c.add_budget(2.0, 2.0, 20.0, fill=True).add_equilibrium(eq, show_ray=True, label=EQ_LABEL)

    vals = [0.2, 0.4, 0.6, 0.8]
    save(_sweep(vals, draw, [rf"$\alpha={v:g}$" for v in vals]), "animation/parameter_sweep")


# ---------------------------------------------------------------------------
# Models
# ---------------------------------------------------------------------------


def _model_figure(name, model, *, px=2.0, py=3.0, income=30.0, x_max=20, y_max=15,
                  n=5, fill=False, ray=False, **utility_kwargs) -> None:
    eq = solve(model, px=px, py=py, income=income)
    c = canvas(x_max=x_max, y_max=y_max)
    c.add_utility(model, levels=levels.around(eq.utility, n=n), **utility_kwargs)
    c.add_budget(px, py, income, fill=fill).add_equilibrium(eq, show_ray=ray, label=EQ_LABEL)
    save(c.fig, name)


figure("models/cobb_douglas")(lambda: _model_figure(
    "models/cobb_douglas", CD, fill=True, ray=True))
figure("models/ces")(lambda: _model_figure(
    "models/ces", CES(alpha=0.5, beta=0.5, rho=-0.5)))
figure("models/translog")(lambda: _model_figure(
    "models/translog", Translog(alpha_x=0.6, alpha_y=0.4, beta_xy=0.12), x_max=18, y_max=12, n=4))
figure("models/leontief")(lambda: _model_figure(
    "models/leontief", Leontief(a=1.0, b=1.0), show_rays=True, show_kinks=True))
figure("models/perfect_substitutes")(lambda: _model_figure(
    "models/perfect_substitutes", PerfectSubstitutes(a=1.0, b=2.0)))
figure("models/maximum")(lambda: _model_figure(
    "models/maximum",
    CustomUtility(func=lambda x, y: np.maximum(1.0 * x, 1.0 * y), name="maximum"),
    x_max=25, y_max=20))
figure("models/quasi_linear")(lambda: _model_figure(
    "models/quasi_linear", QuasiLinear(v_func=np.log, linear_in="y"),
    px=1.0, py=2.0, income=20.0, x_max=15, y_max=15))
# gamma_y = 10 with p_x = p_y = 1 and I = 11 lies in the Giffen range
# gamma_y p_y < I < gamma_y p_y + gamma_x p_x; the optimum is (3, 8).
figure("models/haagsma")(lambda: _model_figure(
    "models/haagsma", Haagsma(gamma_y=10.0), px=1.0, py=1.0, income=11.0, x_max=9, y_max=12, n=4))
figure("models/stone_geary")(lambda: _model_figure(
    "models/stone_geary", StoneGeary(alpha=0.5, beta=0.5, bar_x=2.0, bar_y=2.0), fill=True))


@figure("models/satiation")
def _() -> None:
    model = Satiation(bliss_x=6.0, bliss_y=4.0)
    X, Y = np.meshgrid(np.linspace(0.1, 12.0, 300), np.linspace(0.1, 10.0, 300))
    c = canvas(x_max=12, y_max=10)
    c.add_utility(model, levels=levels.percentile(model(X, Y), n=5))
    save(c.fig, "models/satiation")


figure("models/custom")(lambda: _model_figure(
    "models/custom", CustomUtility(func=lambda x, y: np.log(x) + np.log(y), name="log+log")))
figure("models/multigood")(lambda: _model_figure(
    "models/multigood", MultiGoodCD({"x": 0.3, "y": 0.3, "z": 0.4}).freeze(z=10.0), fill=True))


# ---------------------------------------------------------------------------
# LaTeX parsing
# ---------------------------------------------------------------------------

figure("latex/leontief")(lambda: _model_figure(
    "latex/leontief", parse_latex(r"\min(2x, 3y)"), show_kinks=True))
figure("latex/perfect_substitutes")(lambda: _model_figure(
    "latex/perfect_substitutes", parse_latex(r"2x + 3y")))


# ---------------------------------------------------------------------------


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("only", nargs="*", help="figure names or group prefixes")
    parser.add_argument("--list", action="store_true", help="list figure names")
    args = parser.parse_args()

    if args.list:
        print("\n".join(FIGURES))
        return 0

    selected = [
        name for name in FIGURES
        if not args.only
        or any(name == o or name.startswith(o.rstrip("/") + "/") for o in args.only)
    ]
    if not selected:
        print(f"no figure matches {args.only}", file=sys.stderr)
        return 1

    register_fonts()
    print(f"writing {len(selected)} figure(s):")
    for name in selected:
        FIGURES[name]()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

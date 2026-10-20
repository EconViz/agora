#import "/template/manual.typ": *

= Figures and demand diagrams <sec-figures>

On top of `Canvas`, #pkg("utility-viz") builds these larger diagrams:

- `Figure` for multi-panel layouts;
- `PricePath` and `IncomePath` for budget and equilibrium sweeps;
- `DemandDiagram` for linked goods-space and Marshallian-demand views;
- `decompose_price_effect` for the Hicks and Slutsky decompositions;
- `EdgeworthBox` for two-consumer exchange diagrams.

== Multi-panel figures

#changed("1.5.0", label: "Figure")[Better placement and visibility of axis labels in shared-panel layouts]
#changed("1.10.0", label: "Figure")[Falls back to the active `Config` when no theme or font is given]
#changed("1.11.0", label: "Figure")[Panel backgrounds, labels, lines and markers fully follow the theme]

#api(("Figure",), added: "v1.2.0", syntax: [
  #raw("Figure(")#meta("layout")#raw(", x_max=")#meta("float")#raw(", y_max=")#meta("float")#raw(", ..., shared_x=False, shared_y=False)")
])[
  Compose several canvases into one figure, for before-and-after
  comparisons, decompositions or classroom slides. It takes the same
  styling arguments as `Canvas`. `fig[idx]` returns the panel `Canvas`, so
  the drawing API is unchanged once the layout exists.
]

#example([```python
from utility_viz import Config, Figure, Layout, levels, solve
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # the settings behind this manual's figures

fig = Figure(Layout.SIDE_BY_SIDE, x_max=20, y_max=15, x_label="$x$", y_label="$y$", shared_y=True)

# before and after the price of x doubles and the weights shift towards y
cases = [
    (CobbDouglas(alpha=0.5, beta=0.5), 2.0, 3.0, 30.0),
    (CobbDouglas(alpha=0.3, beta=0.7), 4.0, 3.0, 30.0),
]
for idx, (model, px, py, income) in enumerate(cases):
    eq = solve(model, px=px, py=py, income=income)
    panel = fig[idx]  # each panel is a Canvas
    panel.add_utility(model, levels=levels.around(eq.utility, n=5))
    panel.add_budget(px, py, income, fill=True)
    panel.add_equilibrium(eq, show_ray=True)
fig.save("side_by_side.png")
```])

#fig("/figures/consumer/side_by_side.svg", width: 100%, caption: [
  Price change, before and after.
])

#changed("1.2.0", label: "Layout")[Multi-panel `Figure` layouts and the `Layout` enum]
#api(("Layout",), added: "v1.2.0")[
  The available layouts:
  `SINGLE`, `STACKED`, `SIDE_BY_SIDE`, `TOP_TWO_BOTTOM_ONE`,
  `TOP_ONE_BOTTOM_TWO`, `GRID_2X2` and `GRID_3X3`.
]

#param("SINGLE", type: "Layout")[One panel.]
#param("STACKED", type: "Layout")[Two panels, one above the other.]
#param("SIDE_BY_SIDE", type: "Layout")[Two panels, side by side.]
#param("TOP_TWO_BOTTOM_ONE", type: "Layout")[Two panels on top, one below.]
#param("TOP_ONE_BOTTOM_TWO", type: "Layout")[One panel on top, two below.]
#param("GRID_2X2", type: "Layout")[Four panels in a 2 × 2 grid.]
#param("GRID_3X3", type: "Layout")[Nine panels in a 3 × 3 grid.]

== Paths

#changed("1.2.2", label: "PricePath")[PCC/ICC paths are smoothed by default, with slightly extended ends and no markers unless requested]
#changed("1.2.2", label: "PricePath")[PCC/ICC paths use their own colours; more padding in the goods space of demand diagrams]

#changed("1.2.0", label: "PricePath")[`PricePath`, `IncomePath` and `Canvas.add_path()` for PCC/ICC plots]
#api(("PricePath", "IncomePath"), added: "v1.2.0", syntax: [
  ```python
  from utility_viz import IncomePath, LinearBudget, PricePath
  from utility_viz.models import CobbDouglas

  model = CobbDouglas(alpha=0.5, beta=0.5)
  budget = LinearBudget(px=2.0, py=2.0, income=40.0)

  price_path = PricePath(
      model,
      budget=budget,
      price="px",
      price_range=(0.8, 6.0),
      n=40,
  )
  income_path = IncomePath(
      model,
      budget=budget,
      income_range=(20.0, 80.0),
      n=30,
  )
  ```
])[
  Sweep one budget parameter while repeatedly solving the consumer's
  problem. Use a path to draw price- and income-consumption curves with
  `Canvas.add_path`, to feed a `DemandDiagram`, or to inspect how bundles
  move as prices or income vary.
]

#api(("Canvas.add_path",), added: "v1.2.0", syntax: [
  ```python
  from utility_viz import Canvas, levels

  eq = price_path.equilibria[len(price_path.equilibria) // 2]
  lvls = levels.around(eq.utility, n=5)

  Canvas(x_max=25, y_max=20) \
      .add_utility(model, levels=lvls) \
      .add_path(price_path, label="PCC") \
      .save("price_path.png")
  ```
])[
  Draw a path directly on a canvas when a full demand diagram is not
  needed. For Cobb-Douglas preferences the price-consumption curve is
  horizontal (@fig-price-path): spending on $y$ does not depend on $p_x$.
]

#example([```python
from utility_viz import Canvas, Config, LinearBudget, PricePath, levels
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # the settings behind this manual's figures

model = CobbDouglas(alpha=0.5, beta=0.5)
budget = LinearBudget(px=2.0, py=2.0, income=40.0)
path = PricePath(model, budget=budget, price="px", price_range=(0.8, 6.0), n=40)

# curves around the optimum in the middle of the path
eq = path.equilibria[len(path.equilibria) // 2]

cvs = Canvas(x_max=25, y_max=20, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=5))
cvs.add_path(path)  # the price-consumption curve
cvs.save("price_path.png")
```])

#fig("/figures/consumer/price_path.svg", width: 56%, caption: [
  The price-consumption curve as $p_x$ varies.
]) <fig-price-path>

== Demand diagrams

#changed("1.2.0", label: "DemandDiagram")[`DemandDiagram`, linking goods space and Marshallian demand]
#changed("1.9.0", label: "DemandDiagram")[Supports `Legend`, `Marker`, `Label` and per-layer `Stroke`]
#api(("DemandDiagram",), added: "v1.2.0", syntax: [
  #raw("DemandDiagram(")#meta("price path")#raw(", title=None, ...)") \
  #raw(".add_marshallian_panel(price_markers=None, show_pcc=False, show_demand_guides=True)")
])[
  A stacked two-panel figure: indifference curves, budget lines and
  equilibria in the top panel, the corresponding Marshallian demand curve
  in the bottom one (@fig-demand).

  - `DemandDiagram` expects a `PricePath`.
  - Smooth, kinked and corner demand are handled differently, so that the
    bottom panel stays economically meaningful.
  - `show_pcc=True` overlays the price-consumption curve in goods space.
]

#example([```python
from utility_viz import DemandDiagram, LinearBudget, PricePath
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
budget = LinearBudget(px=2.0, py=2.0, income=40.0)
path = PricePath(
    model,
    budget=budget,
    price="px",
    price_range=(0.8, 6.0),
    n=40,
)

fig = DemandDiagram(path, title="Demand: Cobb-Douglas")
fig.add_marshallian_panel(
    price_markers=[1.5, 4.0],
    show_pcc=False,
    show_demand_guides=True,
)
fig.save("demand_cobb_douglas.png")
```])

The figure below is drawn from MosaicKit layers, so each label can be placed by hand.

#example([```python
from mosaickit import (
    AxisSpec,
    Canvas,
    CanvasGrid,
    CanvasSpec,
    DashStyle,
    Fill,
    Marker,
    MarkerLayer,
    PathLayer,
    Stroke,
    StyleBundle,
    TextLayer,
    TextStyle,
    build_axes,
)
import numpy as np

from utility_viz import solve
from utility_viz.core.scenes import UTILITY_THEME, budget_layers, indifference_layers
from utility_viz.models import CobbDouglas

INK, DARK, GREY = "#1a1a1a", "#222222", "#8c8c8c"  # the colours of manual.toml
text = TextStyle(color=INK, size=14)

# Cobb-Douglas demand for x at two prices p_x = 1.5 at A and 4 at B
model = CobbDouglas(alpha=0.5, beta=0.5)
py, income, px_a, px_b = 2.0, 40.0, 1.5, 4.0
points = {"A": px_a, "B": px_b}
optimum = {name: solve(model, px=px, py=py, income=income) for name, px in points.items()}
X = 29.0  # both panels show x from 0 to 29


def panel(y_min, y_max, height, y_label):
    """A white panel with thin axes; guides from a point to the axes are dashed."""
    spec = CanvasSpec(
        x_range=(0, X), y_range=(y_min, y_max), width=4.6, height=height, x_label="", y_label=""
    )
    roles = {
        "canvas": StyleBundle(fill=Fill(color="#ffffff", opacity=1.0)),
        "axes": StyleBundle(stroke=Stroke(color=INK, width=1.0), text=text),
        "guide": StyleBundle(stroke=Stroke(color=INK, width=0.8, dash=DashStyle.DASHED)),
    }
    cv = Canvas(spec, theme=UTILITY_THEME, role_overrides=roles)
    cv.extend(
        build_axes(
            AxisSpec((0, X), arrow="end", label="$x$"),
            AxisSpec((0, y_max), arrow="end", label=y_label),
        )
    )
    cv.add(TextLayer((0, 0), "0", offset=(-6, -8), anchor="top-right", style=text, id="origin"))
    return cv


def mark(cv, name, x, y):
    """A black dot with its italic letter, and dashed guides to both axes."""
    cv.add(PathLayer([(0, y), (x, y)], id=f"{name}.h", role="guide"))
    cv.add(PathLayer([(x, 0), (x, y)], id=f"{name}.v", role="guide"))
    cv.add(
        MarkerLayer(
            [(x, y)], marker=Marker(color=INK, size=26, edge_width=0), id=f"{name}.dot", z_index=5
        )
    )
    cv.add(
        TextLayer(
            (x, y),
            name,
            math=True,
            offset=(8, 6),
            anchor="bottom-left",
            style=text,
            id=f"{name}.label",
        )
    )


# Top is the goods space with the budget line and the indifference curve at each price
top = panel(-3.5, 24, 3.9, "$y$")
top.extend(budget_layers(px_a, py, income, layer_id="ba", stroke=Stroke(color=DARK, width=2.6)))
top.extend(
    budget_layers(
        px_b, py, income, layer_id="bb", stroke=Stroke(color=DARK, width=2.2, dash=DashStyle.DASHED)
    )
)
for name, eq in optimum.items():
    curve, _ = indifference_layers(
        model, [eq.utility], X, 24, layer_id=f"u.{name}", stroke=Stroke(color=GREY, width=2.6)
    )
    top.extend(curve)
    mark(top, name, eq.x, eq.y)

# Bottom is the demand curve x = alpha * income / p_x with the same two points
bottom = panel(-1.2, 7, 3.6, "$p_x$")
prices = np.linspace(0.8, 6.0, 80)
demand = tuple(zip(0.5 * income / prices, prices))
bottom.add(PathLayer(demand, stroke=Stroke(color=GREY, width=2.6), id="demand"))
for name, eq in optimum.items():
    mark(bottom, name, eq.x, points[name])

CanvasGrid([[top], [bottom]]).save("demand.png")
```])

#fig("/figures/consumer/demand.svg", width: 62%, caption: [
  Demand curve at the optima.
]) <fig-demand>

== Price-effect decomposition

#changed("1.5.0", label: "decompose_price_effect")[Price-effect decomposition: `decompose_price_effect()`, `PriceEffectDecomposition` and `Canvas.add_decomposition()`, drawing bundles A/B/C with substitution and income effects]
#changed("1.5.0", label: "decompose_price_effect")[Decomposition API importable from the package root]
#changed("1.8.0", label: "Canvas.add_decomposition")[`Effect`, `Marker` and `Label` style objects]
#changed("1.9.0", label: "Canvas.add_decomposition")[Draws the indifference curves through A, B and C by default, with curve labels and `Legend`]
#changed("1.9.0", label: "Canvas.add_decomposition")[Effect arrows below the horizontal axis point A→B and B→C; zero effects draw no arrow]

#api(("decompose_price_effect",), added: "v1.5.0", syntax: [
  #raw("decompose_price_effect(")#meta("model")#raw(", px=(")#meta("old")#raw(", ")#meta("new")#raw("), py=")#meta("float")#raw(", income=")#meta("float")#raw(", method=")#meta("method")#raw(")")
])[
  Separate a price change into substitution and income effects. Choose
  `DecompositionMethod.HICKS` to hold the original utility fixed
  #citep(<hicks1939>), or `SLUTSKY` #citep(<slutsky1915>) to keep the original bundle affordable. The result has these
  fields:
]

#param("A, B, C")[The original, compensated and final bundles.]
#param("substitution_effect")[Substitution effect.]
#param("income_effect")[Income effect.]
#param("total_effect")[Total effect.]
#param("compensated_income")[Income after compensation.]

#api(("DecompositionMethod",), added: "v1.5.0", syntax: [
  `DecompositionMethod.HICKS`, `SLUTSKY`
])[
  How the compensated bundle B is chosen.
]

#param("HICKS", type: "DecompositionMethod")[Hold the original utility fixed: B lies on the original indifference curve.]
#param("SLUTSKY", type: "DecompositionMethod")[Keep the original bundle affordable: B is the optimum on the budget line through A at the new prices.]

#api(("Canvas.add_decomposition",), added: "v1.5.0", updated: "v1.9.0")[
  Draw the three bundles A, B and C, the budget lines, the indifference
  curves and the effect arrows. A Hicks decomposition draws the curves
  through A and C; a Slutsky decomposition also draws the one through B.
]

#param("show_curves", type: "bool", default: "True")[Draw the decomposition's indifference curves; set to `False` when you draw your own.]
#param("curve_stroke", type: "Stroke | None", default: "None")[Style of the indifference curves.]
#param("curve_label", type: "Label | None", default: "None")[Show and style the $U_0$, $U_1$ and $U_B$ labels.]
#param("substitution, income", type: "Effect | None", default: "None")[Style of the substitution and income effects (see `Effect` below).]
#param("point_marker", type: "Marker | None", default: "None")[Markers of the bundles.]
#param("point_label", type: "Label | None", default: "None")[Text of the bundles.]
#param("legend", type: "Legend | None", default: "None")[Position and style of the legend (see `Legend` below).]

#api(("Effect",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Effect(color=None, y=None, label=None, label_position="right", label_offset=4, opacity=None)`
])[
  Colour, height of the arrow below the horizontal axis, label and opacity
  of the substitution or income effect. The line itself can still be
  overridden with `substitution_stroke` or `income_stroke`.
]

#api(("Legend",), added: "v1.9.0", syntax: [
  `Legend(position="auto", fontsize=None, frame=None, columns=None, visible=None, opacity=None)`
])[
  `"auto"` picks the inner corner that hides the least of the plot; when
  all four corners overlap it, the legend moves to the right. Inner corners
  such as `"upper left"` and outer positions `"top"`, `"bottom"`, `"left"`
  and `"right"` can also be given. `Legend(visible=False)` hides the legend.
]

#example([```python
from utility_viz import (
    Canvas,
    DecompositionMethod,
    Effect,
    Label,
    Legend,
    decompose_price_effect,
)
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
result = decompose_price_effect(
    model,
    px=(2.0, 4.0),
    py=3.0,
    income=60.0,
    method=DecompositionMethod.HICKS,
)

(
    Canvas(x_max=25, y_max=25, title="Hicks decomposition")
    .add_decomposition(
        result,
        show_arrows=True,
        label_effects=True,
        show_x_projections=True,
        substitution=Effect(label="SE"),
        income=Effect(label="IE", opacity=0.8),
        curve_label=Label(position="right"),
        legend=Legend(position="bottom"),
    )
    .save("hicks.png")
)
```])

The figure below is also drawn from MosaicKit layers; the two effects are named under the axis.

#example([```python
from mosaickit import (
    ArrowLayer,
    ArrowStyle,
    AxisSpec,
    Canvas,
    CanvasSpec,
    DashStyle,
    Fill,
    Marker,
    MarkerLayer,
    PathLayer,
    Stroke,
    StyleBundle,
    TextLayer,
    TextStyle,
    build_axes,
)

from utility_viz import DecompositionMethod
from utility_viz.core.scenes import UTILITY_THEME, budget_layers, indifference_layers
from utility_viz.models import CobbDouglas, decompose_price_effect

INK, DARK, GREY = "#1a1a1a", "#222222", "#8c8c8c"  # the colours of manual.toml
text = TextStyle(color=INK, size=14)
effect_name = TextStyle(color=INK, size=13)

# The price of x doubles from 2 to 4 and A is the old optimum
# C is the new one and B is the bundle on the old curve at the new prices as in the Hicks decomposition
model = CobbDouglas(alpha=0.5, beta=0.5)
px0, px1, py, income = 2.0, 4.0, 3.0, 60.0
result = decompose_price_effect(
    model, px=(px0, px1), py=py, income=income, method=DecompositionMethod.HICKS
)
bundles = {"A": result.A, "B": result.B, "C": result.C}
X, Y = 26.0, 24.0

# A white canvas with thin axes that reaches below the x-axis where the effects are named
spec = CanvasSpec(x_range=(0, X), y_range=(-7.5, Y), width=4.6, height=4.2, x_label="", y_label="")
roles = {
    "canvas": StyleBundle(fill=Fill(color="#ffffff", opacity=1.0)),
    "axes": StyleBundle(stroke=Stroke(color=INK, width=1.0), text=text),
    "guide": StyleBundle(stroke=Stroke(color=INK, width=0.8, dash=DashStyle.DASHED)),
}
cv = Canvas(spec, theme=UTILITY_THEME, role_overrides=roles)
cv.extend(
    build_axes(
        AxisSpec((0, X), arrow="end", label="$x$"), AxisSpec((0, Y), arrow="end", label="$y$")
    )
)
cv.add(TextLayer((0, 0), "0", offset=(-6, -8), anchor="top-right", style=text, id="origin"))

# The budget lines before and after and the dashed compensated line and the two indifference curves
cv.extend(budget_layers(px0, py, income, layer_id="b0", stroke=Stroke(color=DARK, width=2.6)))
cv.extend(budget_layers(px1, py, income, layer_id="b1", stroke=Stroke(color=DARK, width=2.6)))
compensated = [(0, result.compensated_income / py), (X, (result.compensated_income - px1 * X) / py)]
cv.add(
    PathLayer(
        compensated, stroke=Stroke(color=INK, width=1.0, dash=DashStyle.DASHED), id="compensated"
    )
)
for name in ("A", "C"):
    curve, _ = indifference_layers(
        model,
        [bundles[name].utility],
        X,
        Y,
        layer_id=f"u.{name}",
        stroke=Stroke(color=GREY, width=2.6),
    )
    cv.extend(curve)

# The three bundles each with a dashed guide down to the x-axis
for name, bundle in bundles.items():
    cv.add(PathLayer([(bundle.x, 0), (bundle.x, bundle.y)], id=f"{name}.guide", role="guide"))
    cv.add(
        MarkerLayer(
            [(bundle.x, bundle.y)],
            marker=Marker(color=INK, size=26, edge_width=0),
            id=f"{name}.dot",
            z_index=5,
        )
    )
    cv.add(
        TextLayer(
            (bundle.x, bundle.y),
            name,
            math=True,
            offset=(8, 6),
            anchor="bottom-left",
            style=text,
            id=f"{name}.label",
        )
    )

# The effects on x as arrows between the guides from A to B then B to C and each is named by a line
# pulled down below the axis and the lines fan out so that both names sit on one level
gap, row, depth, spread = 0.2, 1.6, -4.4, 3.8
effects = [("A", "B", "Substitution effect", 1), ("B", "C", "Income effect", -1)]
for i, (start, end, name, direction) in enumerate(effects):
    x0, x1 = bundles[start].x, bundles[end].x
    sign = 1 if x1 > x0 else -1
    arrow = Stroke(color=GREY, width=1.8, arrow=ArrowStyle.TRIANGLE)
    cv.add(
        ArrowLayer((x0 + gap * sign, row), (x1 - gap * sign, row), stroke=arrow, id=f"effect.{i}")
    )
    foot = (x0 + x1) / 2 + direction * spread
    cv.add(
        PathLayer(
            [((x0 + x1) / 2, row - 0.6), (foot, depth + 0.4)],
            stroke=Stroke(color=INK, width=0.8),
            id=f"leader.{i}",
            clip=False,
        )
    )
    cv.add(TextLayer((foot, depth), name, anchor="top", style=effect_name, id=f"effect.label.{i}"))

cv.save("hicks.png")
```])

#fig("/figures/consumer/hicks.svg", width: 72%, caption: [
  Hicks decomposition.
])

== Edgeworth box

#changed("1.3.2", label: "EdgeworthBox")[Contract curve and price line default to black dashed lines]
#changed("1.3.1", label: "EdgeworthBox")[Edgeworth internals split into compute, state and plotter modules]
#changed("1.3.0", label: "EdgeworthBox")[`EdgeworthBox` and `EquilibriumFocusConfig` for two-consumer exchange diagrams]
#changed("1.3.0", label: "EdgeworthBox")[Contract-curve, core and Walrasian-equilibrium overlays, with equilibrium-focused indifference curves]
#changed("1.8.0", label: "EdgeworthBox")[Markers, text and axes accept `Marker`, `Label` and `Axis`]
#changed("1.10.0", label: "EdgeworthBox")[Falls back to the active `Config` when no theme or font is given]
#changed("1.11.0", label: "EdgeworthBox")[Box frame, contract curve, core, endowment, price line and Walrasian equilibrium fully follow the theme]

#api(("EdgeworthBox",), added: "v1.3.0", syntax: [
  #raw("EdgeworthBox(")#meta("utility A")#raw(", ")#meta("utility B")#raw(", total_x=")#meta("float")#raw(", total_y=")#meta("float")#raw(", ...)")
])[
  A two-consumer exchange economy #citep(<edgeworth1881>). Consumer $A$ is measured from the
  lower-left origin and consumer $B$ from the upper-right origin. Layers
  are added with `add_endowment`, `add_contract_curve`, `add_core`,
  `add_price_line` and `add_walrasian_equilibrium`.

  Use `method="mrs"` for the contract curve of smooth preferences, and
  `method="pareto"` for models with kinks, corners or custom piecewise
  utility functions.
]

#example([```python
from utility_viz import EdgeworthBox
from utility_viz.models import CobbDouglas

box = EdgeworthBox(
    CobbDouglas(alpha=0.8, beta=0.2),
    CobbDouglas(alpha=0.2, beta=0.8),
    total_x=12.0,
    total_y=10.0,
    title="Asymmetric Cobb-Douglas",
)

(
    box.add_endowment(5.0, 4.0)
    .add_contract_curve(n=100, method="mrs")
    .add_core()
    .add_price_line(px=1.2, py=1.0)
    .add_walrasian_equilibrium(px=1.2, py=1.0)
    .show_legend(loc="center left", bbox_to_anchor=(1.02, 0.5))
    .save("edgeworth.png")
)
```])

The figure below is drawn from MosaicKit layers after a textbook figure, with both consumers' indifference curves.

#example([```python
import numpy as np
from mosaickit import (
    ArrowLayer,
    ArrowStyle,
    AxisSpec,
    Canvas,
    CanvasSpec,
    Fill,
    FillLayer,
    Marker,
    MarkerLayer,
    PathLayer,
    Stroke,
    StyleBundle,
    TextLayer,
    TextStyle,
)
from scipy.interpolate import CubicSpline

from utility_viz.core.scenes import UTILITY_THEME

INK, GREY, LENS = "#1a1a1a", "#8c8c8c", "#ececec"  # the colours of manual.toml
text = TextStyle(color=INK, size=12)

# Drawn after a textbook figure with a box 10 wide and 6 high and person J measured from the
# lower-left corner O_J and person K from the upper-right corner O_K and each indifference curve is a
# cubic spline through a few control points whose x and y are read off that figure
J = {  # xs and ys of the control points of J's curves from the lowest to the highest
    1: (
        [3.80, 3.91, 4.18, 4.59, 5.12, 5.75, 6.46, 7.16, 8.07],
        [5.15, 4.29, 3.49, 2.74, 2.08, 1.52, 1.07, 0.79, 0.58],
    ),
    2: (
        [4.26, 4.37, 4.60, 4.94, 5.25, 5.90, 6.30, 7.15, 7.84],
        [5.28, 4.55, 3.86, 3.22, 2.79, 2.13, 1.83, 1.38, 1.17],
    ),
    3: (
        [5.12, 5.20, 5.38, 5.64, 5.95, 6.35, 6.81, 7.29, 7.80],
        [5.40, 4.88, 4.39, 3.93, 3.50, 3.18, 2.91, 2.73, 2.63],
    ),
}
K = {  # the same for K's curves from the outermost in
    1: (
        [3.38, 4.17, 4.91, 5.57, 5.95, 6.60, 6.93, 7.16, 7.19],
        [4.86, 4.65, 4.30, 3.83, 3.50, 2.57, 1.83, 0.79, 0.24],
    ),
    2: (
        [3.62, 4.22, 4.77, 5.27, 5.68, 6.03, 6.30, 6.47, 6.54],
        [4.35, 4.14, 3.83, 3.43, 2.97, 2.44, 1.83, 1.26, 0.64],
    ),
    3: (
        [3.64, 4.12, 4.55, 4.93, 5.25, 5.53, 5.73, 5.86, 5.92],
        [3.80, 3.65, 3.41, 3.11, 2.79, 2.33, 1.88, 1.41, 0.92],
    ),
}
# Four allocations each where one of J's curves crosses one of K's
allocations = {"A": (7.16, 0.79), "B": (6.30, 1.83), "C": (5.25, 2.79), "D": (5.95, 3.50)}
# Where the letters and curve labels stand at the centre of each text
letters = {"A": (7.41, 0.93), "B": (6.55, 1.90), "C": (5.48, 2.93), "D": (6.14, 3.67)}
curve_labels = {
    "U_J^1": (8.35, 0.48),
    "U_J^2": (8.12, 1.09),
    "U_J^3": (8.05, 2.58),
    "U_K^1": (7.46, 0.25),
    "U_K^2": (6.58, 0.36),
    "U_K^3": (5.95, 0.66),
}


def spline(points, n=240):
    """A smooth curve through the control points, as n sampled points."""
    points = np.column_stack(points)  # xs and ys into a list of x y pairs
    chord = np.r_[0, np.cumsum(np.hypot(*np.diff(points, axis=0).T))]
    return CubicSpline(chord, points)(np.linspace(0, chord[-1], n))


curves_j = {k: spline(v) for k, v in J.items()}
curves_k = {k: spline(v) for k, v in K.items()}

# The canvas is the box plus the margin that holds the four arrows and 0.6 inch is one unit of the
# box and a Matplotlib axes fills 77.5% of the figure width and 77% of its height
x_range, y_range, unit = (-1.0, 11.15), (-0.8, 6.8), 0.6
spec = CanvasSpec(
    x_range=x_range,
    y_range=y_range,
    x_label="",
    y_label="",
    width=(x_range[1] - x_range[0]) * unit / 0.775,
    height=(y_range[1] - y_range[0]) * unit / 0.77,
)
roles = {"canvas": StyleBundle(fill=Fill(color="#ffffff", opacity=1.0))}
cv = Canvas(spec, theme=UTILITY_THEME, role_overrides=roles)
cv.add(
    PathLayer(
        [(0, 0), (10, 0), (10, 6), (0, 6), (0, 0)],
        stroke=Stroke(color=INK, width=0.6),
        id="box",
        clip=False,
    )
)

# The lens between J's lowest curve and K's outermost from where they cross to allocation A
j1, k1 = curves_j[1], curves_k[1]
near = lambda curve, point: int(np.argmin(np.hypot(*(curve - point).T)))
gaps = [
    (np.hypot(*(j1[a] - k1[b])), a, b)
    for a in range(0, 240, 2)
    for b in range(0, 240, 2)
    if j1[a][1] > 4 and k1[b][0] < 4.2
]
_, a_top, b_top = min(gaps)
a_end, b_end = near(j1, allocations["A"]), near(k1, allocations["A"])
lens = [tuple(p) for p in k1[b_top : b_end + 1]] + [tuple(p) for p in j1[a_top : a_end + 1][::-1]]
cv.add(FillLayer(lens, fill=Fill(color=LENS, opacity=1.0), id="lens", z_index=0))

# The curves are 0.62% of the box wide at 2.66 points on a 6 inch box and the dots 1.49% at 6.45 points
for k, points in curves_j.items():
    cv.add(
        PathLayer(
            [tuple(p) for p in points], stroke=Stroke(color=INK, width=2.66), id=f"j{k}", z_index=2
        )
    )
for k, points in curves_k.items():
    cv.add(
        PathLayer(
            [tuple(p) for p in points], stroke=Stroke(color=GREY, width=2.66), id=f"k{k}", z_index=2
        )
    )
for name, point in allocations.items():
    cv.add(
        MarkerLayer(
            [point], marker=Marker(color=INK, size=41.6, edge_width=0), id=f"dot.{name}", z_index=4
        )
    )
    cv.add(
        TextLayer(
            letters[name],
            name,
            math=True,
            anchor="center",
            style=text,
            id=f"letter.{name}",
            z_index=4,
        )
    )
for label, point in curve_labels.items():
    cv.add(TextLayer(point, label, math=True, anchor="center", style=text, id=f"label.{label}"))
cv.add(TextLayer((-0.14, -0.20), "O_J", math=True, anchor="center", style=text, id="origin.j"))
cv.add(TextLayer((10.30, 6.18), "O_K", math=True, anchor="center", style=text, id="origin.k"))

# The four sides and each person's quantities grow along the arrows with J's from O_J and K's from O_K
arrow, plain = Stroke(color=GREY, width=1.0, arrow=ArrowStyle.TRIANGLE), Stroke(
    color=GREY, width=1.0
)
cv.add(ArrowLayer((3.91, -0.34), (5.96, -0.34), stroke=arrow, id="side.bottom"))
cv.add(TextLayer((3.78, -0.35), "x_J", math=True, anchor="right", style=text, id="name.bottom"))
cv.add(ArrowLayer((5.93, 6.35), (3.98, 6.35), stroke=arrow, id="side.top"))
cv.add(TextLayer((6.07, 6.36), "x_K", math=True, anchor="left", style=text, id="name.top"))
cv.add(PathLayer([(-0.67, 1.91), (-0.67, 2.47)], stroke=plain, id="side.left.line", clip=False))
cv.add(ArrowLayer((-0.67, 3.47), (-0.67, 4.18), stroke=arrow, id="side.left"))
cv.add(TextLayer((-0.67, 2.99), "y_J", math=True, anchor="center", style=text, id="name.left"))
cv.add(PathLayer([(10.67, 3.47), (10.67, 4.04)], stroke=plain, id="side.right.line", clip=False))
cv.add(ArrowLayer((10.67, 2.47), (10.67, 1.78), stroke=arrow, id="side.right"))
cv.add(TextLayer((10.67, 3.01), "y_K", math=True, anchor="center", style=text, id="name.right"))

cv.save("edgeworth.png")
```])

#fig("/figures/consumer/edgeworth.svg", width: 86%, caption: [
  Both consumers' indifference curves through allocations A to D; the shaded lens holds the allocations both prefer to A.
])

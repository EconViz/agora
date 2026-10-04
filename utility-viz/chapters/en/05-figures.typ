#import "/template/manual.typ": *

= Figures and demand diagrams <sec-figures>

On top of `Canvas`, #modify[#pkg("utility-viz")] builds these larger diagrams:

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

#example(modify[```python
from utility_viz import Figure, Layout, Legend, levels, solve
from utility_viz.models import CobbDouglas

fig = Figure(
    Layout.SIDE_BY_SIDE,
    x_max=20,
    y_max=15,
    x_label="x",
    y_label="y",
    title="Before / After Price Change",
    shared_y=True,
)

cases = [
    (CobbDouglas(alpha=0.5, beta=0.5), 2.0, 3.0, 30.0, r"Before: $p_x=2$"),
    (CobbDouglas(alpha=0.3, beta=0.7), 4.0, 3.0, 30.0, r"After: $p_x=4$"),
]

for idx, (model, px, py, income, title) in enumerate(cases):
    eq = solve(model, px=px, py=py, income=income)
    panel = fig[idx]
    panel.ax.set_title(title)
    panel.add_utility(model, levels=levels.around(eq.utility, n=5), label="IC")
    panel.add_budget(px, py, income, fill=True, label="BC")
    panel.add_equilibrium(eq, show_ray=True)

fig[0].show_legend(legend=Legend(position="upper right"))
fig.save("figure_side_by_side.png")
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

== Paths

#changed("1.2.2", label: "PricePath")[PCC/ICC paths are smoothed by default, with slightly extended ends and no markers unless requested]
#changed("1.2.2", label: "PricePath")[PCC/ICC paths use their own colours; more padding in the goods space of demand diagrams]

#changed("1.2.0", label: "PricePath")[`PricePath`, `IncomePath` and `Canvas.add_path()` for PCC/ICC plots]
#api(("PricePath", "IncomePath"), added: "v1.2.0", syntax: [
  #modify[```python
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
  ```]
])[
  Sweep one budget parameter while repeatedly solving the consumer's
  problem. Use a path to draw price- and income-consumption curves with
  `Canvas.add_path`, to feed a `DemandDiagram`, or to inspect how bundles
  move as prices or income vary.
]

#api(("Canvas.add_path",), added: "v1.2.0", syntax: [
  #modify[```python
  from utility_viz import Canvas, levels

  eq = price_path.equilibria[len(price_path.equilibria) // 2]
  lvls = levels.around(eq.utility, n=5)

  Canvas(x_max=25, y_max=20) \
      .add_utility(model, levels=lvls) \
      .add_path(price_path, label="PCC") \
      .save("price_path.png")
  ```]
])[
  Draw a path directly on a canvas when a full demand diagram is not
  needed. For Cobb-Douglas preferences the price-consumption curve is
  horizontal (@fig-price-path): spending on $y$ does not depend on $p_x$.
]

#fig("/figures/consumer/price_path.svg", width: 42%, caption: [
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

#example(modify[```python
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

#fig("/figures/consumer/demand.svg", width: 46%, caption: [
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

#example(modify[```python
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

#fig("/figures/consumer/hicks.svg", width: 48%, caption: [
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

#example(modify[```python
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

#fig("/figures/consumer/edgeworth.svg", width: 52%, caption: [
  Contract curve and equilibrium.
])

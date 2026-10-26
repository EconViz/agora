#import "/template/manual.typ": *

= Model and figure <sec-model-figure>

== Model first, figure second

Every topic has two layers.

- A *model* is a frozen dataclass with checked inputs and methods that answer questions: `CubicCost.marginal_cost`, `Monopolist.solve`, `IndustrySupply.quantity`. Models never import a renderer and raise their own errors (`CostError`, `CompetitionError`, `UncertaintyError`) on bad input.
- A *builder* in `micro_viz.visuals` turns a model result into a #pkg("mosaickit") `Canvas`: `unit_cost_canvas(analysis)`, `monopoly_canvas(outcome, analysis)`. A builder has no equations in it; it places what the model computed.

```python
from micro_viz import (
    CubicCost, LinearDemand, Monopolist, analyze_costs, monopoly_canvas,
)

demand = LinearDemand(intercept=30, slope=2)
cost = CubicCost(20, 6, -1.5, 0.15)
outcome = Monopolist(demand, cost).solve()
analysis = analyze_costs(cost, output_range=(1, 10))

monopoly_canvas(outcome, analysis, profit=True).save("monopoly.svg")
```

== Common options <sec-options>

Every builder returns a `Canvas` and accepts the same keyword options. In the signatures of this manual they are written `**options`.

#param("title", type: "str | None", default: "None")[A title. `None` draws none.]
#param("theme", type: "PlotTheme | None", default: "None")[The look of the figure. `None` uses the theme of the loaded settings (@sec-settings).]
#param("labels", type: "Mapping[str, str] | None", default: "None")[Replacement text by label id (@sec-labels).]
#param("x_label", type: "str | None", default: "None")[The horizontal axis title; the default is set by the builder.]
#param("y_label", type: "str | None", default: "None")[The vertical axis title; the default is set by the builder.]
#param("x_max", type: "float | None", default: "None")[The upper end of the horizontal axis; fix it, together with `y_range`, to keep the axes still in an animation (@sec-animation).]
#param("y_range", type: "tuple[float, float] | None", default: "None")[The vertical range.]
#param("margin", type: "float", default: "0.1")[Extra room beyond the largest plotted value on each axis, as a fraction.]
#param("size", type: "tuple[float, float]", default: "(6.0, 6.0)")[Figure size in inches.]
#param("dpi", type: "int", default: "150")[Resolution of PNG output.]

Builders that draw several panels take `titles` (one per panel) instead of `title`.

== Package layout

#tbl(caption: [Where things live])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Where], [What]),
    [`micro_viz/<topic>.py`, `micro_viz/<topic>/`], [Models and solvers, renderer-free],
    [`micro_viz/visuals/`], [Builders that return a `Canvas`; `plane.py` is a small kit (`Plane`) for plane diagrams],
    [`micro_viz/locale/labels.json`], [Every built-in word, by id and language],
    [`micro_viz/theme.py`, `config.py`], [The theme and the `[micro]` settings schema],
    [`micro_viz/animation/`], [Optional animation over a parameter],
    [`examples/scripts/<topic>/`], [Scripts, one folder per topic; the figures of this manual],
  )
] <tab-layout>

== Layer ids

A builder gives every layer a stable id of the form `micro.<prefix>.<kind>.<n>`, such as `micro.cost.avc.label`. The ids are what the per-figure label table of the settings file addresses (@sec-labels) and what an animation matches between frames (@sec-animation).

== Multi-panel figures

Figures with several panels (market and firm, multiplant monopoly, industry supply) use a #pkg("mosaickit") `CanvasGrid`. A dashed line that runs across the gap between panels is a `GridLink` from a point in one cell to a point in the next, so the price or marginal-cost level stays one continuous line.

== Relationship to the other packages

- #pkg("mosaickit") draws everything: scenes, layers, themes, label placement, grids and rendering. #pkg("micro-viz") depends on it and on nothing else at run time.
- #pkg("bezierkit") supplies curve geometry. #pkg("micro-viz") does not import it directly; it joins the dependencies when a figure needs its public geometry API.
- #pkg("kinetickit") animates figures and arrives only with the `animation` extra (@sec-animation).
- #pkg("utility-viz") and #pkg("principle-viz") own consumer theory and introductory market diagrams. Their objects can be used alongside; #pkg("micro-viz") does not rewrite them.

#import "/template/manual.typ": *

= Quick start <sec-quickstart>

A figure takes two steps: build a model, then pass its result to a builder from `micro_viz`.

```python
from micro_viz import CubicCost, analyze_costs, unit_cost_canvas

cost = CubicCost(fixed_cost=50, linear=36, quadratic=-8, cubic=0.6)
analysis = analyze_costs(cost, output_range=(1, 11))

unit_cost_canvas(analysis).save("unit_cost.svg")
```

#fig("/figures/costs/unit_cost.svg", width: 46%, caption: [
  Unit costs
]) <fig-quick-unit-cost>

`save()` writes PNG, SVG or PDF according to the extension. Models are immutable and answer questions without drawing:

```python
analysis.minimum_average_total_cost    # lowest ATC and its output
cost.marginal_cost(5.0)                # MC at one output
```

== Titles, labels and settings

- `title=None` draws no title, and `title="..."` sets one.
- Built-in words (axis titles, curve names, point names) are label ids of a locale table; `labels={"id": "text"}` replaces any of them (@sec-labels).
- Colours, widths, fonts and sizes come from the theme and the `[micro]` tables of the shared `econ-viz.toml` (@sec-settings); the drawing code contains none of them.
- Numbers such as ranges, output marks and sample counts are arguments of the builder.

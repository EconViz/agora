#import "/template/manual.typ": *

= Animation <sec-animation>

#changed("0.2.0.dev0", label: "save_svg")[Animated SVG and GIF from the same builder that draws the static figure; needs the `animation` extra]

A figure about a shift, a sweep or an adjustment animates from the same builder that draws it. It needs the `animation` extra (@sec-extras), which adds #pkg("kinetickit").

A builder here is a function from one number (a shift, a price, an output) to a #pkg("mosaickit") canvas: the function that draws the static figure, with every axis range and the size fixed by the caller so the axes stay put.

#api(("save_svg", "save_gif"), syntax: [
  ```python
  save_svg(builder, values, path)
  save_gif(builder, values, path, fps=15)
  ```
])[
  `save_svg()` morphs between the frames' layers, matched by their stable ids, into a native animated SVG. `save_gif()` renders each frame through #pkg("mosaickit") into a GIF. Both live in `micro_viz.animation` and return the path.
]

```python
from micro_viz.animation import save_svg


def frame(output: float):
    return unit_cost_canvas(analysis, output=output, x_max=12, y_range=(0, 90))


save_svg(frame, [2, 4, 6, 8, 10], "unit_cost_output.svg")
```

`save_svg()` sets the labels from font files, so `econ-viz.toml` needs the `[font]` and `[fonts]` tables; `save_gif()` does not. A PDF shows only the first frame of each animation below; the website plays them.

#fig("/figures/animation/unit_cost_output_animated.svg", width: 46%, caption: [
  Unit costs as output grows
]) <fig-anim-cost>

#fig("/figures/animation/monopoly_demand_shift_animated.svg", width: 46%, caption: [
  A demand shift under monopoly
]) <fig-anim-monopoly>

#fig("/figures/animation/monopolistic_entry_animated.svg", width: 70%, caption: [
  Entry in monopolistic competition
]) <fig-anim-entry>

== Status

Animation examples exist for production (`animate_production.py`), costs (`animate_costs.py`), monopoly (`animate_monopoly.py`) and monopolistic competition (`animate_monopolistic.py`). Figures added after these, such as factor markets, long-run competition, oligopoly, uncertainty and information, have no animation yet. The animated SVG leaves out movement arrows, and it places text from the layers' anchors without collision avoidance; the GIF uses #pkg("mosaickit")'s placement exactly.

Without #pkg("kinetickit") the static figures work unchanged.

#import "/template/manual.typ": *

= Advanced models <sec-advanced>

Advanced models extend the built-in families with user-defined functions
or more than two goods.

=== Custom utility

#api(("CustomUtility",), syntax: [#raw("CustomUtility(func=")#meta("callable")#raw(", name=")#meta("str")#raw(")")])[
  Wrap any vectorised Python callable as an #modify[#pkg("utility-viz")] model. The
  callable must accept two #pkg("NumPy") arrays and return an array of the
  same shape. The example below uses
  $ u(x, y) = ln x + ln y. $
]

#param("func")[Vectorised utility function of $x$ and $y$.]
#param("name")[Display name of the model.]

#modify[```python
import numpy as np
from utility_viz import Canvas, levels, solve
from utility_viz.models import CustomUtility

model = CustomUtility(
    func=lambda x, y: np.log(x) + np.log(y),
    name="log+log",
)
eq = solve(model, px=2.0, py=3.0, income=30.0)

(
    Canvas(x_max=20, y_max=15, title="Custom Utility")
    .add_utility(model, levels=levels.around(eq.utility, n=5))
    .add_budget(2.0, 3.0, 30.0)
    .add_equilibrium(eq)
    .save("custom.png")
)
```]

#fig("/figures/models/custom.svg", width: 42%, caption: [
  A custom model, $ln x + ln y$.
])

=== Many-good Cobb-Douglas

#api(("MultiGoodCD", "MultiGoodCD.freeze"), syntax: [
  #raw("MultiGoodCD(")#meta("shares")#raw(")") \
  #raw(".freeze(")#meta("good")#raw("=")#meta("quantity")#raw(", ...)")
])[
  Cobb-Douglas preferences over $N$ goods:
  $ u(x_1, ..., x_N) = product_(i=1)^N x_i^(alpha_i). $
  `freeze()` fixes every good except $x$ and $y$ and returns a
  `CustomUtility` that can be drawn on a two-dimensional canvas.
]

#param("shares")[Mapping from each good's name to its exponent $alpha_i$.]
#param("freeze(...)")[Fixed quantities of the goods other than $x$ and $y$.]

#modify[```python
from utility_viz import Canvas, levels, solve
from utility_viz.models import MultiGoodCD

model = MultiGoodCD({"x": 0.3, "y": 0.3, "z": 0.4})
two_good_model = model.freeze(z=10.0)
eq = solve(two_good_model, px=2.0, py=3.0, income=30.0)

(
    Canvas(x_max=20, y_max=15, title="Multi-Good Cobb-Douglas")
    .add_utility(
        two_good_model,
        levels=levels.around(eq.utility, n=5),
    )
    .add_budget(2.0, 3.0, 30.0, fill=True)
    .add_equilibrium(eq)
    .save("multigood.png")
)
```]

#fig("/figures/models/multigood.svg", width: 42%, caption: [
  A three-good Cobb-Douglas model with $z = 10$ fixed.
])

#modify[
=== Backend-neutral scenes <sec-scenes>

#changed("2.0.0b1", label: "core.scenes")[#modify[Backend-neutral #pkg("mosaickit") layer factories for budget lines, equilibria and indifference curves, with native Bézier TikZ export]]

`utility_viz.core.scenes` builds the same economic components as `Canvas`,
but as immutable #pkg("mosaickit") layers instead of drawing on
#pkg("matplotlib") axes. Every layer has a stable id (`budget`,
`budget.fill`, `equilibrium.drop`, `ic.2`, ...) and a dotted theme role
(`utility.budget`, `utility.indifference.secondary`, ...), so the scene can
be inspected, edited and rendered by any #pkg("mosaickit") backend. It is an
advanced, additive API: `Canvas` and the other diagrams are unchanged.

#api(("budget_layers", "equilibrium_layers", "indifference_layers"), added: "v2.0.0b1", syntax: [
  #raw("budget_layers(")#meta("float")#raw(", ")#meta("float")#raw(", ")#meta("float")#raw(", fill=False, ...)") \
  #raw("equilibrium_layers(")#meta("equilibrium")#raw(", drop_lines=True, ...)") \
  #raw("indifference_layers(")#meta("model")#raw(", ")#meta("levels")#raw(", ")#meta("max")#raw(", ")#meta("max")#raw(", ...)")
])[
  Return a tuple of layers for the budget line $p_x x + p_y y = I$, the
  equilibrium bundle, and the indifference curves of a model over
  $[0, x_max] times [0, y_max]$. Styling comes from the theme roles; sparse
  `Stroke`, `Marker` and `Fill` overrides are accepted.
  `indifference_layers` returns `(layers, levels)` and traces the curves as
  Bézier paths with #pkg("bezierkit"), so it also handles non-monotone and
  kinked utilities.
]

#api(("UTILITY_THEME", "canvas_to_tikz"), added: "v2.0.0b1")[
  `UTILITY_THEME` is a #pkg("mosaickit") theme with the `utility.*` roles,
  matching the default theme's colours. `canvas_to_tikz(canvas)` exports a
  scene as TikZ with native `.. controls ..` curves.
]

```python
from mosaickit import Canvas, CanvasSpec, quadrant_axes

from utility_viz.core.scenes import (
    UTILITY_THEME,
    budget_layers,
    canvas_to_tikz,
    equilibrium_layers,
    indifference_layers,
)
from utility_viz.models import CobbDouglas, solve

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)
u = eq.utility
ic, _ = indifference_layers(model, [0.6 * u, u, 1.4 * u], 18, 12)

spec = CanvasSpec(x_range=(0, 18), y_range=(0, 12))
canvas = (
    Canvas(spec, theme=UTILITY_THEME)
    .extend(quadrant_axes(18, 12))
    .extend(ic)
    .extend(budget_layers(2.0, 3.0, 30.0, fill=True))
    .extend(equilibrium_layers(eq))
)
canvas.save("scene.png")
tex = canvas_to_tikz(canvas)
```

The TikZ exporter handles path, fill, marker and text layers. The traced
utility must be finite on the plotted region.
]

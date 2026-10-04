#import "/template/manual.typ": *

= Quick start <sec-quickstart>

== A minimal example

This chapter uses the complete Cobb-Douglas consumer problem:

$
  max_(x, y) & u(x, y) = x^(1/2) y^(1/2) \
      "s.t." & 2x + 3y = 30
$

The script solves the optimum and draws the indifference map, budget set,
and equilibrium shown in @fig-quickstart.

#example(modify[```python
from utility_viz import Canvas, levels, solve
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
eq    = solve(model, px=2.0, py=3.0, income=30.0)
lvls  = levels.around(eq.utility, n=5)

cvs = Canvas(
    x_max=20, y_max=15,
    x_label="x", y_label="y",
    title=r"Cobb-Douglas $x^{0.5} y^{0.5}$"
)
cvs.add_utility(model, levels=lvls)
cvs.add_budget(2.0, 3.0, 30.0, fill=True)
cvs.add_equilibrium(eq, show_ray=True)
cvs.save("cobb_douglas.png")
```])

#fig("/figures/models/cobb_douglas.svg", caption: [
  The consumer-equilibrium diagram.
]) <fig-quickstart>

Running `main.py` writes `cobb_douglas.png` to the current working directory.
The optimum is $x^* = 7.5$, $y^* = 5$; spending is
$2 times 7.5 + 3 times 5 = 30$, exactly the income. The budget line meets
the axes at $I / p_x = 15$ and $I / p_y = 10$.

== Step by step

Every diagram follows the same steps: build a model, solve for the
equilibrium, pick utility levels, create a canvas, add layers and export.

#api(("utility_viz.models",), syntax: [
  #modify[```python
  from utility_viz.models import CobbDouglas
  model = CobbDouglas(alpha=0.5, beta=0.5)
  ```]
])[
  Pick a utility function. @sec-models lists every built-in model; any
  Python function can also be wrapped as a model (@sec-advanced).
]

#api(("solve",), syntax: [
  #raw("solve(")#meta("model")#raw(", px=")#meta("float")#raw(", py=")#meta("float")#raw(", income=")#meta("float")#raw(
    ")",
  )
])[
  Solve the consumer's problem and return an immutable `Equilibrium`.

  #param("x", type: "float")[Optimal quantity $x^*$.]
  #param("y", type: "float")[Optimal quantity $y^*$.]
  #param("utility", type: "float")[Utility at the optimum.]
  #param("bundle_type", type: "str")[
    Solution type: `"interior"` for an interior solution, `"boundary"` when the numerical solution sits at a quantity lower bound (e.g. Stone-Geary subsistence), `"kink"` for a Leontief kink and `"corner"` for a perfect-substitutes corner.
  ]

  #modify[```python
  from utility_viz import solve
  eq = solve(model, px=2.0, py=3.0, income=30.0)
  print(eq.x, eq.y, round(eq.utility, 3))

  # 7.5 5.0 6.124
  ```]
]

#api(("levels.around",), syntax: [
  #raw("levels.around(")#meta("utility")#raw(", n=")#meta("int")#raw(")")
])[
  Generate $n$ utility levels centred on a given utility. @fig-quickstart
  uses `n=5`, so it draws five indifference curves.

  `levels.around()` keeps the given utility among the levels, so the
  equilibrium lies on one of the curves. Passing `levels=5` instead lets the
  canvas pick levels from the sampled utility range, which need not include
  the equilibrium utility. To compare the same preferences across several
  figures, compute `lvls` once and pass it to each figure.
]

#api(("Canvas",), syntax: [
  #raw("Canvas(x_max=")#meta("float")#raw(", y_max=")#meta("float")#raw(", ...)")
])[
  Create the canvas and set the axis ranges; the other options are
  described in @sec-canvas.

  The axis ranges only control what is shown; they play no part in
  `solve()`. If the equilibrium is missing from the figure, check whether
  `eq.x` or `eq.y` lies outside the range and raise the axis limits.
]

#api(("Canvas.add_*",))[
  Add indifference curves, a budget line or the equilibrium to the same
  canvas. The calls can be chained (@sec-chaining). `add_equilibrium()` uses
  an existing solution and does not solve again; after changing prices,
  income or the model, call `solve()` again and build a new figure.
]

#api(("Canvas.save", "Canvas.show"))[
  `save()` writes the file in the format given by its extension
  (@sec-export); `show()` opens a #pkg("matplotlib") window. Output paths are
  relative to the working directory of the script; create any subdirectory
  beforehand.
]

=== Checking inputs and failed solves

Prices and income must be positive; otherwise `solve()` raises
`InvalidParameterError`#footnote[Smooth models are solved with sequential least squares programming (SLSQP).].

When the solver does not converge, `solve()` raises `OptimizationError`
rather than returning an invalid equilibrium.

#modify[```python
from utility_viz import InvalidParameterError, OptimizationError, solve

try:
    eq = solve(model, px=2.0, py=3.0, income=30.0)
except (InvalidParameterError, OptimizationError) as error:
    print(error)
else:
    print(round(eq.x, 3), round(eq.y, 3), eq.bundle_type)
```]

#changed("2.0.0b1", label: "UtilityVizError")[#modify[`UtilityVizError` is the base exception; `EconVizError` remains as an alias of the same class]]
#modify[Every exception the package raises derives from `UtilityVizError`;
catch it to handle all of them at once. `EconVizError`, its 1.x name, is
the same class.]

Numerical solutions carry small errors: a result may be close to, but not
exactly, `7.5`. Compare with a tolerance when checking results, and round
with `round()` only for display, so early rounding does not distort later
calculations.

#import "/template/manual.typ": *

= #LaTeX parsing <sec-latex>

#api(("parse_latex",), syntax: [#raw("parse_latex(")#meta("expression")#raw(")")])[
  Parse a #LaTeX utility function into a model, usable with `solve()`,
  `Canvas` or any other API that takes a model.

  ```python
  from utility_viz import parse_latex

  model = parse_latex(r"x^{0.4} y^{0.6}")  # CobbDouglas(alpha=0.4, beta=0.6)
  model = parse_latex(r"\min(2x, 3y)")     # Leontief(a=2.0, b=3.0)
  model = parse_latex(r"2x + 3y")          # PerfectSubstitutes(a=2.0, b=3.0)
  ```
]

== Supported forms

@tab-latex lists the accepted forms. Omitted coefficients and exponents
default to 1.

#tbl(caption: [Utility functions recognised by `parse_latex`.])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([Family], [Pattern], [Example]),
    [Cobb-Douglas],
    [`x^{α} y^{β}` or `x^α y^β`],
    [`x^{0.3} y^{0.7}`],
    [Perfect complements],
    [`\min(ax, by)` or `min(ax, by)`],
    [`\min(2x, y)`],
    [Perfect substitutes],
    [`ax + by`],
    [`3x + 1.5y`],
    [CES],
    [`(αx^ρ + βy^ρ)^{1/ρ}`],
    [`(0.4x^{-0.5}+0.6y^{-0.5})^{-2}`],
  )
] <tab-latex>

A leading `U =` or `u(x, y) =` may be omitted:

```text
U(x,y) = x^{0.5} y^{0.5}
U = x^{0.5} y^{0.5}
x^{0.5} y^{0.5}
```

#example([```python
from utility_viz import Canvas, Config, levels, parse_latex, solve

Config.load("manual.toml").use()  # figure settings

model = parse_latex(r"\min(2x, 3y)")  # Leontief(a=2.0, b=3.0)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=5), show_kinks=True)
cvs.add_budget(2.0, 3.0, 30.0)
cvs.add_equilibrium(eq)
cvs.save("leontief.png")
```])

#fig("/figures/latex/leontief.svg", width: 56%, caption: [
  `parse_latex(r"\min(2x, 3y)")`
])

#example([```python
from utility_viz import Canvas, Config, levels, parse_latex, solve

Config.load("manual.toml").use()  # figure settings

model = parse_latex(r"2x + 3y")  # PerfectSubstitutes(a=2.0, b=3.0)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=5))
cvs.add_budget(2.0, 3.0, 30.0)
cvs.add_equilibrium(eq)
cvs.save("perfect_substitutes.png")
```])

#fig("/figures/latex/perfect_substitutes.svg", width: 56%, caption: [
  `parse_latex(r"2x + 3y")`
])

== Errors

Unparseable input raises `utility_viz.ParseError`, whose message
lists the supported forms:

```python
from utility_viz import ParseError, parse_latex

try:
    model = parse_latex(r"x^2 + y^2")
except ParseError as e:
    print(e)

# Unrecognised LaTeX utility function: 'x^2 + y^2'
# Supported forms:
#   Cobb-Douglas       : x^{alpha} y^{beta}
#   Leontief           : \min(ax, by)
#   Perfect Substitutes: ax + by
#   CES                : (alpha x^{rho} + beta y^{rho})^{1/rho}
```

== In the command-line tool

`utility-viz plot --latex` uses the same parser and accepts the same input
(@sec-cli-plot):

```bash
utility-viz plot --latex "x^{0.4} y^{0.6}" --px 2 --py 3 --income 30 -o out.png
```

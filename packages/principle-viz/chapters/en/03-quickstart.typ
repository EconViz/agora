#import "/template/manual.typ": *

= Quick start <sec-quickstart>

== A minimal example

This chapter works through one market, used again in later chapters:
$
  "demand:" & quad p = 10 - Q, \
  "supply:" & quad p = 2 + Q.
$

#example(```python
from principle_viz import MarketFigure, line_from_inverse, solve_equilibrium

demand = line_from_inverse(10.0, -1.0)   # p = 10 - Q
supply = line_from_inverse(2.0, 1.0)     # p = 2 + Q
eq = solve_equilibrium(demand, supply)
print(eq.q_star, eq.p_star)              # 4.0 6.0

fig = MarketFigure(x_max=12, y_max=12, title="Basic Equilibrium")
fig.add_curves(demand, supply, q_max=10)
fig.add_equilibrium(eq)
fig.finalize()
fig.save("basic_equilibrium.png")
```)

#fig("/figures/quickstart/equilibrium.svg", width: 46%, caption: [
  The market of @sec-quickstart (title omitted).
]) <fig-quickstart>

Demand equals supply where $10 - Q = 2 + Q$, so $Q^* = 4$ and $p^* = 6$.
@fig-quickstart shows the result: each curve is named at its end, the
equilibrium is a filled point named $e^*$, and the axes are titled $p$ and
$Q$ past their arrow tips.

== Step by step

Every figure follows the same four steps.

+ *Describe the market.* `line_from_inverse(a, b)` builds the line
  $p = a + b Q$ (@sec-markets).
+ *Solve.* A solver such as `solve_equilibrium()` returns a frozen
  dataclass of numbers. Nothing is drawn yet.
+ *Draw.* `MarketFigure` is a square diagram with price and quantity axes.
  Its `add_*` methods take curves and results and add the matching layers;
  each returns the figure, so calls can be chained.
+ *Finish and save.* `finalize()` tidies guide lines that would cut a shaded
  area in two; `save()` writes PNG, SVG or PDF, chosen by the file
  extension.

The calculation and the drawing are independent: a result can be printed,
compared or exported without drawing it, and the same result can be drawn on
several figures.

== Results

Results are immutable dataclasses whose fields are plain floats, strings and
tuples. `solve_equilibrium()` returns an `EquilibriumResult`:

#param("q_star", type: "float")[Equilibrium quantity $Q^*$.]
#param("p_star", type: "float")[Equilibrium price $p^*$.]
#param("is_valid_market", type: "bool")[`False` when the equilibrium quantity is negative; a negative price only adds a note.]
#param("notes", type: "tuple[str, ...]")[Explanations of anything unusual about the solution.]

Invalid input raises an exception derived from `PrincipleVizError`
(@sec-errors), so a failed solve is never mistaken for a result.

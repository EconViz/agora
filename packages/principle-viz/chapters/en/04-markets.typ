#import "/template/manual.typ": *

= Linear markets <sec-markets>

== Lines

A demand or supply curve is a straight line in inverse form:

$
  p = a + b Q
$

where $a$ is the price intercept and $b$ the slope ($b < 0$ for demand,
$b > 0$ for supply). Price is always on the vertical axis and quantity on the
horizontal one, following #citet(<marshall1890>). Discrete unit schedules
(@sec-discrete) and market curves summed from individual curves
(@sec-aggregation) are not single straight lines.

#api(("Line",), syntax: [
  #raw("Line.from_inverse(")#meta("float")#raw(", ")#meta("float")#raw(")") \
  #raw("Line.from_standard(")#meta("float")#raw(", ")#meta("float")#raw(", ")#meta("float")#raw(")")
])[
  A straight line in the price--quantity plane, stored as
  $A p + B Q + C = 0$ so that horizontal and vertical lines are allowed.
  `from_inverse(a, b)` builds $p = a + b Q$; `from_standard(A, B, C)` builds
  $A p + B Q + C = 0$. The package root also exports the two constructors as
  `line_from_inverse()` and `line_from_standard()`.
]

#param("p_at(q)")[Price at quantity $q$.]
#param("q_at(p)")[Quantity at price $p$.]
#param("p_intercept()")[Price at $Q = 0$ (the choke price of a demand curve).]
#param("q_intercept()")[Quantity at $p = 0$.]
#param("slope()")[$dif p slash dif Q$.]
#param("to_inverse()")[`(a, b)` for $p = a + b Q$.]
#param("shifted()")[A new line with `delta_intercept` ($Delta a$) added to the intercept and `delta_slope` ($Delta b$) added to the slope.]

```python
from principle_viz import line_from_inverse, line_from_standard

demand = line_from_inverse(10.0, -1.0)
print(demand.q_at(4), demand.p_at(3))         # 6.0 7.0
print(demand.p_intercept(), demand.q_intercept())  # 10.0 10.0
print(line_from_standard(1, 1, -10).to_inverse())  # (10.0, -1.0)
```

$(A, B, C) = (1, 1, -10)$ is equivalent to $p = 10 - Q$.

A horizontal line has no $Q(p)$ and a vertical line has no $p(Q)$; the
corresponding methods raise `NonInvertibleLineError`.

== Equilibrium

#api(("solve_equilibrium",), syntax: [
  #raw("solve_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(")")
])[
  The intersection of two lines, returned as an `EquilibriumResult`
  (@sec-quickstart). Parallel lines raise `ParallelLinesError`, identical
  lines `CoincidentLinesError`.
]

```python
from principle_viz import solve_equilibrium

eq = solve_equilibrium(demand, line_from_inverse(2.0, 1.0))
print(eq)
# EquilibriumResult(q_star=4.0, p_star=6.0,
#                   is_valid_market=True, notes=())
```

$10 - Q = 2 + Q$ gives an equilibrium quantity of 4 and an equilibrium price
of 6; `is_valid_market` is `True` and `notes` is empty.

== Comparative statics <sec-shifts>

#changed("0.10.0", label: "add_comparative_statics")[Redraws only the curve that moved; shifted curves are named $D_1$ / $S_1$ (`demand_label` / `supply_label`)]
#changed("0.10.0", label: "add_comparative_statics")[Movement arrows are thin, black and dashed]

#api(("ShiftSpec", "ShiftScenario"), syntax: [
  #raw("ShiftSpec(delta_intercept=0.0, delta_slope=0.0)") \
  #raw("ShiftScenario(demand_shift=None, supply_shift=None)")
])[
  A shift of one curve in inverse form: `delta_intercept` moves it up
  ($> 0$) or down, `delta_slope` rotates it. A scenario shifts demand,
  supply or both. Both live in `principle_viz.core.shifts`.

  An increase in demand raises the demand intercept; an increase in supply
  lowers the supply intercept, since sellers accept a lower price at every
  quantity.
]

#api(("comparative_statics",), syntax: [
  #raw("comparative_statics(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  Solve the market before and after the shift. The result has these fields:
]

#param("baseline_equilibrium")[The `EquilibriumResult` before the shift.]
#param("shifted_equilibrium")[The `EquilibriumResult` after the shift.]
#param("shifted_market")[The baseline and shifted lines (`baseline_demand`, `shifted_demand`, ...).]
#param("delta_q")[Change in quantity.]
#param("delta_p")[Change in price.]
#param("direction_q")[Direction of the quantity change: `"left"` or `"right"` (`"none"` when unchanged).]
#param("direction_p")[Direction of the price change: `"up"` or `"down"` (`"none"` when unchanged).]

```python
from principle_viz import comparative_statics
from principle_viz.core.shifts import ShiftScenario, ShiftSpec

up = ShiftScenario(demand_shift=ShiftSpec(delta_intercept=3.0))
result = comparative_statics(demand, supply, up)
new = result.shifted_equilibrium
print(new.q_star, new.p_star)                  # 5.5 7.5
print(result.direction_q, result.direction_p)  # right up
```

#api(("MarketFigure.add_comparative_statics",), syntax: [
  #raw("add_comparative_statics(")#meta("result")#raw(", q_max, *, demand_label=\"$D_1$\", supply_label=\"$S_1$\")")
])[
  Draw the curve that moved, both equilibria and dashed arrows from the old
  equilibrium to the new one. Name the original curves $D_0$ and $S_0$ in
  `add_curves()`. An increase in demand is shown in @fig-shifts and a
  decrease in supply in @fig-shift-supply.
]

```python
fig = MarketFigure(x_max=12, y_max=14, title="Increase in Demand")
fig.add_curves(
    demand, supply, q_max=10,
    demand_label="$D_0$", supply_label="$S_0$",
)
fig.add_comparative_statics(result, q_max=10)
fig.finalize()
```

#fig("/figures/markets/shift_demand_increase.svg", width: 46%, caption: [
  An increase in demand.
]) <fig-shifts>

#fig("/figures/markets/shift_supply_decrease.svg", width: 46%, caption: [
  A decrease in supply.
]) <fig-shift-supply>

== Errors <sec-errors>

Every exception the package raises derives from `PrincipleVizError`, in
`principle_viz.exceptions`; catching it handles all of them.
`PrincipleEconError`, the name before 0.10.0, is the same class. @tab-errors
lists when each exception is raised.

#tbl(caption: [Exceptions])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Exception], [Raised when]),
    [`LineError`], [A line cannot be built or transformed],
    [`NonInvertibleLineError`], [A horizontal line is asked for $Q(p)$, or a vertical one for $p(Q)$],
    [`ParallelLinesError`], [Demand and supply never meet],
    [`CoincidentLinesError`], [Demand and supply are the same line],
    [`PolicyError`], [A tax, subsidy, control or trade scenario is invalid],
    [`DiscreteMarketError`], [A discrete schedule is invalid (@sec-discrete)],
    [`AggregationError`, `PiecewiseLinearError`], [Individual curves cannot be summed, or a price is outside a piecewise curve (@sec-aggregation)],
    [`PPFError`], [A production possibilities frontier is invalid (@sec-ppf)],
  )
] <tab-errors>

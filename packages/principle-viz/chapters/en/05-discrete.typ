#import "/template/manual.typ": *

= Discrete markets <sec-discrete>

#changed("0.10.0", label: "MarketFigure.add_discrete_curves")[Accepts a demand schedule, a supply schedule, or both]
#changed("0.10.0", label: "MarketFigure.add_discrete_curves")[Open endpoints are drawn with an opaque white face, joined to the next step by a thin dashed riser]

A discrete market lists units one at a time: each buyer's willingness to pay
for one more unit, and each seller's cost of one more unit. Demand and
supply are step functions, and the equilibrium is a whole number of units
with a range of prices that support it.

== Schedules

#api(("DiscreteDemand", "DiscreteSupply"), syntax: [
  #raw("DiscreteDemand(")#meta("values")#raw(")") \
  #raw("DiscreteSupply(")#meta("values")#raw(")")
])[
  A demand schedule holds marginal willingness-to-pay values, weakly
  decreasing from the first unit to the last; a supply schedule holds
  marginal costs, weakly increasing. Values out of order raise
  `DiscreteMarketError`.
]

#param("quantity_at(price)")[Units bought or sold at `price`; a buyer or seller indifferent at the price trades.]
#param("unit_count")[Number of units in the schedule.]
#param("combine(*schedules)")[Merge several individual schedules into a market schedule (@sec-aggregation).]

== Equilibrium

#api(("solve_discrete_equilibrium",), syntax: [
  #raw("solve_discrete_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(", *, price_rule=\"midpoint\")")
])[
  Trade every unit whose value is at least its cost, and find the interval
  of prices at which exactly that many units are bought and sold. The
  result has these fields:
]

#param("q_star", type: "int")[Units traded.]
#param("price_low, price_high", type: "float")[The interval of supporting prices.]
#param("price", type: "float")[The price chosen from the interval by `price_rule`.]
#param("price_rule", type: "EquilibriumPriceRule")[`MIDPOINT` (default), `LOWER` or `UPPER`; the strings `"midpoint"`, `"lower"` and `"upper"` work too.]
#param("traded_values, traded_costs", type: "tuple")[Values and costs of the traded units.]
#param("gains_from_trade", type: "tuple")[Value minus cost of each traded unit.]
#param("is_unique_price", type: "bool")[Whether the interval is a single price.]

`solve_discrete_market(demand_values, supply_values)` builds both schedules
from plain tuples and solves in one call.

```python
from principle_viz import DiscreteDemand, DiscreteSupply, solve_discrete_equilibrium

demand = DiscreteDemand((11, 9, 7, 5, 3))
supply = DiscreteSupply((1, 3, 5, 8, 10))
eq = solve_discrete_equilibrium(demand, supply)
print(eq.q_star, eq.price_low, eq.price_high, eq.price)  # 3 5.0 7.0 6.0
print(eq.gains_from_trade)                               # (10.0, 6.0, 2.0)
```

Three units trade: the third is worth 7 and costs 5, the fourth is worth 5
but costs 8. Any price from 5 to 7 clears the market; the midpoint rule
reports 6.

#api(("compute_discrete_surplus",), syntax: [
  #raw("compute_discrete_surplus(")#meta("result")#raw(")")
])[
  Consumer and producer surplus at the chosen price, in total and unit by
  unit (`consumer_surplus_by_unit`, `producer_surplus_by_unit`). At a price
  of 6 above, both are $5 + 3 + 1 = 9$.
]

== Figure

#api(("MarketFigure.add_discrete_curves", "MarketFigure.add_discrete_equilibrium"), syntax: [
  #raw("add_discrete_curves(demand=None, supply=None, *, demand_label=\"$D$\", supply_label=\"$S$\")") \
  #raw("add_discrete_equilibrium(")#meta("result")#raw(")")
])[
  Draw each unit as a step $[q, q + 1)$: a filled point where the step
  starts (included) and an open point where it ends (excluded), joined to
  the next step by a dashed riser. Pass one schedule or both. The
  equilibrium marks $Q^*$ and the price interval on the axes (@fig-discrete).
]

```python
fig = MarketFigure(x_max=5.5, y_max=12, title="Discrete Demand and Supply")
fig.add_discrete_curves(demand, supply)
fig.add_discrete_equilibrium(eq)
fig.finalize()
```

#fig("/figures/discrete/market.svg", width: 46%, caption: [
  Discrete demand and supply.
]) <fig-discrete>

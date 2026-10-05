#import "/template/manual.typ": *

= Market curves from individuals <sec-aggregation>

#changed("0.10.0", label: "market_demand")[Market demand and supply as the horizontal sum of individual linear curves, with `PiecewiseLinear`, `solve_piecewise_equilibrium()` and `piecewise_surplus()`]
#changed("0.10.0", label: "DiscreteDemand.combine")[`combine()` and `quantity_at()` for discrete schedules]

A market curve is the horizontal sum of the individual curves: at each price,
market quantity is the sum of the quantities every buyer (or seller) chooses
at that price. A buyer buys nothing above the choke price and a seller sells
nothing below the minimum price. The market curve of linear individuals is
piecewise linear, with a kink where each additional individual enters.

== Summing linear curves

#api(("market_demand", "market_supply"), syntax: [
  #raw("market_demand(")#meta("individuals")#raw(")") \
  #raw("market_supply(")#meta("individuals")#raw(", *, p_max)")
])[
  Sum downward-sloping (demand) or upward-sloping (supply) individual lines.
  The supply sum runs from the lowest minimum price up to `p_max`. Curves of
  the wrong slope raise `AggregationError`.
]

#api(("PiecewiseLinear",), syntax: [
  #raw("PiecewiseLinear(")#meta("points")#raw(")")
])[
  A demand or supply curve through `points` $(Q, p)$, ordered by quantity.
  If the first point has $Q = 0$, quantity is zero at prices beyond it.
]

#param("q_at(p)")[Quantity at a price; a price outside the curve raises `PiecewiseLinearError`.]
#param("p_at(q)")[Price at a quantity; a quantity outside the curve raises `PiecewiseLinearError`.]
#param("points")[All vertices.]
#param("kinks")[The interior vertices where the slope changes.]
#param("domain")[Quantity range covered.]
#param("price_range")[Price range covered.]
#param("breakpoints()")[Vertex prices in ascending order.]
#param("integrate_q()")[Area under $Q(p)$ between the prices `p_low` and `p_high`.]

```python
from principle_viz import (
    line_from_inverse, market_demand, market_supply,
)

a = line_from_inverse(10, -2)    # p = 10 - 2Q
b = line_from_inverse(6, -0.5)   # p = 6 - 0.5Q
demand = market_demand((a, b))
print(demand.points)   # ((0.0, 10.0), (2.0, 6.0), (17.0, 0.0))
print(demand.q_at(4))  # 7.0 = Q_A + Q_B = 3 + 4
```

Buyer B enters at a price of 6, giving the kink $(2, 6)$. At a price of 4,
$Q_A = 3$ and $Q_B = 4$, so market demand is 7.

#api(("solve_piecewise_equilibrium", "piecewise_surplus"), syntax: [
  #raw("solve_piecewise_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(")") \
  #raw("piecewise_surplus(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("result")#raw(")")
])[
  The exact market equilibrium, solved segment by segment, and the consumer
  and producer surplus at it, integrated along price.
]

```python
from principle_viz import (
    piecewise_surplus, solve_piecewise_equilibrium,
)

c = line_from_inverse(2, 1)
d = line_from_inverse(5, 0.5)
supply = market_supply((c, d), p_max=10)
eq = solve_piecewise_equilibrium(demand, supply)
print(round(eq.q_star, 3), round(eq.p_star, 3))  # 3.818 5.273
cs, ps = piecewise_surplus(demand, supply, eq)
```

`piecewise_surplus()` returns the consumer and producer surplus integrated
along price.

== Summing discrete schedules

`DiscreteDemand.combine(*schedules)` merges every buyer's reservation prices
into one market schedule, highest first; `DiscreteSupply.combine()` merges
unit costs, lowest first. Equal values remain separate units, and the result
works with `solve_discrete_equilibrium()` (@sec-discrete). The output is
shown in @fig-discrete-market-demand.

```python
from principle_viz import DiscreteDemand

first = DiscreteDemand((10, 7, 4))
second = DiscreteDemand((8, 5, 2))
market = DiscreteDemand.combine(first, second)
print(market.values)
# (10.0, 8.0, 7.0, 5.0, 4.0, 2.0)
```

== Aggregation figures

#changed("0.10.0", label: "demand_aggregation_figure")[Individual | individual | market figures for demand and supply, linear and discrete, returning an `AggregationFigure`]
#changed("0.10.0", label: "demand_aggregation_figure")[`link_price=True` runs the price line across every panel]
#changed("0.10.1", label: "demand_aggregation_figure")[The market curve names the demand that is active at a kink]

#api(("demand_aggregation_figure", "supply_aggregation_figure", "discrete_demand_aggregation_figure", "discrete_supply_aggregation_figure"), added: "v0.10.0", syntax: [
  #raw("demand_aggregation_figure(")#meta("individuals")#raw(", *, price, price_label=\"$p_1$\", link_price=False, ...)") \
  #raw("supply_aggregation_figure(")#meta("individuals")#raw(", *, price, p_max, ...)") \
  #raw("discrete_demand_aggregation_figure(")#meta("individuals")#raw(", *, price, ...)") \
  #raw("discrete_supply_aggregation_figure(")#meta("individuals")#raw(", *, price, ...)")
])[
  One panel per individual, then the market, side by side and sharing the
  price axis. `individuals` maps each name to a curve or schedule; the
  curves are named $D_A$, $D_B$, ... and $D$ (or $S_A$, ..., $S$). Dashed
  guides at `price` mark $Q_A$, $Q_B$ and $Q_A + Q_B = Q$.
  `supply_aggregation_figure()` also needs `p_max`.
]

#param("link_price", type: "bool", default: "False")[Run the price line across every panel and the gaps between them, marking the price on the first panel only.]
#param("theme")[As for `MarketFigure` (@sec-palettes).]
#param("palette")[As for `MarketFigure` (@sec-palettes).]
#param("labels")[Label overrides by layer id (@sec-labels).]
#param("visibility")[Layer visibility by layer id (@sec-labels).]

The returned `AggregationFigure` has `save()`, `hide()`, `show()`,
`configure_label()`, `layer_ids` and `label_ids`, like `MarketFigure`.

```python
from principle_viz import demand_aggregation_figure

fig = demand_aggregation_figure(
    {"A": a, "B": b}, price=4, link_price=True,
)
fig.save("market_demand.png")
```

The output of `demand_aggregation_figure()` is shown in @fig-market-demand.

#fig("/figures/aggregation/market_demand.svg", width: 100%, caption: [
  Market demand as the horizontal sum.
]) <fig-market-demand>

#fig("/figures/aggregation/discrete_market_demand.svg", width: 100%, caption: [
  Combining two discrete demand schedules.
]) <fig-discrete-market-demand>

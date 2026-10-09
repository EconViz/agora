#import "/template/manual.typ": *

= 由个人加总市场曲线 <sec-aggregation>

#changed("0.10.0", label: "market_demand")[个人线性曲线水平加总为市场需求与供给，并新增 `PiecewiseLinear`、`solve_piecewise_equilibrium()` 与 `piecewise_surplus()`]
#changed("0.10.0", label: "DiscreteDemand.combine")[离散表新增 `combine()` 与 `quantity_at()`]

市场曲线是个人曲线的水平加总：在每个价格下，市场数量等于所有买方（或卖方）在该价格下选择的数量之和。买方在阻绝价格以上不购买，卖方在最低价格以下不销售。线性个人曲线加总后的市场曲线是分段线性的，每多一人进入市场出现一个折点。

== 加总线性曲线

#api(("market_demand", "market_supply"), syntax: [
  #raw("market_demand(")#meta("individuals")#raw(")") \
  #raw("market_supply(")#meta("individuals")#raw(", *, p_max)")
])[
  加总负斜率（需求）或正斜率（供给）的个人直线。供给加总由最低的最低价格延伸到 `p_max`。斜率方向不符时抛出 `AggregationError`。
]

#api(("PiecewiseLinear",), syntax: [
  #raw("PiecewiseLinear(")#meta("points")#raw(")")
])[
  通过 `points` $(Q, p)$ 的需求或供给曲线，点依数量排序。若第一点的 $Q = 0$，超出该点的价格下数量为零。
]

#param("q_at(p)")[价格对应的数量；超出曲线范围时抛出 `PiecewiseLinearError`。]
#param("p_at(q)")[数量对应的价格；超出曲线范围时抛出 `PiecewiseLinearError`。]
#param("points")[所有顶点。]
#param("kinks")[斜率改变的内部顶点。]
#param("domain")[涵盖的数量范围。]
#param("price_range")[涵盖的价格范围。]
#param("breakpoints()")[顶点价格，由小到大排列。]
#param("integrate_q()")[`p_low` 与 `p_high` 两个价格之间 $Q(p)$ 下方的面积。]

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

买方 B 在价格 6 进入市场，折点为 $(2, 6)$。价格为 4 时，$Q_A = 3$、$Q_B = 4$，市场需求量为 7。

#api(("solve_piecewise_equilibrium", "piecewise_surplus"), syntax: [
  #raw("solve_piecewise_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(")") \
  #raw("piecewise_surplus(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("result")#raw(")")
])[
  逐段精确求解的市场均衡，以及沿价格积分得到的消费者剩余与生产者剩余。
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

== 加总离散表

`DiscreteDemand.combine(*schedules)` 将所有买方的保留价格合并为一张市场表，由高到低排列；`DiscreteSupply.combine()` 合并单位成本，由低到高排列。相同的数值保留为不同单位，合并结果可直接交给 `solve_discrete_equilibrium()`（详见#ref(<sec-discrete>)）。输出参见#ref(<fig-discrete-market-demand>)。

```python
from principle_viz import DiscreteDemand

first = DiscreteDemand((10, 7, 4))
second = DiscreteDemand((8, 5, 2))
market = DiscreteDemand.combine(first, second)
print(market.values)
# (10.0, 8.0, 7.0, 5.0, 4.0, 2.0)
```


== 加总图

#changed("0.10.0", label: "demand_aggregation_figure")[需求与供给（线性与离散）的*个人 | 个人 | 市场*图，返回 `AggregationFigure`]
#changed("0.10.0", label: "demand_aggregation_figure")[`link_price=True` 让价格线横跨所有面板]
#changed("0.10.1", label: "demand_aggregation_figure")[市场曲线在折点处标出当时有效的需求]

#api(("demand_aggregation_figure", "supply_aggregation_figure", "discrete_demand_aggregation_figure", "discrete_supply_aggregation_figure"), added: "v0.10.0", syntax: [
  #raw("demand_aggregation_figure(")#meta("individuals")#raw(", *, price, price_label=\"$p_1$\", link_price=False, ...)") \
  #raw("supply_aggregation_figure(")#meta("individuals")#raw(", *, price, p_max, ...)") \
  #raw("discrete_demand_aggregation_figure(")#meta("individuals")#raw(", *, price, ...)") \
  #raw("discrete_supply_aggregation_figure(")#meta("individuals")#raw(", *, price, ...)")
])[
  每位个人一个面板，最后是市场面板，左右并排并共用价格轴。`individuals` 将名称对应到曲线或逐单位表；曲线命名为 $D_A$、$D_B$……与 $D$（或 $S_A$……与 $S$）。在 `price` 处以虚线标出 $Q_A$、$Q_B$ 与 $Q_A + Q_B = Q$。`supply_aggregation_figure()` 另需 `p_max`。
]

#param("link_price", type: "bool", default: "False")[让价格线横跨所有面板及面板间的空隙，只在第一个面板标出价格。]
#param("theme")[与 `MarketFigure` 相同（详见#ref(<sec-palettes>)）。]
#param("palette")[与 `MarketFigure` 相同（详见#ref(<sec-palettes>)）。]
#param("labels")[依图层 id 覆盖标签（详见#ref(<sec-labels>)）。]
#param("visibility")[依图层 id 覆盖图层的显示状态（详见#ref(<sec-labels>)）。]

返回的 `AggregationFigure` 与 `MarketFigure` 一样提供 `save()`、`hide()`、`show()`、`configure_label()`、`layer_ids` 与 `label_ids`。

```python
from principle_viz import demand_aggregation_figure

fig = demand_aggregation_figure(
    {"A": a, "B": b}, price=4, link_price=True,
)
fig.save("market_demand.png")
```

`demand_aggregation_figure()` 的输出参见#ref(<fig-market-demand>)。

#fig("/figures/aggregation/market_demand.svg", width: 100%, caption: [
  水平加总的市场需求。
]) <fig-market-demand>

#fig("/figures/aggregation/discrete_market_demand.svg", width: 100%, caption: [
  合并两张离散需求表。
]) <fig-discrete-market-demand>

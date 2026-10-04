#import "/template/manual.typ": *

= 离散市场 <sec-discrete>

#changed("0.10.0", label: "MarketFigure.add_discrete_curves")[可只传入需求表、只传入供给表，或两者都传入]
#changed("0.10.0", label: "MarketFigure.add_discrete_curves")[空心端点改为不透明的白色填色，并以细虚线连到下一阶]

离散市场逐一列出每个单位：买方对多一单位的愿付价格，以及卖方多生产一单位的成本。需求与供给都是阶梯函数；均衡是整数个单位，并由一段价格区间支持。

== 逐单位表

#api(("DiscreteDemand", "DiscreteSupply"), syntax: [
  #raw("DiscreteDemand(")#meta("values")#raw(")") \
  #raw("DiscreteSupply(")#meta("values")#raw(")")
])[
  需求表存放边际愿付价格，由第一单位到最后一单位弱递减；供给表存放边际成本，弱递增。顺序不符时抛出 `DiscreteMarketError`。
]

#param("quantity_at(price)")[价格为 `price` 时的成交单位数；在该价格下无差异的买方或卖方会交易。]
#param("unit_count")[表中的单位数。]
#param("combine(*schedules)")[将多个个人表合并为市场表（详见#ref(<sec-aggregation>)）。]

== 均衡

#api(("solve_discrete_equilibrium",), syntax: [
  #raw("solve_discrete_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(", *, price_rule=\"midpoint\")")
])[
  交易所有价值不低于成本的单位，并找出恰好使该数量成交的价格区间。结果包含下列字段：
]

#param("q_star", type: "int")[成交单位数。]
#param("price_low, price_high", type: "float")[支持均衡的价格区间。]
#param("price", type: "float")[按 `price_rule` 从区间中选出的价格。]
#param("price_rule", type: "EquilibriumPriceRule")[`MIDPOINT`（默认）、`LOWER` 或 `UPPER`；也可传入字串 `"midpoint"`、`"lower"`、`"upper"`。]
#param("traded_values, traded_costs", type: "tuple")[成交单位的价值与成本。]
#param("gains_from_trade", type: "tuple")[每个成交单位的价值减成本。]
#param("is_unique_price", type: "bool")[区间是否只有单一价格。]

`solve_discrete_market(demand_values, supply_values)` 直接由 tuple 创建两张表并求解。

```python
from principle_viz import DiscreteDemand, DiscreteSupply, solve_discrete_equilibrium

demand = DiscreteDemand((11, 9, 7, 5, 3))
supply = DiscreteSupply((1, 3, 5, 8, 10))
eq = solve_discrete_equilibrium(demand, supply)
print(eq.q_star, eq.price_low, eq.price_high, eq.price)  # 3 5.0 7.0 6.0
print(eq.gains_from_trade)                               # (10.0, 6.0, 2.0)
```

共成交三个单位：第三单位价值 7、成本 5；第四单位价值 5，但成本为 8。5 到 7 之间的任一价格都能结清市场，中点规则给出 6。

#api(("compute_discrete_surplus",), syntax: [
  #raw("compute_discrete_surplus(")#meta("result")#raw(")")
])[
  所选价格下的消费者剩余与生产者剩余，包含总额与逐单位数值（`consumer_surplus_by_unit`、`producer_surplus_by_unit`）。上例价格为 6 时，两者都是 $5 + 3 + 1 = 9$。
]

== 图形

#api(("MarketFigure.add_discrete_curves", "MarketFigure.add_discrete_equilibrium"), syntax: [
  #raw("add_discrete_curves(demand=None, supply=None, *, demand_label=\"$D$\", supply_label=\"$S$\")") \
  #raw("add_discrete_equilibrium(")#meta("result")#raw(")")
])[
  每个单位画成区间 $[q, q + 1)$ 的一阶：起点为实心点（包含），终点为空心点（不包含），并以虚线连到下一阶。可只传入其中一张表。均衡在坐标轴上标出 $Q^*$ 与价格区间（参见#ref(<fig-discrete>)）。
]

```python
fig = MarketFigure(x_max=5.5, y_max=12, title="Discrete Demand and Supply")
fig.add_discrete_curves(demand, supply)
fig.add_discrete_equilibrium(eq)
fig.finalize()
```

#fig("/figures/discrete/market.svg", width: 46%, caption: [
  离散需求与供给。
]) <fig-discrete>

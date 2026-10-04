#import "/template/manual.typ": *

= 離散市場 <sec-discrete>

#changed("0.10.0", label: "MarketFigure.add_discrete_curves")[可只傳入需求表、只傳入供給表，或兩者都傳入]
#changed("0.10.0", label: "MarketFigure.add_discrete_curves")[空心端點改為不透明的白色填色，並以細虛線連到下一階]

離散市場逐一列出每個單位：買方對多一單位的願付價格，以及賣方多生產一單位的成本。需求與供給都是階梯函數；均衡是整數個單位，並由一段價格區間支持。

== 逐單位表

#api(("DiscreteDemand", "DiscreteSupply"), syntax: [
  #raw("DiscreteDemand(")#meta("values")#raw(")") \
  #raw("DiscreteSupply(")#meta("values")#raw(")")
])[
  需求表存放邊際願付價格，由第一單位到最後一單位弱遞減；供給表存放邊際成本，弱遞增。順序不符時拋出 `DiscreteMarketError`。
]

#param("quantity_at(price)")[價格為 `price` 時的成交單位數；在該價格下無差異的買方或賣方會交易。]
#param("unit_count")[表中的單位數。]
#param("combine(*schedules)")[將多個個人表合併為市場表（詳見#ref(<sec-aggregation>)）。]

== 均衡

#api(("solve_discrete_equilibrium",), syntax: [
  #raw("solve_discrete_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(", *, price_rule=\"midpoint\")")
])[
  交易所有價值不低於成本的單位，並找出恰好使該數量成交的價格區間。結果包含下列欄位：
]

#param("q_star", type: "int")[成交單位數。]
#param("price_low, price_high", type: "float")[支持均衡的價格區間。]
#param("price", type: "float")[依 `price_rule` 從區間中選出的價格。]
#param("price_rule", type: "EquilibriumPriceRule")[`MIDPOINT`（預設）、`LOWER` 或 `UPPER`；也可傳入字串 `"midpoint"`、`"lower"`、`"upper"`。]
#param("traded_values, traded_costs", type: "tuple")[成交單位的價值與成本。]
#param("gains_from_trade", type: "tuple")[每個成交單位的價值減成本。]
#param("is_unique_price", type: "bool")[區間是否只有單一價格。]

`solve_discrete_market(demand_values, supply_values)` 直接由 tuple 建立兩張表並求解。

```python
from principle_viz import DiscreteDemand, DiscreteSupply, solve_discrete_equilibrium

demand = DiscreteDemand((11, 9, 7, 5, 3))
supply = DiscreteSupply((1, 3, 5, 8, 10))
eq = solve_discrete_equilibrium(demand, supply)
print(eq.q_star, eq.price_low, eq.price_high, eq.price)  # 3 5.0 7.0 6.0
print(eq.gains_from_trade)                               # (10.0, 6.0, 2.0)
```

共成交三個單位：第三單位價值 7、成本 5；第四單位價值 5，但成本為 8。5 到 7 之間的任一價格都能結清市場，中點規則回報 6。

#api(("compute_discrete_surplus",), syntax: [
  #raw("compute_discrete_surplus(")#meta("result")#raw(")")
])[
  所選價格下的消費者剩餘與生產者剩餘，包含總額與逐單位數值（`consumer_surplus_by_unit`、`producer_surplus_by_unit`）。上例價格為 6 時，兩者都是 $5 + 3 + 1 = 9$。
]

== 圖形

#api(("MarketFigure.add_discrete_curves", "MarketFigure.add_discrete_equilibrium"), syntax: [
  #raw("add_discrete_curves(demand=None, supply=None, *, demand_label=\"$D$\", supply_label=\"$S$\")") \
  #raw("add_discrete_equilibrium(")#meta("result")#raw(")")
])[
  每個單位畫成區間 $[q, q + 1)$ 的一階：起點為實心點（包含），終點為空心點（不包含），並以虛線連到下一階。可只傳入其中一張表。均衡在座標軸上標出 $Q^*$ 與價格區間（參見#ref(<fig-discrete>)）。
]

```python
fig = MarketFigure(x_max=5.5, y_max=12, title="Discrete Demand and Supply")
fig.add_discrete_curves(demand, supply)
fig.add_discrete_equilibrium(eq)
fig.finalize()
```

#fig("/figures/discrete/market.svg", width: 46%, caption: [
  離散需求與供給。
]) <fig-discrete>

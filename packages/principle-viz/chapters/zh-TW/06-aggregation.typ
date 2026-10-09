#import "/template/manual.typ": *

= 由個人加總市場曲線 <sec-aggregation>

#changed("0.10.0", label: "market_demand")[個人線性曲線水平加總為市場需求與供給，並新增 `PiecewiseLinear`、`solve_piecewise_equilibrium()` 與 `piecewise_surplus()`]
#changed("0.10.0", label: "DiscreteDemand.combine")[離散表新增 `combine()` 與 `quantity_at()`]

市場曲線是個人曲線的水平加總：在每個價格下，市場數量等於所有買方（或賣方）在該價格下選擇的數量之和。買方在阻絕價格以上不購買，賣方在最低價格以下不銷售。線性個人曲線加總後的市場曲線是分段線性的，每多一人進入市場出現一個折點。

== 加總線性曲線

#api(("market_demand", "market_supply"), syntax: [
  #raw("market_demand(")#meta("individuals")#raw(")") \
  #raw("market_supply(")#meta("individuals")#raw(", *, p_max)")
])[
  加總負斜率（需求）或正斜率（供給）的個人直線。供給加總由最低的最低價格延伸到 `p_max`。斜率方向不符時拋出 `AggregationError`。
]

#api(("PiecewiseLinear",), syntax: [
  #raw("PiecewiseLinear(")#meta("points")#raw(")")
])[
  通過 `points` $(Q, p)$ 的需求或供給曲線，點依數量排序。若第一點的 $Q = 0$，超出該點的價格下數量為零。
]

#param("q_at(p)")[價格對應的數量；超出曲線範圍時拋出 `PiecewiseLinearError`。]
#param("p_at(q)")[數量對應的價格；超出曲線範圍時拋出 `PiecewiseLinearError`。]
#param("points")[所有頂點。]
#param("kinks")[斜率改變的內部頂點。]
#param("domain")[涵蓋的數量範圍。]
#param("price_range")[涵蓋的價格範圍。]
#param("breakpoints()")[頂點價格，由小到大排列。]
#param("integrate_q()")[`p_low` 與 `p_high` 兩個價格之間 $Q(p)$ 下方的面積。]

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

買方 B 在價格 6 進入市場，折點為 $(2, 6)$。價格為 4 時，$Q_A = 3$、$Q_B = 4$，市場需求量為 7。

#api(("solve_piecewise_equilibrium", "piecewise_surplus"), syntax: [
  #raw("solve_piecewise_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(")") \
  #raw("piecewise_surplus(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("result")#raw(")")
])[
  逐段精確求解的市場均衡，以及沿價格積分得到的消費者剩餘與生產者剩餘。
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

== 加總離散表

`DiscreteDemand.combine(*schedules)` 將所有買方的保留價格合併為一張市場表，由高到低排列；`DiscreteSupply.combine()` 合併單位成本，由低到高排列。相同的數值保留為不同單位，合併結果可直接交給 `solve_discrete_equilibrium()`（詳見#ref(<sec-discrete>)）。輸出參見#ref(<fig-discrete-market-demand>)。

```python
from principle_viz import DiscreteDemand

first = DiscreteDemand((10, 7, 4))
second = DiscreteDemand((8, 5, 2))
market = DiscreteDemand.combine(first, second)
print(market.values)
# (10.0, 8.0, 7.0, 5.0, 4.0, 2.0)
```


== 加總圖

#changed("0.10.0", label: "demand_aggregation_figure")[需求與供給（線性與離散）的*個人 | 個人 | 市場*圖，回傳 `AggregationFigure`]
#changed("0.10.0", label: "demand_aggregation_figure")[`link_price=True` 讓價格線橫跨所有面板]
#changed("0.10.1", label: "demand_aggregation_figure")[市場曲線在折點處標出當時有效的需求]

#api(("demand_aggregation_figure", "supply_aggregation_figure", "discrete_demand_aggregation_figure", "discrete_supply_aggregation_figure"), added: "v0.10.0", syntax: [
  #raw("demand_aggregation_figure(")#meta("individuals")#raw(", *, price, price_label=\"$p_1$\", link_price=False, ...)") \
  #raw("supply_aggregation_figure(")#meta("individuals")#raw(", *, price, p_max, ...)") \
  #raw("discrete_demand_aggregation_figure(")#meta("individuals")#raw(", *, price, ...)") \
  #raw("discrete_supply_aggregation_figure(")#meta("individuals")#raw(", *, price, ...)")
])[
  每位個人一個面板，最後是市場面板，左右並排並共用價格軸。`individuals` 將名稱對應到曲線或逐單位表；曲線命名為 $D_A$、$D_B$……與 $D$（或 $S_A$……與 $S$）。在 `price` 處以虛線標出 $Q_A$、$Q_B$ 與 $Q_A + Q_B = Q$。`supply_aggregation_figure()` 另需 `p_max`。
]

#param("link_price", type: "bool", default: "False")[讓價格線橫跨所有面板及面板間的空隙，只在第一個面板標出價格。]
#param("theme")[與 `MarketFigure` 相同（詳見#ref(<sec-palettes>)）。]
#param("palette")[與 `MarketFigure` 相同（詳見#ref(<sec-palettes>)）。]
#param("labels")[依圖層 id 覆寫標籤（詳見#ref(<sec-labels>)）。]
#param("visibility")[依圖層 id 覆寫圖層的顯示狀態（詳見#ref(<sec-labels>)）。]

回傳的 `AggregationFigure` 與 `MarketFigure` 一樣提供 `save()`、`hide()`、`show()`、`configure_label()`、`layer_ids` 與 `label_ids`。

```python
from principle_viz import demand_aggregation_figure

fig = demand_aggregation_figure(
    {"A": a, "B": b}, price=4, link_price=True,
)
fig.save("market_demand.png")
```

`demand_aggregation_figure()` 的輸出參見#ref(<fig-market-demand>)。

#fig("/figures/aggregation/market_demand.svg", width: 100%, caption: [
  水平加總的市場需求。
]) <fig-market-demand>

#fig("/figures/aggregation/discrete_market_demand.svg", width: 100%, caption: [
  合併兩張離散需求表。
]) <fig-discrete-market-demand>

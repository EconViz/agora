#import "/template/manual.typ": *

= 線性市場 <sec-markets>

== 直線

需求或供給曲線以反函數形式表示為直線：

$
  p = a + b Q
$

其中 $a$ 為價格截距，$b$ 為斜率（需求 $b < 0$，供給 $b > 0$）。價格一律在縱軸、數量在橫軸，沿用 #citet(<marshall1890>) 的畫法。離散的逐單位表（詳見#ref(<sec-discrete>)）與由個人曲線加總而成的分段線性市場曲線（詳見#ref(<sec-aggregation>)）不是單一直線。

#api(("Line",), syntax: [
  #raw("Line.from_inverse(")#meta("float")#raw(", ")#meta("float")#raw(")") \
  #raw("Line.from_standard(")#meta("float")#raw(", ")#meta("float")#raw(", ")#meta("float")#raw(")")
])[
  價格—數量平面上的直線，內部儲存為 $A p + B Q + C = 0$，因此也能表示水平線與垂直線。`from_inverse(a, b)` 建立 $p = a + b Q$；`from_standard(A, B, C)` 建立 $A p + B Q + C = 0$。套件根目錄另以 `line_from_inverse()` 與 `line_from_standard()` 提供這兩個建構函式。
]

#param("p_at(q)")[數量 $q$ 時的價格。]
#param("q_at(p)")[價格 $p$ 時的數量。]
#param("p_intercept()")[$Q = 0$ 時的價格（需求曲線的阻絕價格）。]
#param("q_intercept()")[$p = 0$ 時的數量。]
#param("slope()")[$dif p slash dif Q$。]
#param("to_inverse()")[$p = a + b Q$ 的 `(a, b)`。]
#param("shifted()")[將截距與斜率分別加上 `delta_intercept`（$Delta a$）與 `delta_slope`（$Delta b$）後的新直線。]

```python
from principle_viz import line_from_inverse, line_from_standard

demand = line_from_inverse(10.0, -1.0)
print(demand.q_at(4), demand.p_at(3))         # 6.0 7.0
print(demand.p_intercept(), demand.q_intercept())  # 10.0 10.0
print(line_from_standard(1, 1, -10).to_inverse())  # (10.0, -1.0)
```

$(A, B, C) = (1, 1, -10)$ 與 $p = 10 - Q$ 等價。

水平線沒有 $Q(p)$，垂直線沒有 $p(Q)$；呼叫對應的方法會拋出 `NonInvertibleLineError`。

== 均衡

#api(("solve_equilibrium",), syntax: [
  #raw("solve_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(")")
])[
  兩條直線的交點，回傳 `EquilibriumResult`（詳見#ref(<sec-quickstart>)）。兩線平行時拋出 `ParallelLinesError`，重合時拋出 `CoincidentLinesError`。
]

```python
from principle_viz import solve_equilibrium

eq = solve_equilibrium(demand, line_from_inverse(2.0, 1.0))
print(eq)
# EquilibriumResult(q_star=4.0, p_star=6.0,
#                   is_valid_market=True, notes=())
```

由 $10 - Q = 2 + Q$ 得均衡數量 4、均衡價格 6，`is_valid_market` 為 `True`，`notes` 為空。

== 比較靜態 <sec-shifts>

#changed("0.10.0", label: "add_comparative_statics")[只重畫移動的曲線；移動後的曲線命名為 $D_1$ / $S_1$（`demand_label` / `supply_label`）]
#changed("0.10.0", label: "add_comparative_statics")[移動箭頭改為黑色細虛線]

#api(("ShiftSpec", "ShiftScenario"), syntax: [
  #raw("ShiftSpec(delta_intercept=0.0, delta_slope=0.0)") \
  #raw("ShiftScenario(demand_shift=None, supply_shift=None)")
])[
  以反函數形式描述一條曲線的移動：`delta_intercept` 為正時向上平移、為負時向下，`delta_slope` 旋轉曲線。情境可同時移動需求、供給或兩者。兩者都位於 `principle_viz.core.shifts`。

  需求增加使需求截距上升；供給增加則使供給截距*下降*，因為賣方在每個數量下都願意接受較低的價格。
]

#api(("comparative_statics",), syntax: [
  #raw("comparative_statics(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  求解移動前後的市場，結果包含下列欄位：
]

#param("baseline_equilibrium")[移動前的 `EquilibriumResult`。]
#param("shifted_equilibrium")[移動後的 `EquilibriumResult`。]
#param("shifted_market")[移動前後的直線（`baseline_demand`、`shifted_demand` 等）。]
#param("delta_q")[數量的變動。]
#param("delta_p")[價格的變動。]
#param("direction_q")[數量的變動方向：`"left"` 或 `"right"`（未變動時為 `"none"`）。]
#param("direction_p")[價格的變動方向：`"up"` 或 `"down"`（未變動時為 `"none"`）。]

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
  畫出移動的曲線、兩個均衡點，以及由舊均衡指向新均衡的虛線箭頭。在 `add_curves()` 中將原曲線命名為 $D_0$ 與 $S_0$。需求增加的結果如#ref(<fig-shifts>)，供給減少的結果如#ref(<fig-shift-supply>)。
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
  需求增加。
]) <fig-shifts>

#fig("/figures/markets/shift_supply_decrease.svg", width: 46%, caption: [
  供給減少。
]) <fig-shift-supply>

== 例外 <sec-errors>

套件拋出的所有例外都繼承自 `principle_viz.exceptions` 中的 `PrincipleVizError`，捕捉它即可一併處理。0.10.0 版以前的名稱 `PrincipleEconError` 是同一個類別。各例外的拋出時機如#ref(<tab-errors>)。

#tbl(caption: [例外類別])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([例外], [拋出時機]),
    [`LineError`], [無法建立或轉換直線],
    [`NonInvertibleLineError`], [對水平線求 $Q(p)$，或對垂直線求 $p(Q)$],
    [`ParallelLinesError`], [需求與供給沒有交點],
    [`CoincidentLinesError`], [需求與供給是同一條直線],
    [`PolicyError`], [租稅、補貼、價格管制或貿易情境無效],
    [`DiscreteMarketError`], [離散逐單位表無效（詳見#ref(<sec-discrete>)）],
    [`AggregationError`、`PiecewiseLinearError`], [個人曲線無法加總，或價格超出分段曲線範圍（詳見#ref(<sec-aggregation>)）],
    [`PPFError`], [生產可能曲線無效（詳見#ref(<sec-ppf>)）],
  )
] <tab-errors>

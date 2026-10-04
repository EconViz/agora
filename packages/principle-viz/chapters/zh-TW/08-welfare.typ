#import "/template/manual.typ": *

= 福利 <sec-welfare>

#changed("0.10.0", label: "MarketFigure.add_welfare")[以文字命名各區塊（"Consumer surplus"、"CS" 等），寫在區塊內、改用縮寫或以引線標示；`labels=False` 只填色]
#changed("0.10.0", label: "MarketFigure.add_welfare")[消費者剩餘與生產者剩餘沿用需求與供給的色相；稅收只標示文字、不填色]

福利分析比較某個市場結果與其他可能結果：消費者剩餘、生產者剩餘、政府收入，以及不再成交的單位所造成的無謂損失。

== 市場結果

#api(("MarketOutcome",), syntax: [
  #raw("MarketOutcome(quantity, consumer_price, producer_price, label=\"\")")
])[
  一個數量，加上買方支付與賣方收到的價格。課稅或補貼時兩個價格不同，價差乘以數量就是政府收入（補貼為負）。此類別位於 `principle_viz.welfare.surplus`，同模組也提供由各種結果建立市場結果的函式：
]

#param("outcome_from_equilibrium(eq)")[自由市場：兩個價格都是 $p^*$。]
#param("outcome_from_tax(tax_eq)")[課稅後（詳見#ref(<sec-taxes>)）。]
#param("outcome_from_subsidy(subsidy_eq)")[補貼後。]
#param("outcome_from_control(control)")[價格上限或下限之下（詳見#ref(<sec-controls>)）。]

== 剩餘

#api(("compute_surplus",), syntax: [
  #raw("compute_surplus(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("outcome")#raw(", baseline_outcome=None)")
])[
  `outcome` 下的福利分解。傳入 `baseline_outcome` 時，以其為基準衡量無謂損失。回傳的 `SurplusResult` 包含下列欄位：
]

#param("consumer_surplus, producer_surplus", type: "float")[需求曲線與消費者價格之間、生產者價格與供給曲線之間的面積。]
#param("tax_revenue", type: "float")[政府收入（補貼為負）。]
#param("total_surplus", type: "float")[三者之和。]
#param("deadweight_loss", type: "float")[相對於基準損失的剩餘。]
#param("polygons", type: "SurplusPolygons")[各面積的頂點，供繪圖使用。]

```python
from principle_viz import compute_surplus, solve_equilibrium
from principle_viz.welfare.surplus import outcome_from_equilibrium

eq = solve_equilibrium(demand, supply)
surplus = compute_surplus(demand, supply, outcome_from_equilibrium(eq))
print(surplus.consumer_surplus, surplus.producer_surplus)   # 8.0 8.0
```

#api(("compare_surplus",), syntax: [
  #raw("compare_surplus(")#meta("demand")#raw(", ")#meta("supply")#raw(", baseline_outcome, policy_outcome)")
])[
  兩個福利分解及其差異：`baseline`、`policy`、`delta_consumer_surplus`、`delta_producer_surplus`、`delta_tax_revenue`、`delta_total_surplus` 與 `deadweight_loss`。#ref(<sec-taxes>)以租稅為例使用此函式。
]

== 圖形

#api(("MarketFigure.add_welfare",), syntax: [
  #raw("add_welfare(")#meta("result")#raw(", *, labels=True, regions=None)")
])[
  為消費者剩餘、生產者剩餘、稅收與無謂損失填色並命名：名稱放得下時寫在區塊內，只放得下縮寫時寫 CS、PS、Tax、DWL，否則以引線標示，且不遮住任何線、點或其他文字。
]

#param("labels", type: "bool", default: "True")[設為 `False` 時只填色、不命名。]
#param("regions", type: "iterable | None", default: "None")[只畫 `"cs"`、`"ps"`、`"tax_revenue"` 與 `"dwl"` 中的部分區塊。]

```python
fig = MarketFigure(x_max=12, y_max=12)
fig.add_curves(demand, supply, q_max=10)
fig.add_welfare(surplus)
fig.add_equilibrium(eq)
fig.finalize()
```

#fig("/figures/welfare/equilibrium.svg", width: 46%, caption: [
  均衡下的消費者與生產者剩餘。
]) <fig-welfare>

#api(("MarketFigure.add_welfare_transition",), syntax: [
  #raw("add_welfare_transition(*, baseline_outcome, policy_outcome, surplus)")
])[
  同樣的區塊，再加上基準與政策下數量及價格的輔助線，用於比較前後差異。
]

== 無謂損失報表

#api(("build_dwl_report",), syntax: [
  #raw("build_dwl_report(")#meta("rows")#raw(")")
])[
  將 `(名稱, 基準, 政策)` 三元組（皆為 `SurplusResult`）轉為報表列（`DWLScenarioRow`），包含數量變動、各項剩餘變動與無謂損失。`principle_viz.welfare.report` 中的 `save_dwl_report_csv()` 與 `save_dwl_report_json()` 可將報表寫成檔案。
]

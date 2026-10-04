#import "/template/manual.typ": *

= 租稅與補貼 <sec-taxes>

#changed("0.1.0", label: "TaxScenario")[`fixed`、`per_unit` 與 `ad_valorem` 三種租稅，法定納稅人可為買方或賣方]
#changed("0.10.0", label: "MarketFigure.add_tax_transform")[課稅後的曲線命名為 $S + t$ / $D - t$；旋轉標籤移到箭頭尾端]

租稅在買方支付的價格與賣方收到的價格之間形成楔差。法定上由誰納稅不影響結果：無論向買方或賣方課徵，楔差、數量與兩個價格都相同 #citep(<mankiw2021>)。

== 情境

#api(("TaxScenario",), syntax: [
  #raw("TaxScenario(tax_type, amount, tax_on=TaxOn.PRODUCER, anchor_mode=AnchorMode.NONE)")
])[
  一項租稅，位於 `principle_viz.policy.tax`。
]

#param("tax_type", type: "TaxType")[`FIXED_TAX` 或 `PER_UNIT_TAX`：每單位課徵固定金額，曲線平移 `amount`；`AD_VALOREM_TAX`：依價格課徵比率，曲線旋轉。兩種從量形式的均衡相同。]
#param("amount", type: "float")[每單位稅額，或從價稅的稅率（`0.35` 即 35%）；稅率必須大於 $-1$。]
#param("tax_on", type: "TaxOn", default: "PRODUCER")[法定納稅人：`PRODUCER` 使供給上移，`CONSUMER` 使需求下移。]
#param("anchor_mode", type: "AnchorMode", default: "NONE")[繪製從價稅時，`NONE` 以截距為軸旋轉曲線，`BASELINE_EQUILIBRIUM` 以未課稅的均衡點為軸。]

== 求解

#api(("solve_tax_equilibrium",), syntax: [
  #raw("solve_tax_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  課稅後的市場，回傳 `TaxEquilibriumResult`：`q_star`、`consumer_price`、`producer_price`、`tax_wedge`（兩價之差）與 `tax_revenue`（楔差乘以數量）。
]

```python
from principle_viz import solve_tax_equilibrium
from principle_viz.policy.tax import TaxOn, TaxScenario, TaxType

tax = TaxScenario(TaxType.PER_UNIT_TAX, 3.0, TaxOn.PRODUCER)
print(solve_tax_equilibrium(demand, supply, tax))
# TaxEquilibriumResult(q_star=2.5, consumer_price=7.5, producer_price=4.5,
#                      tax_wedge=3.0, tax_revenue=7.5)
```

改用 `TaxOn.CONSUMER` 結果完全相同。稅率為 $r$ 的從價稅使消費者價格等於生產者價格的 $(1 + r)$ 倍。

#api(("compare_tax_scenario",), syntax: [
  #raw("compare_tax_scenario(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  並列課稅前後的市場：`baseline_equilibrium`、`post_tax`、變動量 `delta_q`、`delta_p_consumer`、`delta_p_producer`，以及各自的方向（`"left"`／`"right"`、`"up"`／`"down"`）。上例中數量減少 1.5，買方多付 1.5，賣方少收 1.5。
]

#api(("build_tax_visual_guide",), syntax: [
  #raw("build_tax_visual_guide(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  課稅曲線的幾何資訊：`base_curve`、`taxed_curve`、`curve_role`（`"supply"` 或 `"demand"`）與 `transform_kind`（`"shift"` 或 `"rotation"`）。`add_tax_transform()` 依此繪圖。
]

== 圖形

#api(("MarketFigure.add_tax_transform",), syntax: [
  #raw("add_tax_transform(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(", q_max)")
])[
  畫出課稅後的曲線並命名為 $S + t$ 或 $D - t$，以虛線箭頭表示平移或旋轉，並標出未課稅的均衡。
]

#fig("/figures/taxes/per_unit_producer.svg", width: 46%, caption: [
  向賣方課徵從量稅。
])

#fig("/figures/taxes/ad_valorem_consumer.svg", width: 46%, caption: [
  向買方課徵從價稅。
])

#changed("0.10.0", label: "MarketFigure.add_tax_comparison")[在價格軸上標出 $p_d$、$p_0$ 與 $p_s$，並加上 "Tax" 括號；新增 `brace_side` 與 `notes`]

#api(("MarketFigure.add_tax_comparison",), syntax: [
  #raw("add_tax_comparison(")#meta("result")#raw(", *, brace_side=\"outside\", notes=False)")
])[
  標出 `compare_tax_scenario()` 結果的楔差：在價格軸上標 $p_d$（買方）、$p_0$（課稅前）與 $p_s$（賣方），並以 "Tax" 括號涵蓋 $p_s$ 到 $p_d$。
]

#param("brace_side", type: "str", default: "\"outside\"")[括號在座標軸外側（`"outside"`）或繪圖區內（`"inside"`）。]
#param("notes", type: "bool", default: "False")[在座標軸旁說明每個標記。]

搭配#ref(<sec-welfare>)的福利區塊，可看出租稅由誰負擔（參見#ref(<fig-tax-welfare>)）：

```python
from principle_viz import compare_tax_scenario
from principle_viz.welfare.surplus import compare_surplus, outcome_from_equilibrium, outcome_from_tax

baseline = outcome_from_equilibrium(solve_equilibrium(demand, supply))
taxed = outcome_from_tax(solve_tax_equilibrium(demand, supply, tax))
delta = compare_surplus(demand, supply, baseline, taxed)
print(delta.policy.tax_revenue, delta.deadweight_loss)   # 7.5 2.25

fig = MarketFigure(x_max=12, y_max=12, title="Welfare Under a Tax")
fig.add_curves(demand, supply, q_max=10)
fig.add_welfare(delta.policy)
fig.add_tax_comparison(compare_tax_scenario(demand, supply, tax))
fig.finalize()
```

#fig("/figures/taxes/welfare.svg", width: 46%, caption: [
  課稅下的剩餘與無謂損失。
]) <fig-tax-welfare>

== 補貼

#changed("0.10.0", label: "MarketFigure.add_subsidy_comparison")[補貼楔差加上 "Subsidy" 括號，並標示補貼成本]

#api(("SubsidyScenario",), syntax: [
  #raw("SubsidyScenario(amount, subsidy_to=SubsidyTo.PRODUCER)")
])[
  每單位 `amount` 的補貼（不得為負），發給賣方（`SubsidyTo.PRODUCER`）或買方（`SubsidyTo.CONSUMER`），位於 `principle_viz.policy.subsidy`。
]

#api(("solve_subsidy_equilibrium", "compare_subsidy_scenario"), syntax: [
  #raw("solve_subsidy_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")") \
  #raw("compare_subsidy_scenario(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  補貼後的市場（`q_star`、`consumer_price`、`producer_price`、`subsidy_wedge`、`government_expenditure`），以及與自由市場的比較（`baseline_equilibrium`、`post_subsidy`、`delta_q`、`delta_p_consumer`、`delta_p_producer`）。在#ref(<sec-quickstart>)的市場中補貼 2，數量增為 5：買方支付 5，賣方收到 7，政府支出 10。
]

#api(("MarketFigure.add_subsidy_comparison",), syntax: [
  #raw("add_subsidy_comparison(")#meta("result")#raw(", *, brace_side=\"outside\", notes=False)")
])[
  以標示稅收楔差的方式標出補貼楔差，加上 "Subsidy" 括號，並標示補貼成本。#ref(<fig-subsidy>)隱藏了部分標籤，且只為無謂損失填色（`regions=("dwl",)`），因為補貼成本與剩餘區塊重疊；所用的 `visibility` 參數詳見#ref(<sec-labels>)。
]

```python
from principle_viz import SubsidyScenario, SubsidyTo, compare_subsidy_scenario

demand = line_from_inverse(12.0, -1.0)
comparison = compare_subsidy_scenario(demand, supply, SubsidyScenario(3.0, SubsidyTo.PRODUCER))
fig = MarketFigure(
    x_max=12, y_max=13, title="Per-Unit Subsidy",
    visibility={
        "market.subsidy.expenditure.label": False,
        "market.subsidy.wedge.label": False,
        "market.subsidy.wedge.mark.p_0": False,
        "market.subsidy.wedge.brace": False,
    },
)
```

#fig("/figures/taxes/subsidy.svg", width: 46%, caption: [
  從量補貼與無謂損失。
]) <fig-subsidy>

#import "/template/manual.typ": *

= 税收与补贴 <sec-taxes>

#changed("0.1.0", label: "TaxScenario")[`fixed`、`per_unit` 与 `ad_valorem` 三种税，法定纳税人可为买方或卖方]
#changed("0.10.0", label: "MarketFigure.add_tax_transform")[征税后的曲线命名为 $S + t$ / $D - t$；旋转标签移到箭头尾端]

征税在买方支付的价格与卖方收到的价格之间打入楔子。法定上由谁纳税不影响结果：无论向买方或卖方征收，楔子、数量与两个价格都相同 #citep(<mankiw2021>)。

== 情景

#api(("TaxScenario",), syntax: [
  #raw("TaxScenario(tax_type, amount, tax_on=TaxOn.PRODUCER, anchor_mode=AnchorMode.NONE)")
])[
  一项税，位于 `principle_viz.policy.tax`。
]

#param("tax_type", type: "TaxType")[`FIXED_TAX` 或 `PER_UNIT_TAX`：每单位征收固定金额，曲线平移 `amount`；`AD_VALOREM_TAX`：按价格征收比率，曲线旋转。两种从量形式的均衡相同。]
#param("amount", type: "float")[每单位税额，或从价税的税率（`0.35` 即 35%）；税率必须大于 $-1$。]
#param("tax_on", type: "TaxOn", default: "PRODUCER")[法定纳税人：`PRODUCER` 使供给上移，`CONSUMER` 使需求下移。]
#param("anchor_mode", type: "AnchorMode", default: "NONE")[绘制从价税时，`NONE` 以截距为轴旋转曲线，`BASELINE_EQUILIBRIUM` 以未征税的均衡点为轴。]

== 求解

#api(("solve_tax_equilibrium",), syntax: [
  #raw("solve_tax_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  征税后的市场，返回 `TaxEquilibriumResult`：`q_star`、`consumer_price`、`producer_price`、`tax_wedge`（两价之差）与 `tax_revenue`（楔子乘以数量）。
]

```python
from principle_viz import solve_tax_equilibrium
from principle_viz.policy.tax import TaxOn, TaxScenario, TaxType

tax = TaxScenario(TaxType.PER_UNIT_TAX, 3.0, TaxOn.PRODUCER)
print(solve_tax_equilibrium(demand, supply, tax))
# TaxEquilibriumResult(q_star=2.5, consumer_price=7.5, producer_price=4.5,
#                      tax_wedge=3.0, tax_revenue=7.5)
```

改用 `TaxOn.CONSUMER` 结果完全相同。税率为 $r$ 的从价税使消费者价格等于生产者价格的 $(1 + r)$ 倍。

#api(("compare_tax_scenario",), syntax: [
  #raw("compare_tax_scenario(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  并列征税前后的市场：`baseline_equilibrium`、`post_tax`、变动量 `delta_q`、`delta_p_consumer`、`delta_p_producer`，以及各自的方向（`"left"`／`"right"`、`"up"`／`"down"`）。上例中数量减少 1.5，买方多付 1.5，卖方少收 1.5。
]

#api(("build_tax_visual_guide",), syntax: [
  #raw("build_tax_visual_guide(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  征税曲线的几何信息：`base_curve`、`taxed_curve`、`curve_role`（`"supply"` 或 `"demand"`）与 `transform_kind`（`"shift"` 或 `"rotation"`）。`add_tax_transform()` 据此绘图。
]

== 图形

#api(("MarketFigure.add_tax_transform",), syntax: [
  #raw("add_tax_transform(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(", q_max)")
])[
  画出征税后的曲线并命名为 $S + t$ 或 $D - t$，以虚线箭头表示平移或旋转，并标出未征税的均衡。
]

#fig("/figures/taxes/per_unit_producer.svg", width: 46%, caption: [
  向卖方征收从量税。
])

#fig("/figures/taxes/ad_valorem_consumer.svg", width: 46%, caption: [
  向买方征收从价税。
])

#changed("0.10.0", label: "MarketFigure.add_tax_comparison")[在价格轴上标出 $p_d$、$p_0$ 与 $p_s$，并加上 "Tax" 括号；新增 `brace_side` 与 `notes`]

#api(("MarketFigure.add_tax_comparison",), syntax: [
  #raw("add_tax_comparison(")#meta("result")#raw(", *, brace_side=\"outside\", notes=False)")
])[
  标出 `compare_tax_scenario()` 结果的楔子：在价格轴上标 $p_d$（买方）、$p_0$（征税前）与 $p_s$（卖方），并以 "Tax" 括号涵盖 $p_s$ 到 $p_d$。
]

#param("brace_side", type: "str", default: "\"outside\"")[括号在坐标轴外侧（`"outside"`）或绘图区内（`"inside"`）。]
#param("notes", type: "bool", default: "False")[在坐标轴旁说明每个标记。]

搭配#ref(<sec-welfare>)的福利区块，可看出税收由谁负担（参见#ref(<fig-tax-welfare>)）：

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
  征税下的剩余与无谓损失。
]) <fig-tax-welfare>

== 补贴

#changed("0.10.0", label: "MarketFigure.add_subsidy_comparison")[补贴楔子加上 "Subsidy" 括号，并标示补贴成本]

#api(("SubsidyScenario",), syntax: [
  #raw("SubsidyScenario(amount, subsidy_to=SubsidyTo.PRODUCER)")
])[
  每单位 `amount` 的补贴（不能为负），发给卖方（`SubsidyTo.PRODUCER`）或买方（`SubsidyTo.CONSUMER`），位于 `principle_viz.policy.subsidy`。
]

#api(("solve_subsidy_equilibrium", "compare_subsidy_scenario"), syntax: [
  #raw("solve_subsidy_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")") \
  #raw("compare_subsidy_scenario(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  补贴后的市场（`q_star`、`consumer_price`、`producer_price`、`subsidy_wedge`、`government_expenditure`），以及与自由市场的比较（`baseline_equilibrium`、`post_subsidy`、`delta_q`、`delta_p_consumer`、`delta_p_producer`）。在#ref(<sec-quickstart>)的市场中补贴 2，数量增为 5：买方支付 5，卖方收到 7，政府支出 10。
]

#api(("MarketFigure.add_subsidy_comparison",), syntax: [
  #raw("add_subsidy_comparison(")#meta("result")#raw(", *, brace_side=\"outside\", notes=False)")
])[
  以标示税收楔子的方式标出补贴楔子，加上 "Subsidy" 括号，并标示补贴成本。#ref(<fig-subsidy>)隐藏了部分标签，且只为无谓损失填色（`regions=("dwl",)`），因为补贴成本与剩余区块重叠；所用的 `visibility` 参数详见#ref(<sec-labels>)。
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
  从量补贴与无谓损失。
]) <fig-subsidy>

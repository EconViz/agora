#import "/template/manual.typ": *

= 福利 <sec-welfare>

#changed("0.10.0", label: "MarketFigure.add_welfare")[以文字命名各区块（"Consumer surplus"、"CS" 等），写在区块内、改用缩写或以引线标示；`labels=False` 只填色]
#changed("0.10.0", label: "MarketFigure.add_welfare")[消费者剩余与生产者剩余沿用需求与供给的色相；税收只标示文字、不填色]

福利分析比较某个市场结果与其他可能结果：消费者剩余、生产者剩余、政府收入，以及无谓损失。

== 市场结果

#api(("MarketOutcome",), syntax: [
  #raw("MarketOutcome(quantity, consumer_price, producer_price, label=\"\")")
])[
  一个数量，加上买方支付与卖方收到的价格。征税或补贴时两个价格不同，价差乘以数量就是政府收入（补贴为负）。此类别位于 `principle_viz.welfare.surplus`，同模块也提供由各种结果创建市场结果的函数：
]

#param("outcome_from_equilibrium(eq)")[自由市场：两个价格都是 $p^*$。]
#param("outcome_from_tax(tax_eq)")[征税后（详见#ref(<sec-taxes>)）。]
#param("outcome_from_subsidy(subsidy_eq)")[补贴后。]
#param("outcome_from_control(control)")[价格上限或下限之下（详见#ref(<sec-controls>)）。]

== 剩余

#api(("compute_surplus",), syntax: [
  #raw("compute_surplus(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("outcome")#raw(", baseline_outcome=None)")
])[
  `outcome` 下的福利分解。传入 `baseline_outcome` 时，以其为基准衡量无谓损失。返回的 `SurplusResult` 包含下列字段：
]

#param("consumer_surplus", type: "float")[需求曲线与消费者价格之间的面积。]
#param("producer_surplus", type: "float")[生产者价格与供给曲线之间的面积。]
#param("tax_revenue", type: "float")[政府收入（补贴为负）。]
#param("total_surplus", type: "float")[三者之和。]
#param("deadweight_loss", type: "float")[相对于基准损失的剩余。]
#param("polygons", type: "SurplusPolygons")[各面积的顶点，供绘图使用。]

```python
from principle_viz import compute_surplus, solve_equilibrium
from principle_viz.welfare.surplus import outcome_from_equilibrium

eq = solve_equilibrium(demand, supply)
outcome = outcome_from_equilibrium(eq)
surplus = compute_surplus(demand, supply, outcome)
print(surplus.consumer_surplus, surplus.producer_surplus)  # 8.0 8.0
```

$(10 - 6) times 4 slash 2 = (6 - 2) times 4 slash 2 = 8$；自由市场的无谓损失为 0。
#api(("compare_surplus",), syntax: [
  #raw("compare_surplus(")#meta("demand")#raw(", ")#meta("supply")#raw(", baseline_outcome, policy_outcome)")
])[
  两个福利分解及其差异：`baseline`、`policy`、`delta_consumer_surplus`、`delta_producer_surplus`、`delta_tax_revenue`、`delta_total_surplus` 与 `deadweight_loss`。#ref(<sec-taxes>)以税收为例使用此函数。
]

== 图形

#api(("MarketFigure.add_welfare",), syntax: [
  #raw("add_welfare(")#meta("result")#raw(", *, labels=True, regions=None)")
])[
  为消费者剩余、生产者剩余、税收与无谓损失填色并命名：名称放得下时写在区块内，只放得下缩写时写 CS、PS、Tax、DWL，否则以引线标示，且不遮住任何线、点或其他文字。
]

#param("labels", type: "bool", default: "True")[设为 `False` 时只填色、不命名。]
#param("regions", type: "iterable | None", default: "None")[只画 `"cs"`、`"ps"`、`"tax_revenue"` 与 `"dwl"` 中的部分区块。]

```python
fig = MarketFigure(x_max=12, y_max=12)
fig.add_curves(demand, supply, q_max=10)
fig.add_welfare(surplus)
fig.add_equilibrium(eq)
fig.finalize()
```

输出参见#ref(<fig-welfare>)。

#fig("/figures/welfare/equilibrium.svg", width: 46%, caption: [
  均衡下的消费者与生产者剩余。
]) <fig-welfare>

#api(("MarketFigure.add_welfare_transition",), syntax: [
  #raw("add_welfare_transition(*, baseline_outcome, policy_outcome, surplus)")
])[
  同样的区块，再加上基准与政策下数量及价格的辅助线，用于比较前后差异。
]

== 无谓损失报表

#api(("build_dwl_report",), syntax: [
  #raw("build_dwl_report(")#meta("rows")#raw(")")
])[
  将 `(名称, 基准, 政策)` 三元组（皆为 `SurplusResult`）转为报表列（`DWLScenarioRow`），包含数量变动、各项剩余变动与无谓损失。`principle_viz.welfare.report` 中的 `save_dwl_report_csv()` 与 `save_dwl_report_json()` 可将报表写成文件。
]

#import "/template/manual.typ": *

= 市场失灵 <sec-failures>

#changed("0.10.0", label: "MarketFigure.add_externality")[社会曲线命名为 $M S C$ / $M S B$；$Q_m$ 与 $Q^*$ 标在数量轴上；矫正税与补贴改为横跨 $Q^*$ 处的差距]

== 外部性

生产对第三方造成成本，或消费为第三方带来利益时，市场数量会偏离社会最适数量。在最适数量处征收等于外部效果的庇古税或给予庇古补贴，即可恢复最适 #citep(<pigou1920>)。

#api(("ExternalityScenario",), syntax: [
  #raw("ExternalityScenario(marginal_external_cost=0.0, marginal_external_benefit=0.0)")
])[
  固定的边际外部成本（加到供给上得到边际社会成本），以及／或边际外部利益（加到需求上得到边际社会利益）。两者都不能为负。
]

#api(("analyze_externality",), syntax: [
  #raw("analyze_externality(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  私人与社会的结果：`private_equilibrium`、`social_equilibrium`、`social_demand`、`social_supply`、`corrective_tax`、`corrective_subsidy`、`quantity_distortion` 与 `deadweight_loss`。
]

```python
from principle_viz import ExternalityScenario, analyze_externality

demand = line_from_inverse(12.0, -1.0)
result = analyze_externality(demand, supply, ExternalityScenario(marginal_external_cost=2))
print(result.private_equilibrium.q_star, result.social_equilibrium.q_star)   # 5.0 4.0
print(result.corrective_tax, result.deadweight_loss)                         # 2.0 1.0
```

#api(("MarketFigure.add_externality",), syntax: [
  #raw("add_externality(")#meta("result")#raw(")")
])[
  画出社会曲线，在数量轴上标出 $Q_m$（市场）与 $Q^*$（最适），在 $Q^*$ 处标出横跨差距的矫正税 $t$ 或补贴 $s$，并为无谓损失填色。
]

#fig("/figures/failures/negative_externality.svg", width: 46%, caption: [
  负外部性。
])

#fig("/figures/failures/positive_externality.svg", width: 46%, caption: [
  正外部性。
])

== 公共资源

#api(("analyze_common_resource",), syntax: [
  #raw("analyze_common_resource(")#meta("benefit")#raw(", ")#meta("cost")#raw(", *, marginal_congestion_cost)")
])[
  将拥挤或耗竭视为边际外部成本：开放获取时，资源会被使用到边际利益等于私人成本为止，超过有效率的水准 #citep(<hardin1968>)。结果包含 `open_access_equilibrium`、`efficient_equilibrium`、`social_cost`、`overuse`、`corrective_fee` 与 `deadweight_loss`。
]

以 $M B = 12 - Q$、$M P C = 2 + Q$、拥挤成本 3 为例，开放获取使用 5 单位，有效率的水准为 3.5；收取 3 的费用即可消除差距。

#api(("MarketFigure.add_common_resource",), syntax: [
  #raw("add_common_resource(")#meta("result")#raw(")")
])[
  画出社会成本，标出 $Q^*$ 与 $Q_"open"$，并为无谓损失填色。在 `add_curves()` 中将曲线命名为 $M B$ 与 $M P C$。
]

#fig("/figures/failures/common_resource.svg", width: 46%, caption: [
  公共资源的过度使用。
])

== 公共物品

#api(("IndividualBenefit", "analyze_public_good"), syntax: [
  #raw("IndividualBenefit(name, marginal_benefit)") \
  #raw("analyze_public_good(")#meta("individuals")#raw(", ")#meta("cost")#raw(", *, samples=101)")
])[
  每个人都消费公共物品的全部数量，因此边际利益*垂直*加总。有效率的数量使边际利益之和等于边际成本 #citep(<samuelson1954>)；私人提供则停在最高的个人边际利益等于边际成本之处。结果包含 `efficient_quantity`、`efficient_marginal_value`、`private_provision_quantity`、`free_rider_gap` 与采样点 `points`。
]

```python
from principle_viz import IndividualBenefit, analyze_public_good

result = analyze_public_good(
    (
        IndividualBenefit("$MB_A$", line_from_inverse(8, -1)),
        IndividualBenefit("$MB_B$", line_from_inverse(6, -1)),
    ),
    line_from_inverse(5, 0),           # constant marginal cost of 5
)
print(result.efficient_quantity, result.private_provision_quantity)   # 4.5 3.0
```

#api(("public_good_canvas",), syntax: [
  #raw("public_good_canvas(")#meta("result")#raw(", *, theme=None, labels=None, visibility=None)")
])[
  位于 `principle_viz.visuals.market_failures` 的 #pkg("mosaickit") 画布，画出各人的边际利益、其垂直加总、边际成本，并在数量轴上标出 $Q_p$ 与 $Q^*$。
]

#fig("/figures/failures/public_good.svg", width: 46%, caption: [
  边际利益的垂直加总。
])

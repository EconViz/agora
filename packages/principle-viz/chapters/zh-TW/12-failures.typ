#import "/template/manual.typ": *

= 市場失靈 <sec-failures>

#changed("0.10.0", label: "MarketFigure.add_externality")[社會曲線命名為 $M S C$ / $M S B$；$Q_m$ 與 $Q^*$ 標在數量軸上；矯正稅與補貼改為橫跨 $Q^*$ 處的差距]

== 外部性

生產對第三方造成成本，或消費為第三方帶來利益時，市場數量會偏離社會最適數量。在最適數量處課徵等於外部效果的皮古稅或給予皮古補貼，即可恢復最適 #citep(<pigou1920>)。

#api(("ExternalityScenario",), syntax: [
  #raw("ExternalityScenario(marginal_external_cost=0.0, marginal_external_benefit=0.0)")
])[
  固定的邊際外部成本（加到供給上得到邊際社會成本），以及／或邊際外部利益（加到需求上得到邊際社會利益）。兩者都不得為負。
]

#api(("analyze_externality",), syntax: [
  #raw("analyze_externality(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  私人與社會的結果：`private_equilibrium`、`social_equilibrium`、`social_demand`、`social_supply`、`corrective_tax`、`corrective_subsidy`、`quantity_distortion` 與 `deadweight_loss`。
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
  畫出社會曲線，在數量軸上標出 $Q_m$（市場）與 $Q^*$（最適），在 $Q^*$ 處標出橫跨差距的矯正稅 $t$ 或補貼 $s$，並為無謂損失填色。
]

#fig("/figures/failures/negative_externality.svg", width: 46%, caption: [
  負外部性。
])

#fig("/figures/failures/positive_externality.svg", width: 46%, caption: [
  正外部性。
])

== 共有資源

#api(("analyze_common_resource",), syntax: [
  #raw("analyze_common_resource(")#meta("benefit")#raw(", ")#meta("cost")#raw(", *, marginal_congestion_cost)")
])[
  將擁擠或耗竭視為邊際外部成本：開放取用時，資源會被使用到邊際利益等於私人成本為止，超過有效率的水準 #citep(<hardin1968>)。結果包含 `open_access_equilibrium`、`efficient_equilibrium`、`social_cost`、`overuse`、`corrective_fee` 與 `deadweight_loss`。
]

以 $M B = 12 - Q$、$M P C = 2 + Q$、擁擠成本 3 為例，開放取用使用 5 單位，有效率的水準為 3.5；收取 3 的費用即可消除差距。

#api(("MarketFigure.add_common_resource",), syntax: [
  #raw("add_common_resource(")#meta("result")#raw(")")
])[
  畫出社會成本，標出 $Q^*$ 與 $Q_"open"$，並為無謂損失填色。在 `add_curves()` 中將曲線命名為 $M B$ 與 $M P C$。
]

#fig("/figures/failures/common_resource.svg", width: 46%, caption: [
  共有資源的過度使用。
])

== 公共財

#api(("IndividualBenefit", "analyze_public_good"), syntax: [
  #raw("IndividualBenefit(name, marginal_benefit)") \
  #raw("analyze_public_good(")#meta("individuals")#raw(", ")#meta("cost")#raw(", *, samples=101)")
])[
  每個人都消費公共財的全部數量，因此邊際利益*垂直*加總。有效率的數量使邊際利益之和等於邊際成本 #citep(<samuelson1954>)；私人提供則停在最高的個人邊際利益等於邊際成本之處。結果包含 `efficient_quantity`、`efficient_marginal_value`、`private_provision_quantity`、`free_rider_gap` 與取樣點 `points`。
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
  位於 `principle_viz.visuals.market_failures` 的 #pkg("mosaickit") 畫布，畫出各人的邊際利益、其垂直加總、邊際成本，並在數量軸上標出 $Q_p$ 與 $Q^*$。
]

#fig("/figures/failures/public_good.svg", width: 46%, caption: [
  邊際利益的垂直加總。
])

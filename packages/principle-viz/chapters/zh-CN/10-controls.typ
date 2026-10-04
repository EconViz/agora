#import "/template/manual.typ": *

= 价格管制 <sec-controls>

#changed("0.10.0", label: "MarketFigure.add_price_control")[有效的管制直接命名管制线，标出 $p_c$、$Q_d$ 与 $Q_s$，并在管制线上以括号标示 "Shortage" 或 "Surplus"；`gap_brace="axis"` 改在数量轴下方标示]

低于均衡价格的价格上限，或高于均衡价格的价格下限，会*具有约束力*：市场无法结清，成交量等于管制价格下需求量与供给量中较小者。

#api(("PriceControlScenario", "PriceControlType"), syntax: [
  #raw("PriceControlScenario(control_type, control_price)")
])[
  位于 `control_price` 的上限（`CEILING`）或下限（`FLOOR`），位于 `principle_viz.core.controls`。
]

#api(("evaluate_price_control",), syntax: [
  #raw("evaluate_price_control(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  管制下的市场，返回 `PriceControlResult`：
]

#param("is_binding", type: "bool")[管制是否改变市场结果。]
#param("traded_quantity", type: "float")[实际成交量。]
#param("consumer_price, producer_price", type: "float")[有约束力时为管制价格，否则为均衡价格。]
#param("shortage, surplus", type: "float")[上限下的超额需求，或下限下的超额供给（其余情况为零）。]
#param("baseline_equilibrium", type: "EquilibriumResult")[未管制的市场。]

```python
from principle_viz import evaluate_price_control
from principle_viz.core.controls import PriceControlScenario, PriceControlType

ceiling = evaluate_price_control(
    demand, supply, PriceControlScenario(PriceControlType.CEILING, 4.0)
)
print(ceiling.is_binding, ceiling.traded_quantity, ceiling.shortage)   # True 2.0 4.0
```

价格为 4 时，买方想买 6 单位，卖方只愿卖 2 单位：成交 2 单位，短缺 4 单位。上限设在 7，高于均衡价格 6，则不具有约束力。

#api(("MarketFigure.add_price_control",), syntax: [
  #raw("add_price_control(")#meta("result")#raw(", *, gap_brace=\"line\")")
])[
  画出管制线并命名为 "Price ceiling" 或 "Price floor"，在价格轴上标出 $p_c$。有约束力时另标出 $Q_d$ 与 $Q_s$，并以括号标示差额：上限下方为 "Shortage"，下限上方为 "Surplus"。`gap_brace="axis"` 改在数量轴下方标示。
]

#fig("/figures/controls/ceiling.svg", width: 46%, caption: [
  有约束力的价格上限。
])

#fig("/figures/controls/floor.svg", width: 46%, caption: [
  有约束力的价格下限。
])

`outcome_from_control()` 将结果转为市场结果，可交给#ref(<sec-welfare>)的福利函数（参见#ref(<fig-ceiling-welfare>)）：

```python
from principle_viz.welfare.surplus import (
    compare_surplus, outcome_from_control, outcome_from_equilibrium,
)

baseline = outcome_from_equilibrium(solve_equilibrium(demand, supply))
delta = compare_surplus(demand, supply, baseline, outcome_from_control(ceiling))
fig.add_price_control(ceiling)
fig.add_welfare(delta.policy)
```

#fig("/figures/controls/ceiling_welfare.svg", width: 46%, caption: [
  上限为 3.5 时的福利。
]) <fig-ceiling-welfare>

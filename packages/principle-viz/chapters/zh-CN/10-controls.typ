#import "/template/manual.typ": *

= 价格管制 <sec-controls>

#changed("0.10.0", label: "MarketFigure.add_price_control")[有效的管制直接命名管制线，标出 $p_c$、$Q_d$ 与 $Q_s$，并在管制线上以括号标示 "Shortage" 或 "Surplus"；`gap_brace="axis"` 改在数量轴下方标示]

低于均衡价格的价格上限，或高于均衡价格的价格下限，会产生约束：市场无法结清，成交量等于管制价格下需求量与供给量中较小者。

#api(("PriceControlScenario", "PriceControlType"), syntax: [
  #raw("PriceControlScenario(control_type, control_price)") \
  #raw("PriceControlType.CEILING | PriceControlType.FLOOR")
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
#param("consumer_price", type: "float")[买方支付的价格：有约束时为管制价格，否则为均衡价格。]
#param("producer_price", type: "float")[卖方收到的价格：有约束时为管制价格，否则为均衡价格。]
#param("shortage", type: "float")[上限下的超额需求（其余情况为零）。]
#param("surplus", type: "float")[下限下的超额供给（其余情况为零）。]
#param("baseline_equilibrium", type: "EquilibriumResult")[未管制的市场。]

```python
from principle_viz import evaluate_price_control
from principle_viz.core.controls import (
    PriceControlScenario, PriceControlType,
)

scenario = PriceControlScenario(PriceControlType.CEILING, 4.0)
ceiling = evaluate_price_control(demand, supply, scenario)
print(ceiling.is_binding, ceiling.traded_quantity, ceiling.shortage)
# True 2.0 4.0
```

上限高于均衡价格（例如 7）时，`is_binding` 为 `False`。

#api(("MarketFigure.add_price_control",), syntax: [
  #raw("add_price_control(")#meta("result")#raw(", *, gap_brace=\"line\")")
])[
  画出管制线并命名为 "Price ceiling" 或 "Price floor"，在价格轴上标出 $p_c$。有约束时另标出 $Q_d$ 与 $Q_s$，并以括号标示差额：上限下方为 "Shortage"，下限上方为 "Surplus"。`gap_brace="axis"` 改在数量轴下方标示（参见#ref(<fig-ceiling>)、#ref(<fig-floor>)）。
]

#fig("/figures/controls/ceiling.svg", width: 46%, caption: [
  有约束的价格上限。
]) <fig-ceiling>

#fig("/figures/controls/floor.svg", width: 46%, caption: [
  有约束的价格下限。
]) <fig-floor>

`outcome_from_control()` 将结果转为市场结果，可交给#ref(<sec-welfare>)的福利函数（参见#ref(<fig-ceiling-welfare>)）：

```python
from principle_viz.welfare.surplus import (
    compare_surplus, outcome_from_control, outcome_from_equilibrium,
)

eq = solve_equilibrium(demand, supply)
baseline = outcome_from_equilibrium(eq)
controlled = outcome_from_control(ceiling)
delta = compare_surplus(demand, supply, baseline, controlled)
fig.add_price_control(ceiling)
fig.add_welfare(delta.policy)
```

#fig("/figures/controls/ceiling_welfare.svg", width: 46%, caption: [
  上限为 3.5 时的福利。
]) <fig-ceiling-welfare>

价格上限下，无谓损失为未成交的交易利益；部分剩余由卖方转移给买方。

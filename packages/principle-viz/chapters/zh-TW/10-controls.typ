#import "/template/manual.typ": *

= 價格管制 <sec-controls>

#changed("0.10.0", label: "MarketFigure.add_price_control")[有效的管制直接命名管制線，標出 $p_c$、$Q_d$ 與 $Q_s$，並在管制線上以括號標示 "Shortage" 或 "Surplus"；`gap_brace="axis"` 改在數量軸下方標示]

低於均衡價格的價格上限，或高於均衡價格的價格下限，會*產生約束*：市場無法結清，成交量等於管制價格下需求量與供給量中較小者。

#api(("PriceControlScenario", "PriceControlType"), syntax: [
  #raw("PriceControlScenario(control_type, control_price)")
])[
  位於 `control_price` 的上限（`CEILING`）或下限（`FLOOR`），位於 `principle_viz.core.controls`。
]

#api(("evaluate_price_control",), syntax: [
  #raw("evaluate_price_control(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  管制下的市場，回傳 `PriceControlResult`：
]

#param("is_binding", type: "bool")[管制是否改變市場結果。]
#param("traded_quantity", type: "float")[實際成交量。]
#param("consumer_price, producer_price", type: "float")[有約束時為管制價格，否則為均衡價格。]
#param("shortage, surplus", type: "float")[上限下的超額需求，或下限下的超額供給（其餘情況為零）。]
#param("baseline_equilibrium", type: "EquilibriumResult")[未管制的市場。]

```python
from principle_viz import evaluate_price_control
from principle_viz.core.controls import PriceControlScenario, PriceControlType

ceiling = evaluate_price_control(
    demand, supply, PriceControlScenario(PriceControlType.CEILING, 4.0)
)
print(ceiling.is_binding, ceiling.traded_quantity, ceiling.shortage)   # True 2.0 4.0
```

價格為 4 時，買方想買 6 單位，賣方只願賣 2 單位：成交 2 單位，短缺 4 單位。上限設在 7，高於均衡價格 6，則不產生約束。

#api(("MarketFigure.add_price_control",), syntax: [
  #raw("add_price_control(")#meta("result")#raw(", *, gap_brace=\"line\")")
])[
  畫出管制線並命名為 "Price ceiling" 或 "Price floor"，在價格軸上標出 $p_c$。有約束時另標出 $Q_d$ 與 $Q_s$，並以括號標示差額：上限下方為 "Shortage"，下限上方為 "Surplus"。`gap_brace="axis"` 改在數量軸下方標示。
]

#fig("/figures/controls/ceiling.svg", width: 46%, caption: [
  有約束的價格上限。
])

#fig("/figures/controls/floor.svg", width: 46%, caption: [
  有約束的價格下限。
])

`outcome_from_control()` 將結果轉為市場結果，可交給#ref(<sec-welfare>)的福利函式（參見#ref(<fig-ceiling-welfare>)）：

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
  上限為 3.5 時的福利。
]) <fig-ceiling-welfare>

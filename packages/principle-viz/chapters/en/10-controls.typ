#import "/template/manual.typ": *

= Price controls <sec-controls>

#changed("0.10.0", label: "MarketFigure.add_price_control")[Binding controls name the control line, mark $p_c$, $Q_d$ and $Q_s$, and brace "Shortage" or "Surplus" on the control line; `gap_brace="axis"` braces it under the quantity axis]

A price ceiling below the equilibrium price, or a floor above it, *binds*: the
market can no longer clear, and the quantity traded is the smaller of the
quantities demanded and supplied at the controlled price.

#api(("PriceControlScenario", "PriceControlType"), syntax: [
  #raw("PriceControlScenario(control_type, control_price)")
])[
  A `CEILING` or `FLOOR` at `control_price`, from
  `principle_viz.core.controls`.
]

#api(("evaluate_price_control",), syntax: [
  #raw("evaluate_price_control(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  The controlled market, as a `PriceControlResult`:
]

#param("is_binding", type: "bool")[Whether the control changes the outcome.]
#param("traded_quantity", type: "float")[Quantity actually traded.]
#param("consumer_price, producer_price", type: "float")[The controlled price when binding, otherwise the equilibrium price.]
#param("shortage, surplus", type: "float")[Excess demand under a ceiling, excess supply under a floor (zero otherwise).]
#param("baseline_equilibrium", type: "EquilibriumResult")[The uncontrolled market.]

```python
from principle_viz import evaluate_price_control
from principle_viz.core.controls import PriceControlScenario, PriceControlType

ceiling = evaluate_price_control(
    demand, supply, PriceControlScenario(PriceControlType.CEILING, 4.0)
)
print(ceiling.is_binding, ceiling.traded_quantity, ceiling.shortage)   # True 2.0 4.0
```

At a price of 4 buyers want 6 units and sellers offer 2: two units trade and
the shortage is 4. A ceiling of 7, above the equilibrium price of 6, does not
bind.

#api(("MarketFigure.add_price_control",), syntax: [
  #raw("add_price_control(")#meta("result")#raw(", *, gap_brace=\"line\")")
])[
  Draw the control line, named "Price ceiling" or "Price floor", with $p_c$
  on the price axis. A binding control also marks $Q_d$ and $Q_s$ and
  braces the gap: "Shortage" below a ceiling, "Surplus" above a floor.
  `gap_brace="axis"` braces it under the quantity axis instead.
]

#fig("/figures/controls/ceiling.svg", width: 46%, caption: [
  A binding price ceiling.
])

#fig("/figures/controls/floor.svg", width: 46%, caption: [
  A binding price floor.
])

`outcome_from_control()` turns the result into a market outcome for the
welfare functions of @sec-welfare (@fig-ceiling-welfare):

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
  Welfare under a binding ceiling (set at 3.5 in this figure).
]) <fig-ceiling-welfare>

#import "/template/manual.typ": *

= Price controls <sec-controls>

#changed("0.10.0", label: "MarketFigure.add_price_control")[Binding controls name the control line, mark $p_c$, $Q_d$ and $Q_s$, and brace "Shortage" or "Surplus" on the control line; `gap_brace="axis"` braces it under the quantity axis]

A price ceiling below the equilibrium price, or a floor above it, binds: the
market does not clear, and the quantity traded is the smaller of the
quantities demanded and supplied at the controlled price.

#api(("PriceControlScenario", "PriceControlType"), syntax: [
  #raw("PriceControlScenario(control_type, control_price)") \
  #raw("PriceControlType.CEILING | PriceControlType.FLOOR")
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
#param("consumer_price", type: "float")[Price buyers pay: the controlled price when binding, otherwise the equilibrium price.]
#param("producer_price", type: "float")[Price sellers receive: the controlled price when binding, otherwise the equilibrium price.]
#param("shortage", type: "float")[Excess demand under a ceiling (zero otherwise).]
#param("surplus", type: "float")[Excess supply under a floor (zero otherwise).]
#param("baseline_equilibrium", type: "EquilibriumResult")[The uncontrolled market.]

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

A ceiling above the equilibrium price (for example 7) leaves `is_binding`
`False`.

#api(("MarketFigure.add_price_control",), syntax: [
  #raw("add_price_control(")#meta("result")#raw(", *, gap_brace=\"line\")")
])[
  Draw the control line, named "Price ceiling" or "Price floor", with $p_c$
  on the price axis. A binding control also marks $Q_d$ and $Q_s$ and
  braces the gap: "Shortage" below a ceiling, "Surplus" above a floor.
  `gap_brace="axis"` braces it under the quantity axis instead (see
  @fig-ceiling and @fig-floor).
]

#fig("/figures/controls/ceiling.svg", width: 46%, caption: [
  A binding price ceiling.
]) <fig-ceiling>

#fig("/figures/controls/floor.svg", width: 46%, caption: [
  A binding price floor.
]) <fig-floor>

`outcome_from_control()` turns the result into a market outcome for the
welfare functions of @sec-welfare (see @fig-ceiling-welfare):

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
  Welfare under a price ceiling of 3.5.
]) <fig-ceiling-welfare>

Under a price ceiling, the deadweight loss is the surplus of the units that
are no longer traded, and part of the remaining surplus transfers from
sellers to buyers.

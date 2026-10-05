#import "/template/manual.typ": *

= Welfare <sec-welfare>

#changed("0.10.0", label: "MarketFigure.add_welfare")[Regions are named in words ("Consumer surplus", "CS", ...) inside, by short name or by callout; `labels=False` shades only]
#changed("0.10.0", label: "MarketFigure.add_welfare")[Consumer and producer surplus reuse the demand and supply hues; tax revenue is labelled rather than shaded]

Welfare analysis compares a market outcome with its alternatives: consumer
surplus, producer surplus, government revenue and deadweight loss.

== Market outcomes

#api(("MarketOutcome",), syntax: [
  #raw("MarketOutcome(quantity, consumer_price, producer_price, label=\"\")")
])[
  A quantity with the price buyers pay and the price sellers receive. The
  two prices differ under a tax or a subsidy; the gap times the quantity is
  government revenue (negative for a subsidy). It lives in
  `principle_viz.welfare.surplus`, together with constructors from each
  kind of result:
]

#param("outcome_from_equilibrium(eq)")[A free market: both prices are $p^*$.]
#param("outcome_from_tax(tax_eq)")[After a tax (@sec-taxes).]
#param("outcome_from_subsidy(subsidy_eq)")[After a subsidy.]
#param("outcome_from_control(control)")[Under a price ceiling or floor (@sec-controls).]

== Surplus

#api(("compute_surplus",), syntax: [
  #raw("compute_surplus(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("outcome")#raw(", baseline_outcome=None)")
])[
  The welfare decomposition at `outcome`. With a `baseline_outcome`, the
  deadweight loss is measured against it. The `SurplusResult` has these
  fields:
]

#param("consumer_surplus", type: "float")[Area between demand and the consumer price.]
#param("producer_surplus", type: "float")[Area between the producer price and supply.]
#param("tax_revenue", type: "float")[Government revenue (negative for a subsidy).]
#param("total_surplus", type: "float")[The sum of the three.]
#param("deadweight_loss", type: "float")[Surplus lost relative to the baseline.]
#param("polygons", type: "SurplusPolygons")[The corner points of each area, used to draw them.]

```python
from principle_viz import compute_surplus, solve_equilibrium
from principle_viz.welfare.surplus import outcome_from_equilibrium

eq = solve_equilibrium(demand, supply)
outcome = outcome_from_equilibrium(eq)
surplus = compute_surplus(demand, supply, outcome)
print(surplus.consumer_surplus, surplus.producer_surplus)  # 8.0 8.0
```

$(10 - 6) times 4 slash 2 = (6 - 2) times 4 slash 2 = 8$; the free market
has no deadweight loss.

#api(("compare_surplus",), syntax: [
  #raw("compare_surplus(")#meta("demand")#raw(", ")#meta("supply")#raw(", baseline_outcome, policy_outcome)")
])[
  Both decompositions and the changes between them: `baseline`, `policy`,
  `delta_consumer_surplus`, `delta_producer_surplus`, `delta_tax_revenue`,
  `delta_total_surplus` and `deadweight_loss`. @sec-taxes uses it for a
  tax.
]

== Figures

#api(("MarketFigure.add_welfare",), syntax: [
  #raw("add_welfare(")#meta("result")#raw(", *, labels=True, regions=None)")
])[
  Shade consumer surplus, producer surplus, tax revenue and deadweight loss,
  and name each region: inside it when the name fits, by its short name
  (CS, PS, Tax, DWL) when only that fits, otherwise by a callout that covers
  no line, point or other text.
]

#param("labels", type: "bool", default: "True")[`False` shades the regions without naming them.]
#param("regions", type: "iterable | None", default: "None")[Limit the shading to some of `"cs"`, `"ps"`, `"tax_revenue"` and `"dwl"`.]

```python
fig = MarketFigure(x_max=12, y_max=12)
fig.add_curves(demand, supply, q_max=10)
fig.add_welfare(surplus)
fig.add_equilibrium(eq)
fig.finalize()
```

The output is shown in @fig-welfare.

#fig("/figures/welfare/equilibrium.svg", width: 46%, caption: [
  Consumer and producer surplus at equilibrium.
]) <fig-welfare>

#api(("MarketFigure.add_welfare_transition",), syntax: [
  #raw("add_welfare_transition(*, baseline_outcome, policy_outcome, surplus)")
])[
  The same regions together with guide lines at the baseline and policy
  quantities and prices, for comparing before and after.
]

== Deadweight-loss reports

#api(("build_dwl_report",), syntax: [
  #raw("build_dwl_report(")#meta("rows")#raw(")")
])[
  Turn `(name, baseline, policy)` triples of `SurplusResult`s into report
  rows (`DWLScenarioRow`) with the change in quantity, in each surplus and
  the deadweight loss. `save_dwl_report_csv()` and `save_dwl_report_json()`
  in `principle_viz.welfare.report` write them to a file.
]

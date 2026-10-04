#import "/template/manual.typ": *

= Taxes and subsidies <sec-taxes>

#changed("0.1.0", label: "TaxScenario")[Fixed, per-unit and ad valorem taxes, with legal incidence on buyers or sellers]
#changed("0.10.0", label: "MarketFigure.add_tax_transform")[Taxed curves are named $S + t$ / $D - t$; the rotation label sits at the arrow's tail]

A tax drives a wedge between the price buyers pay and the price sellers
receive. Who is legally charged does not change the outcome: the wedge,
the quantity and both prices are the same whether buyers or sellers pay the
tax #citep(<mankiw2021>).

== Scenarios

#api(("TaxScenario",), syntax: [
  #raw("TaxScenario(tax_type, amount, tax_on=TaxOn.PRODUCER, anchor_mode=AnchorMode.NONE)")
])[
  One tax, from `principle_viz.policy.tax`.
]

#param("tax_type", type: "TaxType")[`FIXED_TAX` or `PER_UNIT_TAX`: an amount per unit, which shifts a curve by `amount`; `AD_VALOREM_TAX`: a rate on the price, which rotates a curve. The two specific taxes give the same equilibrium.]
#param("amount", type: "float")[The tax per unit, or the rate for an ad valorem tax (`0.35` is 35%); a rate must exceed $-1$.]
#param("tax_on", type: "TaxOn", default: "PRODUCER")[Legal incidence: `PRODUCER` shifts supply up, `CONSUMER` shifts demand down.]
#param("anchor_mode", type: "AnchorMode", default: "NONE")[For drawing an ad valorem tax: `NONE` rotates the curve about its intercept, `BASELINE_EQUILIBRIUM` about the untaxed equilibrium.]

== Solving

#api(("solve_tax_equilibrium",), syntax: [
  #raw("solve_tax_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  The taxed market, as a `TaxEquilibriumResult`: `q_star`,
  `consumer_price`, `producer_price`, `tax_wedge` (their difference) and
  `tax_revenue` (wedge times quantity).
]

```python
from principle_viz import solve_tax_equilibrium
from principle_viz.policy.tax import TaxOn, TaxScenario, TaxType

tax = TaxScenario(TaxType.PER_UNIT_TAX, 3.0, TaxOn.PRODUCER)
print(solve_tax_equilibrium(demand, supply, tax))
# TaxEquilibriumResult(q_star=2.5, consumer_price=7.5, producer_price=4.5,
#                      tax_wedge=3.0, tax_revenue=7.5)
```

With `TaxOn.CONSUMER` the result is identical. An ad valorem tax at rate $r$
sets the consumer price to $(1 + r)$ times the producer price.

#api(("compare_tax_scenario",), syntax: [
  #raw("compare_tax_scenario(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  The untaxed and taxed markets side by side: `baseline_equilibrium`,
  `post_tax`, the changes `delta_q`, `delta_p_consumer`, `delta_p_producer`,
  and their directions (`"left"`/`"right"`, `"up"`/`"down"`). For the tax
  above, quantity falls by 1.5 while buyers pay 1.5 more and sellers receive
  1.5 less.
]

#api(("build_tax_visual_guide",), syntax: [
  #raw("build_tax_visual_guide(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  The geometry of the taxed curve: `base_curve`, `taxed_curve`,
  `curve_role` (`"supply"` or `"demand"`) and `transform_kind` (`"shift"`
  or `"rotation"`). `add_tax_transform()` draws from it.
]

== Figures

#api(("MarketFigure.add_tax_transform",), syntax: [
  #raw("add_tax_transform(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(", q_max)")
])[
  Draw the taxed curve, named $S + t$ or $D - t$, with a dashed arrow for
  the shift or the rotation and the untaxed equilibrium.
]

#fig("/figures/taxes/per_unit_producer.svg", width: 46%, caption: [
  A per-unit tax on sellers shifts supply up.
])

#fig("/figures/taxes/ad_valorem_consumer.svg", width: 46%, caption: [
  An ad valorem tax on buyers rotates demand.
])

#changed("0.10.0", label: "MarketFigure.add_tax_comparison")[Marks $p_d$, $p_0$ and $p_s$ on the price axis with a "Tax" brace; `brace_side` and `notes`]

#api(("MarketFigure.add_tax_comparison",), syntax: [
  #raw("add_tax_comparison(")#meta("result")#raw(", *, brace_side=\"outside\", notes=False)")
])[
  Mark the wedge of a `compare_tax_scenario()` result: $p_d$ (buyers),
  $p_0$ (before the tax) and $p_s$ (sellers) on the price axis, with a "Tax"
  brace over $p_s$ to $p_d$.
]

#param("brace_side", type: "str", default: "\"outside\"")[`"outside"` the axis or `"inside"` the plot.]
#param("notes", type: "bool", default: "False")[Explain each mark beside the axis.]

Together with the welfare regions of @sec-welfare, it shows who bears the
tax (@fig-tax-welfare):

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
  Surplus, tax revenue and deadweight loss under a tax.
]) <fig-tax-welfare>

== Subsidies

#changed("0.10.0", label: "MarketFigure.add_subsidy_comparison")[Subsidy wedge with a "Subsidy" brace, and the subsidy's cost named]

#api(("SubsidyScenario",), syntax: [
  #raw("SubsidyScenario(amount, subsidy_to=SubsidyTo.PRODUCER)")
])[
  A per-unit subsidy of `amount` (non-negative), paid to sellers
  (`SubsidyTo.PRODUCER`) or buyers (`SubsidyTo.CONSUMER`), from
  `principle_viz.policy.subsidy`.
]

#api(("solve_subsidy_equilibrium", "compare_subsidy_scenario"), syntax: [
  #raw("solve_subsidy_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")") \
  #raw("compare_subsidy_scenario(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  The subsidised market (`q_star`, `consumer_price`, `producer_price`,
  `subsidy_wedge`, `government_expenditure`), and its comparison with the
  free market (`baseline_equilibrium`, `post_subsidy`, `delta_q`,
  `delta_p_consumer`, `delta_p_producer`). A subsidy of 2 in the market of
  @sec-quickstart raises the quantity to 5: buyers pay 5, sellers receive 7,
  and the government spends 10.
]

#api(("MarketFigure.add_subsidy_comparison",), syntax: [
  #raw("add_subsidy_comparison(")#meta("result")#raw(", *, brace_side=\"outside\", notes=False)")
])[
  Mark the subsidy wedge like the tax wedge, with a "Subsidy" brace, and
  name the subsidy's cost. @fig-subsidy hides some of these labels and
  shades only the deadweight loss (`regions=("dwl",)`), since the cost
  overlaps the surplus areas; @sec-labels describes the `visibility`
  argument used.
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
  A per-unit subsidy and its deadweight loss.
]) <fig-subsidy>

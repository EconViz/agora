#import "/template/manual.typ": *

= Market failures <sec-failures>

#changed("0.10.0", label: "MarketFigure.add_externality")[Social curves are named $M S C$ / $M S B$; $Q_m$ and $Q^*$ are marked on the quantity axis; corrective taxes and subsidies span the gap at $Q^*$]

== Externalities

When production imposes a cost on third parties, or consumption confers a
benefit on them, the market quantity differs from the social optimum. A
Pigouvian tax or subsidy equal to the external effect at the optimum
restores the optimal quantity #citep(<pigou1920>).

#api(("ExternalityScenario",), syntax: [
  #raw("ExternalityScenario(marginal_external_cost=0.0, marginal_external_benefit=0.0)")
])[
  A constant marginal external cost, which adds to supply to give the
  marginal social cost, and/or a marginal external benefit, which adds to
  demand to give the marginal social benefit. Both must be non-negative.
]

#api(("analyze_externality",), syntax: [
  #raw("analyze_externality(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  The private and social outcomes: `private_equilibrium`,
  `social_equilibrium`, `social_demand`, `social_supply`, `corrective_tax`,
  `corrective_subsidy`, `quantity_distortion` and `deadweight_loss`.
]

```python
from principle_viz import ExternalityScenario, analyze_externality

demand = line_from_inverse(12.0, -1.0)
scenario = ExternalityScenario(marginal_external_cost=2)
result = analyze_externality(demand, supply, scenario)
print(result.private_equilibrium.q_star, result.social_equilibrium.q_star)
# 5.0 4.0
print(result.corrective_tax, result.deadweight_loss)
# 2.0 1.0
```

#api(("MarketFigure.add_externality",), syntax: [
  #raw("add_externality(")#meta("result")#raw(")")
])[
  Draw the social curve, mark $Q_m$ (market) and $Q^*$ (optimum) on the
  quantity axis, label the corrective tax $t$ or subsidy $s$ across the gap
  at $Q^*$, and shade the deadweight loss (see @fig-neg-externality and
  @fig-pos-externality).
]

#fig("/figures/failures/negative_externality.svg", width: 46%, caption: [
  A negative externality.
]) <fig-neg-externality>

#fig("/figures/failures/positive_externality.svg", width: 46%, caption: [
  A positive externality.
]) <fig-pos-externality>

== Common resources

#api(("analyze_common_resource",), syntax: [
  #raw("analyze_common_resource(")#meta("benefit")#raw(", ")#meta("cost")#raw(", *, marginal_congestion_cost)")
])[
  Treat congestion or depletion as a marginal external cost: open access
  uses the resource until marginal benefit equals private cost, beyond the
  efficient level #citep(<hardin1968>). The result has
  `open_access_equilibrium`, `efficient_equilibrium`, `social_cost`,
  `overuse`, `corrective_fee` and `deadweight_loss`.
]

With $M B = 12 - Q$, $M P C = 2 + Q$ and a congestion cost of 3, open access
uses 5 units, the efficient level is 3.5 and `corrective_fee` is 3.

#api(("MarketFigure.add_common_resource",), syntax: [
  #raw("add_common_resource(")#meta("result")#raw(")")
])[
  Draw the social cost, mark $Q^*$ and $Q_"open"$, and shade the
  deadweight loss. Name the curves $M B$ and $M P C$ in `add_curves()`. See
  @fig-common-resource.
]

#fig("/figures/failures/common_resource.svg", width: 46%, caption: [
  Overuse of a common resource.
]) <fig-common-resource>

== Public goods

#api(("IndividualBenefit", "analyze_public_good"), syntax: [
  #raw("IndividualBenefit(name, marginal_benefit)") \
  #raw("analyze_public_good(")#meta("individuals")#raw(", ")#meta("cost")#raw(", *, samples=101)")
])[
  Everyone consumes the whole quantity of a public good, so marginal
  benefits add vertically. The efficient quantity sets their sum equal to
  marginal cost #citep(<samuelson1954>)\; private provision stops where the
  highest individual benefit meets marginal cost. The result has
  `efficient_quantity`, `efficient_marginal_value`,
  `private_provision_quantity`, `free_rider_gap` and the sampled `points`.
]

```python
from principle_viz import IndividualBenefit, analyze_public_good

result = analyze_public_good(
    (
        IndividualBenefit("$MB_A$", line_from_inverse(8, -1)),
        IndividualBenefit("$MB_B$", line_from_inverse(6, -1)),
    ),
    line_from_inverse(5, 0),  # constant marginal cost of 5
)
print(result.efficient_quantity, result.private_provision_quantity)
# 4.5 3.0
```

#api(("public_good_canvas",), syntax: [
  #raw("public_good_canvas(")#meta("result")#raw(", *, theme=None, labels=None, visibility=None)")
])[
  A #pkg("mosaickit") canvas, in `principle_viz.visuals.market_failures`,
  with each marginal benefit, their vertical sum, marginal cost, and $Q_p$
  and $Q^*$ on the quantity axis (see @fig-public-good).
]

#fig("/figures/failures/public_good.svg", width: 46%, caption: [
  The vertical sum of marginal benefits.
]) <fig-public-good>

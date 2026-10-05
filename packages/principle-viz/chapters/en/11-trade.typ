#import "/template/manual.typ": *

= International trade <sec-trade>

#changed("0.10.0", label: "MarketFigure.add_trade")[Marks $Q_s$ / $Q_d$ and braces "Imports" / "Exports" under the quantity axis; the policy price is marked $p_w + t$ or $p_q$]

A small open economy takes the world price $p_w$ as given. Below the autarky
price it imports the gap between domestic demand and supply; above it, it
exports. A tariff or an import quota raises the domestic price and shrinks
imports.

#api(("TradeScenario",), syntax: [
  #raw("TradeScenario(world_price, tariff=0.0, import_quota=None, quota_rent_recipient=QuotaRentRecipient.DOMESTIC)")
])[
  The world price and at most one policy: a per-unit `tariff` or an
  `import_quota`, not both (`PolicyError`).
]

#param("quota_rent_recipient", type: "QuotaRentRecipient")[Who gains the quota rent: `DOMESTIC` importers or `GOVERNMENT` (both count in national surplus; the government's share is reported as revenue), or `FOREIGN` exporters (it leaves the country).]

#api(("analyze_trade",), syntax: [
  #raw("analyze_trade(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  Compare autarky, free trade and the policy. The `TradeComparisonResult`
  holds three `TradeOutcome`s, `autarky`, `free_trade` and `policy`, and
  the `deadweight_loss` of the policy relative to free trade.
]

#param("domestic_price")[Price in the home market.]
#param("quantity_demanded")[Domestic quantity demanded at that price.]
#param("quantity_supplied")[Domestic quantity supplied at that price.]
#param("imports")[Quantity imported.]
#param("exports")[Quantity exported.]
#param("direction")[`TradeDirection`: `IMPORT`, `EXPORT` or `AUTARKY`.]
#param("consumer_surplus")[Consumer surplus.]
#param("producer_surplus")[Producer surplus.]
#param("government_revenue")[Government revenue.]
#param("quota_rent")[Rent created by a quota.]
#param("national_quota_rent")[The part of the quota rent that stays in the country.]
#param("total_surplus")[National surplus.]
#param("gains_from_trade")[Gain over autarky.]
#param("is_policy_binding")[Whether the tariff or quota changes the price.]

```python
from principle_viz import TradeScenario, analyze_trade

demand = line_from_inverse(12.0, -1.0)   # autarky price 7
scenario = TradeScenario(world_price=4, tariff=2)
result = analyze_trade(demand, supply, scenario)
print(result.free_trade.imports, result.policy.imports)
# 6.0 2.0
print(result.policy.government_revenue, result.deadweight_loss)
# 4.0 4.0
```

With the tariff of 2, the domestic price is 6 and government revenue is
$2 times 2 = 4$. An import quota of 2 units gives the same price; the rent
of 4 goes to the party named by `quota_rent_recipient`.

#api(("MarketFigure.add_trade",), syntax: [
  #raw("add_trade(")#meta("result")#raw(")")
])[
  Draw the world price line, named $p_w$, the policy price ($p_w + t$ or
  $p_q$), $Q_s$ and $Q_d$ on the quantity axis with an "Imports" or "Exports"
  brace beneath, and the tariff revenue or quota rent as a named rectangle
  (see @fig-free-trade, @fig-tariff and @fig-quota).
]

#fig("/figures/trade/free_trade_import.svg", width: 46%, caption: [
  Free trade with imports.
]) <fig-free-trade>

#fig("/figures/trade/tariff.svg", width: 46%, caption: [
  An import tariff.
]) <fig-tariff>

#fig("/figures/trade/quota.svg", width: 46%, caption: [
  A binding import quota.
]) <fig-quota>

#import "/template/manual.typ": *


= Monopoly and pricing <sec-monopoly>

Market power: the single-price monopoly, its regulation, and pricing beyond one price.

Each section is one example script and the figures it draws. The scripts come in the archive of this manual; `--help` lists their arguments.

== Monopoly <sec-ex-monopoly>

The monopolist produces where MR = MC and reads the price off demand. Totals, taxes, demand shifts, several plants and the Lerner index are variations on that figure. Sources: #citet(<lerner1934>).

#block(breakable: false)[
#api(("Monopolist", "MonopolyOutcome", "MultiplantMonopoly", "MultiplantOutcome", "elasticity"), syntax: [
  ```python
  Monopolist(demand, cost)
  MultiplantMonopoly(demand, plants)
  elasticity(demand, quantity)
  ```
])[
  `Monopolist.solve()` returns a `MonopolyOutcome` with the output, price and profit; `MultiplantMonopoly` splits output across plants; `elasticity()` is the price elasticity of linear demand.
]
]

#block(breakable: false)[
#api(("lerner_markup_canvas",), syntax: [
  ```python
  lerner_markup_canvas(outcomes, analyses, **options)
  ```
])[
  One panel per demand: a brace on `p - MC` shows the markup, small with elastic demand and large with inelastic demand (the Lerner index is `1 / |e|`).
]
]

#block(breakable: false)[
#api(("monopoly_canvas",), syntax: [
  ```python
  monopoly_canvas(
      outcome,
      analysis,
      *,
      curves=('mc', 'atc'),
      profit=False,
      lost_profit=None,
      extra=(),
      output_mark=True,
      **options,
  )
  ```
])[
  The monopolist: demand `D` (= AR), `MR`, and the cost curves in `curves`.
]
]

#block(breakable: false)[
#api(("monopoly_demand_shift_canvas",), syntax: [
  ```python
  monopoly_demand_shift_canvas(
      before,
      after,
      analysis,
      *,
      rotate=False,
      **options,
  )
  ```
])[
  Demand moves (thin solid `D'` and `MR'`): a parallel shift or, with `rotate`, a change of slope around the quantity-axis end. A monopolist has no supply curve, so the same price can go with different outputs, and the new optimum is read off `MR' = MC`.
]
]

#block(breakable: false)[
#api(("monopoly_dwl_canvas",), syntax: [
  ```python
  monopoly_dwl_canvas(outcome, analysis, **options)
  ```
])[
  Monopoly against the competitive outcome `p = MC`: a transfer rectangle and the deadweight-loss triangle between demand and MC from `Q_m` to `Q_c`.
]
]

#block(breakable: false)[
#api(("monopoly_tax_canvas",), syntax: [
  ```python
  monopoly_tax_canvas(
      before,
      after,
      analysis_before,
      analysis_after,
      **options,
  )
  ```
])[
  A per-unit tax lifts MC (thin solid `MC'`); the arrow rises from the old MC at `Q_m` to the new one and the price moves from `p_m` to `p'`.
]
]

#block(breakable: false)[
#api(("monopoly_totals_canvas",), syntax: [
  ```python
  monopoly_totals_canvas(outcome, *, output_range, samples=121, **options)
  ```
])[
  Total revenue `R`, total cost `TC` and profit against output, with the maximum profit at `Q_m` where the slopes of `R` and `TC` are equal.
]
]

#block(breakable: false)[
#api(("monopoly_totals_grid",), syntax: [
  ```python
  monopoly_totals_grid(outcome, analysis, **options)
  ```
])[
  Totals above, unit curves with the profit rectangle below, sharing the optimum `Q_m`.
]
]

#block(breakable: false)[
#api(("multiplant_canvas",), syntax: [
  ```python
  multiplant_canvas(firm, outcome, **options)
  ```
])[
  Each plant's MC beside the horizontally summed `MC_T` against `D` and `MR`.
]
]

The function of the script that draws the figures follows.

```python
def monopoly_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    demand: LinearDemand,
    shifted: LinearDemand,
    rotated: LinearDemand,
    cost: CubicCost,
    plants: tuple[CubicCost, CubicCost],
    plant_demand: LinearDemand,
    elastic: LinearDemand,
    inelastic: LinearDemand,
    tax: float,
    lost_profit: tuple[float, float],
    min_output: float,
    max_output: float,
    samples: int,
    title: str | None = None,
) -> list[Path]:
    """Write the monopoly figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    window = (min_output, max_output)

    unit = analyze_costs(cost, output_range=window, samples=samples)
    firm = Monopolist(demand, cost)
    outcome = firm.solve()
    taxed_cost = cost.with_unit_tax(tax)
    taxed = analyze_costs(taxed_cost, output_range=window, samples=samples)
    taxed_outcome = Monopolist(demand, taxed_cost).solve()
    shifted_outcome = firm.with_demand(shifted).solve()
    rotated_outcome = firm.with_demand(rotated).solve()
    multi = MultiplantMonopoly(plant_demand, plants)
    elastic_outcome = Monopolist(elastic, cost).solve()
    inelastic_outcome = Monopolist(inelastic, cost).solve()
    figures = {
        "monopoly.svg": monopoly_canvas(
            outcome, unit, curves=("mc",), title=title, theme=theme
        ),
        "monopoly_lost_profit.svg": monopoly_canvas(
            outcome,
            unit,
            curves=("mc",),
            lost_profit=lost_profit,
            title=title,
            theme=theme,
        ),
        "monopoly_profit.svg": monopoly_canvas(
            outcome, unit, profit=True, title=title, theme=theme
        ),
        "monopoly_totals.svg": monopoly_totals_canvas(
            outcome, output_range=window, title=title, theme=theme
        ),
        "monopoly_totals_grid.svg": monopoly_totals_grid(
            outcome, unit, theme=theme
        ),
        "monopoly_dwl.svg": monopoly_dwl_canvas(
            outcome, unit, title=title, theme=theme
        ),
        "monopoly_tax.svg": monopoly_tax_canvas(
            outcome, taxed_outcome, unit, taxed, title=title, theme=theme
        ),
        "monopoly_demand_shift.svg": monopoly_demand_shift_canvas(
            outcome, shifted_outcome, unit, title=title, theme=theme
        ),
        "monopoly_demand_rotate.svg": monopoly_demand_shift_canvas(
            outcome,
            rotated_outcome,
            unit,
            rotate=True,
            title=title,
            theme=theme,
        ),
        "multiplant.svg": multiplant_canvas(
            multi, multi.solve(), theme=theme
        ),
        "lerner_markup.svg": lerner_markup_canvas(
            (elastic_outcome, inelastic_outcome), (unit, unit), theme=theme
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/monopoly/monopoly.svg", width: 46%, caption: [
  *Monopoly: MR = MC.* The monopolist produces where MR = MC and the price is read off demand.
]) <fig-monopoly-monopoly>

#fig("/figures/monopoly/monopoly_lost_profit.svg", width: 46%, caption: [
  *Monopoly: profit lost off the optimum.* Any output other than the one where MR = MC lowers profit.
]) <fig-monopoly-monopoly-lost-profit>

#fig("/figures/monopoly/monopoly_profit.svg", width: 46%, caption: [
  *Monopoly profit.* Profit is the rectangle between the price and ATC.
]) <fig-monopoly-monopoly-profit>

#fig("/figures/monopoly/monopoly_totals.svg", width: 46%, caption: [
  *Revenue, cost and profit.* TR, TC and profit; the slopes are equal where profit is largest.
]) <fig-monopoly-monopoly-totals>

#fig("/figures/monopoly/monopoly_totals_grid.svg", width: 46%, caption: [
  *Totals and unit curves.* Totals above, unit curves with the profit rectangle below.
]) <fig-monopoly-monopoly-totals-grid>

#fig("/figures/monopoly/monopoly_dwl.svg", width: 46%, caption: [
  *Deadweight loss of monopoly.* The transfer rectangle and deadweight-loss triangle against perfect competition.
]) <fig-monopoly-monopoly-dwl>

#fig("/figures/monopoly/monopoly_tax.svg", width: 46%, caption: [
  *Per-unit tax on a monopolist.* A per-unit tax lifts MC; price and output adjust.
]) <fig-monopoly-monopoly-tax>

#fig("/figures/monopoly/monopoly_demand_shift.svg", width: 46%, caption: [
  *Demand shift.* A parallel demand shift; a monopolist has no supply curve, so output and price follow MR' = MC.
]) <fig-monopoly-monopoly-demand-shift>

#fig("/figures/monopoly/monopoly_demand_rotate.svg", width: 46%, caption: [
  *Demand rotation.* When demand rotates, the direction of the price change depends on how.
]) <fig-monopoly-monopoly-demand-rotate>

#fig("/figures/monopoly/multiplant.svg", width: 46%, caption: [
  *Multiplant monopoly.* The plants' MC curves sum horizontally and meet MR, which fixes each plant's output.
]) <fig-monopoly-multiplant>

#fig("/figures/monopoly/lerner_markup.svg", width: 46%, caption: [
  *Lerner markup.* The less elastic demand is, the larger the markup (p - MC).
]) <fig-monopoly-lerner-markup>

== Monopolistic competition <sec-ex-monopolistic-competition>

Each firm faces a downward demand. Entry shifts demand left until it is tangent to ATC, leaving the price above MC and capacity unused. Sources: #citet(<chamberlin1933>).

#block(breakable: false)[
#api(("solve_monopolistic_competition", "MonopolisticOutcome", "long_run_demand"), syntax: [
  ```python
  solve_monopolistic_competition(demand, cost)
  long_run_demand(demand, cost)
  ```
])[
  `solve_monopolistic_competition()` returns the short-run optimum and the long-run tangency after entry; `long_run_demand()` builds the demand curve of equal slope that is tangent to ATC.
]
]

#block(breakable: false)[
#api(("excess_capacity_grid",), syntax: [
  ```python
  excess_capacity_grid(outcome, analysis, **options)
  ```
])[
  Monopolistic competition (price above MC, excess capacity) beside perfect competition (`p = MC` at minimum ATC).
]
]

#block(breakable: false)[
#api(("monopolistic_long_run_canvas",), syntax: [
  ```python
  monopolistic_long_run_canvas(
      outcome,
      analysis,
      *,
      excess_capacity=False,
      **options,
  )
  ```
])[
  The long run: demand tangent to ATC at the output where `MR = MC`, price above MC.
]
]

#block(breakable: false)[
#api(("monopolistic_short_run_canvas",), syntax: [
  ```python
  monopolistic_short_run_canvas(outcome, analysis, **options)
  ```
])[
  The short run: the monopoly optimum with the profit rectangle before entry.
]
]

The function of the script that draws the figures follows.

```python
def monopolistic_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    cost: CubicCost,
    demand: LinearDemand,
    min_output: float,
    max_output: float,
    samples: int,
    title: str | None = None,
) -> list[Path]:
    """Write the monopolistic-competition figures into ``output_dir``."""
    output_dir.mkdir(parents=True, exist_ok=True)
    unit = analyze_costs(
        cost, output_range=(min_output, max_output), samples=samples
    )
    outcome = solve_monopolistic_competition(demand, cost)
    figures = {
        "short_run.svg": monopolistic_short_run_canvas(
            outcome, unit, theme=theme, title=title
        ),
        "long_run.svg": monopolistic_long_run_canvas(
            outcome, unit, theme=theme, title=title
        ),
        "excess_capacity.svg": excess_capacity_grid(
            outcome, unit, theme=theme
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/monopolistic_competition/short_run.svg", width: 46%, caption: [
  *Short run.* In the short run there is a profit: output times the gap between price and ATC.
]) <fig-monopolistic-competition-short-run>

#fig("/figures/monopolistic_competition/long_run.svg", width: 46%, caption: [
  *Long-run tangency.* Long-run equilibrium: demand is tangent to ATC at the output where MR = MC, with the price above MC.
]) <fig-monopolistic-competition-long-run>

#fig("/figures/monopolistic_competition/excess_capacity.svg", width: 46%, caption: [
  *Excess capacity.* Output falls short of the lowest-ATC output; the gap is excess capacity.
]) <fig-monopolistic-competition-excess-capacity>

== Regulation <sec-ex-regulation>

A price ceiling flattens a monopolist's average revenue; a natural monopoly with falling ATC compares unregulated, marginal-cost and average-cost pricing.

#block(breakable: false)[
#api(("price_ceiling_outcome", "CeilingOutcome", "natural_monopoly_pricing", "NaturalMonopolyPricing", "PricingPoint"), syntax: [
  ```python
  price_ceiling_outcome(firm, ceiling)
  natural_monopoly_pricing(firm)
  NaturalMonopolyPricing(
      demand,
      cost,
      unregulated,
      marginal_cost,
      average_cost,
  )
  ```
])[
  `price_ceiling_outcome()` finds the best output under a ceiling; `natural_monopoly_pricing()` returns the three prices as `PricingPoint` values.
]
]

#block(breakable: false)[
#api(("natural_monopoly_canvas",), syntax: [
  ```python
  natural_monopoly_canvas(pricing, analysis, **options)
  ```
])[
  A natural monopoly with falling ATC: the unregulated price, `P = MC` (with the loss shaded) and `P = ATC` (no profit).
]
]

#block(breakable: false)[
#api(("price_ceiling_canvas",), syntax: [
  ```python
  price_ceiling_canvas(outcome, analysis, **options)
  ```
])[
  A price ceiling: average revenue is flat at the ceiling up to `Q_max` and marginal revenue equals the ceiling there, then jumps down to the unregulated `MR`.
]
]

The function of the script that draws the figures follows.

```python
def regulation_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    cost: CubicCost,
    demand: LinearDemand,
    ceiling: float,
    natural_demand: LinearDemand,
    fixed_cost: float,
    marginal_cost: float,
    min_output: float,
    max_output: float,
    samples: int,
    title: str | None = None,
) -> list[Path]:
    """Write the regulation figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    unit = analyze_costs(
        cost, output_range=(min_output, max_output), samples=samples
    )
    capped = price_ceiling_outcome(Monopolist(demand, cost), ceiling)
    natural_cost = PiecewiseCost(
        (
            CostSegment(
                natural_demand.quantity_intercept * 1.05, marginal_cost
            ),
        ),
        fixed_cost=fixed_cost,
    )
    natural = analyze_costs(
        natural_cost,
        output_range=(min_output, natural_demand.quantity_intercept),
        samples=samples,
    )
    pricing = natural_monopoly_pricing(
        Monopolist(natural_demand, natural_cost)
    )
    figures = {
        "price_ceiling.svg": price_ceiling_canvas(
            capped, unit, theme=theme, title=title
        ),
        "natural_monopoly.svg": natural_monopoly_canvas(
            pricing, natural, theme=theme, title=title
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/regulation/price_ceiling.svg", width: 46%, caption: [
  *Price ceiling on a monopolist.* A price ceiling flattens average revenue at the ceiling; marginal revenue drops at that point.
]) <fig-regulation-price-ceiling>

#fig("/figures/regulation/natural_monopoly.svg", width: 46%, caption: [
  *Natural monopoly pricing.* The unregulated price, marginal-cost pricing (a loss) and average-cost pricing.
]) <fig-regulation-natural-monopoly>

== Price discrimination <sec-ex-price-discrimination>

Perfect, block and third-degree discrimination, against the single monopoly price.

#block(breakable: false)[
#api(("first_degree", "block_pricing", "third_degree", "FirstDegree", "BlockPricing", "ThirdDegree", "Block", "MarketSale"), syntax: [
  ```python
  first_degree(demand, cost)
  block_pricing(demand, cost, blocks)
  third_degree(demands, cost)
  FirstDegree(demand, cost, quantity, revenue, profit, single_price)
  BlockPricing(demand, cost, blocks, revenue, profit)
  ThirdDegree(cost, markets, marginal_cost, quantity, profit)
  Block(start, end, price)
  MarketSale(demand, quantity, price, marginal_revenue, served)
  ```
])[
  The functions `first_degree()`, `block_pricing()` and `third_degree()` return the matching outcome objects with the quantities, prices and profit.
]
]

#block(breakable: false)[
#api(("block_pricing_canvas",), syntax: [
  ```python
  block_pricing_canvas(result, *, average_cost=False, **options)
  ```
])[
  Equal blocks each sold at the price of its last buyer: a staircase under demand ending at `D = MC`. `average_cost` adds the (declining) ATC of the cost function.
]
]

#block(breakable: false)[
#api(("first_degree_canvas",), syntax: [
  ```python
  first_degree_canvas(result, **options)
  ```
])[
  Perfect discrimination: price follows demand to `D = MC`; the profit is the area between demand and MC, with the extra gain over the single monopoly price shaded darker.
]
]

#block(breakable: false)[
#api(("single_price_canvas",), syntax: [
  ```python
  single_price_canvas(demand, cost, *, groups=False, **options)
  ```
])[
  One monopoly price (`MR = MC`): the consumer surplus above it and the surplus left uncaptured between demand and MC beyond `Q^*`; `groups` also marks the buyers who pay far less than they would and those who are priced out.
]
]

#block(breakable: false)[
#api(("third_degree_canvas",), syntax: [
  ```python
  third_degree_canvas(result, **options)
  ```
])[
  One panel per market (`D_i`, `MR_i`, the common level `MC*`) and a last panel with the summed `MR_T` meeting MC. A market whose demand starts below `MC*` is not served.
]
]

The function of the script that draws the figures follows.

```python
def discrimination_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    demand: LinearDemand,
    marginal_cost: float,
    fixed_cost: float,
    blocks: int,
    markets: tuple[LinearDemand, ...],
    skipped_market: LinearDemand,
    rising_cost: CubicCost,
    capacity: float,
    title: str | None = None,
) -> list[Path]:
    """Write the price-discrimination figures into ``output_dir``."""
    output_dir.mkdir(parents=True, exist_ok=True)
    flat: CostFunction = PiecewiseCost(
        (CostSegment(capacity, marginal_cost),)
    )
    with_fixed = PiecewiseCost(
        (CostSegment(capacity, marginal_cost),), fixed_cost=fixed_cost
    )
    figures = {
        "single_price.svg": single_price_canvas(
            demand, flat, groups=True, theme=theme, title=title
        ),
        "first_degree.svg": first_degree_canvas(
            first_degree(demand, flat), theme=theme, title=title
        ),
        "block_pricing_three.svg": block_pricing_canvas(
            block_pricing(demand, flat, 3), theme=theme, title=title
        ),
        "block_pricing.svg": block_pricing_canvas(
            block_pricing(demand, with_fixed, blocks),
            average_cost=True,
            theme=theme,
            title=title,
        ),
        "third_degree.svg": third_degree_canvas(
            third_degree(markets, flat), theme=theme
        ),
        "third_degree_corner.svg": third_degree_canvas(
            third_degree((markets[0], skipped_market), rising_cost),
            theme=theme,
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/price_discrimination/single_price.svg", width: 46%, caption: [
  *One monopoly price.* At one price some surplus is left uncaptured.
]) <fig-price-discrimination-single-price>

#fig("/figures/price_discrimination/first_degree.svg", width: 46%, caption: [
  *Perfect discrimination.* Price follows demand; profit is the area between demand and MC.
]) <fig-price-discrimination-first-degree>

#fig("/figures/price_discrimination/block_pricing_three.svg", width: 46%, caption: [
  *Block pricing.* Three-block pricing is an imperfect form of first-degree discrimination.
]) <fig-price-discrimination-block-pricing-three>

#fig("/figures/price_discrimination/block_pricing.svg", width: 46%, caption: [
  *Block pricing with falling ATC.* Block pricing when demand lies above a falling ATC.
]) <fig-price-discrimination-block-pricing>

#fig("/figures/price_discrimination/third_degree.svg", width: 46%, caption: [
  *Third-degree discrimination.* MR1 = MR2 = MC; the summed marginal revenue fixes total output.
]) <fig-price-discrimination-third-degree>

#fig("/figures/price_discrimination/third_degree_corner.svg", width: 46%, caption: [
  *Third degree, corner.* With rising marginal cost a small market may go unserved.
]) <fig-price-discrimination-third-degree-corner>

== Two-part tariffs <sec-ex-two-part-tariff>

An entry fee plus a usage fee. The fee that takes the surplus of the least-surplus buyer served gives the profit. Sources: #citet(<oi1971>).

#block(breakable: false)[
#api(("BuyerType", "best_tariff", "evaluate_tariff", "profit_by_entry_fee"), syntax: [
  ```python
  BuyerType(demand, count=1.0)
  best_tariff(buyers, marginal_cost)
  evaluate_tariff(buyers, marginal_cost, usage_fee, entry_fee)
  profit_by_entry_fee(buyers, marginal_cost, usage_fee, fees)
  ```
])[
  `BuyerType` is a demand curve with a weight; `best_tariff()` searches the usage fees, and `evaluate_tariff()` gives the profit of a given pair of fees.
]
]

#block(breakable: false)[
#api(("tariff_profit_canvas",), syntax: [
  ```python
  tariff_profit_canvas(buyers, marginal_cost, usage_fee, fee_max, **options)
  ```
])[
  Profit from entry fees, from sales and in total against the entry fee `T` at a fixed usage fee: it steps down each time a buyer type is priced out.
]
]

#block(breakable: false)[
#api(("two_part_tariff_canvas",), syntax: [
  ```python
  two_part_tariff_canvas(buyers, outcome, **options)
  ```
])[
  Demand of each buyer type, the constant `MC` and the usage fee `p^*`. The entry fee is the shaded consumer-surplus triangle of the buyer with the least surplus served; when the usage fee is above MC the rectangle `(p^* - MC) Q` is the sales profit.
]
]

The function of the script that draws the figures follows.

```python
def tariff_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    single: BuyerType,
    buyers: tuple[BuyerType, ...],
    marginal_cost: float,
    usage_fee: float,
    fee_max: float,
    title: str | None = None,
) -> list[Path]:
    """Write the tariff figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    flat = evaluate_tariff(
        (single,),
        marginal_cost,
        marginal_cost,
        single.surplus(marginal_cost),
    )
    best = best_tariff(buyers, marginal_cost)
    figures = {
        "single_buyer.svg": two_part_tariff_canvas(
            (single,), flat, theme=theme, title=title
        ),
        "two_buyers.svg": two_part_tariff_canvas(
            buyers, best, theme=theme, title=title
        ),
        "tariff_profit.svg": tariff_profit_canvas(
            buyers,
            marginal_cost,
            usage_fee,
            fee_max,
            theme=theme,
            title=title,
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/two_part_tariff/single_buyer.svg", width: 46%, caption: [
  *Two-part tariff, one buyer.* The usage fee equals MC and the entry fee takes all consumer surplus.
]) <fig-two-part-tariff-single-buyer>

#fig("/figures/two_part_tariff/two_buyers.svg", width: 46%, caption: [
  *Two-part tariff, two buyer types.* The usage fee exceeds MC; the entry fee equals the surplus of the smaller buyer.
]) <fig-two-part-tariff-two-buyers>

#fig("/figures/two_part_tariff/tariff_profit.svg", width: 46%, caption: [
  *Profit against the entry fee.* Profit from fees, from sales and in total, against the entry fee.
]) <fig-two-part-tariff-tariff-profit>

== Bundling <sec-ex-bundling>

Consumers sit in a space of reservation prices. Separate selling, pure bundling and mixed bundling cut that space into purchase regions. Sources: #citet(<adamsyellen1976>).

#block(breakable: false)[
#api(("ValuationProfile", "Offer", "best_separate", "best_pure", "best_mixed", "evaluate_offer", "choice", "choice_regions"), syntax: [
  ```python
  ValuationProfile(points, cost_1=0.0, cost_2=0.0)
  Offer(price_1=None, price_2=None, price_bundle=None)
  best_separate(profile)
  best_pure(profile)
  best_mixed(profile)
  evaluate_offer(profile, offer)
  choice(offer, r1, r2)
  choice_regions(offer, reach)
  ```
])[
  `ValuationProfile` holds the consumers' reservation prices; `best_separate()`, `best_pure()` and `best_mixed()` search for the profit-maximising prices; `choice_regions()` gives the purchase regions as polygons.
]
]

#block(breakable: false)[
#api(("mixed_bundling_canvas",), syntax: [
  ```python
  mixed_bundling_canvas(
      profile,
      offer,
      names=None,
      *,
      numbered=False,
      **options,
  )
  ```
])[
  Regions of mixed bundling (goods at `P1`, `P2` and the bundle at `P_B`). With positive costs the cost lines are marked; `numbered` labels the regions I to IV.
]
]

#block(breakable: false)[
#api(("pure_bundling_canvas",), syntax: [
  ```python
  pure_bundling_canvas(profile, price, names=None, **options)
  ```
])[
  Valuation space split by the diagonal `r1 + r2 = P_B`: consumers above it buy.
]
]

#block(breakable: false)[
#api(("separate_selling_regions_canvas",), syntax: [
  ```python
  separate_selling_regions_canvas(profile, offer, names=None, **options)
  ```
])[
  The four purchase regions cut by `r1 = P1` and `r2 = P2` (goods sold apart).
]
]

#block(breakable: false)[
#api(("valuation_scatter_canvas",), syntax: [
  ```python
  valuation_scatter_canvas(profile, names=None, **options)
  ```
])[
  Consumers as points `(r1, r2)` in valuation space; `names` labels the first points.
]
]

The function of the script that draws the figures follows.

```python
def bundling_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    consumers: tuple[tuple[float, float], ...],
    count: int,
    low: float,
    high: float,
    spread: float,
    cost_1: float,
    cost_2: float,
    title: str | None = None,
) -> list[Path]:
    """Write the bundling figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    few = ValuationProfile(consumers)
    negative = ValuationProfile.correlated(
        count, low=low, high=high, direction=-1.0, spread=spread
    )
    costly = ValuationProfile.correlated(
        count,
        low=low,
        high=high,
        direction=-1.0,
        spread=spread,
        cost_1=cost_1,
        cost_2=cost_2,
    )
    positive = ValuationProfile.correlated(
        count, low=low, high=high, direction=1.0, spread=spread
    )
    separate = best_separate(negative).offer
    figures = {
        "valuation_points.svg": valuation_scatter_canvas(
            few, theme=theme, title=title
        ),
        "separate_regions.svg": separate_selling_regions_canvas(
            negative, separate, theme=theme, title=title
        ),
        "pure_bundling.svg": pure_bundling_canvas(
            negative,
            best_pure(negative).offer.price_bundle or 0.0,
            theme=theme,
            title=title,
        ),
        "mixed_bundling.svg": mixed_bundling_canvas(
            negative, best_mixed(negative).offer, theme=theme, title=title
        ),
        "mixed_with_costs.svg": mixed_bundling_canvas(
            costly, best_mixed(costly).offer, theme=theme, title=title
        ),
        "regions_numbered.svg": mixed_bundling_canvas(
            positive,
            best_mixed(positive).offer,
            numbered=True,
            theme=theme,
            title=title,
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/bundling/valuation_points.svg", width: 46%, caption: [
  *Valuation space.* Consumers placed by their reservation prices r1 and r2.
]) <fig-bundling-valuation-points>

#fig("/figures/bundling/separate_regions.svg", width: 46%, caption: [
  *Separate selling.* The prices P1 and P2 cut the valuation space into four purchase regions.
]) <fig-bundling-separate-regions>

#fig("/figures/bundling/pure_bundling.svg", width: 46%, caption: [
  *Pure bundling.* Consumers above the diagonal r1 + r2 = PB buy the bundle.
]) <fig-bundling-pure-bundling>

#fig("/figures/bundling/mixed_bundling.svg", width: 46%, caption: [
  *Mixed bundling.* The four purchase regions under mixed bundling.
]) <fig-bundling-mixed-bundling>

#fig("/figures/bundling/mixed_with_costs.svg", width: 46%, caption: [
  *Mixed bundling with costs.* Mixed-bundling regions when marginal costs are positive.
]) <fig-bundling-mixed-with-costs>

#fig("/figures/bundling/regions_numbered.svg", width: 46%, caption: [
  *Regions I to IV.* The regions of mixed bundling numbered I to IV.
]) <fig-bundling-regions-numbered>

== Intertemporal and peak-load pricing <sec-ex-time-pricing>

Two groups of buyers are charged different prices over time, or two periods share a capacity cost.

#block(breakable: false)[
#api(("IntertemporalPricing", "PeakLoadPricing", "IntertemporalOutcome", "PeakLoadOutcome"), syntax: [
  ```python
  IntertemporalPricing(first, second, marginal_cost)
  PeakLoadPricing(peak, off_peak, marginal_cost, capacity_cost)
  ```
])[
  `IntertemporalPricing` and `PeakLoadPricing` solve the two markets and return the matching outcome objects.
]
]

#block(breakable: false)[
#api(("intertemporal_pricing_canvas",), syntax: [
  ```python
  intertemporal_pricing_canvas(pricing, **options)
  ```
])[
  Two demands and their marginal revenues against a constant `MC`: the high price is charged to the early group, the lower price to the later one.
]
]

#block(breakable: false)[
#api(("peak_load_canvas",), syntax: [
  ```python
  peak_load_canvas(pricing, **options)
  ```
])[
  Peak and off-peak demands with their marginal revenues; running cost `MC` for both periods and `MC + MC_K` (the capacity cost) for the peak.
]
]

The function of the script that draws the figures follows.

```python
def time_pricing_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    first: LinearDemand,
    second: LinearDemand,
    peak: LinearDemand,
    off_peak: LinearDemand,
    marginal_cost: float,
    capacity_cost: float,
    title: str | None = None,
) -> list[Path]:
    """Write the time-pricing figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    figures = {
        "intertemporal.svg": intertemporal_pricing_canvas(
            IntertemporalPricing(first, second, marginal_cost),
            theme=theme,
            title=title,
        ),
        "peak_load.svg": peak_load_canvas(
            PeakLoadPricing(peak, off_peak, marginal_cost, capacity_cost),
            theme=theme,
            title=title,
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/time_pricing/intertemporal.svg", width: 46%, caption: [
  *Intertemporal pricing.* The high-valuation group pays a high price first; the price is cut later.
]) <fig-time-pricing-intertemporal>

#fig("/figures/time_pricing/peak_load.svg", width: 46%, caption: [
  *Peak-load pricing.* Peak and off-peak demands are priced apart; the peak bears the capacity cost.
]) <fig-time-pricing-peak-load>

== Advertising <sec-ex-advertising>

Advertising shifts average revenue out and raises average cost; the figure compares profit before and after.

#block(breakable: false)[
#api(("AdvertisingDecision", "AdvertisingOutcome"), syntax: [
  ```python
  AdvertisingDecision(
      baseline,
      advertised,
      marginal_cost,
      fixed_cost,
      advertising_cost,
  )
  ```
])[
  `AdvertisingDecision` compares the profit with and without advertising and returns an `AdvertisingOutcome`.
]
]

#block(breakable: false)[
#api(("advertising_effect_canvas",), syntax: [
  ```python
  advertising_effect_canvas(decision, **options)
  ```
])[
  `AR` shifts out to `AR'` and average cost up to `AC'`; the rectangles show profit before (lighter) and after (darker). Changed curves are thin and solid.
]
]

The function of the script that draws the figures follows.

```python
def advertising_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    decision: AdvertisingDecision,
    title: str | None = None,
) -> list[Path]:
    """Write the advertising figure into ``output_dir`` and return its path."""
    output_dir.mkdir(parents=True, exist_ok=True)
    path = output_dir / "advertising.svg"
    advertising_effect_canvas(decision, theme=theme, title=title).save(path)
    return [path]
```

#fig("/figures/advertising/advertising.svg", width: 46%, caption: [
  *Advertising.* Advertising shifts AR out and raises average cost; profit before and after is compared.
]) <fig-advertising-advertising>

== Exhaustible resources <sec-ex-exhaustible-resource>

The price net of marginal extraction cost rises at the rate of interest until the choke price at the date the stock runs out. Sources: #citet(<hotelling1931>).

#block(breakable: false)[
#api(("ExhaustibleResourcePath",), syntax: [
  ```python
  ExhaustibleResourcePath(
      demand_intercept,
      demand_slope,
      extraction_cost,
      interest_rate,
      stock,
  )
  ```
])[
  `ExhaustibleResourcePath` gives the price path $p(t)$ and the matching static view of demand and the stock.
]
]

#block(breakable: false)[
#api(("resource_price_path_canvas",), syntax: [
  ```python
  resource_price_path_canvas(path, **options)
  ```
])[
  Left, the price path `p(t)` rising from `p_0` to the choke price at `T` above the marginal extraction cost `c`; right, the matching static view: demand `D` with the quantities extracted at the start and at `T / 2`, moving up the demand curve.
]
]

The function of the script that draws the figures follows.

```python
def resource_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    path: ExhaustibleResourcePath,
    title: str | None = None,
) -> list[Path]:
    """Write the resource figure into ``output_dir`` and return its path."""
    output_dir.mkdir(parents=True, exist_ok=True)
    target = output_dir / "resource_price_path.svg"
    resource_price_path_canvas(
        path, titles=(title, None), theme=theme
    ).save(target)
    return [target]
```

#fig("/figures/exhaustible_resource/resource_price_path.svg", width: 46%, caption: [
  *Exhaustible resource.* Price less marginal extraction cost grows at the interest rate; the static view is beside it.
]) <fig-exhaustible-resource-resource-price-path>

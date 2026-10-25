#import "/template/manual.typ": *


= Competition and the long run <sec-competition>

Price-taking firms, industry supply, long-run costs and entry.

Each section is one example script and the figures it draws. The scripts come in the archive of this manual; `--help` lists their arguments.

== Perfect competition <sec-ex-competition>

The price-taking firm produces where the price equals MC. Profit, loss and shutdown follow from where the price lies against ATC and AVC.

#block(breakable: false)[
#api(("LinearDemand", "solve_competitive_firm", "CompetitiveOutcome", "FirmSupply", "IndustrySupply", "analyze_revenue_cost", "Regime"), syntax: [
  ```python
  LinearDemand(intercept, slope)
  solve_competitive_firm(cost, price, *, tolerance=1e-09)
  FirmSupply(cost)
  IndustrySupply(firms)
  analyze_revenue_cost(cost, price, *, output_range, samples=201)
  ```
])[
  `solve_competitive_firm()` returns a `CompetitiveOutcome` whose `Regime` says whether the firm earns a profit, takes a loss or shuts down; `FirmSupply` and `IndustrySupply` give the supply of one firm and the horizontal sum of several; `analyze_revenue_cost()` samples revenue, cost and profit.
]
]

#block(breakable: false)[
#api(("competitive_firm_canvas",), syntax: [
  ```python
  competitive_firm_canvas(analysis, outcome, *, lost_profit=None, **options)
  ```
])[
  The price-taking firm: ATC, AVC and MC against the price line `P = MR`.
]
]

#block(breakable: false)[
#api(("cost_shift_canvas",), syntax: [
  ```python
  cost_shift_canvas(before, after, price, *, tax=None, **options)
  ```
])[
  MC before and after a cost increase, with the price line and the two outputs.
]
]

#block(breakable: false)[
#api(("firm_supply_canvas",), syntax: [
  ```python
  firm_supply_canvas(analysis, *, prices=(), **options)
  ```
])[
  The firm's supply curve: the part of MC above the lowest AVC, drawn solid.
]
]

#block(breakable: false)[
#api(("industry_supply_canvas",), syntax: [
  ```python
  industry_supply_canvas(
      industry,
      *,
      prices=(),
      price_max,
      samples=61,
      firm_curves=True,
      **options,
  )
  ```
])[
  Industry supply as the horizontal sum of the firms' supply curves.
]
]

#block(breakable: false)[
#api(("industry_supply_panels",), syntax: [
  ```python
  industry_supply_panels(
      industry,
      *,
      prices,
      price_max,
      samples=61,
      **options,
  )
  ```
])[
  The firms' supply curves side by side and the industry supply that sums them.
]
]

#block(breakable: false)[
#api(("market_and_firm_canvas",), syntax: [
  ```python
  market_and_firm_canvas(demand, price, *, firm_output_max, **options)
  ```
])[
  The firm beside the market: horizontal demand `d` at the market price, and the downward market demand `D`, with a dashed link carrying the price across.
]
]

#block(breakable: false)[
#api(("producer_surplus_canvas",), syntax: [
  ```python
  producer_surplus_canvas(analysis, outcome, **options)
  ```
])[
  Producer surplus: the area between the price and MC from zero to `q*`.
]
]

#block(breakable: false)[
#api(("revenue_cost_profit_canvas",), syntax: [
  ```python
  revenue_cost_profit_canvas(analysis, **options)
  ```
])[
  Total revenue, total cost and the profit curve against output.
]
]

The function of the script that draws the figures follows.

```python
def competition_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    cost: CubicCost,
    profit_price: float,
    loss_price: float,
    shutdown_price: float,
    lost_profit: tuple[float, float],
    supply_prices: tuple[float, float],
    tax: float,
    firms: tuple[CubicCost, ...],
    industry_prices: tuple[float, ...],
    demand: LinearDemand,
    market_price: float,
    min_output: float,
    max_output: float,
    samples: int,
    title: str | None = None,
) -> list[Path]:
    """Write the competition figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    unit = analyze_costs(
        cost, output_range=(min_output, max_output), samples=samples
    )
    taxed_cost = cost.with_unit_tax(tax)
    taxed = analyze_costs(
        taxed_cost, output_range=(min_output, max_output), samples=samples
    )
    figures = {
        "revenue_cost_profit.svg": revenue_cost_profit_canvas(
            analyze_revenue_cost(
                cost,
                profit_price,
                output_range=(0.0, max_output),
                samples=samples,
            ),
            theme=theme,
            title=title,
        ),
        "market_and_firm.svg": market_and_firm_canvas(
            demand,
            market_price,
            firm_output_max=max_output,
            theme=theme,
            titles=(title, None),
        ),
        "firm_profit.svg": competitive_firm_canvas(
            unit,
            solve_competitive_firm(cost, profit_price),
            theme=theme,
            title=title,
        ),
        "firm_lost_profit.svg": competitive_firm_canvas(
            unit,
            solve_competitive_firm(cost, profit_price),
            lost_profit=lost_profit,
            theme=theme,
            title=title,
        ),
        "firm_loss.svg": competitive_firm_canvas(
            unit,
            solve_competitive_firm(cost, loss_price),
            theme=theme,
            title=title,
        ),
        "firm_shutdown.svg": competitive_firm_canvas(
            unit,
            solve_competitive_firm(cost, shutdown_price),
            theme=theme,
            title=title,
        ),
        "firm_supply.svg": firm_supply_canvas(
            unit, prices=supply_prices, theme=theme, title=title
        ),
        "cost_shift.svg": cost_shift_canvas(
            unit, taxed, profit_price, theme=theme, title=title
        ),
        "unit_tax.svg": cost_shift_canvas(
            unit, taxed, profit_price, tax=tax, theme=theme, title=title
        ),
        "industry_supply.svg": industry_supply_panels(
            IndustrySupply(firms),
            prices=industry_prices,
            price_max=max(industry_prices) * 1.1,
            theme=theme,
            titles=(title,),
            size=(4.2, 4.2),
        ),
        "industry_supply_total.svg": industry_supply_canvas(
            IndustrySupply(firms),
            prices=industry_prices,
            price_max=max(industry_prices) * 1.1,
            firm_curves=False,
            theme=theme,
            title=title,
        ),
        "producer_surplus.svg": producer_surplus_canvas(
            unit,
            solve_competitive_firm(cost, profit_price),
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

#fig("/figures/competition/revenue_cost_profit.svg", width: 46%, caption: [
  *Revenue, cost and profit.* Profit is largest where total revenue exceeds total cost by the most.
]) <fig-competition-revenue-cost-profit>

#fig("/figures/competition/market_and_firm.svg", width: 46%, caption: [
  *Market and firm.* The market demand sets the price; the firm faces a horizontal demand.
]) <fig-competition-market-and-firm>

#fig("/figures/competition/firm_profit.svg", width: 46%, caption: [
  *Firm earning a profit.* With the price above ATC, profit is the rectangle between the price and ATC.
]) <fig-competition-firm-profit>

#fig("/figures/competition/firm_lost_profit.svg", width: 46%, caption: [
  *Profit lost off the optimum.* Any output other than the one where MR = MC loses profit.
]) <fig-competition-firm-lost-profit>

#fig("/figures/competition/firm_loss.svg", width: 46%, caption: [
  *Firm with a loss.* With the price between AVC and ATC the firm keeps producing at a loss.
]) <fig-competition-firm-loss>

#fig("/figures/competition/firm_shutdown.svg", width: 46%, caption: [
  *Shutdown.* With the price below the lowest AVC the firm stops producing.
]) <fig-competition-firm-shutdown>

#fig("/figures/competition/firm_supply.svg", width: 46%, caption: [
  *Firm supply curve.* The supply curve is the part of MC above the lowest AVC.
]) <fig-competition-firm-supply>

#fig("/figures/competition/cost_shift.svg", width: 46%, caption: [
  *Cost shift.* Higher costs shift MC and AVC up and output falls.
]) <fig-competition-cost-shift>

#fig("/figures/competition/unit_tax.svg", width: 46%, caption: [
  *Per-unit tax.* A per-unit tax shifts MC up by the tax and the firm cuts output.
]) <fig-competition-unit-tax>

#fig("/figures/competition/industry_supply.svg", width: 46%, caption: [
  *Industry supply.* Industry supply is the horizontal sum of the firms' supply curves.
]) <fig-competition-industry-supply>

#fig("/figures/competition/industry_supply_total.svg", width: 46%, caption: [
  *Industry supply alone.* Only the industry supply curve and the output at each price.
]) <fig-competition-industry-supply-total>

#fig("/figures/competition/producer_surplus.svg", width: 46%, caption: [
  *Producer surplus.* Producer surplus is the area between the price and MC.
]) <fig-competition-producer-surplus>

== Long-run costs <sec-ex-long-run-costs>

LAC envelops the short-run average cost curves of plants of different size; LMC passes through its lowest point. Sources: #citet(<viner1931>).

#block(breakable: false)[
#api(("PlantFamily", "EnvelopeFigure"), syntax: [
  ```python
  PlantFamily(efficient_scale, minimum_cost, scale_curvature, steepness)
  EnvelopeFigure(
      minimum_cost,
      minimum_output,
      left_tangent,
      left_cost,
      right_tangent,
      left_minimum,
      right_minimum,
      upper_cost,
  )
  ```
])[
  `PlantFamily` holds the SAC curves of plants that touch LAC; `EnvelopeFigure` is the textbook envelope with the tangency and lowest-point outputs.
]
]

#block(breakable: false)[
#api(("envelope_figure_canvas",), syntax: [
  ```python
  envelope_figure_canvas(
      figure,
      x_max,
      ceiling,
      *,
      smc_reach=0.1,
      label_at=0.9,
      lmc_start=0.12,
      samples=120,
      **options,
  )
  ```
])[
  LAC enveloping SAC1 to SAC3 as in a textbook figure of long-run cost.
]
]

#block(breakable: false)[
#api(("lac_lmc_canvas",), syntax: [
  ```python
  lac_lmc_canvas(family, output_max, *, samples=60, **options)
  ```
])[
  U-shaped LAC with LMC cutting it at its lowest point `C_min` (output `Q_e`).
]
]

#block(breakable: false)[
#api(("plant_family_canvas",), syntax: [
  ```python
  plant_family_canvas(
      family,
      sizes,
      output_max,
      *,
      smc_for=None,
      drops=True,
      smc_reach=0.3,
      samples=60,
      **options,
  )
  ```
])[
  SAC curves of the plants in `sizes` touching LAC, with LAC and LMC.
]
]

The function of the script that draws the figures follows.

```python
def long_run_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    family: PlantFamily,
    sizes: tuple[float, ...],
    output_max: float,
    smc_for: tuple[int, ...],
    envelope: EnvelopeFigure,
    envelope_x_max: float,
    envelope_ceiling: float,
    title: str | None = None,
) -> list[Path]:
    """Write the long-run cost figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    figures = {
        "lac_lmc.svg": lac_lmc_canvas(
            family, output_max, theme=theme, title=title
        ),
        "short_run_envelope.svg": envelope_figure_canvas(
            envelope,
            envelope_x_max,
            envelope_ceiling,
            theme=theme,
            title=title,
        ),
        "plant_family.svg": plant_family_canvas(
            family,
            sizes,
            output_max,
            smc_for=smc_for,
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

#fig("/figures/long_run_costs/lac_lmc.svg", width: 46%, caption: [
  *LAC and LMC.* LMC passes through the lowest point of LAC.
]) <fig-long-run-costs-lac-lmc>

#fig("/figures/long_run_costs/short_run_envelope.svg", width: 46%, caption: [
  *Short-run envelope.* LAC envelops SAC1 to SAC3; each SAC touches LAC and SMC passes through the lowest point of its SAC.
]) <fig-long-run-costs-short-run-envelope>

#fig("/figures/long_run_costs/plant_family.svg", width: 46%, caption: [
  *Plant family.* Each plant's SAC touches LAC, and SMC meets LMC at the point of tangency.
]) <fig-long-run-costs-plant-family>

== Long-run competition <sec-ex-long-run-competition>

Entry and exit move the industry to zero profit. The long-run supply curve is horizontal, rising or, with a scarce advantage, shows a rent.

#block(breakable: false)[
#api(("IndustryEntry", "MarketPoint"), syntax: [
  ```python
  IndustryEntry(demand, cost)
  ```
])[
  `IndustryEntry` solves the long-run industry for a demand curve and a firm's cost: the zero-profit price, the number of firms and the points before and after entry.
]
]

#block(breakable: false)[
#api(("constant_cost_canvas",), syntax: [
  ```python
  constant_cost_canvas(industry, demand, analysis, **options)
  ```
])[
  Constant-cost industry: demand rises, price jumps then returns to the same lowest ATC; the long-run supply curve LRS is horizontal.
]
]

#block(breakable: false)[
#api(("entry_canvas",), syntax: [
  ```python
  entry_canvas(industry, firms, analysis, **options)
  ```
])[
  Profit draws entry: the firm (profit rectangle) beside the industry, where more firms shift supply right until the price has fallen to the lowest ATC.
]
]

#block(breakable: false)[
#api(("increasing_cost_canvas",), syntax: [
  ```python
  increasing_cost_canvas(industry, demand, cost_shift, analysis, **options)
  ```
])[
  Increasing-cost industry: entry raises input prices by `cost_shift` per unit of extra industry output, so every firm's cost curves rise and LRS slopes up.
]
]

#block(breakable: false)[
#api(("long_run_firm_canvas",), syntax: [
  ```python
  long_run_firm_canvas(family, price, output_max, *, samples=60, **options)
  ```
])[
  LAC, LMC and the price line: the firm produces where `price = LMC` with the plant whose SAC touches LAC there, and the profit is the rectangle between price and LAC.
]
]

#block(breakable: false)[
#api(("rent_canvas",), syntax: [
  ```python
  rent_canvas(
      industry,
      advantaged,
      analysis,
      advantaged_analysis,
      **options,
  )
  ```
])[
  Zero profit for the marginal firm, and a rent rectangle for a firm with lower costs (a scarce advantage), beside the long-run industry.
]
]

The function of the script that draws the figures follows.

```python
def competition_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    family: PlantFamily,
    long_run_price: float,
    family_output_max: float,
    cost: CubicCost,
    advantaged: CubicCost,
    demand: LinearDemand,
    higher_demand: LinearDemand,
    firms: float,
    cost_shift: float,
    min_output: float,
    max_output: float,
    title: str | None = None,
) -> list[Path]:
    """Write the long-run competition figures into ``output_dir``."""
    output_dir.mkdir(parents=True, exist_ok=True)
    window = (min_output, max_output)
    industry = IndustryEntry(demand, cost)
    unit = analyze_costs(cost, output_range=window)
    figures = {
        "long_run_firm.svg": long_run_firm_canvas(
            family,
            long_run_price,
            family_output_max,
            theme=theme,
            title=title,
        ),
        "entry.svg": entry_canvas(industry, firms, unit, theme=theme),
        "economic_rent.svg": rent_canvas(
            industry,
            advantaged,
            unit,
            analyze_costs(advantaged, output_range=window),
            theme=theme,
        ),
        "constant_cost.svg": constant_cost_canvas(
            industry, higher_demand, unit, theme=theme
        ),
        "increasing_cost.svg": increasing_cost_canvas(
            industry, higher_demand, cost_shift, unit, theme=theme
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/long_run_competition/long_run_firm.svg", width: 46%, caption: [
  *Firm in the long run.* Long-run output is where the price equals LMC; profit is the rectangle between the price and LAC.
]) <fig-long-run-competition-long-run-firm>

#fig("/figures/long_run_competition/entry.svg", width: 46%, caption: [
  *Entry.* Profit draws entry; industry supply shifts right until the price falls to the lowest ATC.
]) <fig-long-run-competition-entry>

#fig("/figures/long_run_competition/economic_rent.svg", width: 46%, caption: [
  *Economic rent.* A firm with lower costs earns an economic rent at the zero-profit price.
]) <fig-long-run-competition-economic-rent>

#fig("/figures/long_run_competition/constant_cost.svg", width: 46%, caption: [
  *Constant-cost industry.* The long-run supply of a constant-cost industry is horizontal.
]) <fig-long-run-competition-constant-cost>

#fig("/figures/long_run_competition/increasing_cost.svg", width: 46%, caption: [
  *Increasing-cost industry.* The long-run supply of an increasing-cost industry slopes upward.
]) <fig-long-run-competition-increasing-cost>

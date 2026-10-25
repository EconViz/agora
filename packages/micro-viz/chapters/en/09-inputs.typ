#import "/template/manual.typ": *


= Inputs and technology <sec-inputs>

Long-run technology, the choice of inputs, and factor markets.

Each section is one example script and the figures it draws. The scripts come in the archive of this manual; `--help` lists their arguments.

== Isoquants <sec-ex-isoquants>

Isoquants of Cobb-Douglas, perfect-substitute and fixed-proportion technologies, with the MRTS and returns to scale.

#block(breakable: false)[
#api(("CobbDouglas", "PerfectSubstitutes", "FixedProportions", "Technology", "Returns"), syntax: [
  ```python
  CobbDouglas(labor_share=0.5, capital_share=0.5, scale=1.0)
  PerfectSubstitutes(labor_weight=1.0, capital_weight=1.0)
  FixedProportions(labor_weight=1.0, capital_weight=1.0)
  Technology()
  ```
])[
  Each technology is a `Technology`: it gives output at an input bundle, the capital needed for an output, the MRTS and the `Returns` to scale.
]
]

#block(breakable: false)[
#api(("isoquant_map_canvas",), syntax: [
  ```python
  isoquant_map_canvas(
      tech,
      outputs,
      bounds,
      *,
      ray=False,
      level_names=None,
      samples=121,
      **options,
  )
  ```
])[
  Isoquants of the given `outputs` inside the box `bounds = (L_max, K_max)`.
]
]

#block(breakable: false)[
#api(("mrts_steps_canvas",), syntax: [
  ```python
  mrts_steps_canvas(
      tech,
      output,
      labors,
      bounds,
      *,
      delta_labels=False,
      samples=121,
      **options,
  )
  ```
])[
  One isoquant with points at the given `labors`; between neighbours the chord and the right triangle of `ΔK` and `ΔL` whose ratio is the (average) MRTS, flatter step by step.
]
]

#block(breakable: false)[
#api(("returns_to_scale_grid",), syntax: [
  ```python
  returns_to_scale_grid(technologies, outputs, bounds, direction, **options)
  ```
])[
  One panel per technology: isoquants of the listed outputs cut by a ray with direction `(L, K)`; they are evenly spaced under constant returns and closer under increasing.
]
]

The function of the script that draws the figures follows.

```python
def isoquant_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    technology: CobbDouglas,
    outputs: list[float],
    bounds: tuple[float, float],
    steps: list[float],
    triangle: list[float],
    substitutes: PerfectSubstitutes,
    proportions: FixedProportions,
    increasing: CobbDouglas,
    scale_outputs: list[float],
    direction: tuple[float, float],
    title: str | None = None,
) -> list[Path]:
    """Write the isoquant figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    middle = outputs[len(outputs) // 2]
    figures = {
        "isoquant_map.svg": isoquant_map_canvas(
            technology, outputs, bounds, theme=theme, title=title
        ),
        "mrts_steps.svg": mrts_steps_canvas(
            technology, middle, steps, bounds, theme=theme, title=title
        ),
        "mrts_triangle.svg": mrts_steps_canvas(
            technology,
            middle,
            triangle,
            bounds,
            delta_labels=True,
            theme=theme,
            title=title,
        ),
        "perfect_substitutes.svg": isoquant_map_canvas(
            substitutes, outputs, bounds, theme=theme, title=title
        ),
        "fixed_proportions.svg": isoquant_map_canvas(
            proportions, outputs, bounds, ray=True, theme=theme, title=title
        ),
        "returns_to_scale.svg": returns_to_scale_grid(
            (technology, increasing),
            (scale_outputs, scale_outputs),
            bounds,
            direction,
            theme=theme,
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/isoquants/isoquant_map.svg", width: 46%, caption: [
  *Isoquant map.* Isoquants: the farther from the origin, the larger the output.
]) <fig-isoquants-isoquant-map>

#fig("/figures/isoquants/mrts_steps.svg", width: 46%, caption: [
  *Diminishing MRTS.* The MRTS falls along an isoquant to the right.
]) <fig-isoquants-mrts-steps>

#fig("/figures/isoquants/mrts_triangle.svg", width: 46%, caption: [
  *MRTS triangle.* The ratio of the changes in K and L between two points defines the MRTS.
]) <fig-isoquants-mrts-triangle>

#fig("/figures/isoquants/perfect_substitutes.svg", width: 46%, caption: [
  *Perfect substitutes.* Isoquants of perfect substitutes are straight and the MRTS is constant.
]) <fig-isoquants-perfect-substitutes>

#fig("/figures/isoquants/fixed_proportions.svg", width: 46%, caption: [
  *Fixed proportions.* Isoquants of fixed proportions are L-shaped, with corners on one ray.
]) <fig-isoquants-fixed-proportions>

#fig("/figures/isoquants/returns_to_scale.svg", width: 46%, caption: [
  *Returns to scale.* Along a ray, isoquants are evenly spaced under constant returns and closer under increasing returns.
]) <fig-isoquants-returns-to-scale>

== Cost minimization <sec-ex-cost-minimization>

The isocost line touches the isoquant at the cheapest bundle; the figures move input prices, technology and a fixed capital stock.

#block(breakable: false)[
#api(("Bundle", "cost_minimizing_bundle", "cost_of", "isocost_segment", "expansion_path", "ray_points"), syntax: [
  ```python
  Bundle(labor, capital, cost)
  cost_minimizing_bundle(tech, output, wage, rent)
  cost_of(labor, capital, wage, rent)
  isocost_segment(cost, wage, rent, bounds)
  expansion_path(tech, outputs, wage, rent)
  ray_points(slope, bounds)
  ```
])[
  `cost_minimizing_bundle()` returns the cheapest `Bundle` for an output at the input prices; `expansion_path()` gives the cheapest bundle of each output, whose cost is long-run total cost.
]
]

#block(breakable: false)[
#api(("cost_minimization_canvas",), syntax: [
  ```python
  cost_minimization_canvas(
      tech,
      output,
      wage,
      rent,
      bounds,
      *,
      cost_offsets=(0.7, 1.35),
      **options,
  )
  ```
])[
  The isoquant of `output` with the isocost line that touches it at the cheapest bundle, and a lower and a higher isocost line (scaled by `cost_offsets`): the lower one cannot reach the output, the higher one costs more than needed.
]
]

#block(breakable: false)[
#api(("expansion_path_canvas",), syntax: [
  ```python
  expansion_path_canvas(tech, outputs, wage, rent, bounds, **options)
  ```
])[
  Above: isoquants with tangent isocost lines and the expansion path through the tangencies; below: the long-run total cost `C` plotted against output `Q`.
]
]

#block(breakable: false)[
#api(("fixed_capital_canvas",), syntax: [
  ```python
  fixed_capital_canvas(
      tech,
      outputs,
      capital,
      wage,
      rent,
      bounds,
      **options,
  )
  ```
])[
  With capital fixed at `K_0` output can only grow along the horizontal line; the long-run expansion path through the tangencies is cheaper beyond the design output.
]
]

#block(breakable: false)[
#api(("input_price_change_canvas",), syntax: [
  ```python
  input_price_change_canvas(
      tech,
      output,
      wage,
      rent,
      new_wage,
      bounds,
      *,
      along=False,
      **options,
  )
  ```
])[
  Labour becomes dearer (`new_wage`): the isocost line steepens, its new tangency uses less labour and more capital. With `along` an arrow runs along the isoquant between the two tangencies.
]
]

#block(breakable: false)[
#api(("technical_change_canvas",), syntax: [
  ```python
  technical_change_canvas(
      before,
      after,
      output,
      wage,
      rent,
      bounds,
      **options,
  )
  ```
])[
  Technical change: the isoquant of the same `output` moves inward (thin `Q'`) and the cheapest bundle falls onto a lower isocost line.
]
]

The function of the script that draws the figures follows.

```python
def cost_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    technology: CobbDouglas,
    improved: CobbDouglas,
    outputs: list[float],
    output: float,
    wage: float,
    rent: float,
    new_wage: float,
    capital: float,
    bounds: tuple[float, float],
    title: str | None = None,
) -> list[Path]:
    """Write the cost-minimization figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    figures = {
        "cost_minimization.svg": cost_minimization_canvas(
            technology, output, wage, rent, bounds, theme=theme, title=title
        ),
        "input_price_change.svg": input_price_change_canvas(
            technology,
            output,
            wage,
            rent,
            new_wage,
            bounds,
            along=True,
            theme=theme,
            title=title,
        ),
        "technical_change.svg": technical_change_canvas(
            technology,
            improved,
            output,
            wage,
            rent,
            bounds,
            theme=theme,
            title=title,
        ),
        "expansion_path.svg": expansion_path_canvas(
            technology, outputs, wage, rent, bounds, theme=theme
        ),
        "fixed_capital.svg": fixed_capital_canvas(
            technology,
            outputs,
            capital,
            wage,
            rent,
            bounds,
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

#fig("/figures/cost_minimization/cost_minimization.svg", width: 46%, caption: [
  *Cost minimization.* The cheapest bundle is where the isocost line touches the isoquant.
]) <fig-cost-minimization-cost-minimization>

#fig("/figures/cost_minimization/input_price_change.svg", width: 46%, caption: [
  *Dearer labor.* A dearer labour input steepens the isocost line; the new tangency uses less labour.
]) <fig-cost-minimization-input-price-change>

#fig("/figures/cost_minimization/technical_change.svg", width: 46%, caption: [
  *Technical change.* Technical change moves the isoquant inward and lowers cost.
]) <fig-cost-minimization-technical-change>

#fig("/figures/cost_minimization/expansion_path.svg", width: 46%, caption: [
  *Expansion path.* The expansion path joins the tangencies and gives the long-run total cost curve.
]) <fig-cost-minimization-expansion-path>

#fig("/figures/cost_minimization/fixed_capital.svg", width: 46%, caption: [
  *Fixed capital.* With capital fixed, output grows only along a horizontal line; the long-run path is cheaper.
]) <fig-cost-minimization-fixed-capital>

== Learning, scope and frontier <sec-ex-production-extensions>

Learning lowers input per unit as cumulative output grows; scope, technology shifts and the production frontier extend the production model. Sources: #citet(<wright1936>), #citet(<arrow1962>).

#block(breakable: false)[
#api(("LearningCurve", "LearningAverageCost", "ProductTransformation", "TechnologyShift", "ProductionFrontier"), syntax: [
  ```python
  LearningCurve(floor, gain, rate)
  LearningAverageCost(minimum_cost, minimum_output, curvature)
  ProductTransformation(max_1, max_2, bow)
  TechnologyShift(base, factors)
  ProductionFrontier(scale, exponent, interior=())
  ```
])[
  `LearningCurve` and `LearningAverageCost` give input and cost per unit against cumulative output; `ProductTransformation`, `TechnologyShift` and `ProductionFrontier` are the matching models.
]
]

#block(breakable: false)[
#api(("learning_curve_canvas",), syntax: [
  ```python
  learning_curve_canvas(
      learning,
      cumulative_max,
      cumulative_min=1.0,
      **options,
  )
  ```
])[
  Input per unit of output against cumulative output: it falls toward the floor `A`.
]
]

#block(breakable: false)[
#api(("product_transformation_canvas",), syntax: [
  ```python
  product_transformation_canvas(curve, *, reference=True, **options)
  ```
])[
  The product transformation curve `PT`; `reference` adds the straight line joining the two maxima (no gains from joint production) so the outward bow reads as economies of scope.
]
]

#block(breakable: false)[
#api(("production_frontier_canvas",), syntax: [
  ```python
  production_frontier_canvas(frontier, input_max, names=None, **options)
  ```
])[
  Production frontier with diminishing returns; interior points lie strictly below it (inefficient use of inputs). `names` labels the points in order.
]
]

#block(breakable: false)[
#api(("scale_vs_learning_canvas",), syntax: [
  ```python
  scale_vs_learning_canvas(cost, learning, start, stop, **options)
  ```
])[
  Two average-cost curves: moving from `A` to `B` along `AC_1` is a gain from scale; the vertical shift from `B` onto `AC_2` (`C`) is learning.
]
]

#block(breakable: false)[
#api(("technology_shift_canvas",), syntax: [
  ```python
  technology_shift_canvas(shift, input_max, arrow_input=None, **options)
  ```
])[
  Total-product curves shifted upward by better technology; the base curve is thick, the others thin and solid. `arrow_input` draws a vertical arrow from the base curve.
]
]

The function of the script that draws the figures follows.

```python
def extension_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    learning: LearningCurve,
    cumulative_max: float,
    cost: LearningAverageCost,
    learning_gain: float,
    scale_range: tuple[float, float],
    transformation: ProductTransformation,
    production: ShortRunProductionFunction,
    factors: tuple[float, ...],
    input_max: float,
    frontier: ProductionFrontier,
    point_names: tuple[str, ...],
    title: str | None = None,
) -> list[Path]:
    """Write the production-extension figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    figures = {
        "learning_curve.svg": learning_curve_canvas(
            learning, cumulative_max, theme=theme, title=title
        ),
        "scale_vs_learning.svg": scale_vs_learning_canvas(
            cost,
            learning_gain,
            scale_range[0],
            scale_range[1],
            theme=theme,
            title=title,
        ),
        "product_transformation.svg": product_transformation_canvas(
            transformation, theme=theme, title=title
        ),
        "technology_shift.svg": technology_shift_canvas(
            TechnologyShift(production, factors),
            input_max,
            input_max / 2,
            theme=theme,
            title=title,
        ),
        "production_frontier.svg": production_frontier_canvas(
            frontier, input_max, point_names, theme=theme, title=title
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/production_extensions/learning_curve.svg", width: 46%, caption: [
  *Learning curve.* Input per unit of output falls toward a floor as cumulative output grows.
]) <fig-production-extensions-learning-curve>

#fig("/figures/production_extensions/scale_vs_learning.svg", width: 46%, caption: [
  *Scale versus learning.* Moving along an AC curve is scale; dropping to another AC curve is learning.
]) <fig-production-extensions-scale-vs-learning>

#fig("/figures/production_extensions/product_transformation.svg", width: 46%, caption: [
  *Product transformation curve.* A bowed-out transformation curve means economies of scope.
]) <fig-production-extensions-product-transformation>

#fig("/figures/production_extensions/technology_shift.svg", width: 46%, caption: [
  *Technical progress.* Better technology shifts the total-product curve up.
]) <fig-production-extensions-technology-shift>

#fig("/figures/production_extensions/production_frontier.svg", width: 46%, caption: [
  *Production frontier.* Points below the frontier use inputs inefficiently.
]) <fig-production-extensions-production-frontier>

== Factor markets <sec-ex-factor-markets>

A firm hires where MRP equals the factor price; the figures compare competitive and monopoly output markets, short and long run, and economic rent.

#block(breakable: false)[
#api(("FactorMarket", "DerivedDemand", "IndustryFactorDemand", "InputAdjustment", "CapitalAdjustment", "LandMarket", "LinearSupply", "LinearValue"), syntax: [
  ```python
  FactorMarket(demand, supply)
  DerivedDemand(marginal_product, price, mr_share=1.0)
  IndustryFactorDemand(firm, firms, price_effect)
  InputAdjustment(anchor_quantity, anchor_wage, short_slope, long_slope)
  CapitalAdjustment(base, levels)
  LandMarket(demand, supply)
  LinearSupply(intercept, slope)
  LinearValue(intercept, slope)
  ```
])[
  `LinearValue` is a marginal value product and `LinearSupply` a factor supply; `FactorMarket` solves the equilibrium, `DerivedDemand` compares VMP and MRP, and `LandMarket` has vertical supply.
]
]

#block(breakable: false)[
#api(("capital_adjustment_canvas",), syntax: [
  ```python
  capital_adjustment_canvas(adjustment, wages, **options)
  ```
])[
  MRP curves for increasing capital with one hiring point per curve at the matching entry of `wages` (a falling wage prompts the firm to add capital), joined by the demand locus.
]
]

#block(breakable: false)[
#api(("derived_demand_canvas",), syntax: [
  ```python
  derived_demand_canvas(derived, **options)
  ```
])[
  `VMP` (competitive output market) above `MRP` (monopoly output market): both are the marginal product valued at the price, the monopolist's marginal revenue being lower.
]
]

#block(breakable: false)[
#api(("economic_rent_canvas",), syntax: [
  ```python
  economic_rent_canvas(market, **options)
  ```
])[
  Economic rent: the triangle between the market wage and the supply curve up to employment.
]
]

#block(breakable: false)[
#api(("factor_equilibrium_canvas",), syntax: [
  ```python
  factor_equilibrium_canvas(competitive, monopoly, **options)
  ```
])[
  Labour-market equilibrium with a competitive output market (`MRP = VMP`) beside one with a monopoly output market (lower MRP: lower wage and employment).
]
]

#block(breakable: false)[
#api(("firm_hiring_canvas",), syntax: [
  ```python
  firm_hiring_canvas(market, wage, lower_wage=None, **options)
  ```
])[
  A firm facing the flat supply `W*` hires where `MRP = W*`. With `lower_wage` the flat supply shifts down (a thin solid line) and hiring moves along the MRP curve.
]
]

#block(breakable: false)[
#api(("industry_factor_demand_canvas",), syntax: [
  ```python
  industry_factor_demand_canvas(industry, anchor_wage, **options)
  ```
])[
  A firm's demand beside the industry's: the dashed-free pair shows the horizontal sum of firm demands (thin) and the steeper industry demand through the same anchor.
]
]

#block(breakable: false)[
#api(("land_rent_canvas",), syntax: [
  ```python
  land_rent_canvas(land, **options)
  ```
])[
  Vertical land supply at `supply` with demand setting the rent `R*`; the whole rectangle under the rent is economic rent.
]
]

#block(breakable: false)[
#api(("market_supply_canvas",), syntax: [
  ```python
  market_supply_canvas(market, **options)
  ```
])[
  Upward market supply of an input beside the flat supply one firm faces at the market wage.
]
]

#block(breakable: false)[
#api(("short_long_run_canvas",), syntax: [
  ```python
  short_long_run_canvas(adjustment, wage_max, **options)
  ```
])[
  Short- and long-run input demand through one point, the long run flatter.
]
]

The function of the script that draws the figures follows.

```python
def factor_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    product: LinearValue,
    price: float,
    mr_share: float,
    supply: LinearSupply,
    wage: float,
    lower_wage: float,
    firms: int,
    price_effect: float,
    capital: tuple[float, ...],
    wages: tuple[float, ...],
    land: tuple[float, float, float],
    title: str | None = None,
) -> list[Path]:
    """Write the factor-market figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    competitive = DerivedDemand(product, price)
    monopoly = DerivedDemand(product, price, mr_share)
    market = FactorMarket(competitive.demand, supply)
    anchor = market.equilibrium()
    firm = FactorMarket(competitive.demand, supply)
    industry = IndustryFactorDemand(competitive.demand, firms, price_effect)
    adjustment = InputAdjustment(
        anchor[0],
        anchor[1],
        competitive.demand.slope * 2,
        competitive.demand.slope / 2,
    )
    figures = {
        "derived_demand.svg": derived_demand_canvas(
            monopoly, theme=theme, title=title
        ),
        "firm_hiring.svg": firm_hiring_canvas(
            firm, wage, theme=theme, title=title
        ),
        "wage_decline.svg": firm_hiring_canvas(
            firm, wage, lower_wage, theme=theme, title=title
        ),
        "capital_adjustment.svg": capital_adjustment_canvas(
            CapitalAdjustment(competitive.demand, capital),
            wages,
            theme=theme,
            title=title,
        ),
        "industry_demand.svg": industry_factor_demand_canvas(
            industry, anchor[1], theme=theme
        ),
        "short_long_run.svg": short_long_run_canvas(
            adjustment,
            competitive.demand.intercept,
            theme=theme,
            title=title,
        ),
        "market_supply.svg": market_supply_canvas(market, theme=theme),
        "factor_equilibrium.svg": factor_equilibrium_canvas(
            market, FactorMarket(monopoly.demand, supply), theme=theme
        ),
        "economic_rent.svg": economic_rent_canvas(
            market, theme=theme, title=title
        ),
        "land_rent.svg": land_rent_canvas(
            LandMarket(LinearValue(land[0], land[1]), land[2]),
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

#fig("/figures/factor_markets/derived_demand.svg", width: 46%, caption: [
  *VMP and MRP.* VMP under a competitive output market lies above MRP under a monopoly output market.
]) <fig-factor-markets-derived-demand>

#fig("/figures/factor_markets/firm_hiring.svg", width: 46%, caption: [
  *Firm hiring.* The firm faces a flat supply and hires where MRP = W.
]) <fig-factor-markets-firm-hiring>

#fig("/figures/factor_markets/wage_decline.svg", width: 46%, caption: [
  *A lower market wage.* A lower wage shifts the flat supply down; hiring rises along MRP.
]) <fig-factor-markets-wage-decline>

#fig("/figures/factor_markets/capital_adjustment.svg", width: 46%, caption: [
  *MRP as capital adjusts.* More capital shifts MRP right; the hiring points trace the long-run demand.
]) <fig-factor-markets-capital-adjustment>

#fig("/figures/factor_markets/industry_demand.svg", width: 46%, caption: [
  *Firm and industry demand.* Industry demand is steeper than the horizontal sum of firm demands.
]) <fig-factor-markets-industry-demand>

#fig("/figures/factor_markets/short_long_run.svg", width: 46%, caption: [
  *Short- and long-run input demand.* Long-run input demand is flatter than short-run demand.
]) <fig-factor-markets-short-long-run>

#fig("/figures/factor_markets/market_supply.svg", width: 46%, caption: [
  *Market and firm supply.* Upward market supply beside the flat supply one firm faces.
]) <fig-factor-markets-market-supply>

#fig("/figures/factor_markets/factor_equilibrium.svg", width: 46%, caption: [
  *Factor-market equilibrium.* A monopoly output market lowers MRP, and with it the wage and employment.
]) <fig-factor-markets-factor-equilibrium>

#fig("/figures/factor_markets/economic_rent.svg", width: 46%, caption: [
  *Economic rent of labor.* The area between the wage and the supply curve is the economic rent of labour.
]) <fig-factor-markets-economic-rent>

#fig("/figures/factor_markets/land_rent.svg", width: 46%, caption: [
  *Land rent.* Land supply is vertical and demand sets the rent.
]) <fig-factor-markets-land-rent>

== Monopsony and unions <sec-ex-monopsony>

A single buyer hires where ME = MV and pays the supply price; a union picks a point on labour demand.

#block(breakable: false)[
#api(("Monopsonist", "UnionWageSetting", "TwoSectorLabor"), syntax: [
  ```python
  Monopsonist(supply, value)
  UnionWageSetting(demand, supply)
  TwoSectorLabor(demand_1, demand_2, total)
  ```
])[
  `Monopsonist` solves the buyer's choice and the deadweight loss; `UnionWageSetting` and `TwoSectorLabor` solve the union cases.
]
]

#block(breakable: false)[
#api(("competitive_pair_canvas",), syntax: [
  ```python
  competitive_pair_canvas(value, supply, price, **options)
  ```
])[
  A competitive buyer (flat `ME = AE` at `price` against `MV`) beside a competitive seller (flat `MR = AR` at `price` against `MC`).
]
]

#block(breakable: false)[
#api(("monopoly_monopsony_pair_canvas",), syntax: [
  ```python
  monopoly_monopsony_pair_canvas(model, **options)
  ```
])[
  Monopoly (`AR`, `MR`, `MC`) beside monopsony (`MV`, `ME`, `AE`) built from the same pair of linear curves: the monopolist's demand is the value curve and its cost the supply curve.
]
]

#block(breakable: false)[
#api(("monopsony_canvas",), syntax: [
  ```python
  monopsony_canvas(model, *, labor=False, **options)
  ```
])[
  Monopsony: the buyer hires where `ME = MV` (`MRP` for labour) and pays the supply price at that quantity, below the competitive quantity and price. `labor` switches the text to `L`, `W` and `MRP`.
]
]

#block(breakable: false)[
#api(("monopsony_dwl_canvas",), syntax: [
  ```python
  monopsony_dwl_canvas(model, **options)
  ```
])[
  Monopsony against the competitive outcome: the rectangle `A` is the transfer from sellers to the buyer and the triangles `B` and `C` (above and below the competitive price) together are the deadweight loss.
]
]

#block(breakable: false)[
#api(("supply_elasticity_canvas",), syntax: [
  ```python
  supply_elasticity_canvas(value, supplies, **options)
  ```
])[
  One monopsony panel per supply curve, on common axes: the flatter (more elastic) the supply, the closer `ME` lies to `AE`.
]
]

#block(breakable: false)[
#api(("two_sector_labor_canvas",), syntax: [
  ```python
  two_sector_labor_canvas(model, union_wage, **options)
  ```
])[
  Two sectors: a union wage above the competitive wage `W_c` cuts employment in sector 1, the displaced workers crowd into sector 2 and lower its wage.
]
]

#block(breakable: false)[
#api(("union_wage_canvas",), syntax: [
  ```python
  union_wage_canvas(setting, wage=None, **options)
  ```
])[
  A union picks a point on the firm's labour demand: employment `L`, the wage-bill rectangle and the rent above members' supply price.
]
]

The function of the script that draws the figures follows.

```python
def monopsony_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    value: LinearValue,
    supply: LinearSupply,
    elastic: LinearSupply,
    inelastic: LinearSupply,
    price: float,
    sector_2: LinearValue,
    total: float,
    union_wage: float,
    title: str | None = None,
) -> list[Path]:
    """Write the monopsony figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    model = Monopsonist(supply, value)
    figures = {
        "competitive_pair.svg": competitive_pair_canvas(
            value, supply, price, theme=theme
        ),
        "monopsony.svg": monopsony_canvas(model, theme=theme, title=title),
        "monopoly_monopsony.svg": monopoly_monopsony_pair_canvas(
            model, theme=theme
        ),
        "supply_elasticity.svg": supply_elasticity_canvas(
            value, (elastic, inelastic), theme=theme
        ),
        "monopsony_dwl.svg": monopsony_dwl_canvas(
            model, theme=theme, title=title
        ),
        "labor_monopsony.svg": monopsony_canvas(
            model, labor=True, theme=theme, title=title
        ),
        "union.svg": union_wage_canvas(
            UnionWageSetting(value, supply), theme=theme, title=title
        ),
        "two_sector.svg": two_sector_labor_canvas(
            TwoSectorLabor(value, sector_2, total), union_wage, theme=theme
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/monopsony/competitive_pair.svg", width: 46%, caption: [
  *Competitive buyer and seller.* A competitive buyer faces a flat ME = AE; a competitive seller faces a flat MR = AR.
]) <fig-monopsony-competitive-pair>

#fig("/figures/monopsony/monopsony.svg", width: 46%, caption: [
  *Monopsony.* The monopsonist buys where ME = MV and pays the price on AE.
]) <fig-monopsony-monopsony>

#fig("/figures/monopsony/monopoly_monopsony.svg", width: 46%, caption: [
  *Monopoly and monopsony.* Monopoly (AR, MR, MC) beside monopsony (MV, ME, AE).
]) <fig-monopsony-monopoly-monopsony>

#fig("/figures/monopsony/supply_elasticity.svg", width: 46%, caption: [
  *Supply elasticity.* The more elastic supply is, the closer ME lies to AE.
]) <fig-monopsony-supply-elasticity>

#fig("/figures/monopsony/monopsony_dwl.svg", width: 46%, caption: [
  *Monopsony deadweight loss.* The transfer rectangle A and the deadweight-loss triangles B and C.
]) <fig-monopsony-monopsony-dwl>

#fig("/figures/monopsony/labor_monopsony.svg", width: 46%, caption: [
  *Labor monopsony.* In the labour market both employment and the wage fall below the competitive level.
]) <fig-monopsony-labor-monopsony>

#fig("/figures/monopsony/union.svg", width: 46%, caption: [
  *Union wage setting.* A union picks a point on labour demand: employment, rent and opportunity cost.
]) <fig-monopsony-union>

#fig("/figures/monopsony/two_sector.svg", width: 46%, caption: [
  *Two-sector labor market.* A union wage cuts employment in sector 1; displaced workers lower the wage in sector 2.
]) <fig-monopsony-two-sector>

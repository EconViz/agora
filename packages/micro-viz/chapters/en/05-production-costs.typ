#import "/template/manual.typ": *


= Production and costs <sec-production-costs>

Short-run production and the cost curves that follow from it.

Each section is one example script and the figures it draws. The scripts come in the archive of this manual; `--help` lists their arguments.

== Short-run production <sec-ex-production>

One variable input and one fixed input give total, average and marginal product. The marginal-return regions are classified from the model and shaded in the figure.

#block(breakable: false)[
#api(("ShortRunProductionFunction", "analyze_production"), syntax: [
  ```python
  ShortRunProductionFunction(
      linear,
      quadratic,
      cubic,
      input_symbol="L",
      output_symbol="Q",
  )
  analyze_production(production_function, *, input_range, samples=201)
  ```
])[
  `ShortRunProductionFunction` is the cubic production function $Q = a L + b L^2 + c L^3$; `analyze_production()` samples TP, AP and MP and classifies the range into regions of increasing, diminishing and negative marginal returns.
]
]

#block(breakable: false)[
#api(("average_marginal_product_canvas",), syntax: [
  ```python
  average_marginal_product_canvas(
      result,
      *,
      regions=True,
      region_colors=None,
      guides=True,
      **options,
  )
  ```
])[
  An AP/MP diagram with the marginal-return regions and the AP = MP and MP = 0 points.
]
]

#block(breakable: false)[
#api(("total_product_canvas",), syntax: [
  ```python
  total_product_canvas(
      result,
      *,
      regions=True,
      region_colors=None,
      guides=True,
      **options,
  )
  ```
])[
  A TP diagram: the curve, its three marginal-return regions and the boundary guides.
]
]

The function of the script that draws the figures follows.

```python
def production_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    function: ShortRunProductionFunction,
    input_range: tuple[float, float],
    samples: int,
    region_colors: dict[str, str] | None = None,
    title: str | None = None,
) -> tuple[Path, Path]:
    """Write the two production examples into ``output_dir`` and return their paths."""
    analysis = analyze_production(
        function, input_range=input_range, samples=samples
    )
    output_dir.mkdir(parents=True, exist_ok=True)
    total_output = output_dir / "total_product.svg"
    products_output = output_dir / "average_marginal_product.svg"
    total_product_canvas(
        analysis, theme=theme, title=title, region_colors=region_colors
    ).save(total_output)
    average_marginal_product_canvas(
        analysis, theme=theme, title=title, region_colors=region_colors
    ).save(products_output)
    # The same figures with the shade stopping at the curve instead of reaching the top.
    under = replace(theme, region_extent="curve")
    total_product_canvas(
        analysis, theme=under, title=title, region_colors=region_colors
    ).save(output_dir / "total_product_under_curve.svg")
    average_marginal_product_canvas(
        analysis, theme=under, title=title, region_colors=region_colors
    ).save(output_dir / "average_marginal_product_under_curve.svg")
    return total_output, products_output
```

#fig("/figures/production/total_product.svg", width: 46%, caption: [
  *Total product.* Short-run total product, with the regions of increasing and diminishing marginal returns marked.
]) <fig-production-total-product>

#fig("/figures/production/average_marginal_product.svg", width: 46%, caption: [
  *Average and marginal product.* Average and marginal product; MP crosses AP at the top of AP.
]) <fig-production-average-marginal-product>

#fig("/figures/production/total_product_under_curve.svg", width: 46%, caption: [
  *Total product, shade under the curve.* The same regions, shaded only down to the curve.
]) <fig-production-total-product-under-curve>

#fig("/figures/production/average_marginal_product_under_curve.svg", width: 46%, caption: [
  *Average and marginal product, shade under the curve.* The same regions, shaded only down to the AP and MP curves.
]) <fig-production-average-marginal-product-under-curve>

== Short-run costs <sec-ex-costs>

A cubic cost function gives total, variable and fixed cost and the four unit costs. MC passes through the lowest points of AVC and ATC.

#block(breakable: false)[
#api(("CubicCost", "analyze_costs"), syntax: [
  ```python
  CubicCost(
      fixed_cost=0.0,
      linear=1.0,
      quadratic=0.0,
      cubic=1.0,
      output_symbol="Q",
  )
  analyze_costs(cost, *, output_range, samples=201)
  ```
])[
  `CubicCost` is $"TC" = "FC" + b Q + c Q^2 + d Q^3$; `analyze_costs()` evaluates every cost measure over an output range and finds the minima of AVC and ATC.
]
]

#block(breakable: false)[
#api(("cost_curves_grid",), syntax: [
  ```python
  cost_curves_grid(analysis, **options)
  ```
])[
  The total-cost panel above the per-unit panel, sharing the output axis.
]
]

#block(breakable: false)[
#api(("cost_curves_panels",), syntax: [
  ```python
  cost_curves_panels(analysis, **options)
  ```
])[
  The two panels of `cost_curves_grid` as separate canvases: total cost, then unit costs, on the same output axis. Each stands alone as a figure.
]
]

#block(breakable: false)[
#api(("total_cost_canvas",), syntax: [
  ```python
  total_cost_canvas(analysis, *, ray=True, marks=True, **options)
  ```
])[
  TC, VC and FC against output.
]
]

#block(breakable: false)[
#api(("unit_cost_canvas",), syntax: [
  ```python
  unit_cost_canvas(
      analysis,
      *,
      curves=('mc', 'atc', 'avc', 'afc'),
      minima=True,
      output=None,
      **options,
  )
  ```
])[
  MC, ATC, AVC and AFC against output (choose a subset with `curves`).
]
]

The function of the script that draws the figures follows.

```python
def cost_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    cost: CubicCost,
    min_output: float,
    max_output: float,
    samples: int,
    avc_reach: float = 1.15,
    title: str | None = None,
) -> list[Path]:
    """Write the cost-curve examples for ``cost`` into ``output_dir`` and return the paths."""
    analysis = analyze_costs(
        cost, output_range=(min_output, max_output), samples=samples
    )
    no_fixed = analyze_costs(
        CubicCost(
            fixed_cost=0.0,
            linear=cost.linear,
            quadratic=cost.quadratic,
            cubic=cost.cubic,
            output_symbol=cost.output_symbol,
        ),
        output_range=(min_output, max_output * avc_reach),
        samples=samples,
    )
    total_panel, unit_panel = cost_curves_panels(
        analysis, theme=theme, titles=(title, None)
    )
    output_dir.mkdir(parents=True, exist_ok=True)
    figures = {
        "total_cost.svg": total_cost_canvas(
            analysis, theme=theme, title=title
        ),
        "unit_cost.svg": unit_cost_canvas(
            analysis, theme=theme, title=title
        ),
        "cubic_avc_mc.svg": unit_cost_canvas(
            no_fixed, curves=("mc", "avc"), theme=theme, title=title
        ),
        "cost_curves_total.svg": total_panel,
        "cost_curves_unit.svg": unit_panel,
        "cost_curves.svg": cost_curves_grid(
            analysis, theme=theme, titles=(title, None)
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/costs/total_cost.svg", width: 46%, caption: [
  *Total, variable and fixed cost.* Total, variable and fixed cost.
]) <fig-costs-total-cost>

#fig("/figures/costs/unit_cost.svg", width: 46%, caption: [
  *Unit costs.* MC, ATC, AVC and AFC; MC passes through the lowest points of AVC and ATC.
]) <fig-costs-unit-cost>

#fig("/figures/costs/cubic_avc_mc.svg", width: 46%, caption: [
  *AVC and MC of a cubic cost.* AVC and MC of a cubic cost function.
]) <fig-costs-cubic-avc-mc>

#fig("/figures/costs/cost_curves.svg", width: 46%, caption: [
  *Cost curves.* Total cost above unit costs on a shared output axis.
]) <fig-costs-cost-curves>

#fig("/figures/costs/cost_curves_total.svg", width: 46%, caption: [
  *Total cost panel.* The total-cost panel of the two-panel figure, usable on its own.
]) <fig-costs-cost-curves-total>

#fig("/figures/costs/cost_curves_unit.svg", width: 46%, caption: [
  *Unit cost panel.* The unit-cost panel of the two-panel figure, usable on its own.
]) <fig-costs-cost-curves-unit>

== Stepped and kinked cost <sec-ex-piecewise-costs>

Several plants of fixed capacity give a stepped marginal cost; one plant with a capacity limit gives a kinked one.

#block(breakable: false)[
#api(("PiecewiseCost", "CostSegment"), syntax: [
  ```python
  PiecewiseCost(segments, fixed_cost=0.0, output_symbol="Q")
  ```
])[
  `PiecewiseCost` joins `CostSegment` pieces, each with its own capacity and marginal cost; it is a `CostFunction`, so `analyze_costs()` accepts it.
]
]

#block(breakable: false)[
#api(("piecewise_cost_canvas",), syntax: [
  ```python
  piecewise_cost_canvas(analysis, *, prices=(), average=True, **options)
  ```
])[
  Stepped or kinked marginal cost with its capacity and price bands.
]
]

The function of the script that draws the figures follows.

```python
def piecewise_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    stepped: PiecewiseCost,
    kinked: PiecewiseCost,
    prices: tuple[float, ...],
    kinked_prices: tuple[float, ...],
    kinked_y_min: float,
    samples: int,
    title: str | None = None,
) -> list[Path]:
    """Write the stepped and kinked marginal-cost examples into ``output_dir``."""
    output_dir.mkdir(parents=True, exist_ok=True)
    step_analysis = analyze_costs(
        stepped, output_range=(0.0, stepped.capacity), samples=samples
    )
    kink_analysis = analyze_costs(
        kinked, output_range=(0.0, kinked.capacity), samples=samples
    )
    kink_top = max(value for _, value in kink_analysis.marginal_cost_path)
    figures = {
        "stepped_cost.svg": piecewise_cost_canvas(
            step_analysis, theme=theme, title=title
        ),
        "stepped_cost_prices.svg": piecewise_cost_canvas(
            step_analysis, prices=prices, theme=theme, title=title
        ),
        "kinked_marginal_cost.svg": piecewise_cost_canvas(
            kink_analysis,
            prices=kinked_prices,
            average=False,
            y_range=(
                kinked_y_min,
                kink_top + (kink_top - kinked_y_min) * 0.1,
            ),
            theme=theme,
            title=title,
        ),
    }
    for name, figure in figures.items():
        figure.save(output_dir / name)
    return [output_dir / name for name in figures]
```

#fig("/figures/piecewise_costs/stepped_cost.svg", width: 46%, caption: [
  *Stepped marginal cost.* Stepped marginal cost of several plants.
]) <fig-piecewise-costs-stepped-cost>

#fig("/figures/piecewise_costs/stepped_cost_prices.svg", width: 46%, caption: [
  *Stepped cost and output.* Output jumps as the price crosses a step.
]) <fig-piecewise-costs-stepped-cost-prices>

#fig("/figures/piecewise_costs/kinked_marginal_cost.svg", width: 46%, caption: [
  *Kinked marginal cost.* Kinked marginal cost with a capacity limit.
]) <fig-piecewise-costs-kinked-marginal-cost>

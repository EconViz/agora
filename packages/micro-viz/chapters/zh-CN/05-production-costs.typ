#import "/template/manual.typ": *


= 生产与成本 <sec-production-costs>

短期生产，以及由此得到的成本曲线。

每一节是一支范例脚本与它画出的图。脚本随手册的压缩档提供，参数可用 `--help` 查看。

== 短期生产 <sec-ex-production>

一种变动投入与一种固定投入，得到总产量、平均产量与边际产量。边际报酬的区间由模型分类，图中以底色标出。

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
  `ShortRunProductionFunction` 是三次生产函数 $Q = a L + b L^2 + c L^3$；`analyze_production()` 采样 TP、AP 与 MP，并把范围分成边际报酬递增、递减与为负的区间。
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
  平均与边际产量图：含边际报酬区间，并标出 AP = MP 与 MP = 0 的点。
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
  总产量图：曲线、三个边际报酬区间与分界线。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

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

#fig("/figures/production/total_product.zh-CN.svg", width: 46%, caption: [
  *总产量曲线。* 短期总产量曲线，并标出边际报酬递增与递减的区间。
]) <fig-production-total-product>

#fig("/figures/production/average_marginal_product.zh-CN.svg", width: 46%, caption: [
  *平均与边际产量。* 平均产量与边际产量曲线，MP 通过 AP 的最高点。
]) <fig-production-average-marginal-product>

#fig("/figures/production/total_product_under_curve.zh-CN.svg", width: 46%, caption: [
  *总产量，底色在曲线下。* 区域底色只填到曲线为止。
]) <fig-production-total-product-under-curve>

#fig("/figures/production/average_marginal_product_under_curve.zh-CN.svg", width: 46%, caption: [
  *平均与边际产量，底色在曲线下。* 区域底色只填到 AP、MP 的上缘为止。
]) <fig-production-average-marginal-product-under-curve>

== 短期成本 <sec-ex-costs>

三次成本函数得到总成本、变动成本、固定成本与四条单位成本曲线。MC 通过 AVC 与 ATC 的最低点。

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
  `CubicCost` 是 $"TC" = "FC" + b Q + c Q^2 + d Q^3$；`analyze_costs()` 在产量范围内计算各种成本，并找出 AVC 与 ATC 的最低点。
]
]

#block(breakable: false)[
#api(("cost_curves_grid",), syntax: [
  ```python
  cost_curves_grid(analysis, **options)
  ```
])[
  上方是总成本、下方是单位成本，共用产量轴。
]
]

#block(breakable: false)[
#api(("cost_curves_panels",), syntax: [
  ```python
  cost_curves_panels(analysis, **options)
  ```
])[
  把 `cost_curves_grid` 的两栏分成两张画布，各自可独立成图。
]
]

#block(breakable: false)[
#api(("total_cost_canvas",), syntax: [
  ```python
  total_cost_canvas(analysis, *, ray=True, marks=True, **options)
  ```
])[
  TC、VC 与 FC 对产量。
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
  MC、ATC、AVC 与 AFC 对产量；`curves` 可选子集。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

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

#fig("/figures/costs/total_cost.zh-CN.svg", width: 46%, caption: [
  *总成本曲线。* 总成本、变动成本与固定成本曲线。
]) <fig-costs-total-cost>

#fig("/figures/costs/unit_cost.zh-CN.svg", width: 46%, caption: [
  *单位成本曲线。* MC、ATC、AVC 与 AFC 曲线，MC 通过 AVC 与 ATC 的最低点。
]) <fig-costs-unit-cost>

#fig("/figures/costs/cubic_avc_mc.zh-CN.svg", width: 46%, caption: [
  *三次函数的 AVC 与 MC。* 三次成本函数的 AVC 与 MC。
]) <fig-costs-cubic-avc-mc>

#fig("/figures/costs/cost_curves.zh-CN.svg", width: 46%, caption: [
  *成本曲在线下对照。* 总成本与单位成本的两栏对照图。
]) <fig-costs-cost-curves>

#fig("/figures/costs/cost_curves_total.zh-CN.svg", width: 46%, caption: [
  *总成本图。* 两栏对照图中的总成本图，可单独使用。
]) <fig-costs-cost-curves-total>

#fig("/figures/costs/cost_curves_unit.zh-CN.svg", width: 46%, caption: [
  *单位成本图。* 两栏对照图中的单位成本图，可单独使用。
]) <fig-costs-cost-curves-unit>

== 阶梯与折点成本 <sec-ex-piecewise-costs>

数个容量固定的厂房得到阶梯式边际成本；一个有产能限制的厂房得到折线边际成本。

#block(breakable: false)[
#api(("PiecewiseCost", "CostSegment"), syntax: [
  ```python
  PiecewiseCost(segments, fixed_cost=0.0, output_symbol="Q")
  ```
])[
  `PiecewiseCost` 把各有容量与边际成本的 `CostSegment` 接起来；它是 `CostFunction`，因此 `analyze_costs()` 可以使用。
]
]

#block(breakable: false)[
#api(("piecewise_cost_canvas",), syntax: [
  ```python
  piecewise_cost_canvas(analysis, *, prices=(), average=True, **options)
  ```
])[
  阶梯或折线边际成本，含容量与价格带。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

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

#fig("/figures/piecewise_costs/stepped_cost.zh-CN.svg", width: 46%, caption: [
  *阶梯式边际成本。* 多个厂房的阶梯式边际成本。
]) <fig-piecewise-costs-stepped-cost>

#fig("/figures/piecewise_costs/stepped_cost_prices.zh-CN.svg", width: 46%, caption: [
  *阶梯成本与产量。* 价格穿过阶梯时产量随之跳动。
]) <fig-piecewise-costs-stepped-cost-prices>

#fig("/figures/piecewise_costs/kinked_marginal_cost.zh-CN.svg", width: 46%, caption: [
  *折线边际成本。* 有产能限制的折线边际成本。
]) <fig-piecewise-costs-kinked-marginal-cost>

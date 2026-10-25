#import "/template/manual.typ": *


= 竞争与长期 <sec-competition>

价格接受者厂商、产业供给、长期成本与进入。

每一节是一支范例脚本与它画出的图。脚本随手册的压缩档提供，参数可用 `--help` 查看。

== 完全竞争 <sec-ex-competition>

价格接受者厂商在价格等于 MC 处生产。利润、亏损与停业取决于价格相对 ATC 与 AVC 的位置。

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
  `solve_competitive_firm()` 回传 `CompetitiveOutcome`，其 `Regime` 说明厂商有利润、亏损或停业；`FirmSupply` 与 `IndustrySupply` 给出单一厂商的供给与多家厂商的水平加总；`analyze_revenue_cost()` 采样收益、成本与利润。
]
]

#block(breakable: false)[
#api(("competitive_firm_canvas",), syntax: [
  ```python
  competitive_firm_canvas(analysis, outcome, *, lost_profit=None, **options)
  ```
])[
  价格接受者厂商：ATC、AVC 与 MC，以及价格线 `P = MR`。
]
]

#block(breakable: false)[
#api(("cost_shift_canvas",), syntax: [
  ```python
  cost_shift_canvas(before, after, price, *, tax=None, **options)
  ```
])[
  成本上升前后的 MC，含价格线与两个产量。
]
]

#block(breakable: false)[
#api(("firm_supply_canvas",), syntax: [
  ```python
  firm_supply_canvas(analysis, *, prices=(), **options)
  ```
])[
  厂商供给曲线：MC 在最低 AVC 以上的部分，以实线画出。
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
  产业供给为各厂商供给的水平加总。
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
  各厂商的供给曲线并列，再加上加总后的产业供给。
]
]

#block(breakable: false)[
#api(("market_and_firm_canvas",), syntax: [
  ```python
  market_and_firm_canvas(demand, price, *, firm_output_max, **options)
  ```
])[
  厂商与市场并列：厂商面对市场价格的水平需求 `d`，市场为向下的需求 `D`，以虚线链接价格。
]
]

#block(breakable: false)[
#api(("producer_surplus_canvas",), syntax: [
  ```python
  producer_surplus_canvas(analysis, outcome, **options)
  ```
])[
  生产者剩余：价格与 MC 之间、从 0 到 `q*` 的面积。
]
]

#block(breakable: false)[
#api(("revenue_cost_profit_canvas",), syntax: [
  ```python
  revenue_cost_profit_canvas(analysis, **options)
  ```
])[
  总收益、总成本与利润曲线对产量。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

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

#fig("/figures/competition/revenue_cost_profit.zh-CN.svg", width: 46%, caption: [
  *收益、成本与利润。* 总收益与总成本之差最大处即为利润极大产量。
]) <fig-competition-revenue-cost-profit>

#fig("/figures/competition/market_and_firm.zh-CN.svg", width: 46%, caption: [
  *市场与厂商。* 市场需求决定价格，个别厂商面对水平需求线。
]) <fig-competition-market-and-firm>

#fig("/figures/competition/firm_profit.zh-CN.svg", width: 46%, caption: [
  *厂商有利润。* 价格高于 ATC 时，利润为价格与 ATC 之间的长方形。
]) <fig-competition-firm-profit>

#fig("/figures/competition/firm_lost_profit.zh-CN.svg", width: 46%, caption: [
  *偏离最适产量的损失。* 少于或多于 MR = MC 的产量都会损失利润。
]) <fig-competition-firm-lost-profit>

#fig("/figures/competition/firm_loss.zh-CN.svg", width: 46%, caption: [
  *厂商亏损。* 价格介于 AVC 与 ATC 之间时，厂商继续生产但亏损。
]) <fig-competition-firm-loss>

#fig("/figures/competition/firm_shutdown.zh-CN.svg", width: 46%, caption: [
  *停止生产。* 价格低于最低 AVC 时，厂商停止生产。
]) <fig-competition-firm-shutdown>

#fig("/figures/competition/firm_supply.zh-CN.svg", width: 46%, caption: [
  *厂商供给曲线。* 供给曲线是 MC 在最低 AVC 以上的部分。
]) <fig-competition-firm-supply>

#fig("/figures/competition/cost_shift.zh-CN.svg", width: 46%, caption: [
  *成本上升。* 成本上升使 MC 与 AVC 上移，产量减少。
]) <fig-competition-cost-shift>

#fig("/figures/competition/unit_tax.zh-CN.svg", width: 46%, caption: [
  *从量税。* 从量税使 MC 上移一个税额，厂商减产。
]) <fig-competition-unit-tax>

#fig("/figures/competition/industry_supply.zh-CN.svg", width: 46%, caption: [
  *产业供给。* 产业供给为各厂商供给的水平加总。
]) <fig-competition-industry-supply>

#fig("/figures/competition/industry_supply_total.zh-CN.svg", width: 46%, caption: [
  *只画产业供给。* 只画产业供给曲线与各价格下的产量。
]) <fig-competition-industry-supply-total>

#fig("/figures/competition/producer_surplus.zh-CN.svg", width: 46%, caption: [
  *生产者剩余。* 生产者剩余为价格与 MC 之间的面积。
]) <fig-competition-producer-surplus>

== 长期成本 <sec-ex-long-run-costs>

LAC 是各种规模厂房的短期平均成本曲线的包络线；LMC 通过它的最低点。 出处：#citet(<viner1931>)。

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
  `PlantFamily` 保存与 LAC 相切的各厂房 SAC 曲线；`EnvelopeFigure` 是教科书的包络线图，含相切产量与最低点产量。
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
  教科书式的长期成本包络线：LAC 包络 SAC1 至 SAC3。
]
]

#block(breakable: false)[
#api(("lac_lmc_canvas",), syntax: [
  ```python
  lac_lmc_canvas(family, output_max, *, samples=60, **options)
  ```
])[
  U 形 LAC，LMC 在其最低点 `C_min`（产量 `Q_e`）与之相交。
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
  `sizes` 中各厂房的 SAC 与 LAC 相切，并画出 LAC 与 LMC。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

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

#fig("/figures/long_run_costs/lac_lmc.zh-CN.svg", width: 46%, caption: [
  *LAC 与 LMC。* LMC 通过 LAC 的最低点。
]) <fig-long-run-costs-lac-lmc>

#fig("/figures/long_run_costs/short_run_envelope.zh-CN.svg", width: 46%, caption: [
  *短期成本包络线。* LAC 是 SAC1 至 SAC3 的包络线；各 SAC 与 LAC 相切，SMC 通过其 SAC 的最低点。
]) <fig-long-run-costs-short-run-envelope>

#fig("/figures/long_run_costs/plant_family.zh-CN.svg", width: 46%, caption: [
  *厂房族。* 各厂房的 SAC 与 LAC 相切，SMC 与 LMC 在切点相交。
]) <fig-long-run-costs-plant-family>

== 长期竞争 <sec-ex-long-run-competition>

进入与退出使产业趋向零利润。长期供给曲线是水平的、向上的，或在有稀少优势时出现租。

#block(breakable: false)[
#api(("IndustryEntry", "MarketPoint"), syntax: [
  ```python
  IndustryEntry(demand, cost)
  ```
])[
  `IndustryEntry` 对一条需求曲线与厂商的成本求长期产业均衡：零利润价格、厂商数，以及进入前后的点。
]
]

#block(breakable: false)[
#api(("constant_cost_canvas",), syntax: [
  ```python
  constant_cost_canvas(industry, demand, analysis, **options)
  ```
])[
  固定成本产业：需求上升使价格先跳升再回到同一最低 ATC，长期供给 LRS 为水平线。
]
]

#block(breakable: false)[
#api(("entry_canvas",), syntax: [
  ```python
  entry_canvas(industry, firms, analysis, **options)
  ```
])[
  利润吸引进入：厂商（利润长方形）与产业并列，更多厂商使供给右移，直到价格降到最低 ATC。
]
]

#block(breakable: false)[
#api(("increasing_cost_canvas",), syntax: [
  ```python
  increasing_cost_canvas(industry, demand, cost_shift, analysis, **options)
  ```
])[
  递增成本产业：进入使投入价格上升，厂商成本曲在线移，LRS 向右上倾斜。
]
]

#block(breakable: false)[
#api(("long_run_firm_canvas",), syntax: [
  ```python
  long_run_firm_canvas(family, price, output_max, *, samples=60, **options)
  ```
])[
  LAC、LMC 与价格线：厂商在价格等于 LMC 处生产，所用厂房的 SAC 在该点与 LAC 相切，利润为价格与 LAC 之间的长方形。
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
  边际厂商利润为零，成本较低的厂商（稀少优势）有租的长方形，与长期产业并列。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

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

#fig("/figures/long_run_competition/long_run_firm.zh-CN.svg", width: 46%, caption: [
  *长期的厂商。* 长期产量在价格等于 LMC 处，利润为价格与 LAC 之间的长方形。
]) <fig-long-run-competition-long-run-firm>

#fig("/figures/long_run_competition/entry.zh-CN.svg", width: 46%, caption: [
  *进入。* 利润吸引进入，产业供给右移直到价格降到最低 ATC。
]) <fig-long-run-competition-entry>

#fig("/figures/long_run_competition/economic_rent.zh-CN.svg", width: 46%, caption: [
  *经济租。* 成本较低的厂商在零利润价格下仍有经济租。
]) <fig-long-run-competition-economic-rent>

#fig("/figures/long_run_competition/constant_cost.zh-CN.svg", width: 46%, caption: [
  *固定成本产业。* 固定成本产业的长期供给为水平线。
]) <fig-long-run-competition-constant-cost>

#fig("/figures/long_run_competition/increasing_cost.zh-CN.svg", width: 46%, caption: [
  *递增成本产业。* 递增成本产业的长期供给向右上倾斜。
]) <fig-long-run-competition-increasing-cost>

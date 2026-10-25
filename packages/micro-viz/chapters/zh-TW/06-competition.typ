#import "/template/manual.typ": *


= 競爭與長期 <sec-competition>

價格接受者廠商、產業供給、長期成本與進入。

每一節是一支範例腳本與它畫出的圖。腳本隨手冊的壓縮檔提供，參數可用 `--help` 查看。

== 完全競爭 <sec-ex-competition>

價格接受者廠商在價格等於 MC 處生產。利潤、虧損與停業取決於價格相對 ATC 與 AVC 的位置。

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
  `solve_competitive_firm()` 回傳 `CompetitiveOutcome`，其 `Regime` 說明廠商有利潤、虧損或停業；`FirmSupply` 與 `IndustrySupply` 給出單一廠商的供給與多家廠商的水平加總；`analyze_revenue_cost()` 取樣收益、成本與利潤。
]
]

#block(breakable: false)[
#api(("competitive_firm_canvas",), syntax: [
  ```python
  competitive_firm_canvas(analysis, outcome, *, lost_profit=None, **options)
  ```
])[
  價格接受者廠商：ATC、AVC 與 MC，以及價格線 `P = MR`。
]
]

#block(breakable: false)[
#api(("cost_shift_canvas",), syntax: [
  ```python
  cost_shift_canvas(before, after, price, *, tax=None, **options)
  ```
])[
  成本上升前後的 MC，含價格線與兩個產量。
]
]

#block(breakable: false)[
#api(("firm_supply_canvas",), syntax: [
  ```python
  firm_supply_canvas(analysis, *, prices=(), **options)
  ```
])[
  廠商供給曲線：MC 在最低 AVC 以上的部分，以實線畫出。
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
  產業供給為各廠商供給的水平加總。
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
  各廠商的供給曲線並列，再加上加總後的產業供給。
]
]

#block(breakable: false)[
#api(("market_and_firm_canvas",), syntax: [
  ```python
  market_and_firm_canvas(demand, price, *, firm_output_max, **options)
  ```
])[
  廠商與市場並列：廠商面對市場價格的水平需求 `d`，市場為向下的需求 `D`，以虛線連結價格。
]
]

#block(breakable: false)[
#api(("producer_surplus_canvas",), syntax: [
  ```python
  producer_surplus_canvas(analysis, outcome, **options)
  ```
])[
  生產者剩餘：價格與 MC 之間、從 0 到 `q*` 的面積。
]
]

#block(breakable: false)[
#api(("revenue_cost_profit_canvas",), syntax: [
  ```python
  revenue_cost_profit_canvas(analysis, **options)
  ```
])[
  總收益、總成本與利潤曲線對產量。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/competition/revenue_cost_profit.zh-TW.svg", width: 46%, caption: [
  *收益、成本與利潤。* 總收益與總成本之差最大處即為利潤極大產量。
]) <fig-competition-revenue-cost-profit>

#fig("/figures/competition/market_and_firm.zh-TW.svg", width: 46%, caption: [
  *市場與廠商。* 市場需求決定價格，個別廠商面對水平需求線。
]) <fig-competition-market-and-firm>

#fig("/figures/competition/firm_profit.zh-TW.svg", width: 46%, caption: [
  *廠商有利潤。* 價格高於 ATC 時，利潤為價格與 ATC 之間的長方形。
]) <fig-competition-firm-profit>

#fig("/figures/competition/firm_lost_profit.zh-TW.svg", width: 46%, caption: [
  *偏離最適產量的損失。* 少於或多於 MR = MC 的產量都會損失利潤。
]) <fig-competition-firm-lost-profit>

#fig("/figures/competition/firm_loss.zh-TW.svg", width: 46%, caption: [
  *廠商虧損。* 價格介於 AVC 與 ATC 之間時，廠商繼續生產但虧損。
]) <fig-competition-firm-loss>

#fig("/figures/competition/firm_shutdown.zh-TW.svg", width: 46%, caption: [
  *停止生產。* 價格低於最低 AVC 時，廠商停止生產。
]) <fig-competition-firm-shutdown>

#fig("/figures/competition/firm_supply.zh-TW.svg", width: 46%, caption: [
  *廠商供給曲線。* 供給曲線是 MC 在最低 AVC 以上的部分。
]) <fig-competition-firm-supply>

#fig("/figures/competition/cost_shift.zh-TW.svg", width: 46%, caption: [
  *成本上升。* 成本上升使 MC 與 AVC 上移，產量減少。
]) <fig-competition-cost-shift>

#fig("/figures/competition/unit_tax.zh-TW.svg", width: 46%, caption: [
  *從量稅。* 從量稅使 MC 上移一個稅額，廠商減產。
]) <fig-competition-unit-tax>

#fig("/figures/competition/industry_supply.zh-TW.svg", width: 46%, caption: [
  *產業供給。* 產業供給為各廠商供給的水平加總。
]) <fig-competition-industry-supply>

#fig("/figures/competition/industry_supply_total.zh-TW.svg", width: 46%, caption: [
  *只畫產業供給。* 只畫產業供給曲線與各價格下的產量。
]) <fig-competition-industry-supply-total>

#fig("/figures/competition/producer_surplus.zh-TW.svg", width: 46%, caption: [
  *生產者剩餘。* 生產者剩餘為價格與 MC 之間的面積。
]) <fig-competition-producer-surplus>

== 長期成本 <sec-ex-long-run-costs>

LAC 是各種規模廠房的短期平均成本曲線的包絡線；LMC 通過它的最低點。 出處：#citet(<viner1931>)。

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
  `PlantFamily` 保存與 LAC 相切的各廠房 SAC 曲線；`EnvelopeFigure` 是教科書的包絡線圖，含相切產量與最低點產量。
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
  教科書式的長期成本包絡線：LAC 包絡 SAC1 至 SAC3。
]
]

#block(breakable: false)[
#api(("lac_lmc_canvas",), syntax: [
  ```python
  lac_lmc_canvas(family, output_max, *, samples=60, **options)
  ```
])[
  U 形 LAC，LMC 在其最低點 `C_min`（產量 `Q_e`）與之相交。
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
  `sizes` 中各廠房的 SAC 與 LAC 相切，並畫出 LAC 與 LMC。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/long_run_costs/lac_lmc.zh-TW.svg", width: 46%, caption: [
  *LAC 與 LMC。* LMC 通過 LAC 的最低點。
]) <fig-long-run-costs-lac-lmc>

#fig("/figures/long_run_costs/short_run_envelope.zh-TW.svg", width: 46%, caption: [
  *短期成本包絡線。* LAC 是 SAC1 至 SAC3 的包絡線；各 SAC 與 LAC 相切，SMC 通過其 SAC 的最低點。
]) <fig-long-run-costs-short-run-envelope>

#fig("/figures/long_run_costs/plant_family.zh-TW.svg", width: 46%, caption: [
  *廠房族。* 各廠房的 SAC 與 LAC 相切，SMC 與 LMC 在切點相交。
]) <fig-long-run-costs-plant-family>

== 長期競爭 <sec-ex-long-run-competition>

進入與退出使產業趨向零利潤。長期供給曲線是水平的、向上的，或在有稀少優勢時出現租。

#block(breakable: false)[
#api(("IndustryEntry", "MarketPoint"), syntax: [
  ```python
  IndustryEntry(demand, cost)
  ```
])[
  `IndustryEntry` 對一條需求曲線與廠商的成本求長期產業均衡：零利潤價格、廠商數，以及進入前後的點。
]
]

#block(breakable: false)[
#api(("constant_cost_canvas",), syntax: [
  ```python
  constant_cost_canvas(industry, demand, analysis, **options)
  ```
])[
  固定成本產業：需求上升使價格先跳升再回到同一最低 ATC，長期供給 LRS 為水平線。
]
]

#block(breakable: false)[
#api(("entry_canvas",), syntax: [
  ```python
  entry_canvas(industry, firms, analysis, **options)
  ```
])[
  利潤吸引進入：廠商（利潤長方形）與產業並列，更多廠商使供給右移，直到價格降到最低 ATC。
]
]

#block(breakable: false)[
#api(("increasing_cost_canvas",), syntax: [
  ```python
  increasing_cost_canvas(industry, demand, cost_shift, analysis, **options)
  ```
])[
  遞增成本產業：進入使投入價格上升，廠商成本曲線上移，LRS 向右上傾斜。
]
]

#block(breakable: false)[
#api(("long_run_firm_canvas",), syntax: [
  ```python
  long_run_firm_canvas(family, price, output_max, *, samples=60, **options)
  ```
])[
  LAC、LMC 與價格線：廠商在價格等於 LMC 處生產，所用廠房的 SAC 在該點與 LAC 相切，利潤為價格與 LAC 之間的長方形。
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
  邊際廠商利潤為零，成本較低的廠商（稀少優勢）有租的長方形，與長期產業並列。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/long_run_competition/long_run_firm.zh-TW.svg", width: 46%, caption: [
  *長期的廠商。* 長期產量在價格等於 LMC 處，利潤為價格與 LAC 之間的長方形。
]) <fig-long-run-competition-long-run-firm>

#fig("/figures/long_run_competition/entry.zh-TW.svg", width: 46%, caption: [
  *進入。* 利潤吸引進入，產業供給右移直到價格降到最低 ATC。
]) <fig-long-run-competition-entry>

#fig("/figures/long_run_competition/economic_rent.zh-TW.svg", width: 46%, caption: [
  *經濟租。* 成本較低的廠商在零利潤價格下仍有經濟租。
]) <fig-long-run-competition-economic-rent>

#fig("/figures/long_run_competition/constant_cost.zh-TW.svg", width: 46%, caption: [
  *固定成本產業。* 固定成本產業的長期供給為水平線。
]) <fig-long-run-competition-constant-cost>

#fig("/figures/long_run_competition/increasing_cost.zh-TW.svg", width: 46%, caption: [
  *遞增成本產業。* 遞增成本產業的長期供給向右上傾斜。
]) <fig-long-run-competition-increasing-cost>

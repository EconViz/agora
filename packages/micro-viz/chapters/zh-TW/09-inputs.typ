#import "/template/manual.typ": *


= 投入與技術 <sec-inputs>

長期技術、投入選擇與要素市場。

每一節是一支範例腳本與它畫出的圖。腳本隨手冊的壓縮檔提供，參數可用 `--help` 查看。

== 等產量線 <sec-ex-isoquants>

柯布－道格拉斯、完全替代與固定比例技術的等產量線，以及 MRTS 與規模報酬。

#block(breakable: false)[
#api(("CobbDouglas", "PerfectSubstitutes", "FixedProportions", "Technology", "Returns"), syntax: [
  ```python
  CobbDouglas(labor_share=0.5, capital_share=0.5, scale=1.0)
  PerfectSubstitutes(labor_weight=1.0, capital_weight=1.0)
  FixedProportions(labor_weight=1.0, capital_weight=1.0)
  Technology()
  ```
])[
  每種技術都是 `Technology`：給出投入組合下的產量、某產量所需的資本、MRTS 與規模報酬 `Returns`。
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
  `bounds = (L_max, K_max)` 方框內給定 `outputs` 的等產量線。
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
  一條等產量線上在 `labors` 處的點，相鄰兩點間畫弦與 `ΔK`、`ΔL` 的直角三角形，其比值是（平均）MRTS。
]
]

#block(breakable: false)[
#api(("returns_to_scale_grid",), syntax: [
  ```python
  returns_to_scale_grid(technologies, outputs, bounds, direction, **options)
  ```
])[
  每種技術一欄：給定產量的等產量線被一條射線截斷；固定報酬下等距，規模報酬遞增下愈來愈近。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/isoquants/isoquant_map.zh-TW.svg", width: 46%, caption: [
  *等產量線圖。* 等產量線圖：愈遠離原點產量愈高。
]) <fig-isoquants-isoquant-map>

#fig("/figures/isoquants/mrts_steps.zh-TW.svg", width: 46%, caption: [
  *MRTS 遞減。* 沿等產量線向右，邊際技術替代率遞減。
]) <fig-isoquants-mrts-steps>

#fig("/figures/isoquants/mrts_triangle.zh-TW.svg", width: 46%, caption: [
  *MRTS 三角形。* 兩點間的 ΔK 與 ΔL 之比定義邊際技術替代率。
]) <fig-isoquants-mrts-triangle>

#fig("/figures/isoquants/perfect_substitutes.zh-TW.svg", width: 46%, caption: [
  *完全替代。* 完全替代的等產量線為直線，MRTS 為常數。
]) <fig-isoquants-perfect-substitutes>

#fig("/figures/isoquants/fixed_proportions.zh-TW.svg", width: 46%, caption: [
  *固定比例。* 固定比例的等產量線呈 L 形，轉折點在同一條射線上。
]) <fig-isoquants-fixed-proportions>

#fig("/figures/isoquants/returns_to_scale.zh-TW.svg", width: 46%, caption: [
  *規模報酬。* 沿射線，固定報酬下等產量線等距，規模報酬遞增則愈來愈近。
]) <fig-isoquants-returns-to-scale>

== 成本最小化 <sec-ex-cost-minimization>

等成本線在成本最低的組合與等產量線相切；圖中改變投入價格、技術與固定資本。

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
  `cost_minimizing_bundle()` 在投入價格下回傳某產量的最低成本 `Bundle`；`expansion_path()` 給出各產量的最低成本組合，其成本即長期總成本。
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
  `output` 的等產量線與在最低成本組合相切的等成本線，另有一條較低與一條較高的等成本線。
]
]

#block(breakable: false)[
#api(("expansion_path_canvas",), syntax: [
  ```python
  expansion_path_canvas(tech, outputs, wage, rent, bounds, **options)
  ```
])[
  上圖是等產量線、相切的等成本線與經過切點的擴張線；下圖是長期總成本 `C` 對產量。
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
  資本固定在 `K_0` 時產量只能沿水平線增加；超過某點後，經過切點的長期擴張線較便宜。
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
  勞動變貴（`new_wage`）：等成本線變陡，新切點用較少勞動、較多資本；`along` 另畫沿等產量線的箭頭。
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
  技術進步：同一 `output` 的等產量線內移（細線 `Q'`），最低成本組合落在較低的等成本線上。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/cost_minimization/cost_minimization.zh-TW.svg", width: 46%, caption: [
  *成本最小化。* 等成本線與等產量線相切處為成本最低的組合。
]) <fig-cost-minimization-cost-minimization>

#fig("/figures/cost_minimization/input_price_change.zh-TW.svg", width: 46%, caption: [
  *工資上升。* 工資上升使等成本線變陡，新切點使用較少勞動。
]) <fig-cost-minimization-input-price-change>

#fig("/figures/cost_minimization/technical_change.zh-TW.svg", width: 46%, caption: [
  *技術進步。* 技術進步使等產量線內移，成本降低。
]) <fig-cost-minimization-technical-change>

#fig("/figures/cost_minimization/expansion_path.zh-TW.svg", width: 46%, caption: [
  *擴張線。* 擴張線連接各切點，並推得長期總成本曲線。
]) <fig-cost-minimization-expansion-path>

#fig("/figures/cost_minimization/fixed_capital.zh-TW.svg", width: 46%, caption: [
  *資本固定。* 資本固定時產量只能沿水平線擴張，長期擴張線較便宜。
]) <fig-cost-minimization-fixed-capital>

== 學習、範疇與生產前緣 <sec-ex-production-extensions>

學習使單位投入隨累積產量下降；範疇、技術進步與生產前緣擴充生產模型。 出處：#citet(<wright1936>)、#citet(<arrow1962>)。

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
  `LearningCurve` 與 `LearningAverageCost` 給出單位投入與成本對累積產量的關係；`ProductTransformation`、`TechnologyShift` 與 `ProductionFrontier` 是對應的模型。
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
  單位產出的投入量對累積產量：向下趨近下限 `A`。
]
]

#block(breakable: false)[
#api(("product_transformation_canvas",), syntax: [
  ```python
  product_transformation_canvas(curve, *, reference=True, **options)
  ```
])[
  產品轉換曲線 `PT`；`reference` 加上連接兩個最大值的直線（沒有聯合生產的利益），顯示外凸。
]
]

#block(breakable: false)[
#api(("production_frontier_canvas",), syntax: [
  ```python
  production_frontier_canvas(frontier, input_max, names=None, **options)
  ```
])[
  邊際報酬遞減的生產前緣；內部的點嚴格在前緣之下（投入使用無效率）；`names` 依序標點。
]
]

#block(breakable: false)[
#api(("scale_vs_learning_canvas",), syntax: [
  ```python
  scale_vs_learning_canvas(cost, learning, start, stop, **options)
  ```
])[
  兩條平均成本曲線：沿 `AC_1` 從 `A` 到 `B` 是規模利益；從 `B` 垂直下移到 `AC_2`（`C`）是學習。
]
]

#block(breakable: false)[
#api(("technology_shift_canvas",), syntax: [
  ```python
  technology_shift_canvas(shift, input_max, arrow_input=None, **options)
  ```
])[
  技術進步使總產量曲線上移；基準曲線為粗線，其餘為細實線；`arrow_input` 畫垂直箭頭。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/production_extensions/learning_curve.zh-TW.svg", width: 46%, caption: [
  *學習曲線。* 單位產出投入量隨累積產量下降並趨近下限。
]) <fig-production-extensions-learning-curve>

#fig("/figures/production_extensions/scale_vs_learning.zh-TW.svg", width: 46%, caption: [
  *規模與學習。* 沿 AC 移動是規模效果，下移到另一條 AC 是學習效果。
]) <fig-production-extensions-scale-vs-learning>

#fig("/figures/production_extensions/product_transformation.zh-TW.svg", width: 46%, caption: [
  *產品轉換曲線。* 向外凸的轉換曲線表示範疇經濟。
]) <fig-production-extensions-product-transformation>

#fig("/figures/production_extensions/technology_shift.zh-TW.svg", width: 46%, caption: [
  *技術進步。* 技術進步使總產量曲線向上移動。
]) <fig-production-extensions-technology-shift>

#fig("/figures/production_extensions/production_frontier.zh-TW.svg", width: 46%, caption: [
  *生產前緣。* 前緣之下的點表示投入使用無效率。
]) <fig-production-extensions-production-frontier>

== 要素市場 <sec-ex-factor-markets>

廠商在 MRP 等於要素價格處僱用；圖中比較競爭與獨占的產品市場、短期與長期，以及經濟租。

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
  `LinearValue` 是邊際價值產量，`LinearSupply` 是要素供給；`FactorMarket` 求均衡，`DerivedDemand` 比較 VMP 與 MRP，`LandMarket` 的供給為垂直。
]
]

#block(breakable: false)[
#api(("capital_adjustment_canvas",), syntax: [
  ```python
  capital_adjustment_canvas(adjustment, wages, **options)
  ```
])[
  資本增加時的 MRP 曲線，每條曲線上一個僱用點，對應 `wages` 中的工資（工資下降使廠商增加資本）。
]
]

#block(breakable: false)[
#api(("derived_demand_canvas",), syntax: [
  ```python
  derived_demand_canvas(derived, **options)
  ```
])[
  `VMP`（競爭產品市場）在 `MRP`（獨占產品市場）之上：兩者都是以價格計算的邊際產量，獨占者的邊際收益較低。
]
]

#block(breakable: false)[
#api(("economic_rent_canvas",), syntax: [
  ```python
  economic_rent_canvas(market, **options)
  ```
])[
  經濟租：市場工資與供給曲線之間、到僱用量為止的三角形。
]
]

#block(breakable: false)[
#api(("factor_equilibrium_canvas",), syntax: [
  ```python
  factor_equilibrium_canvas(competitive, monopoly, **options)
  ```
])[
  產品市場競爭（`MRP = VMP`）與獨占（較低的 MRP：工資與僱用量較低）的要素市場均衡並列。
]
]

#block(breakable: false)[
#api(("firm_hiring_canvas",), syntax: [
  ```python
  firm_hiring_canvas(market, wage, lower_wage=None, **options)
  ```
])[
  面對水平供給 `W*` 的廠商在 `MRP = W*` 處僱用；`lower_wage` 使水平供給下移（細實線），僱用沿 MRP 增加。
]
]

#block(breakable: false)[
#api(("industry_factor_demand_canvas",), syntax: [
  ```python
  industry_factor_demand_canvas(industry, anchor_wage, **options)
  ```
])[
  廠商需求與產業需求並列：細線是廠商需求的水平加總，產業需求更陡。
]
]

#block(breakable: false)[
#api(("land_rent_canvas",), syntax: [
  ```python
  land_rent_canvas(land, **options)
  ```
])[
  垂直的土地供給 `supply`，需求決定地租 `R*`；地租以下的整個長方形都是經濟租。
]
]

#block(breakable: false)[
#api(("market_supply_canvas",), syntax: [
  ```python
  market_supply_canvas(market, **options)
  ```
])[
  向上的投入市場供給，與單一廠商在市場工資下面對的水平供給並列。
]
]

#block(breakable: false)[
#api(("short_long_run_canvas",), syntax: [
  ```python
  short_long_run_canvas(adjustment, wage_max, **options)
  ```
])[
  經過同一點的短期與長期投入需求，長期更平坦。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/factor_markets/derived_demand.zh-TW.svg", width: 46%, caption: [
  *VMP 與 MRP。* 完全競爭產品市場的 VMP 高於獨佔產品市場的 MRP。
]) <fig-factor-markets-derived-demand>

#fig("/figures/factor_markets/firm_hiring.zh-TW.svg", width: 46%, caption: [
  *廠商僱用。* 廠商面對水平的供給，在 MRP = W 處僱用。
]) <fig-factor-markets-firm-hiring>

#fig("/figures/factor_markets/wage_decline.zh-TW.svg", width: 46%, caption: [
  *市場工資下降。* 工資下降使水平供給下移，僱用量沿 MRP 增加。
]) <fig-factor-markets-wage-decline>

#fig("/figures/factor_markets/capital_adjustment.zh-TW.svg", width: 46%, caption: [
  *資本調整。* 資本增加使 MRP 右移，各僱用點連成長期需求軌跡。
]) <fig-factor-markets-capital-adjustment>

#fig("/figures/factor_markets/industry_demand.zh-TW.svg", width: 46%, caption: [
  *廠商與產業需求。* 產業需求比廠商需求的水平加總更陡。
]) <fig-factor-markets-industry-demand>

#fig("/figures/factor_markets/short_long_run.zh-TW.svg", width: 46%, caption: [
  *短期與長期投入需求。* 長期投入需求比短期更平坦。
]) <fig-factor-markets-short-long-run>

#fig("/figures/factor_markets/market_supply.zh-TW.svg", width: 46%, caption: [
  *市場與廠商供給。* 向上的市場供給與單一廠商面對的水平供給。
]) <fig-factor-markets-market-supply>

#fig("/figures/factor_markets/factor_equilibrium.zh-TW.svg", width: 46%, caption: [
  *要素市場均衡。* 產品市場獨佔使 MRP 較低，工資與僱用量也較低。
]) <fig-factor-markets-factor-equilibrium>

#fig("/figures/factor_markets/economic_rent.zh-TW.svg", width: 46%, caption: [
  *勞動的經濟租。* 工資與供給曲線之間的面積是勞動的經濟租。
]) <fig-factor-markets-economic-rent>

#fig("/figures/factor_markets/land_rent.zh-TW.svg", width: 46%, caption: [
  *地租。* 土地供給垂直，需求決定地租。
]) <fig-factor-markets-land-rent>

== 買方獨佔與工會 <sec-ex-monopsony>

單一買者在 ME = MV 處購買，並支付供給價格；工會在勞動需求上選點。

#block(breakable: false)[
#api(("Monopsonist", "UnionWageSetting", "TwoSectorLabor"), syntax: [
  ```python
  Monopsonist(supply, value)
  UnionWageSetting(demand, supply)
  TwoSectorLabor(demand_1, demand_2, total)
  ```
])[
  `Monopsonist` 求買者的選擇與無謂損失；`UnionWageSetting` 與 `TwoSectorLabor` 求解工會的情形。
]
]

#block(breakable: false)[
#api(("competitive_pair_canvas",), syntax: [
  ```python
  competitive_pair_canvas(value, supply, price, **options)
  ```
])[
  競爭買方（水平的 `ME = AE` 對 `MV`）與競爭賣方（水平的 `MR = AR` 對 `MC`）並列。
]
]

#block(breakable: false)[
#api(("monopoly_monopsony_pair_canvas",), syntax: [
  ```python
  monopoly_monopsony_pair_canvas(model, **options)
  ```
])[
  獨占（`AR`、`MR`、`MC`）與買方獨佔（`MV`、`ME`、`AE`）並列，由同一組線性曲線建成。
]
]

#block(breakable: false)[
#api(("monopsony_canvas",), syntax: [
  ```python
  monopsony_canvas(model, *, labor=False, **options)
  ```
])[
  買方獨佔：買者在 `ME = MV`（勞動為 `MRP`）處僱用，支付該數量下的供給價格，低於競爭的數量與價格。
]
]

#block(breakable: false)[
#api(("monopsony_dwl_canvas",), syntax: [
  ```python
  monopsony_dwl_canvas(model, **options)
  ```
])[
  買方獨佔與競爭結果的比較：長方形 `A` 是由賣者移轉給買者，三角形 `B`、`C` 是無謂損失。
]
]

#block(breakable: false)[
#api(("supply_elasticity_canvas",), syntax: [
  ```python
  supply_elasticity_canvas(value, supplies, **options)
  ```
])[
  每條供給曲線一欄，共用座標軸：供給愈平坦（愈有彈性），`ME` 愈接近 `AE`。
]
]

#block(breakable: false)[
#api(("two_sector_labor_canvas",), syntax: [
  ```python
  two_sector_labor_canvas(model, union_wage, **options)
  ```
])[
  兩部門：高於競爭工資 `W_c` 的工會工資使部門 1 就業下降，失業工人湧入部門 2 並壓低其工資。
]
]

#block(breakable: false)[
#api(("union_wage_canvas",), syntax: [
  ```python
  union_wage_canvas(setting, wage=None, **options)
  ```
])[
  工會在廠商勞動需求上選點：僱用量 `L`、工資總額長方形，以及高於會員供給價格的租。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/monopsony/competitive_pair.zh-TW.svg", width: 46%, caption: [
  *競爭的買方與賣方。* 競爭買方面對水平的 ME = AE，競爭賣方面對水平的 MR = AR。
]) <fig-monopsony-competitive-pair>

#fig("/figures/monopsony/monopsony.zh-TW.svg", width: 46%, caption: [
  *買方獨佔。* 買方獨佔在 ME = MV 處購買，支付 AE 上的價格。
]) <fig-monopsony-monopsony>

#fig("/figures/monopsony/monopoly_monopsony.zh-TW.svg", width: 46%, caption: [
  *獨占與買方獨佔。* 獨佔的 AR、MR、MC 與買方獨佔的 MV、ME、AE 並列。
]) <fig-monopsony-monopoly-monopsony>

#fig("/figures/monopsony/supply_elasticity.zh-TW.svg", width: 46%, caption: [
  *供給彈性。* 供給愈有彈性，ME 愈接近 AE。
]) <fig-monopsony-supply-elasticity>

#fig("/figures/monopsony/monopsony_dwl.zh-TW.svg", width: 46%, caption: [
  *買方獨佔的無謂損失。* 移轉長方形 A 與無謂損失三角形 B、C。
]) <fig-monopsony-monopsony-dwl>

#fig("/figures/monopsony/labor_monopsony.zh-TW.svg", width: 46%, caption: [
  *勞動買方獨佔。* 勞動市場的買方獨佔：僱用量與工資都低於競爭水準。
]) <fig-monopsony-labor-monopsony>

#fig("/figures/monopsony/union.zh-TW.svg", width: 46%, caption: [
  *工會訂工資。* 工會在勞動需求上選點：就業、租與機會成本。
]) <fig-monopsony-union>

#fig("/figures/monopsony/two_sector.zh-TW.svg", width: 46%, caption: [
  *兩部門勞動市場。* 工會工資使部門 1 就業下降，工人流入部門 2 而壓低其工資。
]) <fig-monopsony-two-sector>

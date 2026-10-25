#import "/template/manual.typ": *


= 獨占與定價 <sec-monopoly>

市場力量：單一價格的獨占、對它的管制，以及不只一個價格的定價。

每一節是一支範例腳本與它畫出的圖。腳本隨手冊的壓縮檔提供，參數可用 `--help` 查看。

== 獨占 <sec-ex-monopoly>

獨占者在 MR = MC 處生產，價格由需求曲線決定。總量、稅、需求移動、多個廠房與勒納指數都是這張圖的變化。 出處：#citet(<lerner1934>)。

#block(breakable: false)[
#api(("Monopolist", "MonopolyOutcome", "MultiplantMonopoly", "MultiplantOutcome", "elasticity"), syntax: [
  ```python
  Monopolist(demand, cost)
  MultiplantMonopoly(demand, plants)
  elasticity(demand, quantity)
  ```
])[
  `Monopolist.solve()` 回傳含產量、價格與利潤的 `MonopolyOutcome`；`MultiplantMonopoly` 把產量分給各廠房；`elasticity()` 是線性需求的價格彈性。
]
]

#block(breakable: false)[
#api(("lerner_markup_canvas",), syntax: [
  ```python
  lerner_markup_canvas(outcomes, analyses, **options)
  ```
])[
  每個需求一欄：以大括號標出 `p - MC` 的加成，需求有彈性時小、缺乏彈性時大。
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
  獨占者：需求 `D`（= AR）、`MR` 與 `curves` 中的成本曲線。
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
  需求移動（細實線 `D'` 與 `MR'`）：平行移動，或以 `rotate` 繞數量軸端點轉動。
]
]

#block(breakable: false)[
#api(("monopoly_dwl_canvas",), syntax: [
  ```python
  monopoly_dwl_canvas(outcome, analysis, **options)
  ```
])[
  獨占與競爭結果 `p = MC` 的比較：移轉長方形與需求和 MC 之間的無謂損失三角形。
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
  從量稅使 MC 上移（細實線 `MC'`）；箭頭從 `Q_m` 處的舊 MC 指向新 MC，價格由 `p_m` 變為 `p'`。
]
]

#block(breakable: false)[
#api(("monopoly_totals_canvas",), syntax: [
  ```python
  monopoly_totals_canvas(outcome, *, output_range, samples=121, **options)
  ```
])[
  總收益、總成本與利潤對產量，利潤最大處 `Q_m` 的 R 與 TC 斜率相等。
]
]

#block(breakable: false)[
#api(("monopoly_totals_grid",), syntax: [
  ```python
  monopoly_totals_grid(outcome, analysis, **options)
  ```
])[
  上方是總量，下方是單位曲線與利潤長方形，共用最適點 `Q_m`。
]
]

#block(breakable: false)[
#api(("multiplant_canvas",), syntax: [
  ```python
  multiplant_canvas(firm, outcome, **options)
  ```
])[
  各廠房的 MC 與水平加總的 `MC_T`，對 `D` 與 `MR`。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/monopoly/monopoly.zh-TW.svg", width: 46%, caption: [
  *獨占均衡。* 獨占者在 MR = MC 處生產，價格由需求曲線決定。
]) <fig-monopoly-monopoly>

#fig("/figures/monopoly/monopoly_lost_profit.zh-TW.svg", width: 46%, caption: [
  *偏離最適產量的損失。* 偏離 MR = MC 的產量都使利潤下降。
]) <fig-monopoly-monopoly-lost-profit>

#fig("/figures/monopoly/monopoly_profit.zh-TW.svg", width: 46%, caption: [
  *獨占利潤。* 利潤為價格與 ATC 之間的長方形。
]) <fig-monopoly-monopoly-profit>

#fig("/figures/monopoly/monopoly_totals.zh-TW.svg", width: 46%, caption: [
  *總收益、總成本與利潤。* TR、TC 與利潤曲線，利潤最大處的斜率相等。
]) <fig-monopoly-monopoly-totals>

#fig("/figures/monopoly/monopoly_totals_grid.zh-TW.svg", width: 46%, caption: [
  *總量與單位曲線。* 上圖為總量，下圖為單位曲線與利潤長方形。
]) <fig-monopoly-monopoly-totals-grid>

#fig("/figures/monopoly/monopoly_dwl.zh-TW.svg", width: 46%, caption: [
  *獨占的無謂損失。* 與完全競爭相比的移轉長方形與無謂損失三角形。
]) <fig-monopoly-monopoly-dwl>

#fig("/figures/monopoly/monopoly_tax.zh-TW.svg", width: 46%, caption: [
  *對獨占者課從量稅。* 從量稅使 MC 上移，價格與產量隨之調整。
]) <fig-monopoly-monopoly-tax>

#fig("/figures/monopoly/monopoly_demand_shift.zh-TW.svg", width: 46%, caption: [
  *需求移動。* 需求平行外移，獨占者沒有供給曲線，產量與價格隨 MR' = MC 改變。
]) <fig-monopoly-monopoly-demand-shift>

#fig("/figures/monopoly/monopoly_demand_rotate.zh-TW.svg", width: 46%, caption: [
  *需求轉動。* 需求曲線轉動時，價格與產量的變動方向取決於轉動的方式。
]) <fig-monopoly-monopoly-demand-rotate>

#fig("/figures/monopoly/multiplant.zh-TW.svg", width: 46%, caption: [
  *多廠房獨占。* 各廠房 MC 水平加總後與 MR 相交，並決定各廠產量。
]) <fig-monopoly-multiplant>

#fig("/figures/monopoly/lerner_markup.zh-TW.svg", width: 46%, caption: [
  *勒納加成。* 需求愈缺乏彈性，加成 (p − MC) 愈大。
]) <fig-monopoly-lerner-markup>

== 獨占性競爭 <sec-ex-monopolistic-competition>

每家廠商面對向下的需求。進入使需求左移，直到與 ATC 相切，價格高於 MC，產能閒置。 出處：#citet(<chamberlin1933>)。

#block(breakable: false)[
#api(("solve_monopolistic_competition", "MonopolisticOutcome", "long_run_demand"), syntax: [
  ```python
  solve_monopolistic_competition(demand, cost)
  long_run_demand(demand, cost)
  ```
])[
  `solve_monopolistic_competition()` 回傳短期最適點與進入後的長期相切點；`long_run_demand()` 建立斜率相同且與 ATC 相切的需求曲線。
]
]

#block(breakable: false)[
#api(("excess_capacity_grid",), syntax: [
  ```python
  excess_capacity_grid(outcome, analysis, **options)
  ```
])[
  獨占性競爭（價格高於 MC、有超額產能）與完全競爭（`p = MC` 在最低 ATC）並列。
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
  長期：需求在 `MR = MC` 的產量與 ATC 相切，價格高於 MC。
]
]

#block(breakable: false)[
#api(("monopolistic_short_run_canvas",), syntax: [
  ```python
  monopolistic_short_run_canvas(outcome, analysis, **options)
  ```
])[
  短期：獨占最適點與進入前的利潤長方形。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/monopolistic_competition/short_run.zh-TW.svg", width: 46%, caption: [
  *短期均衡。* 短期有利潤，利潤矩形為價格與 ATC 之差乘以產量。
]) <fig-monopolistic-competition-short-run>

#fig("/figures/monopolistic_competition/long_run.zh-TW.svg", width: 46%, caption: [
  *長期相切。* 長期均衡：需求與 ATC 相切於 MR = MC 的產量，價格高於 MC。
]) <fig-monopolistic-competition-long-run>

#fig("/figures/monopolistic_competition/excess_capacity.zh-TW.svg", width: 46%, caption: [
  *超額產能。* 獨占性競爭的產量低於最低 ATC 的產量，差距為超額產能。
]) <fig-monopolistic-competition-excess-capacity>

== 管制 <sec-ex-regulation>

價格上限使獨占者的平均收益變平；ATC 遞減的自然獨占比較不管制、邊際成本定價與平均成本定價。

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
  `price_ceiling_outcome()` 求價格上限下的最適產量；`natural_monopoly_pricing()` 以 `PricingPoint` 回傳三種價格。
]
]

#block(breakable: false)[
#api(("natural_monopoly_canvas",), syntax: [
  ```python
  natural_monopoly_canvas(pricing, analysis, **options)
  ```
])[
  ATC 遞減的自然獨占：不管制價格、`P = MC`（虧損以底色標出）與 `P = ATC`（零利潤）。
]
]

#block(breakable: false)[
#api(("price_ceiling_canvas",), syntax: [
  ```python
  price_ceiling_canvas(outcome, analysis, **options)
  ```
])[
  價格上限：平均收益在上限處到 `Q_max` 為水平，邊際收益在該點等於上限，之後跳降回未管制的 MR。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/regulation/price_ceiling.zh-TW.svg", width: 46%, caption: [
  *價格上限。* 價格上限使平均收益在上限處變平，邊際收益在該點跳降。
]) <fig-regulation-price-ceiling>

#fig("/figures/regulation/natural_monopoly.zh-TW.svg", width: 46%, caption: [
  *自然獨占定價。* 比較不管制價格、邊際成本定價（虧損）與平均成本定價。
]) <fig-regulation-natural-monopoly>

== 價格歧視 <sec-ex-price-discrimination>

完全、分段與三級差別訂價，與單一獨占價格對照。

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
  `first_degree()`、`block_pricing()` 與 `third_degree()` 回傳對應的結果物件，含數量、價格與利潤。
]
]

#block(breakable: false)[
#api(("block_pricing_canvas",), syntax: [
  ```python
  block_pricing_canvas(result, *, average_cost=False, **options)
  ```
])[
  每一段以最後一位買者的價格出售：需求下方的階梯，到 `D = MC` 為止；`average_cost` 另加遞減的 ATC。
]
]

#block(breakable: false)[
#api(("first_degree_canvas",), syntax: [
  ```python
  first_degree_canvas(result, **options)
  ```
])[
  完全差別訂價：價格隨需求到 `D = MC`，利潤為需求與 MC 之間的面積。
]
]

#block(breakable: false)[
#api(("single_price_canvas",), syntax: [
  ```python
  single_price_canvas(demand, cost, *, groups=False, **options)
  ```
])[
  單一獨占價格（`MR = MC`）：其上的消費者剩餘，以及 `Q^*` 之後需求與 MC 之間未被攫取的剩餘；`groups` 可另加分組。
]
]

#block(breakable: false)[
#api(("third_degree_canvas",), syntax: [
  ```python
  third_degree_canvas(result, **options)
  ```
])[
  每個市場一欄（`D_i`、`MR_i` 與共同水準 `MC*`），最後一欄是加總的 `MR_T` 與 MC 相交。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/price_discrimination/single_price.zh-TW.svg", width: 46%, caption: [
  *單一價格。* 單一價格下有未攫取的剩餘。
]) <fig-price-discrimination-single-price>

#fig("/figures/price_discrimination/first_degree.zh-TW.svg", width: 46%, caption: [
  *完全差別訂價。* 價格隨需求曲線，利潤為需求與 MC 之間的面積。
]) <fig-price-discrimination-first-degree>

#fig("/figures/price_discrimination/block_pricing_three.zh-TW.svg", width: 46%, caption: [
  *三段式定價。* 三段式定價是不完全的一級差別訂價。
]) <fig-price-discrimination-block-pricing-three>

#fig("/figures/price_discrimination/block_pricing.zh-TW.svg", width: 46%, caption: [
  *遞減 ATC 的分段定價。* 需求在遞減平均成本之上，分段定價。
]) <fig-price-discrimination-block-pricing>

#fig("/figures/price_discrimination/third_degree.zh-TW.svg", width: 46%, caption: [
  *三級差別訂價。* MR1 = MR2 = MC，加總的邊際收益決定總產量。
]) <fig-price-discrimination-third-degree>

#fig("/figures/price_discrimination/third_degree_corner.zh-TW.svg", width: 46%, caption: [
  *角解。* 邊際成本上升時，小市場可能不被服務。
]) <fig-price-discrimination-third-degree-corner>

== 兩部定價 <sec-ex-two-part-tariff>

入場費加使用費。入場費取走被服務買者中剩餘最小者的剩餘，由此得到利潤。 出處：#citet(<oi1971>)。

#block(breakable: false)[
#api(("BuyerType", "best_tariff", "evaluate_tariff", "profit_by_entry_fee"), syntax: [
  ```python
  BuyerType(demand, count=1.0)
  best_tariff(buyers, marginal_cost)
  evaluate_tariff(buyers, marginal_cost, usage_fee, entry_fee)
  profit_by_entry_fee(buyers, marginal_cost, usage_fee, fees)
  ```
])[
  `BuyerType` 是附權重的需求曲線；`best_tariff()` 搜尋使用費，`evaluate_tariff()` 給出一組費用的利潤。
]
]

#block(breakable: false)[
#api(("tariff_profit_canvas",), syntax: [
  ```python
  tariff_profit_canvas(buyers, marginal_cost, usage_fee, fee_max, **options)
  ```
])[
  入場費利潤、銷售利潤與總利潤對入場費 `T`：每當一類買者被擠出就向下跳。
]
]

#block(breakable: false)[
#api(("two_part_tariff_canvas",), syntax: [
  ```python
  two_part_tariff_canvas(buyers, outcome, **options)
  ```
])[
  各類買者的需求、固定的 MC 與使用費 `p^*`；入場費是剩餘最小的買者的消費者剩餘三角形。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/two_part_tariff/single_buyer.zh-TW.svg", width: 46%, caption: [
  *兩部定價，單一買者。* 使用費等於 MC，入場費取走整個消費者剩餘。
]) <fig-two-part-tariff-single-buyer>

#fig("/figures/two_part_tariff/two_buyers.zh-TW.svg", width: 46%, caption: [
  *兩部定價，兩類買者。* 使用費高於 MC，入場費等於需求較小者的剩餘。
]) <fig-two-part-tariff-two-buyers>

#fig("/figures/two_part_tariff/tariff_profit.zh-TW.svg", width: 46%, caption: [
  *利潤與入場費。* 入場費利潤、銷售利潤與總利潤隨入場費變動。
]) <fig-two-part-tariff-tariff-profit>

== 搭售 <sec-ex-bundling>

消費者位於保留價格空間。分開銷售、純粹搭售與混合搭售把這個空間切成購買區域。 出處：#citet(<adamsyellen1976>)。

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
  `ValuationProfile` 保存消費者的保留價格；`best_separate()`、`best_pure()` 與 `best_mixed()` 搜尋利潤最大的價格；`choice_regions()` 以多邊形給出購買區域。
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
  混合搭售的區域（商品價格 `P1`、`P2`，組合價格 `P_B`）；成本為正時標出成本線，`numbered` 以編號標示區域。
]
]

#block(breakable: false)[
#api(("pure_bundling_canvas",), syntax: [
  ```python
  pure_bundling_canvas(profile, price, names=None, **options)
  ```
])[
  保留價格空間被對角線 `r1 + r2 = P_B` 切開，線上方的消費者購買。
]
]

#block(breakable: false)[
#api(("separate_selling_regions_canvas",), syntax: [
  ```python
  separate_selling_regions_canvas(profile, offer, names=None, **options)
  ```
])[
  `r1 = P1` 與 `r2 = P2` 切出的四個購買區域（分開銷售）。
]
]

#block(breakable: false)[
#api(("valuation_scatter_canvas",), syntax: [
  ```python
  valuation_scatter_canvas(profile, names=None, **options)
  ```
])[
  消費者是保留價格空間中的點 `(r1, r2)`；`names` 標出前幾個點。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/bundling/valuation_points.zh-TW.svg", width: 46%, caption: [
  *保留價格空間。* 以保留價格 r1、r2 標出各消費者的位置。
]) <fig-bundling-valuation-points>

#fig("/figures/bundling/separate_regions.zh-TW.svg", width: 46%, caption: [
  *分開銷售。* 價格 P1、P2 把保留價格空間分成四個購買區域。
]) <fig-bundling-separate-regions>

#fig("/figures/bundling/pure_bundling.zh-TW.svg", width: 46%, caption: [
  *純粹搭售。* 對角線 r1 + r2 = PB 以上的消費者購買組合。
]) <fig-bundling-pure-bundling>

#fig("/figures/bundling/mixed_bundling.zh-TW.svg", width: 46%, caption: [
  *混合搭售。* 混合搭售下四個購買區域。
]) <fig-bundling-mixed-bundling>

#fig("/figures/bundling/mixed_with_costs.zh-TW.svg", width: 46%, caption: [
  *有成本的混合搭售。* 邊際成本為正時的混合搭售區域。
]) <fig-bundling-mixed-with-costs>

#fig("/figures/bundling/regions_numbered.zh-TW.svg", width: 46%, caption: [
  *區域編號。* 以編號 I 至 IV 標示混合搭售的區域。
]) <fig-bundling-regions-numbered>

== 跨期與尖峰定價 <sec-ex-time-pricing>

兩群買者在不同時間面對不同價格，或兩個時期分攤容量成本。

#block(breakable: false)[
#api(("IntertemporalPricing", "PeakLoadPricing", "IntertemporalOutcome", "PeakLoadOutcome"), syntax: [
  ```python
  IntertemporalPricing(first, second, marginal_cost)
  PeakLoadPricing(peak, off_peak, marginal_cost, capacity_cost)
  ```
])[
  `IntertemporalPricing` 與 `PeakLoadPricing` 求解兩個市場，回傳對應的結果物件。
]
]

#block(breakable: false)[
#api(("intertemporal_pricing_canvas",), syntax: [
  ```python
  intertemporal_pricing_canvas(pricing, **options)
  ```
])[
  兩個需求與其邊際收益對固定 MC：高價給較早的一群，低價給較晚的一群。
]
]

#block(breakable: false)[
#api(("peak_load_canvas",), syntax: [
  ```python
  peak_load_canvas(pricing, **options)
  ```
])[
  尖峰與離峰需求與各自的邊際收益；兩期都有營運成本 `MC`，尖峰另加容量成本 `MC + MC_K`。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/time_pricing/intertemporal.zh-TW.svg", width: 46%, caption: [
  *跨期訂價。* 先對高估價的買者索取高價，之後再降價。
]) <fig-time-pricing-intertemporal>

#fig("/figures/time_pricing/peak_load.zh-TW.svg", width: 46%, caption: [
  *尖峰訂價。* 尖峰與離峰需求分別訂價，容量成本由尖峰負擔。
]) <fig-time-pricing-peak-load>

== 廣告 <sec-ex-advertising>

廣告使平均收益外移、平均成本上升；圖中比較前後的利潤。

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
  `AdvertisingDecision` 比較有無廣告的利潤，回傳 `AdvertisingOutcome`。
]
]

#block(breakable: false)[
#api(("advertising_effect_canvas",), syntax: [
  ```python
  advertising_effect_canvas(decision, **options)
  ```
])[
  `AR` 外移到 `AR'`、平均成本上升到 `AC'`；長方形顯示前（淺）後（深）的利潤。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/advertising/advertising.zh-TW.svg", width: 46%, caption: [
  *廣告。* 廣告使 AR 外移、平均成本上升，比較前後利潤。
]) <fig-advertising-advertising>

== 可耗竭資源 <sec-ex-exhaustible-resource>

價格減去邊際開採成本以利率成長，直到存量耗盡時達到禁止價格。 出處：#citet(<hotelling1931>)。

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
  `ExhaustibleResourcePath` 給出價格路徑 $p(t)$，以及對應的靜態需求與存量。
]
]

#block(breakable: false)[
#api(("resource_price_path_canvas",), syntax: [
  ```python
  resource_price_path_canvas(path, **options)
  ```
])[
  左圖是價格路徑 `p(t)`，從 `p_0` 上升到時間 `T` 的禁止價格，高於邊際開採成本 `c`；右圖是對應的靜態圖。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

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

#fig("/figures/exhaustible_resource/resource_price_path.zh-TW.svg", width: 46%, caption: [
  *可耗竭資源。* 價格減邊際開採成本以利率成長，並對應靜態需求。
]) <fig-exhaustible-resource-resource-price-path>

#import "/template/manual.typ": *


= 寡占與垂直關係 <sec-oligopoly>

少數廠商，以及同一條供應鏈上不同階段的廠商。

每一節是一支範例腳本與它畫出的圖。腳本隨手冊的壓縮檔提供，參數可用 `--help` 查看。

== 雙占 <sec-ex-oligopoly>

產量與價格的反應曲線給出古諾、史塔克柏格、柏川與勾結的結果。 出處：#citet(<cournot1838>)、#citet(<stackelberg1934>)、#citet(<bertrand1883>)。

#block(breakable: false)[
#api(("Duopoly", "DifferentiatedDuopoly", "CournotEquilibrium", "BertrandEquilibrium"), syntax: [
  ```python
  Duopoly(intercept, slope, cost_1, cost_2)
  DifferentiatedDuopoly(
      alpha_1,
      alpha_2,
      beta_1,
      beta_2,
      gamma_1,
      gamma_2,
      cost_1,
      cost_2,
  )
  ```
])[
  `Duopoly` 有 `cournot()`、`stackelberg()`、`competitive_total()` 與 `collusive_total()`；`DifferentiatedDuopoly` 的 `bertrand()` 處理價格競爭。
]
]

#block(breakable: false)[
#api(("price_reaction_canvas",), syntax: [
  ```python
  price_reaction_canvas(duopoly, *, collusive=True, **options)
  ```
])[
  `(p1, p2)` 空間中向上傾斜的價格反應曲線 `R1`、`R2`、納許價格 `N`，以及可選的勾結價格。
]
]

#block(breakable: false)[
#api(("reaction_curves_canvas",), syntax: [
  ```python
  reaction_curves_canvas(
      duopoly,
      *,
      competitive=False,
      collusive=False,
      leader=None,
      **options,
  )
  ```
])[
  `(Q1, Q2)` 空間中的反應曲線 `R1`、`R2` 相交於古諾點 `N`；`competitive` 與 `collusive` 另加總產量固定線。
]
]

#block(breakable: false)[
#api(("residual_demand_canvas",), syntax: [
  ```python
  residual_demand_canvas(duopoly, guesses, **options)
  ```
])[
  廠商 1 對各種對手產量猜測下的剩餘需求 `D1(q2)` 與 `MR1(q2)`，以及它的邊際成本。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

```python
def oligopoly_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    duopoly: Duopoly,
    guesses: tuple[float, ...],
    differentiated: DifferentiatedDuopoly,
    title: str | None = None,
) -> list[Path]:
    """Write the oligopoly figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    figures = {
        "residual_demand.svg": residual_demand_canvas(
            duopoly, guesses, theme=theme, title=title
        ),
        "cournot.svg": reaction_curves_canvas(
            duopoly, theme=theme, title=title
        ),
        "cournot_points.svg": reaction_curves_canvas(
            duopoly,
            competitive=True,
            collusive=True,
            theme=theme,
            title=title,
        ),
        "stackelberg.svg": reaction_curves_canvas(
            duopoly, leader=1, theme=theme, title=title
        ),
        "price_reaction.svg": price_reaction_canvas(
            differentiated, theme=theme, title=title
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/oligopoly/residual_demand.zh-TW.svg", width: 46%, caption: [
  *剩餘需求。* 對手產量的各種猜測對應的剩餘需求與邊際收益。
]) <fig-oligopoly-residual-demand>

#fig("/figures/oligopoly/cournot.zh-TW.svg", width: 46%, caption: [
  *反應曲線。* 兩條反應曲線的交點即古諾均衡 N。
]) <fig-oligopoly-cournot>

#fig("/figures/oligopoly/cournot_points.zh-TW.svg", width: 46%, caption: [
  *競爭、古諾與勾結。* 競爭、古諾與勾結的點，以及勾結曲線。
]) <fig-oligopoly-cournot-points>

#fig("/figures/oligopoly/stackelberg.zh-TW.svg", width: 46%, caption: [
  *史塔克柏格。* 領導者沿追隨者的反應曲線選擇產量。
]) <fig-oligopoly-stackelberg>

#fig("/figures/oligopoly/price_reaction.zh-TW.svg", width: 46%, caption: [
  *價格反應曲線。* 差異化產品的價格反應曲線、納許價格與勾結價格。
]) <fig-oligopoly-price-reaction>

== 拗折需求、支配廠商與卡特爾 <sec-ex-dominant-firm>

對手跟進降價但不跟進漲價，需求出現拗折；有邊緣廠商的廠商面對剩餘需求。 出處：#citet(<sweezy1939>)。

#block(breakable: false)[
#api(("KinkedDemand", "DominantFirm", "DominantFirmOutcome"), syntax: [
  ```python
  KinkedDemand(quantity, price, upper_slope, lower_slope)
  DominantFirm(
      demand_intercept,
      demand_slope,
      fringe_start,
      fringe_slope,
      cost_intercept,
      cost_slope=0.0,
  )
  ```
])[
  `KinkedDemand` 給出拗折點與邊際收益的缺口；`DominantFirm` 對邊緣廠商求解剩餘需求。
]
]

#block(breakable: false)[
#api(("cartel_elasticity_canvas",), syntax: [
  ```python
  cartel_elasticity_canvas(inelastic, elastic, **options)
  ```
])[
  卡特爾與邊緣廠商：缺乏彈性的需求與有彈性的需求（市場力量小）並列。
]
]

#block(breakable: false)[
#api(("dominant_firm_canvas",), syntax: [
  ```python
  dominant_firm_canvas(
      firm,
      *,
      cartel=False,
      prefix="oligopoly.dominant",
      **options,
  )
  ```
])[
  市場需求 `D`、邊緣廠商供給 `S_F`，以及剩餘需求 `D_D = D - S_F`、其邊際收益與廠商的邊際成本。
]
]

#block(breakable: false)[
#api(("kinked_demand_canvas",), syntax: [
  ```python
  kinked_demand_canvas(kinked, marginal_costs, **options)
  ```
])[
  拗折需求與其邊際收益在拗折點的垂直缺口；`marginal_costs` 中每條 MC 畫成水平線。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

```python
def dominant_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    kinked: KinkedDemand,
    costs: tuple[float, ...],
    firm: DominantFirm,
    inelastic: DominantFirm,
    elastic: DominantFirm,
    title: str | None = None,
) -> list[Path]:
    """Write the dominant-firm figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    figures = {
        "kinked_demand.svg": kinked_demand_canvas(
            kinked, costs, theme=theme, title=title
        ),
        "dominant_firm.svg": dominant_firm_canvas(
            firm, theme=theme, title=title
        ),
        "cartel_fringe.svg": dominant_firm_canvas(
            firm,
            cartel=True,
            theme=theme,
            title=title,
            prefix="oligopoly.cartel",
        ),
        "cartel_elasticity.svg": cartel_elasticity_canvas(
            inelastic, elastic, theme=theme
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/dominant_firm/kinked_demand.zh-TW.svg", width: 46%, caption: [
  *拗折需求。* 拗折需求與 MR 的缺口，缺口內的 MC 變動不影響價格。
]) <fig-dominant-firm-kinked-demand>

#fig("/figures/dominant_firm/dominant_firm.zh-TW.svg", width: 46%, caption: [
  *支配廠商。* 市場需求減去邊緣廠商供給即支配廠商的剩餘需求。
]) <fig-dominant-firm-dominant-firm>

#fig("/figures/dominant_firm/cartel_fringe.zh-TW.svg", width: 46%, caption: [
  *卡特爾與邊緣廠商。* 卡特爾面對總需求減去邊緣廠商供給後的需求。
]) <fig-dominant-firm-cartel-fringe>

#fig("/figures/dominant_firm/cartel_elasticity.zh-TW.svg", width: 46%, caption: [
  *卡特爾與需求彈性。* 需求愈有彈性，卡特爾的市場力量愈小。
]) <fig-dominant-firm-cartel-elasticity>

== 垂直關係 <sec-ex-vertical>

兩個上下游的獨占者各加成一次。整合廠商只有一次加成；外部市場決定移轉價格。 出處：#citet(<spengler1950>)。

#block(breakable: false)[
#api(("VerticalChain", "ChainOutcome", "transfer_pricing", "TransferPricingOutcome"), syntax: [
  ```python
  VerticalChain(
      demand,
      downstream_cost,
      upstream_intercept,
      upstream_slope=0.0,
  )
  transfer_pricing(chain, market_price)
  ```
])[
  `VerticalChain` 求解分開與整合的結果；`transfer_pricing()` 在有外部市場時給出最適移轉價格。
]
]

#block(breakable: false)[
#api(("double_marginalization_canvas",), syntax: [
  ```python
  double_marginalization_canvas(chain, **options)
  ```
])[
  兩個疊起來的獨占：最終需求 `D`、`NMR`（上游面對的需求）、上游邊際收益 `MR_u` 與 `MC_u`。
]
]

#block(breakable: false)[
#api(("integrated_firm_canvas",), syntax: [
  ```python
  integrated_firm_canvas(chain, **options)
  ```
])[
  整合廠商令 `NMR = MC_u`：產量 `Q_i` 高於分開時的 `Q_s`，最終價格 `p_i` 較低。
]
]

#block(breakable: false)[
#api(("transfer_price_outside_market_canvas",), syntax: [
  ```python
  transfer_price_outside_market_canvas(
      chain,
      market_price,
      *,
      kinked=True,
      **options,
  )
  ```
])[
  有外部市場價格 `P_m` 時，有效邊際成本在 `Q_u` 以下為 `MC_u`，之後為水平的 `P_m`。
]
]

下面是腳本中畫圖的函式，與圖形使用相同的程式碼。

```python
def vertical_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    chain: VerticalChain,
    market_price: float,
    title: str | None = None,
) -> list[Path]:
    """Write the vertical-chain figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    figures = {
        "double_marginalization.svg": double_marginalization_canvas(
            chain, theme=theme, title=title
        ),
        "integrated_firm.svg": integrated_firm_canvas(
            chain, theme=theme, title=title
        ),
        "transfer_kinked.svg": transfer_price_outside_market_canvas(
            chain, market_price, theme=theme, title=title
        ),
        "transfer_price.svg": transfer_price_outside_market_canvas(
            chain, market_price, kinked=False, theme=theme, title=title
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/vertical/double_marginalization.zh-TW.svg", width: 46%, caption: [
  *雙重加成。* 下游 NMR 即上游需求，兩次加成使產量更低。
]) <fig-vertical-double-marginalization>

#fig("/figures/vertical/integrated_firm.zh-TW.svg", width: 46%, caption: [
  *整合廠商。* 整合廠商令 NMR 等於上游 MC，產量較高、價格較低。
]) <fig-vertical-integrated-firm>

#fig("/figures/vertical/transfer_kinked.zh-TW.svg", width: 46%, caption: [
  *折線移轉價格。* 有外部市場時，MC 在市場價格處拗折。
]) <fig-vertical-transfer-kinked>

#fig("/figures/vertical/transfer_price.zh-TW.svg", width: 46%, caption: [
  *最適移轉價格。* 最適內部移轉價格等於市場價格，餘量在外部出售。
]) <fig-vertical-transfer-price>

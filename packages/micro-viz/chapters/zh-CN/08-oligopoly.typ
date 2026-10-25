#import "/template/manual.typ": *


= 寡占与垂直关系 <sec-oligopoly>

少数厂商，以及同一条供应链上不同阶段的厂商。

每一节是一支范例脚本与它画出的图。脚本随手册的压缩档提供，参数可用 `--help` 查看。

== 双占 <sec-ex-oligopoly>

产量与价格的反应曲线给出古诺、史塔克柏格、柏川与勾结的结果。 出处：#citet(<cournot1838>)、#citet(<stackelberg1934>)、#citet(<bertrand1883>)。

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
  `Duopoly` 有 `cournot()`、`stackelberg()`、`competitive_total()` 与 `collusive_total()`；`DifferentiatedDuopoly` 的 `bertrand()` 处理价格竞争。
]
]

#block(breakable: false)[
#api(("price_reaction_canvas",), syntax: [
  ```python
  price_reaction_canvas(duopoly, *, collusive=True, **options)
  ```
])[
  `(p1, p2)` 空间中向上倾斜的价格反应曲线 `R1`、`R2`、纳许价格 `N`，以及可选的勾结价格。
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
  `(Q1, Q2)` 空间中的反应曲线 `R1`、`R2` 相交于古诺点 `N`；`competitive` 与 `collusive` 另加总产量固定线。
]
]

#block(breakable: false)[
#api(("residual_demand_canvas",), syntax: [
  ```python
  residual_demand_canvas(duopoly, guesses, **options)
  ```
])[
  厂商 1 对各种对手产量猜测下的剩余需求 `D1(q2)` 与 `MR1(q2)`，以及它的边际成本。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

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

#fig("/figures/oligopoly/residual_demand.zh-CN.svg", width: 46%, caption: [
  *剩余需求。* 对手产量的各种猜测对应的剩余需求与边际收益。
]) <fig-oligopoly-residual-demand>

#fig("/figures/oligopoly/cournot.zh-CN.svg", width: 46%, caption: [
  *反应曲线。* 两条反应曲线的交点即古诺均衡 N。
]) <fig-oligopoly-cournot>

#fig("/figures/oligopoly/cournot_points.zh-CN.svg", width: 46%, caption: [
  *竞争、古诺与勾结。* 竞争、古诺与勾结的点，以及勾结曲线。
]) <fig-oligopoly-cournot-points>

#fig("/figures/oligopoly/stackelberg.zh-CN.svg", width: 46%, caption: [
  *史塔克柏格。* 领导者沿追随者的反应曲线选择产量。
]) <fig-oligopoly-stackelberg>

#fig("/figures/oligopoly/price_reaction.zh-CN.svg", width: 46%, caption: [
  *价格反应曲线。* 差异化产品的价格反应曲线、纳许价格与勾结价格。
]) <fig-oligopoly-price-reaction>

== 拗折需求、支配厂商与卡特尔 <sec-ex-dominant-firm>

对手跟进降价但不跟进涨价，需求出现拗折；有边缘厂商的厂商面对剩余需求。 出处：#citet(<sweezy1939>)。

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
  `KinkedDemand` 给出拗折点与边际收益的缺口；`DominantFirm` 对边缘厂商求解剩余需求。
]
]

#block(breakable: false)[
#api(("cartel_elasticity_canvas",), syntax: [
  ```python
  cartel_elasticity_canvas(inelastic, elastic, **options)
  ```
])[
  卡特尔与边缘厂商：缺乏弹性的需求与有弹性的需求（市场力量小）并列。
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
  市场需求 `D`、边缘厂商供给 `S_F`，以及剩余需求 `D_D = D - S_F`、其边际收益与厂商的边际成本。
]
]

#block(breakable: false)[
#api(("kinked_demand_canvas",), syntax: [
  ```python
  kinked_demand_canvas(kinked, marginal_costs, **options)
  ```
])[
  拗折需求与其边际收益在拗折点的垂直缺口；`marginal_costs` 中每条 MC 画成水平线。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

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

#fig("/figures/dominant_firm/kinked_demand.zh-CN.svg", width: 46%, caption: [
  *拗折需求。* 拗折需求与 MR 的缺口，缺口内的 MC 变动不影响价格。
]) <fig-dominant-firm-kinked-demand>

#fig("/figures/dominant_firm/dominant_firm.zh-CN.svg", width: 46%, caption: [
  *支配厂商。* 市场需求减去边缘厂商供给即支配厂商的剩余需求。
]) <fig-dominant-firm-dominant-firm>

#fig("/figures/dominant_firm/cartel_fringe.zh-CN.svg", width: 46%, caption: [
  *卡特尔与边缘厂商。* 卡特尔面对总需求减去边缘厂商供给后的需求。
]) <fig-dominant-firm-cartel-fringe>

#fig("/figures/dominant_firm/cartel_elasticity.zh-CN.svg", width: 46%, caption: [
  *卡特尔与需求弹性。* 需求愈有弹性，卡特尔的市场力量愈小。
]) <fig-dominant-firm-cartel-elasticity>

== 垂直关系 <sec-ex-vertical>

两个上下游的独占者各加成一次。集成厂商只有一次加成；外部市场决定移转价格。 出处：#citet(<spengler1950>)。

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
  `VerticalChain` 求解分开与集成的结果；`transfer_pricing()` 在有外部市场时给出最适移转价格。
]
]

#block(breakable: false)[
#api(("double_marginalization_canvas",), syntax: [
  ```python
  double_marginalization_canvas(chain, **options)
  ```
])[
  两个叠起来的独占：最终需求 `D`、`NMR`（上游面对的需求）、上游边际收益 `MR_u` 与 `MC_u`。
]
]

#block(breakable: false)[
#api(("integrated_firm_canvas",), syntax: [
  ```python
  integrated_firm_canvas(chain, **options)
  ```
])[
  集成厂商令 `NMR = MC_u`：产量 `Q_i` 高于分开时的 `Q_s`，最终价格 `p_i` 较低。
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
  有外部市场价格 `P_m` 时，有效边际成本在 `Q_u` 以下为 `MC_u`，之后为水平的 `P_m`。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

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

#fig("/figures/vertical/double_marginalization.zh-CN.svg", width: 46%, caption: [
  *双重加成。* 下游 NMR 即上游需求，两次加成使产量更低。
]) <fig-vertical-double-marginalization>

#fig("/figures/vertical/integrated_firm.zh-CN.svg", width: 46%, caption: [
  *集成厂商。* 集成厂商令 NMR 等于上游 MC，产量较高、价格较低。
]) <fig-vertical-integrated-firm>

#fig("/figures/vertical/transfer_kinked.zh-CN.svg", width: 46%, caption: [
  *折线移转价格。* 有外部市场时，MC 在市场价格处拗折。
]) <fig-vertical-transfer-kinked>

#fig("/figures/vertical/transfer_price.zh-CN.svg", width: 46%, caption: [
  *最适移转价格。* 最适内部移转价格等于市场价格，余量在外部出售。
]) <fig-vertical-transfer-price>

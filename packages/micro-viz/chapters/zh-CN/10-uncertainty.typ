#import "/template/manual.typ": *


= 不确定性与信息 <sec-uncertainty>

风险、拍卖与信息不对称。

每一节是一支范例脚本与它画出的图。脚本随手册的压缩档提供，参数可用 `--help` 查看。

== 不确定下的选择 <sec-ex-uncertainty>

期望效用与风险态度、均数变异数选择、状态请求权与随机优势。 出处：#citet(<pratt1964>)、#citet(<rothschildstiglitz1970>)、#citet(<markowitz1952>)。

#block(breakable: false)[
#api(("Gamble", "IncomeUtility", "UniformLottery", "MeanVarianceInvestor", "RiskReturnLine", "StateClaims", "TwoAssetFrontier", "cdf_crossing", "first_order_dominates", "second_order_dominates"), syntax: [
  ```python
  Gamble(low, high, probability=0.5)
  IncomeUtility(exponent)
  UniformLottery(low, high)
  MeanVarianceInvestor(risk_aversion)
  RiskReturnLine(risk_free, price_of_risk)
  StateClaims(good, bad, loss_probability, exponent=0.5)
  TwoAssetFrontier(mean_1, sd_1, mean_2, sd_2, correlation)
  cdf_crossing(a, b)
  first_order_dominates(better, worse)
  second_order_dominates(better, worse)
  ```
])[
  `Gamble` 与 `IncomeUtility` 给出期望效用、确定等值与风险贴水；`MeanVarianceInvestor` 与 `RiskReturnLine` 求风险报酬选择；`StateClaims`、`UniformLottery` 与 `TwoAssetFrontier` 处理保险、优势与前缘。
]
]

#block(breakable: false)[
#api(("mean_variance_frontier_canvas",), syntax: [
  ```python
  mean_variance_frontier_canvas(frontier, weights=(-0.4, 1.4), **options)
  ```
])[
  两资产组合在标准差－平均数平面上的前缘：最小变异数组合 `G` 以上的效率部分为粗线。
]
]

#block(breakable: false)[
#api(("risk_attitude_canvas",), syntax: [
  ```python
  risk_attitude_canvas(investors, level, sd_max, **options)
  ```
])[
  标准差－所得平面上每位投资人一栏的无异曲线：愈趋避风险，曲线愈陡。
]
]

#block(breakable: false)[
#api(("risk_premium_canvas",), syntax: [
  ```python
  risk_premium_canvas(gamble, utility, **options)
  ```
])[
  凹的 `u` 与弦：确定等值 `CE` 的效用等于赌局的 `EU`，风险贴水是 `E(I)` 与 `CE` 之差。
]
]

#block(breakable: false)[
#api(("risk_return_choice_canvas",), syntax: [
  ```python
  risk_return_choice_canvas(
      line,
      investors,
      level,
      sd_max,
      market_sd=None,
      **options,
  )
  ```
])[
  风险报酬线与各投资人和它相切的无异曲线；`market_sd` 另标市场投资组合 `M`，其外是借款。
]
]

#block(breakable: false)[
#api(("state_claims_canvas",), syntax: [
  ```python
  state_claims_canvas(claims, premium_rates, **options)
  ```
])[
  状态请求权：45 度的确定线、禀赋 `E`、每个保费率一条预算线（第一条画粗；公平保费导致完全保险）。
]
]

#block(breakable: false)[
#api(("stochastic_dominance_canvas",), syntax: [
  ```python
  stochastic_dominance_canvas(first, second, kind="first", **options)
  ```
])[
  两个赌局的 CDF `F_A` 与 `F_B`：`kind="first"` 显示 `F_A` 处处在 `F_B` 之下，`kind="second"` 显示二阶优势。
]
]

#block(breakable: false)[
#api(("utility_of_income_canvas",), syntax: [
  ```python
  utility_of_income_canvas(gamble, utilities, **options)
  ```
])[
  每个效用函数一小栏：`u(I)`、两个结果间的弦，以及弦上高于期望所得处的期望效用。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

```python
def uncertainty_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    gamble: Gamble,
    exponents: tuple[float, float, float],
    averse: float,
    flat: float,
    level: float,
    line: RiskReturnLine,
    sd_max: float,
    market_sd: float,
    claims: StateClaims,
    premiums: tuple[float, float],
    lotteries: tuple[
        UniformLottery, UniformLottery, UniformLottery, UniformLottery
    ],
    frontier: TwoAssetFrontier,
    title: str | None = None,
) -> list[Path]:
    """Write the uncertainty figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    concave, convex, linear = (IncomeUtility(e) for e in exponents)
    steep, shallow = (
        MeanVarianceInvestor(averse),
        MeanVarianceInvestor(flat),
    )
    figures = {
        "utility_of_income.svg": utility_of_income_canvas(
            gamble, (concave, convex, linear), theme=theme
        ),
        "risk_premium.svg": risk_premium_canvas(
            gamble, concave, theme=theme, title=title
        ),
        "risk_attitude.svg": risk_attitude_canvas(
            (steep, shallow), level, sd_max, theme=theme
        ),
        "risk_return_choice.svg": risk_return_choice_canvas(
            line, (steep,), level, sd_max, theme=theme, title=title
        ),
        "risk_return_two_investors.svg": risk_return_choice_canvas(
            line, (steep, shallow), level, sd_max, theme=theme, title=title
        ),
        "state_claims_fair.svg": state_claims_canvas(
            claims, premiums[:1], theme=theme, title=title
        ),
        "state_claims_unfair.svg": state_claims_canvas(
            claims, premiums, theme=theme, title=title
        ),
        "first_order_dominance.svg": stochastic_dominance_canvas(
            lotteries[0], lotteries[1], "first", theme=theme, title=title
        ),
        "second_order_dominance.svg": stochastic_dominance_canvas(
            lotteries[2], lotteries[3], "second", theme=theme, title=title
        ),
        "mean_variance_frontier.svg": mean_variance_frontier_canvas(
            frontier, theme=theme, title=title
        ),
        "risk_return_borrowing.svg": risk_return_choice_canvas(
            line,
            (shallow,),
            level,
            sd_max,
            market_sd,
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

#fig("/figures/uncertainty/utility_of_income.zh-CN.svg", width: 46%, caption: [
  *所得效用。* 三种风险态度的所得效用与期望效用弦。
]) <fig-uncertainty-utility-of-income>

#fig("/figures/uncertainty/risk_premium.zh-CN.svg", width: 46%, caption: [
  *风险贴水。* 确定等值与风险贴水。
]) <fig-uncertainty-risk-premium>

#fig("/figures/uncertainty/risk_attitude.zh-CN.svg", width: 46%, caption: [
  *风险态度。* 风险趋避愈强，无异曲线愈陡。
]) <fig-uncertainty-risk-attitude>

#fig("/figures/uncertainty/risk_return_choice.zh-CN.svg", width: 46%, caption: [
  *风险报酬选择。* 无异曲线与风险报酬线相切。
]) <fig-uncertainty-risk-return-choice>

#fig("/figures/uncertainty/risk_return_two_investors.zh-CN.svg", width: 46%, caption: [
  *两位投资人。* 不同风险趋避者选择不同切点。
]) <fig-uncertainty-risk-return-two-investors>

#fig("/figures/uncertainty/state_claims_fair.zh-CN.svg", width: 46%, caption: [
  *状态请求权，公平保费。* 公平保费下，消费者选择两状态所得相等的*完全保险*。
]) <fig-uncertainty-state-claims-fair>

#fig("/figures/uncertainty/state_claims_unfair.zh-CN.svg", width: 46%, caption: [
  *状态请求权，高保费。* 保费高于公平时，消费者只买*部分保险*。
]) <fig-uncertainty-state-claims-unfair>

#fig("/figures/uncertainty/first_order_dominance.zh-CN.svg", width: 46%, caption: [
  *一阶随机优势。* 一条 CDF 处处在另一条之下，即*一阶随机优势*。
]) <fig-uncertainty-first-order-dominance>

#fig("/figures/uncertainty/second_order_dominance.zh-CN.svg", width: 46%, caption: [
  *二阶随机优势。* 平均数相同、较不分散者*二阶随机优势*。
]) <fig-uncertainty-second-order-dominance>

#fig("/figures/uncertainty/mean_variance_frontier.zh-CN.svg", width: 46%, caption: [
  *均数变异数前缘。* 两资产组合的*效率前缘*与无效率部分。
]) <fig-uncertainty-mean-variance-frontier>

#fig("/figures/uncertainty/risk_return_borrowing.zh-CN.svg", width: 46%, caption: [
  *借款。* 借款可持有超过市场投资组合的风险。
]) <fig-uncertainty-risk-return-borrowing>

== 拍卖 <sec-ex-auctions>

独立均匀估值下的第一与第二价格密封拍卖：出价函数与收益相等。 出处：#citet(<vickrey1961>)。

#block(breakable: false)[
#api(("Auction",), syntax: [
  ```python
  Auction(bidders, max_value=1.0)
  ```
])[
  `Auction` 给出某估值下的出价，以及两种形式的预期收益。
]
]

#block(breakable: false)[
#api(("bid_functions_canvas",), syntax: [
  ```python
  bid_functions_canvas(auctions, **options)
  ```
])[
  出价对估值：45 度的第二价格出价 `b = v`，以及 `auctions` 中每个拍卖的第一价格出价 `b = (n - 1) v / n`。
]
]

#block(breakable: false)[
#api(("revenue_equivalence_canvas",), syntax: [
  ```python
  revenue_equivalence_canvas(bidders, max_value=1.0, **options)
  ```
])[
  两种形式下卖者的预期收益对竞标者数目：两条曲线重合（收益相等），并随人数上升。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

```python
def auction_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    bidders: tuple[int, ...],
    max_value: float,
    title: str | None = None,
) -> list[Path]:
    """Write the auction figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    figures = {
        "bid_functions.svg": bid_functions_canvas(
            (Auction(bidders[0], max_value),), theme=theme, title=title
        ),
        "bid_functions_by_bidders.svg": bid_functions_canvas(
            tuple(Auction(n, max_value) for n in bidders),
            theme=theme,
            title=title,
        ),
        "revenue_equivalence.svg": revenue_equivalence_canvas(
            tuple(range(2, max(bidders) + 8)),
            max_value,
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

#fig("/figures/auctions/bid_functions.zh-CN.svg", width: 46%, caption: [
  *出价函数。* 第二价格拍卖出价等于估值，第一价格出价*低于估值*。
]) <fig-auctions-bid-functions>

#fig("/figures/auctions/bid_functions_by_bidders.zh-CN.svg", width: 46%, caption: [
  *出价折减。* 竞标者愈多，第一价格出价愈*接近估值*。
]) <fig-auctions-bid-functions-by-bidders>

#fig("/figures/auctions/revenue_equivalence.zh-CN.svg", width: 46%, caption: [
  *收益相等。* 两种拍卖的*预期收益相同*，且随竞标者增加。
]) <fig-auctions-revenue-equivalence>

== 信息 <sec-ex-information>

逆选择、信号、道德风险、诱因兼容的奖金与效率工资。 出处：#citet(<akerlof1970>)、#citet(<spence1973>)、#citet(<shapirostiglitz1984>)。

#block(breakable: false)[
#api(("LemonsMarket", "Signaling", "MoralHazard", "BonusSchedule", "EfficiencyWage", "EfficiencyWageOutcome"), syntax: [
  ```python
  LemonsMarket(demand_high, demand_low, cost_high, cost_low, supply_slope)
  Signaling(wage_gap, cost_low, cost_high)
  MoralHazard(demand, marginal_cost, coverage)
  BonusSchedule(report_rate, under_rate, over_rate)
  EfficiencyWage(
      demand_intercept,
      demand_slope,
      supply_intercept,
      supply_slope,
      shirk_intercept,
      shirk_slope,
  )
  ```
])[
  每个模型求解一种信息不对称的情形；`Signaling` 有分离与混同两种信号。
]
]

#block(breakable: false)[
#api(("bonus_schedule_canvas",), syntax: [
  ```python
  bonus_schedule_canvas(schedule, capacities, reach, **options)
  ```
])[
  奖金对申报的厂房规模 `R`，每种真实产能一条：每条在申报等于产能处最高，所以诚实申报是最适。
]
]

#block(breakable: false)[
#api(("efficiency_wage_canvas",), syntax: [
  ```python
  efficiency_wage_canvas(model, **options)
  ```
])[
  劳动需求 `D`、供给 `S` 与不偷懒条件 `NSC`：均衡在 `NSC` 与 `D` 相交处，工资高于竞争工资。
]
]

#block(breakable: false)[
#api(("lemons_market_canvas",), syntax: [
  ```python
  lemons_market_canvas(market, shares, **options)
  ```
])[
  每个高品质比例一栏：高、低品质的需求 `D_H`、`D_L`，卖者的保留线 `S_H`、`S_L` 与混合需求。
]
]

#block(breakable: false)[
#api(("moral_hazard_canvas",), syntax: [
  ```python
  moral_hazard_canvas(hazard, **options)
  ```
])[
  需求 `D` 对真实边际成本 `MC`，以及被保险病人面对的较低价格 `MC'`：使用量由 `Q_e` 增至 `Q_i`，三角形是无谓损失。
]
]

#block(breakable: false)[
#api(("signaling_canvas",), syntax: [
  ```python
  signaling_canvas(signaling, signal=None, **options)
  ```
])[
  低能力组（左）与高能力组（右）的教育成本对工资利益：在分离信号 `y*` 下只有高能力者购买。
]
]

下面是脚本中画图的函数，与图形使用相同的代码。

```python
def information_examples(
    output_dir: Path,
    theme: PlotTheme,
    *,
    lemons: LemonsMarket,
    shares: tuple[float, ...],
    signaling: Signaling,
    hazard: MoralHazard,
    bonus: BonusSchedule,
    capacities: tuple[float, ...],
    reach: float,
    efficiency: EfficiencyWage,
    title: str | None = None,
) -> list[Path]:
    """Write the information figures into ``output_dir`` and return their paths."""
    output_dir.mkdir(parents=True, exist_ok=True)
    figures = {
        "lemons.svg": lemons_market_canvas(lemons, shares, theme=theme),
        "signaling.svg": signaling_canvas(signaling, theme=theme),
        "pooling.svg": signaling_canvas(
            signaling, signaling.low_ceiling / 2, theme=theme
        ),
        "moral_hazard.svg": moral_hazard_canvas(
            hazard, theme=theme, title=title
        ),
        "bonus_schedule.svg": bonus_schedule_canvas(
            bonus, capacities, reach, theme=theme, title=title
        ),
        "efficiency_wage.svg": efficiency_wage_canvas(
            efficiency, theme=theme, title=title
        ),
    }
    paths = []
    for name, figure in figures.items():
        figure.save(output_dir / name)
        paths.append(output_dir / name)
    return paths
```

#fig("/figures/information/pooling.zh-CN.svg", width: 46%, caption: [
  *混同信号。* 信号成本低时，两类型皆购买，形成*混同均衡*。
]) <fig-information-pooling>

#fig("/figures/information/lemons.zh-CN.svg", width: 46%, caption: [
  *柠檬市场。* 高品质比例过低时，高品质被逐出市场。
]) <fig-information-lemons>

#fig("/figures/information/signaling.zh-CN.svg", width: 46%, caption: [
  *信号。* 分离信号只有高能力者愿意购买。
]) <fig-information-signaling>

#fig("/figures/information/moral_hazard.zh-CN.svg", width: 46%, caption: [
  *道德风险。* 保险降低价格，造成过度使用。
]) <fig-information-moral-hazard>

#fig("/figures/information/bonus_schedule.zh-CN.svg", width: 46%, caption: [
  *奖金表。* 诚实申报时奖金最大，诱因兼容。
]) <fig-information-bonus-schedule>

#fig("/figures/information/efficiency_wage.zh-CN.svg", width: 46%, caption: [
  *效率工资。* 不偷懒条件使工资高于均衡并产生失业。
]) <fig-information-efficiency-wage>

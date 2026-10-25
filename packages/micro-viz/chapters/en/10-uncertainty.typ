#import "/template/manual.typ": *


= Uncertainty and information <sec-uncertainty>

Risk, auctions and asymmetric information.

Each section is one example script and the figures it draws. The scripts come in the archive of this manual; `--help` lists their arguments.

== Choice under uncertainty <sec-ex-uncertainty>

Expected utility and risk attitude, mean-variance choice, state-contingent claims and stochastic dominance. Sources: #citet(<pratt1964>), #citet(<rothschildstiglitz1970>), #citet(<markowitz1952>).

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
  `Gamble` and `IncomeUtility` give expected utility, the certainty equivalent and the risk premium; `MeanVarianceInvestor` and `RiskReturnLine` solve the risk-return choice; `StateClaims`, `UniformLottery` and `TwoAssetFrontier` cover insurance, dominance and the frontier.
]
]

#block(breakable: false)[
#api(("mean_variance_frontier_canvas",), syntax: [
  ```python
  mean_variance_frontier_canvas(frontier, weights=(-0.4, 1.4), **options)
  ```
])[
  The frontier of portfolios of two assets in the standard-deviation-mean plane: the efficient part above the minimum-variance portfolio `G` is thick, the inefficient part thin and solid.
]
]

#block(breakable: false)[
#api(("risk_attitude_canvas",), syntax: [
  ```python
  risk_attitude_canvas(investors, level, sd_max, **options)
  ```
])[
  One panel of indifference curves per investor in the standard-deviation-income plane: the more risk averse, the steeper the curves.
]
]

#block(breakable: false)[
#api(("risk_premium_canvas",), syntax: [
  ```python
  risk_premium_canvas(gamble, utility, **options)
  ```
])[
  Concave `u` with the chord: the certainty equivalent `CE` has the utility `EU` of the gamble and the risk premium is the gap between `E(I)` and `CE` at that height.
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
  The risk-return line with each investor's indifference curve tangent to it. With `market_sd` the market portfolio `M` is marked and the part beyond it (borrowing to hold more risk) is a thin solid segment.
]
]

#block(breakable: false)[
#api(("state_claims_canvas",), syntax: [
  ```python
  state_claims_canvas(claims, premium_rates, **options)
  ```
])[
  State-contingent claims: the 45-degree certainty line, the endowment `E`, one budget line per premium rate (the first thick; a fair rate leads to full insurance on the certainty line, an unfair one to partial insurance) and the indifference curve through each choice.
]
]

#block(breakable: false)[
#api(("stochastic_dominance_canvas",), syntax: [
  ```python
  stochastic_dominance_canvas(first, second, kind="first", **options)
  ```
])[
  The CDFs `F_A` and `F_B` of two lotteries. `kind="first"` shows `F_A` lying everywhere below `F_B` (A first-order dominates B); `kind="second"` shades the two areas enclosed where the CDFs cross, the larger one lying under the dominated lottery's CDF.
]
]

#block(breakable: false)[
#api(("utility_of_income_canvas",), syntax: [
  ```python
  utility_of_income_canvas(gamble, utilities, **options)
  ```
])[
  One small panel per utility function: `u(I)`, the chord between the two outcomes and the expected utility on it above expected income.
]
]

The function of the script that draws the figures follows.

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

#fig("/figures/uncertainty/utility_of_income.svg", width: 46%, caption: [
  *Utility of income.* Utility of income and the expected-utility chord for three risk attitudes.
]) <fig-uncertainty-utility-of-income>

#fig("/figures/uncertainty/risk_premium.svg", width: 46%, caption: [
  *Risk premium.* The certainty equivalent and the risk premium.
]) <fig-uncertainty-risk-premium>

#fig("/figures/uncertainty/risk_attitude.svg", width: 46%, caption: [
  *Risk attitude.* The more risk averse, the steeper the indifference curves.
]) <fig-uncertainty-risk-attitude>

#fig("/figures/uncertainty/risk_return_choice.svg", width: 46%, caption: [
  *Risk-return choice.* The indifference curve touches the risk-return line.
]) <fig-uncertainty-risk-return-choice>

#fig("/figures/uncertainty/risk_return_two_investors.svg", width: 46%, caption: [
  *Two investors.* Investors with different risk aversion pick different tangencies.
]) <fig-uncertainty-risk-return-two-investors>

#fig("/figures/uncertainty/state_claims_fair.svg", width: 46%, caption: [
  *State claims, fair premium.* At a fair premium the consumer chooses full insurance, equal income in both states.
]) <fig-uncertainty-state-claims-fair>

#fig("/figures/uncertainty/state_claims_unfair.svg", width: 46%, caption: [
  *State claims, unfair premium.* At an unfair premium the consumer buys only partial insurance.
]) <fig-uncertainty-state-claims-unfair>

#fig("/figures/uncertainty/first_order_dominance.svg", width: 46%, caption: [
  *First-order dominance.* One CDF lies everywhere below the other: first-order dominance.
]) <fig-uncertainty-first-order-dominance>

#fig("/figures/uncertainty/second_order_dominance.svg", width: 46%, caption: [
  *Second-order dominance.* With equal means the less spread lottery dominates at second order.
]) <fig-uncertainty-second-order-dominance>

#fig("/figures/uncertainty/mean_variance_frontier.svg", width: 46%, caption: [
  *Mean-variance frontier.* The efficient frontier of two assets and its inefficient part.
]) <fig-uncertainty-mean-variance-frontier>

#fig("/figures/uncertainty/risk_return_borrowing.svg", width: 46%, caption: [
  *Borrowing.* Borrowing allows more risk than the market portfolio.
]) <fig-uncertainty-risk-return-borrowing>

== Auctions <sec-ex-auctions>

First- and second-price sealed-bid auctions with independent uniform values: the bid functions and revenue equivalence. Sources: #citet(<vickrey1961>).

#block(breakable: false)[
#api(("Auction",), syntax: [
  ```python
  Auction(bidders, max_value=1.0)
  ```
])[
  `Auction` gives the bid at a value and the expected revenue under both formats.
]
]

#block(breakable: false)[
#api(("bid_functions_canvas",), syntax: [
  ```python
  bid_functions_canvas(auctions, **options)
  ```
])[
  Bid against value: the 45-degree second-price bid `b = v` and, for each auction in `auctions`, the first-price bid `b = (n - 1) v / n` below it (the gap is the shading, smaller with more bidders).
]
]

#block(breakable: false)[
#api(("revenue_equivalence_canvas",), syntax: [
  ```python
  revenue_equivalence_canvas(bidders, max_value=1.0, **options)
  ```
])[
  Expected seller revenue against the number of bidders under both formats: the curves coincide (revenue equivalence), rising toward the largest possible value.
]
]

The function of the script that draws the figures follows.

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

#fig("/figures/auctions/bid_functions.svg", width: 46%, caption: [
  *Bid functions.* The second-price bid equals value; the first-price bid is below value.
]) <fig-auctions-bid-functions>

#fig("/figures/auctions/bid_functions_by_bidders.svg", width: 46%, caption: [
  *Bid shading.* With more bidders the first-price bid is closer to value.
]) <fig-auctions-bid-functions-by-bidders>

#fig("/figures/auctions/revenue_equivalence.svg", width: 46%, caption: [
  *Revenue equivalence.* Both formats give the same expected revenue, rising with the number of bidders.
]) <fig-auctions-revenue-equivalence>

== Information <sec-ex-information>

Adverse selection, signalling, moral hazard, incentive-compatible bonuses and efficiency wages. Sources: #citet(<akerlof1970>), #citet(<spence1973>), #citet(<shapirostiglitz1984>).

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
  Each model solves one asymmetric-information case; `Signaling` has a separating and a pooling signal.
]
]

#block(breakable: false)[
#api(("bonus_schedule_canvas",), syntax: [
  ```python
  bonus_schedule_canvas(schedule, capacities, reach, **options)
  ```
])[
  Bonus against the reported plant size `R` for each true capacity: every schedule peaks where the report equals the capacity, so truthful reporting is incentive compatible.
]
]

#block(breakable: false)[
#api(("efficiency_wage_canvas",), syntax: [
  ```python
  efficiency_wage_canvas(model, **options)
  ```
])[
  Labor demand `D`, supply `S` and the no-shirking constraint `NSC`: equilibrium is where `NSC` meets `D`, at a wage above the competitive one, so `L_s - L*` workers are unemployed.
]
]

#block(breakable: false)[
#api(("lemons_market_canvas",), syntax: [
  ```python
  lemons_market_canvas(market, shares, **options)
  ```
])[
  One panel per high-quality share: demands for high (`D_H`) and low (`D_L`) quality, the sellers' reservation lines `S_H` and `S_L` and the demand `D` of buyers who cannot tell them apart. When `D` starts below `S_H` high quality is driven out.
]
]

#block(breakable: false)[
#api(("moral_hazard_canvas",), syntax: [
  ```python
  moral_hazard_canvas(hazard, **options)
  ```
])[
  Demand `D` against the true marginal cost `MC` and the lower price `MC'` an insured patient faces: use rises from `Q_e` to `Q_i` and the triangle between is the loss.
]
]

#block(breakable: false)[
#api(("signaling_canvas",), syntax: [
  ```python
  signaling_canvas(signaling, signal=None, **options)
  ```
])[
  Education cost against the wage benefit for the low-ability group (left) and the high-ability group (right): at a separating signal `y*` only the high group's cost lies below the benefit.
]
]

The function of the script that draws the figures follows.

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

#fig("/figures/information/pooling.svg", width: 46%, caption: [
  *Pooling signal.* When the signal is cheap both types buy it, a pooling equilibrium.
]) <fig-information-pooling>

#fig("/figures/information/lemons.svg", width: 46%, caption: [
  *Lemons market.* When the share of high quality is too low, it is driven out of the market.
]) <fig-information-lemons>

#fig("/figures/information/signaling.svg", width: 46%, caption: [
  *Signaling.* At a separating signal only the high-ability type buys it.
]) <fig-information-signaling>

#fig("/figures/information/moral_hazard.svg", width: 46%, caption: [
  *Moral hazard.* Insurance lowers the price and causes overuse.
]) <fig-information-moral-hazard>

#fig("/figures/information/bonus_schedule.svg", width: 46%, caption: [
  *Bonus schedule.* The bonus is largest when the report is truthful: incentive compatible.
]) <fig-information-bonus-schedule>

#fig("/figures/information/efficiency_wage.svg", width: 46%, caption: [
  *Efficiency wage.* The no-shirking condition puts the wage above equilibrium and creates unemployment.
]) <fig-information-efficiency-wage>

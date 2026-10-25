#import "/template/manual.typ": *


= Oligopoly and vertical chains <sec-oligopoly>

A few firms, and firms at different stages of one chain.

Each section is one example script and the figures it draws. The scripts come in the archive of this manual; `--help` lists their arguments.

== Duopoly <sec-ex-oligopoly>

Reaction curves in output and in price give the Cournot, Stackelberg, Bertrand and collusive outcomes. Sources: #citet(<cournot1838>), #citet(<stackelberg1934>), #citet(<bertrand1883>).

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
  `Duopoly` has `cournot()`, `stackelberg()`, `competitive_total()` and `collusive_total()`; `DifferentiatedDuopoly` has `bertrand()` for price competition.
]
]

#block(breakable: false)[
#api(("price_reaction_canvas",), syntax: [
  ```python
  price_reaction_canvas(duopoly, *, collusive=True, **options)
  ```
])[
  Upward-sloping price reaction curves `R1` and `R2` in `(p1, p2)` space, the Nash prices `N` and (optionally) the joint-profit-maximising prices `M`.
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
  Reaction curves `R1` and `R2` in `(Q1, Q2)` space meeting at the Cournot-Nash point `N`. `competitive` and `collusive` add the constant-total-output lines and their symmetric points `C` and `M`; `leader` adds the Stackelberg point `S`.
]
]

#block(breakable: false)[
#api(("residual_demand_canvas",), syntax: [
  ```python
  residual_demand_canvas(duopoly, guesses, **options)
  ```
])[
  Firm 1's residual demand `D1(q2)` and `MR1(q2)` for each guess of the rival's output, with its marginal cost. Each guess shifts both curves left by `q2`.
]
]

The function of the script that draws the figures follows.

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

#fig("/figures/oligopoly/residual_demand.svg", width: 46%, caption: [
  *Residual demand.* Residual demand and marginal revenue for each guess of the rival's output.
]) <fig-oligopoly-residual-demand>

#fig("/figures/oligopoly/cournot.svg", width: 46%, caption: [
  *Reaction curves.* The reaction curves meet at the Cournot equilibrium N.
]) <fig-oligopoly-cournot>

#fig("/figures/oligopoly/cournot_points.svg", width: 46%, caption: [
  *Competitive, Cournot and collusive.* The competitive, Cournot and collusive points, and the collusion line.
]) <fig-oligopoly-cournot-points>

#fig("/figures/oligopoly/stackelberg.svg", width: 46%, caption: [
  *Stackelberg.* The leader picks output along the follower's reaction curve.
]) <fig-oligopoly-stackelberg>

#fig("/figures/oligopoly/price_reaction.svg", width: 46%, caption: [
  *Price reaction curves.* Price reaction curves of differentiated products, with the Nash and collusive prices.
]) <fig-oligopoly-price-reaction>

== Kinked demand, dominant firm and cartel <sec-ex-dominant-firm>

Rivals that follow price cuts but not rises give a kink; a firm with a competitive fringe faces the residual demand. Sources: #citet(<sweezy1939>).

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
  `KinkedDemand` gives the kink and the gap in marginal revenue; `DominantFirm` solves the residual demand against a competitive fringe.
]
]

#block(breakable: false)[
#api(("cartel_elasticity_canvas",), syntax: [
  ```python
  cartel_elasticity_canvas(inelastic, elastic, **options)
  ```
])[
  The cartel-with-fringe diagram for inelastic demand beside elastic demand (little market power).
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
  Market demand `D`, fringe supply `S_F` and the residual demand `D_D = D - S_F` with its marginal revenue and the firm's marginal cost; the firm sets `MR = MC` and the fringe supplies the rest at the same price. `cartel` switches the names to the cartel's.
]
]

#block(breakable: false)[
#api(("kinked_demand_canvas",), syntax: [
  ```python
  kinked_demand_canvas(kinked, marginal_costs, **options)
  ```
])[
  Kinked demand and its marginal revenue with the vertical gap at the kink. Each marginal cost in `marginal_costs` is drawn flat; the first is the thick curve and the rest thin and solid. Those inside the gap leave price and quantity at the kink.
]
]

The function of the script that draws the figures follows.

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

#fig("/figures/dominant_firm/kinked_demand.svg", width: 46%, caption: [
  *Kinked demand.* Kinked demand and the gap in MR; MC changes within the gap leave the price unchanged.
]) <fig-dominant-firm-kinked-demand>

#fig("/figures/dominant_firm/dominant_firm.svg", width: 46%, caption: [
  *Dominant firm.* Market demand less fringe supply is the dominant firm's residual demand.
]) <fig-dominant-firm-dominant-firm>

#fig("/figures/dominant_firm/cartel_fringe.svg", width: 46%, caption: [
  *Cartel with a competitive fringe.* The cartel faces total demand less the fringe's supply.
]) <fig-dominant-firm-cartel-fringe>

#fig("/figures/dominant_firm/cartel_elasticity.svg", width: 46%, caption: [
  *Cartel, inelastic and elastic demand.* The more elastic demand is, the less market power the cartel has.
]) <fig-dominant-firm-cartel-elasticity>

== Vertical chains <sec-ex-vertical>

Two stacked monopolies mark up twice. An integrated firm sets one margin; an outside market fixes the transfer price. Sources: #citet(<spengler1950>).

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
  `VerticalChain` solves the stacked and the integrated outcome; `transfer_pricing()` gives the optimal transfer price when an outside market exists.
]
]

#block(breakable: false)[
#api(("double_marginalization_canvas",), syntax: [
  ```python
  double_marginalization_canvas(chain, **options)
  ```
])[
  Two stacked monopolies: `D` (final demand), `NMR` (the upstream firm's demand), the upstream marginal revenue `MR_u` and `MC_u`. Quantity `Q_s` is set where `MR_u = MC_u`; the transfer price `W_s` is read on `NMR` and the final price `p_s` on `D`.
]
]

#block(breakable: false)[
#api(("integrated_firm_canvas",), syntax: [
  ```python
  integrated_firm_canvas(chain, **options)
  ```
])[
  An integrated firm sets `NMR = MC_u`: output `Q_i` exceeds the stacked output `Q_s` (drawn as a mark) and the final price `p_i` is lower.
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
  With an outside market at `P_m` the firm's effective marginal cost is `MC_u` up to the quantity `Q_u` where it meets `P_m` and flat at `P_m` beyond (`kinked`); without it, the figure shows the optimal transfer price `P_m` with downstream use `Q_d` and the surplus `Q_u - Q_d` sold outside.
]
]

The function of the script that draws the figures follows.

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

#fig("/figures/vertical/double_marginalization.svg", width: 46%, caption: [
  *Double marginalization.* Downstream NMR is the upstream demand; two markups make output lower.
]) <fig-vertical-double-marginalization>

#fig("/figures/vertical/integrated_firm.svg", width: 46%, caption: [
  *Integrated firm.* The integrated firm sets NMR = upstream MC: more output at a lower price.
]) <fig-vertical-integrated-firm>

#fig("/figures/vertical/transfer_kinked.svg", width: 46%, caption: [
  *Transfer price, kinked MC.* With an outside market MC kinks at the market price.
]) <fig-vertical-transfer-kinked>

#fig("/figures/vertical/transfer_price.svg", width: 46%, caption: [
  *Optimal transfer price.* The optimal internal transfer price is the market price; the rest is sold outside.
]) <fig-vertical-transfer-price>

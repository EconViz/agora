#import "/template/manual.typ": *

= Command-line interface <sec-cli>

#changed("0.1.0", label: "principle-viz")[Command-line interface with JSON output]

The `principle-viz` command runs the calculations of this manual from the
shell and prints the result as JSON; `--output` also writes it to a file. It
draws no figures. Install it as a tool (@sec-install-cli), or prefix each
command with `uv run` inside a project.

```bash
principle-viz equilibrium \
  --demand-intercept 10 --demand-slope -1 \
  --supply-intercept 2 --supply-slope 1
```

```text
{
  "q_star": 4.0,
  "p_star": 6.0,
  "is_valid_market": true,
  "notes": []
}
```

== Market arguments

Most commands describe the market by two lines in inverse form,
$p = a + b Q$:

#param("--demand-intercept")[Price intercept $a$ of demand.]
#param("--demand-slope")[Slope $b$ of demand.]
#param("--supply-intercept")[Price intercept $a$ of supply.]
#param("--supply-slope")[Slope $b$ of supply.]
#param("--output")[Also write the JSON to this file, creating its directory.]

== Commands

#tbl(caption: [CLI commands])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([Command], [Calculation and extra options], [Section]),
    [`equilibrium`], [Linear equilibrium], [#ref(<sec-markets>)],
    [`shift`], [Comparative statics: #box[`--demand-delta-intercept`], #box[`--demand-delta-slope`], #box[`--supply-delta-intercept`], #box[`--supply-delta-slope`]], [#ref(<sec-shifts>)],
    [`discrete`], [Discrete market: #box[`--demand-values`], #box[`--supply-values`], #box[`--price-rule {midpoint,lower,upper}`]], [#ref(<sec-discrete>)],
    [`elasticity`], [Point elasticity: #box[`--intercept`], #box[`--slope`], #box[`--quantity`]; arc elasticity with #box[`--q1`], #box[`--p1`]], [#ref(<sec-elasticity>)],
    [`revenue`], [Elasticity and revenue schedule: #box[`--samples`]], [#ref(<sec-elasticity>)],
    [`welfare`], [Surplus: #box[`--policy {baseline,tax,subsidy,control}`] with the options of that policy], [#ref(<sec-welfare>)],
    [`report-dwl`], [One-row DWL report: #box[`--policy {tax,subsidy,control}`], #box[`--csv`]], [#ref(<sec-welfare>)],
    [`tax`], [#box[`--tax-type {fixed,per_unit,ad_valorem}`], #box[`--amount`], #box[`--tax-on {consumer,producer}`]], [#ref(<sec-taxes>)],
    [`subsidy`], [#box[`--amount`], #box[`--subsidy-to {consumer,producer}`]], [#ref(<sec-taxes>)],
    [`controls`], [#box[`--control-type {ceiling,floor}`], #box[`--control-price`]], [#ref(<sec-controls>)],
    [`trade`], [#box[`--world-price`], #box[`--tariff`], #box[`--import-quota`], #box[`--quota-rent-recipient`]], [#ref(<sec-trade>)],
    [`externality`], [#box[`--external-cost`], #box[`--external-benefit`]], [#ref(<sec-failures>)],
    [`common-resource`], [#box[`--congestion-cost`]], [#ref(<sec-failures>)],
    [`public-good`], [#box[`--benefit-intercepts`], #box[`--benefit-slopes`], #box[`--cost-intercept`], #box[`--cost-slope`], #box[`--samples`]], [#ref(<sec-failures>)],
    [`minimum-wage`], [#box[`--labor-demand-*`], #box[`--labor-supply-*`], #box[`--minimum-wage`]], [#ref(<sec-factor>)],
    [`loanable-funds`], [#box[`--savings-*`], #box[`--investment-*`], #box[`--savings-shift`], #box[`--investment-shift`], #box[`--government-borrowing`]], [#ref(<sec-factor>)],
    [`ppf`], [#box[`--x-intercept`], #box[`--y-intercept`], #box[`--curvature`], #box[`--x-good`], #box[`--y-good`], #box[`--x-growth`], #box[`--y-growth`], #box[`--samples`]], [#ref(<sec-ppf>)],
  )
] <tab-cli>

`principle-viz <command> --help` lists every option of a command.

```bash
principle-viz tax \
  --demand-intercept 10 --demand-slope -1 \
  --supply-intercept 2 --supply-slope 1 \
  --tax-type per_unit --amount 1 --tax-on producer
```

The output holds the untaxed equilibrium (`baseline_equilibrium`), the taxed
one (`post_tax`) and the changes, as `compare_tax_scenario()` returns them:
here a quantity of 3.5, a consumer price of 6.5 and a producer price of 5.5.

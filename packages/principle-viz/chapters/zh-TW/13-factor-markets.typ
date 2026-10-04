#import "/template/manual.typ": *

= 勞動與可貸資金 <sec-factor>

== 最低工資

#changed("0.10.0", label: "MarketFigure.add_minimum_wage")[以價格下限的方式繪製："Minimum wage" 線、$w_min$、$L_d$ / $L_s$ 與 "Unemployment" 括號]

#api(("analyze_minimum_wage",), syntax: [
  #raw("analyze_minimum_wage(")#meta("demand")#raw(", ")#meta("supply")#raw(", minimum_wage)")
])[
  設有工資下限的競爭勞動市場。`MinimumWageResult` 包含 `equilibrium`、`minimum_wage`、`is_binding`、`labor_demanded`、`labor_supplied`、`employment`（兩者中較小者）、`unemployment`（兩者之差）與 `wage_bill`。
]

```python
from principle_viz import analyze_minimum_wage

labor_demand = line_from_inverse(12, -1)
labor_supply = line_from_inverse(2, 1)
labor = analyze_minimum_wage(labor_demand, labor_supply, minimum_wage=9)
print(labor.employment, labor.unemployment)   # 3.0 4.0
```

#api(("MarketFigure.add_minimum_wage",), syntax: [
  #raw("add_minimum_wage(")#meta("result")#raw(", *, gap_brace=\"line\")")
])[
  以價格下限的方式繪製工資下限（詳見#ref(<sec-controls>)）："Minimum wage" 線、工資軸上的 $w_min$，有約束時另標出 $L_d$ 與 $L_s$ 及 "Unemployment" 括號。座標軸命名為 $L$ 與 $w$，曲線命名為 $D_L$ 與 $S_L$：
]

```python
fig = MarketFigure(x_max=11, y_max=14, x_label="L", y_label="w")
fig.add_curves(labor_demand, labor_supply, q_max=10, demand_label="$D_L$", supply_label="$S_L$")
fig.add_minimum_wage(labor)
```

#fig("/figures/factor/minimum_wage.svg", width: 46%, caption: [
  有約束的最低工資。
])

== 可貸資金

#api(("LoanableFundsScenario",), syntax: [
  #raw("LoanableFundsScenario(savings_quantity_shift=0.0, investment_quantity_shift=0.0, government_borrowing=0.0)")
])[
  儲蓄（供給）與投資（需求）以數量衡量的水平移動。政府借款（不得為負）加入可貸資金的需求。
]

#api(("analyze_loanable_funds",), syntax: [
  #raw("analyze_loanable_funds(")#meta("savings")#raw(", ")#meta("investment")#raw(", ")#meta("scenario")#raw(")")
])[
  移動前後的可貸資金市場：`baseline_equilibrium`、`shifted_equilibrium`、`shifted_savings`、`shifted_investment_demand`、`private_investment_after`、`interest_rate_change`，以及 `crowding_out`，即利率上升所排擠的民間投資。
]

```python
from principle_viz import LoanableFundsScenario, analyze_loanable_funds

savings = line_from_inverse(2, 0.5)
investment = line_from_inverse(12, -0.5)
funds = analyze_loanable_funds(savings, investment, LoanableFundsScenario(government_borrowing=4))
print(funds.interest_rate_change, funds.crowding_out)   # 1.0 2.0
```

政府借款 4 使利率由 7 升到 8；民間投資由 10 降到 8，借款中有一半排擠了民間投資。

#api(("MarketFigure.add_loanable_funds",), syntax: [
  #raw("add_loanable_funds(")#meta("result")#raw(")")
])[
  畫出移動後的曲線並命名為 $D_1$ 或 $S_1$，以及兩個均衡點與其間的移動。價格軸命名為 $r$。
]

#fig("/figures/factor/loanable_funds.svg", width: 46%, caption: [
  政府借款排擠民間投資。
])

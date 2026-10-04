#import "/template/manual.typ": *

= 线性市场 <sec-markets>

== 直线

#api(("Line",), syntax: [
  #raw("Line.from_inverse(")#meta("float")#raw(", ")#meta("float")#raw(")") \
  #raw("Line.from_standard(")#meta("float")#raw(", ")#meta("float")#raw(", ")#meta("float")#raw(")")
])[
  价格—数量平面上的直线，内部保存为 $A p + B Q + C = 0$，因此也能表示水平线与垂直线。`from_inverse(a, b)` 创建 $p = a + b Q$；`from_standard(A, B, C)` 创建 $A p + B Q + C = 0$。软件包根目录另外以 `line_from_inverse()` 与 `line_from_standard()` 提供这两个构造函数。
]

#param("p_at(q)")[数量 $q$ 时的价格。]
#param("q_at(p)")[价格 $p$ 时的数量。]
#param("p_intercept()")[$Q = 0$ 时的价格（需求曲线的窒息价格）。]
#param("q_intercept()")[$p = 0$ 时的数量。]
#param("slope()")[$dif p slash dif Q$。]
#param("to_inverse()")[$p = a + b Q$ 的 `(a, b)`。]
#param("shifted(delta_intercept, delta_slope)")[截距与斜率分别加上 $Delta a$ 与 $Delta b$ 后的新直线。]

```python
from principle_viz import line_from_inverse, line_from_standard

demand = line_from_inverse(10.0, -1.0)
print(demand.q_at(4), demand.p_at(3))         # 6.0 7.0
print(demand.p_intercept(), demand.q_intercept())  # 10.0 10.0
print(line_from_standard(1, 1, -10).to_inverse())  # (10.0, -1.0)
```

水平线没有 $Q(p)$，垂直线没有 $p(Q)$；调用对应的方法会抛出 `NonInvertibleLineError`。

== 均衡

#api(("solve_equilibrium",), syntax: [
  #raw("solve_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(")")
])[
  两条直线的交点，返回 `EquilibriumResult`（详见#ref(<sec-quickstart>)）。两线平行时抛出 `ParallelLinesError`，重合时抛出 `CoincidentLinesError`。
]

```python
from principle_viz import solve_equilibrium

eq = solve_equilibrium(demand, line_from_inverse(2.0, 1.0))
print(eq)
# EquilibriumResult(q_star=4.0, p_star=6.0, is_valid_market=True, notes=())
```

== 比较静态 <sec-shifts>

#changed("0.10.0", label: "add_comparative_statics")[只重画移动的曲线；移动后的曲线命名为 $D_1$ / $S_1$（`demand_label` / `supply_label`）]
#changed("0.10.0", label: "add_comparative_statics")[移动箭头改为黑色细虚线]

#api(("ShiftSpec", "ShiftScenario"), syntax: [
  #raw("ShiftSpec(delta_intercept=0.0, delta_slope=0.0)") \
  #raw("ShiftScenario(demand_shift=None, supply_shift=None)")
])[
  以反函数形式描述一条曲线的移动：`delta_intercept` 为正时向上平移、为负时向下，`delta_slope` 旋转曲线。情景可同时移动需求、供给或两者。两者都位于 `principle_viz.core.shifts`。

  需求增加使需求截距上升；供给增加则使供给截距*下降*，因为卖方在每个数量下都愿意接受较低的价格。
]

#api(("comparative_statics",), syntax: [
  #raw("comparative_statics(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  求解移动前后的市场，结果包含下列字段：
]

#param("baseline_equilibrium, shifted_equilibrium")[移动前后的两个 `EquilibriumResult`。]
#param("shifted_market")[移动前后的直线（`baseline_demand`、`shifted_demand` 等）。]
#param("delta_q, delta_p")[数量与价格的变动。]
#param("direction_q, direction_p")[`"left"`／`"right"` 与 `"up"`／`"down"`（未变动时为 `"none"`）。]

```python
from principle_viz import comparative_statics
from principle_viz.core.shifts import ShiftScenario, ShiftSpec

up = ShiftScenario(demand_shift=ShiftSpec(delta_intercept=3.0))
result = comparative_statics(demand, supply, up)
print(result.shifted_equilibrium.q_star, result.shifted_equilibrium.p_star)  # 5.5 7.5
print(result.direction_q, result.direction_p)                               # right up
```

#api(("MarketFigure.add_comparative_statics",), syntax: [
  #raw("add_comparative_statics(")#meta("result")#raw(", q_max, *, demand_label=\"$D_1$\", supply_label=\"$S_1$\")")
])[
  画出移动的曲线、两个均衡点，以及由旧均衡指向新均衡的虚线箭头。在 `add_curves()` 中将原曲线命名为 $D_0$ 与 $S_0$，读者便能对照前后（参见#ref(<fig-shifts>)）。
]

```python
fig = MarketFigure(x_max=12, y_max=14, title="Increase in Demand")
fig.add_curves(demand, supply, q_max=10, demand_label="$D_0$", supply_label="$S_0$")
fig.add_comparative_statics(result, q_max=10)
fig.finalize()
```

#fig("/figures/markets/shift_demand_increase.svg", width: 46%, caption: [
  需求增加。
]) <fig-shifts>

#fig("/figures/markets/shift_supply_decrease.svg", width: 46%, caption: [
  供给减少。
])

== 异常 <sec-errors>

软件包抛出的所有异常都继承自 `principle_viz.exceptions` 中的 `PrincipleVizError`，捕获它即可一并处理。0.10.0 版以前的名称 `PrincipleEconError` 是同一个类。

#tbl(caption: [异常类])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([异常], [抛出时机]),
    [`LineError`], [无法创建或转换直线],
    [`NonInvertibleLineError`], [对水平线求 $Q(p)$，或对垂直线求 $p(Q)$],
    [`ParallelLinesError`], [需求与供给没有交点],
    [`CoincidentLinesError`], [需求与供给是同一条直线],
    [`PolicyError`], [税收、补贴、价格管制或贸易情景无效],
    [`DiscreteMarketError`], [离散逐单位表无效（详见#ref(<sec-discrete>)）],
    [`AggregationError`、`PiecewiseLinearError`], [个人曲线无法加总，或价格超出分段曲线范围（详见#ref(<sec-aggregation>)）],
    [`PPFError`], [生产可能性曲线无效（详见#ref(<sec-ppf>)）],
  )
]

#import "/template/manual.typ": *

= 生产可能性曲线 <sec-ppf>

#api(("ProductionPossibilitiesFrontier",), syntax: [
  #raw("ProductionPossibilitiesFrontier(x_intercept, y_intercept, curvature=1.0, x_good=\"Good X\", y_good=\"Good Y\")")
])[
  通过截距 $X$ 与 $Y$ 的生产可能性曲线
  $ y = Y (1 - (x slash X)^c). $
  曲率 $c = 1$ 为直线（机会成本固定）；$c > 1$ 时曲线向外凸出（机会成本递增）。截距与曲率必须为正且 $c >= 1$，否则抛出 `PPFError`。
]

#param("y_at(x)")[第一种商品生产 $x$ 单位时 $y$ 的产量。]
#param("opportunity_cost_x(x)")[多生产一单位 $x$ 所放弃的 $y$，即 $abs(dif y slash dif x)$。]
#param("assess(x, y)")[返回 `PointStatus`：曲线上为 `EFFICIENT`，曲线内为 `INEFFICIENT`，曲线外为 `UNATTAINABLE`。]

```python
from principle_viz import ProductionPossibilitiesFrontier

ppf = ProductionPossibilitiesFrontier(10, 8, curvature=2,
                                      x_good="Consumer goods", y_good="Capital goods")
print(ppf.y_at(6), ppf.opportunity_cost_x(6))   # 5.12 0.96
print(ppf.assess(4, 3), ppf.assess(7, 6))       # PointStatus.INEFFICIENT PointStatus.UNATTAINABLE
```

#api(("analyze_ppf", "ppf_canvas"), syntax: [
  #raw("analyze_ppf(")#meta("frontier")#raw(", points=(), *, samples=101)") \
  #raw("ppf_canvas(")#meta("result")#raw(", *, theme=None, labels=None, visibility=None)")
])[
  在曲线上采样，并评估以 `(x, y, label)` 三元组给定的点；`principle_viz.visuals.ppf` 中的 `ppf_canvas()` 画出曲线、为可达成的区域填色并标出各点（参见#ref(<fig-ppf>)）。
]

```python
from principle_viz import analyze_ppf
from principle_viz.visuals.ppf import ppf_canvas

result = analyze_ppf(ppf, points=((6, ppf.y_at(6), "A"), (4, 3, "B"), (7, 6, "C")))
ppf_canvas(result).save("ppf_points.png")
```

#fig("/figures/ppf/points.svg", width: 46%, caption: [
  有效率、无效率与无法达成的点。
]) <fig-ppf>

#api(("PPFGrowthScenario", "analyze_ppf_growth", "ppf_growth_canvas"), syntax: [
  #raw("PPFGrowthScenario(x_growth_rate=0.0, y_growth_rate=0.0)") \
  #raw("analyze_ppf_growth(")#meta("frontier")#raw(", ")#meta("scenario")#raw(", *, samples=101)")
])[
  经济成长使各截距乘以一加上对应的成长率；结果包含 `baseline` 与 `shifted` 两条曲线及其采样点。`ppf_growth_canvas()` 画出两条曲线并命名为 $P P F_0$ 与 $P P F_1$。
]

#fig("/figures/ppf/growth.svg", width: 46%, caption: [
  消费品成长 20%、资本品成长 10%。
])

== 比较优势

#api(("compare_linear_ppfs",), syntax: [
  #raw("compare_linear_ppfs(name_a, frontier_a, name_b, frontier_b)")
])[
  比较两条直线型生产可能性曲线：各生产者生产 $x$ 的机会成本，以及各商品的比较优势归属（成本相同时为 `"tie"`）。曲线型的生产可能性曲线会抛出 `PPFError`。
]

```python
from principle_viz import compare_linear_ppfs

ann = ProductionPossibilitiesFrontier(10, 5)   # 1 unit of x costs 0.5 y
bob = ProductionPossibilitiesFrontier(6, 6)    # 1 unit of x costs 1 y
result = compare_linear_ppfs("Ann", ann, "Bob", bob)
print(result.comparative_advantage_x, result.comparative_advantage_y)   # Ann Bob
```

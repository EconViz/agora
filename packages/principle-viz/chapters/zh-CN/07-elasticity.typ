#import "/template/manual.typ": *

= 弹性与总收益 <sec-elasticity>

== 价格弹性

#api(("compute_point_elasticity", "compute_arc_elasticity"), syntax: [
  #raw("compute_point_elasticity(")#meta("demand")#raw(", ")#meta("quantity")#raw(")") \
  #raw("compute_arc_elasticity(q0, p0, q1, p1)")
])[
  直线在某数量下的点价格弹性
  $ epsilon = (dif Q) / (dif p) dot p / Q, $
  以及两点之间的弧弹性（中点法）
  $ epsilon = (Delta Q slash overline(Q)) / (Delta p slash overline(p)), $
  其中 $overline(Q)$ 与 $overline(p)$ 为两点的平均值。负斜率需求的弹性皆为负值。
]

```python
from principle_viz import (
    compute_arc_elasticity, compute_point_elasticity, line_from_inverse,
)

demand = line_from_inverse(10.0, -1.0)
print(compute_point_elasticity(demand, 4))   # -1.5
print(compute_point_elasticity(demand, 5))   # -1.0 (unit elastic)
print(compute_arc_elasticity(4, 6, 6, 4))    # -1.0
```

$Q = 4$ 处弹性为 $-1.5$，绝对值大于 1，需求有弹性；$Q = 5$ 为单位弹性，也是 $p = 10 - Q$ 的中点。弧弹性以两点的平均值计算，因此由 $(4, 6)$ 到 $(6, 4)$ 与反方向的结果相同。
`principle_viz.core.elasticity` 中的 `classify_elasticity(value)` 依绝对值分类：大于 1 为 `"elastic"`，等于 1 为 `"unit_elastic"`，小于 1 为 `"inelastic"`。

== 总收益

#api(("elasticity_revenue_schedule",), syntax: [
  #raw("elasticity_revenue_schedule(")#meta("demand")#raw(", *, samples=101)")
])[
  在线性需求上由 $Q = 0$ 采样到阻绝数量，返回每一点的价格、总收益 $p Q$、弹性与其分类。总收益在单位弹性处（直线的中点）最大。
]

#param("points")[`RevenuePoint` 串行，含 `quantity`、`price`、`total_revenue`、`elasticity` 与 `classification`。]
#param("unit_elastic_quantity")[直线中点的数量。]
#param("unit_elastic_price")[直线中点的价格。]
#param("maximum_revenue")[该点的总收益。]
#param("choke_quantity")[数量轴截距。]
#param("choke_price")[价格轴截距。]

$p = 12 - Q$ 的总收益最大值为 36，位于 $Q = 6$、$p = 6$。

#api(("elasticity_revenue_canvases",), syntax: [
  #raw("elasticity_revenue_canvases(")#meta("demand")#raw(", ")#meta("result")#raw(", *, theme=None, labels=None, visibility=None)")
])[
  返回两张 #pkg("mosaickit") 画布，位于 `principle_viz.visuals.revenue`：一张是需求曲线，沿线标出 "Elastic"、"Unit elastic" 与 "Inelastic"，并标记单位弹性点；另一张是总收益对数量的曲线，标记最大值。两张画布各有标题。以 `mosaickit.CanvasGrid` 左右并排（参见#ref(<fig-revenue>)）。
]

```python
from mosaickit import CanvasGrid
from principle_viz import PlotTheme, elasticity_revenue_schedule
from principle_viz.visuals.revenue import (
    elasticity_revenue_canvases,
)

demand = line_from_inverse(12.0, -1.0)
schedule = elasticity_revenue_schedule(demand)
canvases = elasticity_revenue_canvases(
    demand, schedule, theme=PlotTheme(),
)
CanvasGrid(canvases, rows=1).save("elasticity_total_revenue.png")
```

输出参见#ref(<fig-revenue>)。

#fig("/figures/elasticity/revenue.svg", width: 100%, caption: [
  需求曲在线的弹性与总收益。
]) <fig-revenue>

#import "/template/manual.typ": *

= 彈性與總收益 <sec-elasticity>

== 價格彈性

#api(("compute_point_elasticity", "compute_arc_elasticity"), syntax: [
  #raw("compute_point_elasticity(")#meta("demand")#raw(", ")#meta("quantity")#raw(")") \
  #raw("compute_arc_elasticity(q0, p0, q1, p1)")
])[
  直線在某數量下的點價格彈性
  $ epsilon = (dif Q) / (dif p) dot p / Q, $
  以及兩點之間的弧彈性（中點法）
  $ epsilon = (Delta Q slash overline(Q)) / (Delta p slash overline(p)), $
  其中 $overline(Q)$ 與 $overline(p)$ 為兩點的平均值。負斜率需求的彈性皆為負值。
]

```python
from principle_viz import compute_arc_elasticity, compute_point_elasticity, line_from_inverse

demand = line_from_inverse(10.0, -1.0)
print(compute_point_elasticity(demand, 4))   # -1.5
print(compute_point_elasticity(demand, 5))   # -1.0 (unit elastic)
print(compute_arc_elasticity(4, 6, 6, 4))    # -1.0
```

`principle_viz.core.elasticity` 中的 `classify_elasticity(value)` 依絕對值分類：大於 1 為 `"elastic"`，等於 1 為 `"unit_elastic"`，小於 1 為 `"inelastic"`。

== 總收益

#api(("elasticity_revenue_schedule",), syntax: [
  #raw("elasticity_revenue_schedule(")#meta("demand")#raw(", *, samples=101)")
])[
  在線性需求上由 $Q = 0$ 取樣到阻絕數量，回傳每一點的價格、總收益 $p Q$、彈性與其分類。總收益在單位彈性處達到最大，也就是直線的中點。
]

#param("points")[`RevenuePoint` 序列，含 `quantity`、`price`、`total_revenue`、`elasticity` 與 `classification`。]
#param("unit_elastic_quantity, unit_elastic_price")[直線的中點。]
#param("maximum_revenue")[該點的總收益。]
#param("choke_quantity, choke_price")[兩個截距。]

以 $p = 12 - Q$ 為例，總收益在 $Q = 6$、$p = 6$ 達到最大值 $36$。

#api(("elasticity_revenue_canvases",), syntax: [
  #raw("elasticity_revenue_canvases(")#meta("demand")#raw(", ")#meta("result")#raw(", *, theme=None, labels=None, visibility=None)")
])[
  回傳兩張 #pkg("mosaickit") 畫布，位於 `principle_viz.visuals.revenue`：一張是需求曲線，沿線標出 "Elastic"、"Unit elastic" 與 "Inelastic"，並標記單位彈性點；另一張是總收益對數量的曲線，標記最大值。兩張畫布各有標題。以 `mosaickit.CanvasGrid` 左右並排（參見#ref(<fig-revenue>)）。
]

```python
from mosaickit import CanvasGrid
from principle_viz import PlotTheme, elasticity_revenue_schedule
from principle_viz.visuals.revenue import elasticity_revenue_canvases

demand = line_from_inverse(12.0, -1.0)
schedule = elasticity_revenue_schedule(demand)
canvases = elasticity_revenue_canvases(demand, schedule, theme=PlotTheme())
CanvasGrid(canvases, rows=1).save("elasticity_total_revenue.png")
```

#fig("/figures/elasticity/revenue.svg", width: 100%, caption: [
  需求曲線上的彈性與總收益。
]) <fig-revenue>

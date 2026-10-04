#import "/template/manual.typ": *

= 等值线 <sec-implicit>

无差异曲线、等产量曲线与等高线，都是二元函数的等值集。

#definition(name: [等值集])[
  对 $F: RR^2 -> RR$ 与水准 $c in RR$，等值集为
  $ L_c = {(x, y) : F(x, y) = c}. $
] <def-level-set>

`trace_implicit` 不需解出 $y$ 就能把等值集转为三次路径，因此可以处理会折返、闭合或分成数段的曲线。

#api(("trace_implicit",), syntax: [
  #raw("trace_implicit(")#meta("function")#raw(", *, levels, viewport, resolution=(101, 101), tolerance=1e-2, gradient=None)")
])[
  在矩形 `viewport` $= (x_min, x_max, y_min, y_max)$ 内，描绘每个水准 $c$ 的 $F(x, y) = c$，位于 `bezierkit.implicit`。
]

#param("function")[$F$，以两个浮点数调用；在每个网格点都必须为有限值，否则抛出 `ValueError`。]
#param("levels")[单一水准，或由有限水准值组成的可迭代对象。]
#param("resolution", type: "(int, int)", default: "(101, 101)")[沿 $x$ 与 $y$ 的网格点数，各至少 2。]
#param("tolerance", type: "float", default: "1e-2")[简化与弯曲线段的容许偏差，单位同坐标。]
#param("gradient", type: "callable | None", default: "None")[$nabla F = (F_x, F_y)$，以 tuple 或 `Vector` 返回。提供时，直线段会弯成沿曲线切线方向的三次曲线。]

== 算法

+ *采样。*在 viewport 的规则网格上计算 $F$。
+ *行进。*在每个网格单元中标出 $F >= c$ 的角点。两端标记不同的边与等值集相交，交点即#ref(<def-crossing>)所定义的点 #citep(<lorensen1987>)。有两个交点的单元贡献一条线段。有四个交点的单元是鞍点，由四个角点值的平均决定如何连接（参见#ref(<fig-saddle>)）。
+ *缝合。*把端点相同的线段串成链。回到起点的链是闭合的；抵达 viewport 边界或分支点的链是开放的。互不相连的部分保持为不同的路径。
+ *简化。*以 `tolerance` 对每条链调用 `fit_polyline`（详见#ref(<sec-fitting>)），不保留转角。
+ *弯曲*（提供 `gradient` 时）。把每条直线段换成端点切线沿等值集方向的三次曲线（详见#ref(<thm-gradient>)），控制柄长为弦长的三分之一。只有当三次曲线与弦的距离不超过 `tolerance` 时才采用；任一端 $nabla F = 0$ 时维持直线。

#definition(name: [边上的交点])[
  设网格的一条边由 $p$ 到 $q$，且 $F(p) >= c > F(q)$ 或 $F(q) >= c > F(p)$。其交点为 $p + lambda (q - p)$，其中
  $ lambda = (c - F(p)) / (F(q) - F(p)), $
  即 $F - c$ 沿该边的线性插值之零点。
] <def-crossing>

#fig("/figures/implicit/saddle.pdf", width: auto, caption: [
  鞍点单元：(a) 中心高、(b) 中心低。
]) <fig-saddle>

#ref(<fig-saddle>)中实心角点代表 $F >= c$。

#theorem(name: [等值集的切线])[
  设 $F$ 在点 $p$ 附近连续可微，$F(p) = c$ 且 $nabla F(p) != 0$。则在 $p$ 附近等值集 $F = c$ 是一条 $C^1$ 曲线，其在 $p$ 的切线平行于 $(F_y(p), -F_x(p))$。
] <thm-gradient>

切线 $(F_y, -F_x)$ 不需除法，因此垂直切线（$F_y = 0$）与其他情况一样容易处理；图形形式的斜率 $dif y slash dif x = -F_x slash F_y$ 在该处则为无穷大。

```python
from bezierkit.implicit import trace_implicit

contours = trace_implicit(
    lambda x, y: x**2 * y,
    levels=[1, 2, 4],
    viewport=(0.5, 4, 0, 6),
    resolution=(121, 121),
    tolerance=0.01,
    gradient=lambda x, y: (2 * x * y, x**2),
)
print(contours.level_values)                     # (1.0, 2.0, 4.0)
print(len(contours.for_level(4)[0].segments))    # 15
```

#fig("/figures/implicit/contours.pdf", width: auto, caption: [
  $x^2 y = c$，$c = 1, 2, 4$ 由内而外。
]) <fig-contours>

== 结果

#api(("ContourSet", "LevelContours"))[
  `trace_implicit` 返回 `ContourSet`，其 `contours` 按给定顺序为每个水准保存一个 `LevelContours`：水准值 `level` 与路径 `paths`，每个连通部分一条 `PiecewiseBezier`。`level_values` 列出各水准，`paths` 汇集所有路径，`for_level(c)` 返回某一水准的路径（未描绘的水准抛出 `KeyError`）。
]

== 限制

描绘出的曲线只在网格交点上精确；交点之间是移动方块法得到的折线，再于 `tolerance` 内简化与弯曲。需要更贴近时，请提高 `resolution` 并降低 `tolerance`。比网格单元小的特征可能遗漏，鞍点规则也只会选择两种可能连接方式之一。Leontief 无差异曲线的折角等尖点会在网格间距内被光滑化，因为网格看不到精确的转角。

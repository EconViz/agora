#import "/template/manual.typ": *

= 三次线段与路径 <sec-paths>

绘图端画的是三次曲线：TikZ 的 `.. controls ..`、SVG 的 `C` 与 Matplotlib 的 `CURVE4` 都接收四个控制点。`CubicBezierSegment` 就是以数值对象表示的三次曲线，`PiecewiseBezier` 则把三次曲线连接成路径。

== 三次线段

#api(("CubicBezierSegment",), syntax: [
  #raw("CubicBezierSegment(p0, p1, p2, p3, *, fit_error=None)")
])[
  不可变的三次曲线，四个控制点即字段 `p0`、`p1`、`p2`、`p3`（亦可用 `control_points` 或逐个取出）。求值、微分、分割、截取与反转的方式与 `BezierCurve` 相同，但 `split()`、`segment()` 与 `reversed()` 仍返回三次线段。`segment(t, t)` 返回四个控制点都是 $B(t)$ 的退化三次曲线。
]

#param("fit_error", type: "float | None", default: "None")[拟合线段的实测误差（详见#ref(<sec-fitting>)）；分割、截取与反转后保留，判断相等时忽略。]
#param("as_curve(), from_curve(curve)")[与 3 次 `BezierCurve` 互相转换，不改变任何控制点。]
#param("from_line(p0, p3), from_quadratic(p0, c, p3)")[直线或二次曲线的精确三次表示（详见#ref(<thm-elevation>)）。]

== 紧密边界框

控制点凸包包含曲线（详见#ref(<thm-hull>)），但可能比曲线大得多。`bounding_box` 返回最小的轴对齐方框（参见#ref(<fig-bbox>)）。

#theorem(name: [边界框])[
  将三次曲线写成 $B(t) = a t^3 + b t^2 + c t + P_0$，其中 $a = -P_0 + 3P_1 - 3P_2 + P_3$、$b = 3P_0 - 6P_1 + 3P_2$、$c = 3(P_1 - P_0)$。在每个坐标轴 $k$ 上，$B_k(t)$ 于 $[0, 1]$ 的最小值与最大值出现在 $t = 0$、$t = 1$，或 $3a_k t^2 + 2 b_k t + c_k$ 在 $(0, 1)$ 内的根。
] <thm-bbox>

#api(("CubicBezierSegment.bounding_box",))[
  返回 `(low, high)` 两点，分别为曲线在各轴的最小值与最大值，由#ref(<thm-bbox>)的候选参数求值而得。
]

#fig("/figures/paths/bbox.pdf", width: auto, caption: [
  三次曲线的紧密边界框。
]) <fig-bbox>

== 升阶

#theorem(name: [升阶])[
  由 $P_0$ 到 $P_3$ 的直线，等于控制点为 $P_0$、$P_0 + 1/3 (P_3 - P_0)$、$P_0 + 2/3 (P_3 - P_0)$、$P_3$ 的三次曲线。控制点为 $P_0, C, P_3$ 的二次曲线，等于控制点为 $P_0$、$P_0 + 2/3 (C - P_0)$、$P_3 + 2/3 (C - P_3)$、$P_3$ 的三次曲线。两者都是同一条曲线，参数化也相同。
] <thm-elevation>

#api(("to_cubic", "line_to_cubic", "quadratic_to_cubic"), syntax: [
  #raw("to_cubic(")#meta("curve")#raw(")")
])[
  位于 `bezierkit.bezier`。`to_cubic()` 根据#ref(<thm-elevation>)将一次、二次或三次 `BezierCurve` 转为 `CubicBezierSegment`（传入线段时原样返回）；更高次数抛出 `DegreeError`。
]

```python
from bezierkit.bezier import to_cubic

q = BezierCurve.quadratic(Point(0, 0), Point(3, 6), Point(9, 0))
print(to_cubic(q).control_points)
# (Point(coords=(0.0, 0.0)), Point(coords=(2.0, 4.0)),
#  Point(coords=(5.0, 4.0)), Point(coords=(9.0, 0.0)))
```

== 分段路径

#api(("PiecewiseBezier",), syntax: [
  #raw("PiecewiseBezier(")#meta("segments")#raw(", *, closed=False, continuity_tolerance=1e-9)") \
  #raw("PiecewiseBezier.compound(")#meta("paths")#raw(")")
])[
  由三次线段组成的路径。相邻线段必须相接：每段的 `p3` 与下一段的 `p0` 距离不得超过 `continuity_tolerance`，闭合路径最后的 `p3` 与第一个 `p0` 亦然，否则抛出 `ValueError`。`closed` 是给导出器的信息（SVG 的 `Z`、TikZ 的 `cycle`），不会额外加入闭合线段。
]

由 $m$ 段 $S_0, dots, S_(m-1)$ 组成的路径采均匀参数化：
$ P(t) = S_k (m t - k), quad k = min(floor(m t), m - 1), $
不论长短，每段都占 $[0, 1]$ 的 $1 slash m$。

#param("segments, control_points, subpaths")[依次排列的线段、其控制点，以及各 `BezierSubpath`。]
#param("at(t), at_many(values)")[按均匀参数化求值。]
#param("split(t), segment(t0, t1)")[分割路径，或保留两个参数之间的部分；参数落在某段内时会分割该段（详见#ref(<thm-subdivision>)）。]
#param("reversed()")[反转线段顺序与每一段。]
#param("closed, is_compound, dimension")[闭合标志、是否含多条子路径，以及 $d$。]

#changed("1.0.0", label: "PiecewiseBezier.segment")[`t0` 落在线段内部时返回正确的区间；先前会先在 `t0` 分割再对后半段重新参数化，导致终点错误]

```python
from bezierkit import CubicBezierSegment, PiecewiseBezier

path = PiecewiseBezier([
    CubicBezierSegment.from_line(Point(0, 0), Point(2, 0)),
    CubicBezierSegment.from_line(Point(2, 0), Point(2, 4)),
])
print(path.at(0.75))                     # Point(coords=(2.0, 2.0))
print(path.segment(0.25, 0.75).at(1.0))  # Point(coords=(2.0, 2.0))
```

`compound()` 把多条路径合为一条，各子路径保持分开，例如有洞的形状。复合路径没有单一的参数化：求值、分割或截取会抛出 `ValueError`；反转与导出则可正常使用。分割或截取闭合路径也会抛出异常（整条路径或单点除外），因为闭合路径没有可保留的起点与终点。

== 连续性

#theorem(name: [三次曲线接点的连续性])[
  设控制点为 $P_0, dots, P_3$ 与 $Q_0, dots, Q_3$ 的三次曲线 $S$、$T$ 依次占据长度为 $h_S$、$h_T$ 的参数区间，且 $P_3 = Q_0$。接合后的曲线在接点为 $C^1$，若且唯若 $(P_3 - P_2) slash h_S = (Q_1 - Q_0) slash h_T$。在 `PiecewiseBezier` 的均匀参数化下 $h_S = h_T$，条件即为 $P_3 - P_2 = Q_1 - Q_0$。
] <thm-continuity>

`PiecewiseBezier` 只要求 $C^0$，也就是端点相接。接点是否也要平滑由调用方决定：无差异曲线的折角或折线的转角本来就该保留。

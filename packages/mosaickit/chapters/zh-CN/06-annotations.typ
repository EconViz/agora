#import "/template/manual.typ": *

= 坐标轴注释 <sec-annotations>

#changed("0.3.0", label: "mosaickit")[坐标轴外的文字按栏排列：标记、外侧大括号（每条轨道一栏）、注释；标记与注释会沿轴分散，互不重叠]

y 轴是绘图区的左缘，x 轴是下缘，两轴外侧的空间称为#emph[边栏]。三种图层写在边栏，第四种在绘图区内画大括号。

== 标记、注释与大括号

#api(("AxisMarkLayer",), added: "0.3.0", syntax: [#raw("AxisMarkLayer(axis, value, label, math=False, style=None, *, role=\"axes\", ...)")])[
  在轴 `"x"` 或 `"y"` 的 `value` 处、绘图区外的短符号，例如 $a_0$ 或 $p^*$。
]

#api(("AxisNoteLayer",), added: "0.3.0", syntax: [#raw("AxisNoteLayer(axis, value, text, style=None, *, role=\"axes.note\", ...)")])[
  说明 `value` 的文字，可跨多行，位于边栏最外侧的栏。在默认主题中，`axes.note` 角色使注释比标记小且淡（9 pt、`grey-600`）。
  #changed("0.3.0")[默认主题新增 `axes.note` 角色]
]

#api(("BraceLayer",), added: "0.3.0", syntax: [#raw("BraceLayer(axis, start, end, label=None, side=\"inside\", *, role=\"axes\", math=False, style=None, stroke=None, ...)")])[
  覆盖轴上 `start`..`end` 的大括号，可加标签。`side="outside"` 画在边栏、标记之外；`"inside"` 画在绘图区内侧，标签配置在不遮盖任何线、点、区域或文字之处，尖端外没有空位时改以引线拉出。
  #changed("0.4.0")[内侧大括号的标签在尖端外没有空位时改以引线拉出（先前会重叠并发出警告）]
]

#api(("SpanBraceLayer",), added: "0.4.0", syntax: [#raw("SpanBraceLayer(start, end, label=None, side=\"below\", *, role=\"axes\", math=False, style=None, stroke=None, ...)")])[
  绘图区内两点之间的大括号。跨距必须是水平（`side` 为 `"above"` 或 `"below"`）或垂直（`"left"` 或 `"right"`）；大括号往 `side` 凸出，离两点 4 pt、深 8 pt，标签位于尖端之外，配置在不遮盖任何东西之处（详见#ref(<sec-labels>)）。
]

```python
from mosaickit import AxisMarkLayer, AxisNoteLayer, BraceLayer, Canvas, quadrant_axes

canvas = Canvas().extend(quadrant_axes(10, 10))
for value, symbol, note in [(7, "a_1", "Upper\nvalue"), (5, "a_0", "Lower\nvalue")]:
    canvas.add(AxisMarkLayer("y", value, symbol, math=True))
    canvas.add(AxisNoteLayer("y", value, note))
canvas.add(BraceLayer("y", 5, 7, "Span", side="outside"))
canvas.add(AxisMarkLayer("x", 6, "b", math=True))
```

#fig("/figures/annotations/gutter.pdf", width: auto, caption: [
  y 轴边栏的标记、注释与大括号。
]) <fig-gutter>

#fig("/figures/annotations/span.pdf", width: auto, caption: [
  两点之间的跨距大括号。
]) <fig-span>

== 边栏的字段

各栏从轴线向外排列，与轴线相距 5 pt，彼此相距 8 pt：标记、每条外侧大括号轨道一栏、注释。每栏宽度等于其中最宽的内容，空栏不占空间也不加间距（参见#ref(<fig-gutter>)，图中另加了辅助线）。剩下两个问题：同一栏中相邻的文字不可重叠，以及哪些大括号可以共用一条轨道。

== 沿轴分散文字

一栏中的每段文字都是沿轴的一个区间，以它所标示的值为中心。区间重叠时将它们分开，保持顺序，并在最小二乘意义下移动最少。

#definition(name: [保序排列])[
  设 $c_1, dots, c_n$ 为中心、$s_1, dots, s_n >= 0$ 为大小、$g >= 0$ 为间距，编号使 $c_1 <= dots.c <= c_n$（相等者按输入顺序）。#emph[排列]是满足
  $ x_(k+1) - x_k >= (s_k + s_(k+1)) / 2 + g, quad k = 1, dots, n - 1 $
  的向量 $x in RR^n$；#emph[保序排列问题]是在所有排列中最小化 $sum_k (x_k - c_k)^2$。
] <def-packing>

#api(("spread",), added: "0.3.0", syntax: [#raw("mosaickit.layout.stack1d.spread(centers, sizes, gap=0.0) -> tuple[float, ...]")])[
  求解此问题：把重叠的连续项目合并成群，每群紧密排列在其成员目标的平均值周围，只要某群撞上前一群就再合并。结果按输入顺序返回。长度不一致或大小为负时引发 `ValueError`。
]

#theorem(name: [分散为最佳解])[
  `spread` 返回#ref(<def-packing>)保序排列问题的唯一解。
] <thm-spread>

这个程序其实是保序回归的相邻违反者合并算法 #citep(<ayer1955>)：扣除紧密排列的位移后，间距限制就变成 $y_1 <= dots.c <= y_n$。

#corollary(name: [分散结果的性质])[
  设 $x$ 为 `spread` 的结果，则
  (i) 任两项 $i != j$ 满足 $|x_i - x_j| >= (s_i + s_j) / 2 + g$；
  (ii) 若各中心本身已构成排列，则 $x = c$；
  (iii) 每群的位移总和为零，因此群的平均位置等于其成员的平均目标。
] <cor-spread>

#fig("/figures/geometry/spread.pdf", width: auto, caption: [
  目标（上）与分散结果（下）。
]) <fig-spread>

#ref(<fig-spread>)中前三项重叠而形成一群，群的位置以它们想要的位置平均为中心；其余两项本来就分开，不会移动。

== 大括号的轨道

跨距（连同标签）彼此太近的大括号必须放在不同轨道，也就是与轴线不同的距离。

#definition(name: [冲突区间])[
  对间距 $g >= 0$，若 $b + g <= a'$ 与 $b' + g <= a$ 都不成立，则区间 $[a, b]$ 与 $[a', b']$ #emph[冲突]。#emph[轨道指派]为每个区间指定一个轨道编号，使冲突的区间不共用轨道。
] <def-conflict>

#api(("assign_lanes",), added: "0.3.0", syntax: [#raw("mosaickit.layout.stack1d.assign_lanes(intervals, gap=0.0) -> tuple[int, ...]")])[
  首次适应：按输入顺序处理区间，把每个区间放进与已有区间都不冲突的最低轨道。端点可按任一顺序给出。
]

#theorem(name: [首次适应使用最少轨道])[
  `assign_lanes` 一定返回轨道指派。若区间按下端递增的顺序给出，且每个都满足 $b - a + g > 0$，则它恰好使用 $omega$ 条轨道，其中 $omega$ 为两两冲突的区间数的最大值；没有任何轨道指派能用得更少。
] <thm-lanes>

其他顺序下，首次适应可能用到多于必要的轨道，因此可能重叠的大括号应按数值由低到高加入。

#api(("gutter_columns",), added: "0.3.0", syntax: [#raw("mosaickit.layout.gutter.gutter_columns(mark_width, brace_widths, note_width, *, start, gap)")])[
  边栏背后的纯字段配置：返回 `GutterColumns`，含 `marks`、`braces`（每条轨道一个 `Band`，由内而外）与 `notes`，各为从轴线向外量的 `Band(near, far)`，以及最远边缘 `extent`。
]

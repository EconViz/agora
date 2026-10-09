#import "/template/manual.typ": *

= 参数、网格与动画 <sec-parameters>

== 参数与表达式

图层坐标不一定是数字，也可以是由命名参数组成的表达式。此时，场景描述一族图形，每组参数值对应一张图；绑定参数就是从中选出一张。

#api(("Parameter",), syntax: [#raw("Parameter(name, value_type=None)")])[
  命名的占位符。设置 `value_type` 后，绑定值必须是该类型的实例；所有绑定值都必须可哈希。`values(seq)` 返回 `ParameterValues`，并立即检查每个值。
]

#api(("Expression", "Constant"), syntax: [#raw("Constant(value)")])[
  不可变的表达式树。参数与常数可用 `+`、`-`、`*`、`/`、`**`、一元 `-`，以及比较运算 `<`、`<=`、`>`、`>=` 与 `equals()` 组合；一般数字会包装成常数。表达式的相等是结构相等（`==` 比较两棵树，因此改用 `equals()` 创建比较表达式），把表达式当成布尔值使用会引发 `BindingError`：须先求值。`evaluate(bindings)` 根据参数到值的对应计算结果；`free_parameters()` 是树中所含参数的集合。
]

#definition(name: [表达式与绑定])[
  #emph[表达式]是常数、参数，或对表达式 $e_1, e_2$ 与运算 $circle.small$ 而言的 $e_1 circle.small e_2$。其自由参数为 $"free"(c) = emptyset$、$"free"(p) = {p}$、$"free"(e_1 circle.small e_2) = "free"(e_1) union "free"(e_2)$。#emph[绑定] $beta$ 是从参数到值的有限对应，而 $"bind"(e, beta)$ 定义为：若 $"free"(e) subset.eq "dom" beta$，则为值 $e(beta)$；否则若 $e$ 为参数，则为 $e$ 本身；否则为 $"bind"(e_1, beta) circle.small "bind"(e_2, beta)$。一般值 $v$ 没有自由参数，求值结果为其本身。
] <def-binding>

#theorem(name: [部分绑定])[
  对每个表达式 $e$ 与绑定 $beta$，
  (i) $"free"("bind"(e, beta)) = "free"(e) without "dom" beta$；
  (ii) 对每个满足 $"dom" gamma inter "dom" beta = emptyset$ 且 $"dom" gamma supset.eq "free"(e) without "dom" beta$ 的绑定 $gamma$，$"bind"(e, beta)(gamma) = e(beta union gamma)$。
] <thm-binding>

#corollary(name: [分阶段绑定])[
  对定义域不相交的绑定 $beta_1, beta_2$，$"bind"("bind"(e, beta_1), beta_2)$ 与 $"bind"(e, beta_1 union beta_2)$ 有相同的自由参数，且在这些参数的每个绑定下有相同的值。特别地，`canvas.bind(p, 1).bind(q, 2)` 与 `canvas.bind({p: 1, q: 2})` 画出相同的图。
] <cor-stages>

`bind` 会遍历 tuple、mapping 与所有 `mosaickit` dataclass，因此整个场景一次绑定；图层的 `model` 保持不变。绘制仍含自由参数的场景时，引发指出这些参数的 `BindingError`。

```python
from mosaickit import Canvas, Parameter, TextLayer

x = Parameter("x", value_type=float)
template = Canvas().add(TextLayer((x, 2 * x + 1), "moving"))
frame = template.bind(x, 3.0)
print(frame.snapshot().layers[0].position)    # (3.0, 7.0)
```

== 网格

#api(("CanvasGrid", "Span"), syntax: [
  #raw("CanvasGrid(cells, rows=None, cols=None, shape=None, links=())") \
  #raw("Span(canvas, rows=1, cols=1)")
])[
  在一张图中放多个画布。`cells` 可以是画布、`Span` 与 `None`（空格）组成的平面列表，逐行填入；也可以是行的列表，此时允许跨行，且每行必须覆盖所有列。`shape=(rows, cols)` 等同同时传入两者。每个画布都会复制，之后修改它不影响网格。跨格重叠、跨格超出边界、单元过多，或混用平面与嵌套单元，都引发 `ConfigurationError`。`render()` 与 `save()` 的用法与画布相同。
]

#proposition(name: [推断的网格形状])[
  对 $n >= 1$ 个一般单元组成的平面列表，若未给 `rows` 与 `cols`，网格有 $c = ceil(sqrt(n))$ 列、$r = ceil(n slash c)$ 行。此时 $r c >= n$、$r <= c$，且空格少于 $c$ 个，全部位于最后一行。
] <prop-grid-shape>

只给 `cols` 时 $r = ceil(n slash c)$；只给 `rows` 时 $c = ceil(n slash r)$。

#api(("Layout", "CanvasGrid.from_layout"), syntax: [#raw("CanvasGrid.from_layout(canvases, layout)")])[
  常见的排列：`SINGLE`、`STACKED`（两行）、`SIDE_BY_SIDE`、`GRID_2X2`、`GRID_3X3`，以及三个画布的 `TOP_TWO_BOTTOM_ONE` 与 `TOP_ONE_BOTTOM_TWO`，其中单独的画布横跨两列。
]

#api(("CanvasGrid.sweep",), syntax: [#raw("CanvasGrid.sweep(template, values, *, cols=None)")])[
  `ParameterValues` 的每个值一格，每格是绑定该值的模板。
]

#api(("GridLink",), added: "0.5.0", syntax: [#raw("GridLink(start_cell, start, end_cell, end, role=\"link\", stroke=None)")])[
  从某格的 `start` 到另一格的 `end` 的直线，两点各以所在单元的数据坐标表示，画在整张图上、横越单元间的空隙。单元按布局顺序编号。样式是在起点单元的主题中解析的 `role`，再叠上 `stroke`。单元编号超出范围时，在创建网格时引发 `ConfigurationError`。
  #changed("0.5.0", label: "CanvasGrid")[新增 `links`]
]

```python
from mosaickit import Canvas, CanvasGrid, GridLink, MarkerLayer, Parameter, Stroke

shift = Parameter("shift", value_type=float)
template = Canvas().add(MarkerLayer([(5, 2.5 + shift)]))
cells = [template.bind(shift, v) for v in (0.0, 2.0, 4.0)]
link = GridLink(0, (5, 2.5), 2, (5, 6.5), stroke=Stroke(dash="dashed"))
CanvasGrid(cells, cols=3, links=[link]).save("sweep.pdf")
```

#fig("/figures/grids/sweep.pdf", width: auto, caption: [
  三个值的扫描与跨格连线。
]) <fig-sweep>

== 动画

#api(("Animation",), syntax: [
  #raw("Animation(template, parameter, values, fps=30)") \
  #raw("Animation.sweep(canvas, values, *, fps=30)")
])[
  每个值对应一帧，由模板绑定该参数值而成。`frames()` 以与渲染器无关的场景逐一产生帧；`save(path)` 写出 GIF（通过 Pillow）或 MP4（通过 `ffmpeg`）。创建动画时即按参数检查各值；值列表为空或 `fps` 非正时引发 `ConfigurationError`。
]

```python
from mosaickit import Animation

values = shift.values([0.0, 1.0, 2.0, 3.0])
Animation.sweep(template, values, fps=4).save("sweep.gif")
```

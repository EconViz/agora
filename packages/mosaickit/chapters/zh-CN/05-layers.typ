#import "/template/manual.typ": *

= 图层与坐标轴 <sec-layers>

== 共同字段

#api(("Layer",), syntax: [#raw("Layer(*, id=")#meta("uuid")#raw(", role=\"primary\", z_index=0, visible=True, legend=None, model=None)")])[
  所有图层的不可变基础类。每种图层都在自己的位置参数之后接受这些仅限关键字的字段。
]

#param("id")[非空字符串，在场景中唯一；默认为随机十六进位字符串。图例、区域标签与 `remove()` 以 id 引用图层。]
#param("role")[以点分隔的角色名称，例如 `"primary"` 或 `"mypkg.boundary"`；它决定图层从主题获取的样式（详见#ref(<sec-themes>)）。每种图层有自己的默认角色，以及最后才查询的回退类别。]
#param("z_index")[有限的绘制顺序；数值越大越晚画、越在上层。群组会把自己的 `z_index` 加到子图层上。]
#param("visible")[`False` 时绘制会略过该图层。]
#param("legend")[图层在图例中的标签；没有标签的图层不列入图例。]
#param("model")[建出该图层的任意领域对象。它参与绘制缓存（详见#ref(<sec-rendering>)），但不参与相等比较与绑定。]

坐标是有限实数对（数据单位），或参数表达式（详见#ref(<sec-parameters>)）。无效的几何在创建图层时就引发 `ConfigurationError`，不会等到绘制时。

== 基本图层

#tbl(caption: [基本图层])[
  #booktabs(
    columns: (auto, auto, 1fr),
    header: ([图层], [默认角色], [绘制内容]),
    [`PathLayer(path, stroke)`], [`primary`], [通过至少两点的折线],
    [`FillLayer(boundary, fill, stroke)`], [`region`], [至少三点的多边形，含填色与外框],
    [`MarkerLayer(points, marker)`], [`point`], [每个点上的标记，至少一点],
    [`TextLayer(position, text)`], [`text`], [某点上的文字],
    [`ArrowLayer(start, end, stroke)`], [`annotation`], [直线箭头，可加标签],
    [`LegendLayer(entries, style)`], [`legend`], [有标签图层的图例],
    [`GroupLayer(children)`], [`primary`], [本身不画任何东西，只将图层分组],
  )
] <tab-layers>

#api(("PathLayer",), syntax: [#raw("PathLayer(path, stroke=None, arrow_placement=ArrowPlacement.END, clip=True, *, ...)")])[
  以直线段连接各点。解析后的线条样式设有 `arrow` 时，在 `START`、`END` 或 `BOTH` 端画出与端段对齐的箭头。`clip=False` 让线条以完整宽度越过绘图区边缘，坐标轴预设即使用此设置。
  #changed("0.2.0")[新增 `clip`（默认 `True`）；箭头不再于路径末端重画实线，虚线箭头因此保持虚线]
]

#api(("FillLayer",), syntax: [#raw("FillLayer(boundary, fill=None, stroke=None, *, ...)")])[
  以 `fill` 填色、以 `stroke` 描边的闭合多边形。`RegionLabelLayer` 以它的 id 引用它。
]

#api(("MarkerLayer",), syntax: [#raw("MarkerLayer(points, marker=None, *, ...)")])[
  每点一个标记。标记一律完整画出：中心在绘图区边缘的标记（例如坐标轴上的点）不会被切半，中心在绘图区外的则略过。
  #changed("0.5.1")[绘图区边缘的标记完整画出；中心在绘图区外的标记略过]
]

#api(("TextLayer",), syntax: [#raw("TextLayer(position, text, style=None, offset=(0, 0), anchor=\"center\", math=False, *, ...)")])[
  位于 `position`、偏移 `offset` pt 的文字。`anchor` 指定文字框的哪一点放在该处：`center`、`left`、`right`、`top`、`bottom`、`top-left`、`top-right`、`bottom-left` 或 `bottom-right`。`math=True` 时文字以数学式排版（`"a_1"` 成为 $a_1$）。
  #changed("0.2.0")[`anchor` 接受四个角 `top-left`、`top-right`、`bottom-left`、`bottom-right`]
]

#api(("ArrowLayer",), syntax: [#raw("ArrowLayer(start, end, stroke=None, label=None, arrow_placement=ArrowPlacement.END, *, ...)")])[
  从 `start` 到 `end` 的直线箭头，除非线条样式指定其他 `ArrowStyle`，否则为开放式箭头；`label` 写在中点。虚线、点线或点划线的线条只套用在箭身，箭头维持实线。箭头不受绘图区裁切。
  #changed("0.2.0")[箭头不再被坐标轴裁切]
  #changed("0.5.0")[虚线、点线或点划线套用在箭身；箭头维持实线]
]

#api(("LegendLayer",), syntax: [#raw("LegendLayer(entries=(), style=None, *, ...)")])[
  列出 id 在 `entries` 中的图层；`entries` 为空时列出所有带 `legend` 标签的图层。不存在或没有标签的 id 引发 `RenderError`。`LegendStyle(visible=False)` 隐藏图例。
]

#api(("GroupLayer",), syntax: [#raw("GroupLayer(children, *, ...)")])[
  由图层组成的图层。子图层如同直接位于场景中般绘制，`z_index` 再加上群组的值；隐藏群组即隐藏全部子图层。
]

== 坐标轴

#api(("AxisSpec", "build_axes"), syntax: [
  #raw("AxisSpec(extent, arrow=None, label=None)") \
  #raw("build_axes(x, y) -> list[Layer]")
])[
  `build_axes` 把两个坐标轴规格转为角色为 `axes` 的一般图层。两者都没有 `arrow` 时，结果是围住范围的闭合框；否则每条轴是沿 $y = 0$ 或 $x = 0$ 的直线，并在指定的 `ArrowPlacement` 画实心三角箭头。标题位于箭头尖端之外 6 pt：x 轴标题在右，y 轴标题在上。
  #changed("0.2.0")[坐标轴预设改画实心三角箭头；轴线不受裁切，在绘图区边缘保持完整宽度]
  #changed("0.3.0")[坐标轴标题改放在箭头尖端之外，不再置中于尖端]
]

#api(("quadrant_axes", "crosshair_axes", "box_frame"), syntax: [
  #raw("quadrant_axes(x_max, y_max)") \
  #raw("crosshair_axes(x_range, y_range)") \
  #raw("box_frame(total_x, total_y)")
])[
  预设：从原点出发、远端带箭头的两轴；穿过原点、两端带箭头的两轴；不带箭头的外框。
]

每条坐标轴都由 `PathLayer` 与 `TextLayer` 组成，因此可通过 `axes` 角色改变样式、以 id（`axes.x`、`axes.y`、`axes.frame`、`axes.x.label`、`axes.y.label`）移除，或改用自行创建的图层。

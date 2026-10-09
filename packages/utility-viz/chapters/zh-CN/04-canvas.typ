#import "/template/manual.typ": *

= Canvas 画布 <sec-canvas>

`Canvas` 以 #pkg("matplotlib") 的 `Figure` 与 `Axes` 为基础，提供无差异曲线、预算线与均衡点等图层。

== 构造函数

#changed("1.7.0", label: "Canvas")[支持为每幅图单独设置的文字与数学字体，不影响 #pkg("matplotlib") 的全局设置]
#changed("1.8.0", label: "Canvas")[添加 `Axis`、`Marker`、`Label` 与 `Fill` 样式对象]
#changed("1.9.0", label: "Canvas")[坐标轴、原点、标题与其他文字元素接受 `Label`]
#changed("1.11.0", label: "Canvas")[背景、标签、线条与标记均由主题提供默认值]
#changed("1.12.0", label: "Canvas.add_utility")[添加焦点效用层级、次要曲线样式及序数标签]

#api(("Canvas",), updated: "v1.7.0", syntax: [
  ```python
  from utility_viz import ArrowStyle, Canvas, Stroke, themes

  cvs = Canvas(
      x_max=20,
      y_max=15,
      x_label="x",
      y_label="y",
      title=r"Cobb-Douglas $x^{0.5} y^{0.5}$",
      dpi=300,
      x_label_pos="right",   # "top"、"right" 或 "bottom"
      y_label_pos="top",     # "left"、"top" 或 "right"
      font="DejaVu Sans",
      math_font="stix",
      axis_stroke=Stroke(width=1.0, arrow=ArrowStyle.TRIANGLE),
      theme=themes.default,
  )
  ```
])[
  创建画布，并设置坐标范围、轴标签、字体、线条样式与主题。未明确传入的视觉设置取自当前的 `Config` 与 `Theme`。
]

#param("x_max", type: "float", default: "10")[横轴上限。]
#param("y_max", type: "float", default: "10")[纵轴上限。]
#param("x_label", type: "str", default: "\"X\"")[横轴末端的标签。]
#param("y_label", type: "str", default: "\"Y\"")[纵轴末端的标签。]
#param("title", type: "str | None", default: "None")[图形标题。]
#param("dpi", type: "int", default: "300")[位图导出分辨率，限制在 1–1200 之间。]
#param("x_label_pos", type: "str", default: "\"right\"")[
  横轴标签相对箭头的位置，也接受 `LabelPosition`（参见#ref(<tab-x-label-pos>)）。

]
#tbl(caption: [`x_label_pos` 值])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([值], [位置]),
    [`"top"`], [箭头上方],
    [`"right"`], [箭头右侧],
    [`"bottom"`], [箭头下方],
  )
] <tab-x-label-pos>
#param("y_label_pos", type: "str", default: "\"top\"")[
  纵轴标签相对箭头的位置（参见#ref(<tab-y-label-pos>)）。

]
#tbl(caption: [`y_label_pos` 值])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([值], [位置]),
    [`"left"`], [箭头左侧],
    [`"top"`], [箭头上方],
    [`"right"`], [箭头右侧],
  )
] <tab-y-label-pos>
#param("font", type: "str | list", default: "None")[
  所有文字使用的字体，或候选字体列表。此项设置仅作用于指定画布，不会改变 #pkg("matplotlib") 的全局设置。
]
#param("math_font", type: "str", default: "None")[
  #pkg("matplotlib") 的数学字体：`dejavusans`、`dejavuserif`、`cm`、`stix` 或 `stixsans` 等。
]
#param("axis_stroke", type: "Stroke", default: "theme")[
  同时设置两轴的粗细、线条样式、颜色与箭头（详见#ref(<sec-styles>)）。
]
#param("x_axis_stroke", type: "Stroke", default: "None")[单独覆盖横轴。]
#param("y_axis_stroke", type: "Stroke", default: "None")[单独覆盖纵轴。]
#param("theme", type: "Theme", default: "themes.default")[配色与样式主题（详见#ref(<sec-themes>)）。]

== 绘图方法

`add_*` 方法在当前的画布添加图层，并返回同一个 `Canvas`，因此可链式调用（详见#ref(<sec-chaining>)）。

#api(("add_utility",), syntax: [
  ```python
  cvs.add_utility(
      func,
      levels=3,          # 曲线条数或效用值列表
      color=None,        # 默认 theme.ic_color
      linewidth=None,    # 默认 theme.ic_linewidth
      show_rays=False,
      show_kinks=False,
      kink_radius=1.0,
      show_bliss=True,   # 标出饱和点（Satiation）
      show_ic_labels=False,
      stroke=None,
      ray_stroke=None,
      ic_label=None,
      highlight_level=None,
      secondary_stroke=None,
      label_style="numeric",
  )
  ```
])[
  绘制无差异曲线。
]

#param("levels", type: "int | list", default: "3")[曲线条数或效用值列表；例如 `levels.around(eq.utility, n=5)` 会在均衡效用附近选取五个水平。]
#param("highlight_level", type: "float | None", default: "None")[焦点效用值。绘制时选择最接近的曲线，以主要样式显示。]
#param("secondary_stroke", type: "Stroke | None", default: "None")[其他曲线的样式；省略时使用 `theme.secondary_ic_stroke`。]
#param("show_ic_labels", type: "bool", default: "False")[显示曲线标签。标签沿曲线切线旋转，并保持在可见绘图区内（参见#ref(<fig-ic-hierarchy>)）。]
#param("label_style", type: "str", default: "\"numeric\"")[`"numeric"` 显示效用值；`"ordinal"` 按效用递增顺序显示 $u_1, u_2, dots$。]

```python
lvls = levels.around(eq.utility, n=5)
cvs.add_utility(
    model,
    levels=lvls,
    highlight_level=eq.utility,
    show_ic_labels=True,
    label_style="ordinal",
)
```

#fig("/figures/canvas/add_utility.svg", width: 42%, caption: [
  三条无差异曲线。
]) <fig-add-utility>

#fig("/figures/canvas/ic_hierarchy.svg", width: 82%, caption: [
  无差异曲线主次层级。
]) <fig-ic-hierarchy>

#api(("add_budget",), syntax: [
  ```python
  cvs.add_budget(
      px, py, income,
      color=None,
      linewidth=None,
      linestyle="-",
      label=None,        # 图例标签（LaTeX）
      fill=False,        # 可行集合阴影
      fill_alpha=None,   # 默认 theme.budget_fill_alpha
      stroke=None,
  )
  ```
])[
  绘制预算线 $p_x x + p_y y = I$。
]

#param("fill", type: "bool | Fill", default: "False")[`True` 使用主题的阴影设置；传入 `Fill` 可覆盖阴影颜色与透明度。]
#param("stroke", type: "Stroke | None", default: "None")[统一设置预算线的颜色、线宽、线型与透明度，优先于 `color`、`linewidth`、`linestyle` 等简写参数（详见#ref(<sec-styles>)）。]
#param("label", type: "str | None", default: "None")[图例文字；调用 `show_legend()` 后才会显示图例。]

#fig("/figures/canvas/add_budget.svg", width: 42%, caption: [
  预算线与阴影。
])

#api(("add_equilibrium",), syntax: [
  ```python
  cvs.add_equilibrium(
      eq,                # solve() 的返回值
      color=None,
      markersize=None,
      label="x^*",
      drop_dashes=True,  # 到两轴的虚线
      show_ray=False,    # 扩张路径
      drop_stroke=None,
      ray_stroke=None,
      marker=None,
  )
  ```
])[
  标记 `solve()` 返回的最优消费组合。
]

#param("drop_dashes", type: "bool", default: "True")[显示至两轴的投影线。]
#param("show_ray", type: "bool", default: "False")[显示通过原点与均衡点的射线。]
#param("marker", type: "Marker | None", default: "None")[均衡点的标记样式（详见#ref(<sec-styles>)）。]

#fig("/figures/canvas/add_equilibrium.svg", width: 42%, caption: [
  均衡点与虚线。
])

#api(("add_ray",), syntax: [
  ```python
  cvs.add_ray(
      slope,             # dy/dx
      color=None,
      linewidth=None,
      stroke=None,
  )
  ```
])[
  绘制通过原点、斜率为 `slope`（$dif y slash dif x$）的射线，用于标记扩张路径或固定比例。
]

#fig("/figures/canvas/add_ray.svg", width: 42%, caption: [
  扩张路径射线。
])

#api(("add_point",), syntax: [
  ```python
  cvs.add_point(
      x, y,
      label=None,
      color=None,
      markersize=None,
      offset=None,       # 标签位移（pt）
      marker=None,
  )
  ```
])[
  在指定坐标标记点。
]

#param("label", type: "str | Label | None", default: "None")[标记文字，可传入字符串或 `Label`。]
#param("offset", type: "tuple | None", default: "None")[文字相对标记点的位移，单位为 pt。]
#param("marker", type: "Marker | None", default: "None")[标记样式。]

#fig("/figures/canvas/add_point.svg", width: 42%, caption: [
  标记点 $A$。
])

#api(("show", "save"), syntax: [
  ```python
  cvs.show()               # 交互窗口
  cvs.save("figure.png")   # .png / .pdf / .svg / .tex
  ```
])[
  `show()` 打开交互窗口；`save()` 根据扩展名导出文件（详见#ref(<sec-export>)），并释放对应的 #pkg("matplotlib") 图形，因此应最后调用。
]

#fig("/figures/canvas/show_save.svg", width: 42%, caption: [
  完整画布。
]) <fig-show-save>

== 样式 <sec-styles>

#changed("1.7.0", label: "Canvas")[`Canvas` 与 `Figure` 支持分别设置坐标轴标签位置、线条样式与箭头样式]
#changed("1.7.0", label: "Stroke")[统一控制画布、多面板图、需求图与 Edgeworth 箱形图中线条的粗细、样式、颜色与箭头]
#changed("1.8.0", label: "Stroke")[线条样式统一由 `Stroke` 表示；个别样式参数保留为简写]
#changed("1.9.0", label: "Stroke")[添加 `opacity` 透明度]
#changed("1.6.0", label: "Canvas")[无差异曲线的默认线宽从 `2.0` 降为 `1.8`]
#changed("1.0.2", label: "Canvas")[数学式的坐标轴标签不再被重复包装]
#changed("1.3.1", label: "Canvas")[Canvas 的绘制拆成 `canvas.renderers` 与 `canvas.primitives`]

`LineStyle` 定义线型，`ArrowStyle` 定义箭头样式，`Stroke` 统一设置线宽、线型、颜色与箭头，可应用于坐标轴、预算线、路径与投影线。

=== 线条样式

#api(("LineStyle",), added: "v1.7.0", syntax: [
  `LineStyle.SOLID`、`DASHED`、`DOTTED`、`DASHDOT`
])[
  提供实线、虚线、点线与点画线（参见#ref(<fig-line-styles>)）。坐标轴接受枚举值或对应字符串；其他线条通过 `Stroke(style=...)` 设置。
]

```python
import matplotlib.pyplot as plt

from utility_viz import Canvas, LineStyle

styles = [
    LineStyle.SOLID,
    LineStyle.DASHED,
    LineStyle.DOTTED,
    LineStyle.DASHDOT,
]

fig, axes = plt.subplots(1, 4, figsize=(8.5, 2.2))
for ax, style in zip(axes, styles):
    Canvas(
        title=style.value,
        x_line_style=style,
        y_line_style=style,
        fig=fig,
        ax=ax,
    )

# 轴标签会放在箭头外侧；四张图并排时要多留一点水平间距。
fig.subplots_adjust(wspace=0.62)
fig.savefig("line_styles.png", dpi=160, transparent=True)
```

#fig("/figures/canvas/line_styles.svg", width: 94%, caption: [
  四种线条样式。
]) <fig-line-styles>

=== 箭头样式

#api(("ArrowStyle",), added: "v1.7.0", syntax: [
  `ArrowStyle.SIMPLE`、`TRIANGLE`、`FANCY`、`WEDGE`
])[
  提供四种箭头样式（参见#ref(<fig-arrow-styles>)）。坐标轴通过 `x_arrow_style`、`y_arrow_style` 设置；其他线条通过 `Stroke(arrow=...)` 设置。
]

#fig("/figures/canvas/arrow_styles.svg", width: 94%, caption: [
  四种箭头样式。
]) <fig-arrow-styles>

=== Stroke

#api(("Stroke",), added: "v1.7.0", updated: "v1.9.0", syntax: [
  #raw("Stroke(width=")#meta("float")#raw(", style=")#meta("LineStyle")#raw(", color=")#meta("str")#raw(
    ", arrow=",
  )#meta("ArrowStyle")#raw(", opacity=")#meta("float")#raw(")")
])[
  设置线宽、线型、颜色、箭头与透明度。未指定的字段沿用当前主题。`opacity` 的有效范围为 0 至 1。
]

=== Axis

#api(("Axis",), added: "v1.8.0", syntax: [
  `Axis(label=None, label_position=None, stroke=None)`
])[
  集中设置单一坐标轴的标签、标签位置与线条。`Canvas`、`Figure`、`DemandDiagram` 与 `EdgeworthBox` 均接受 `x_axis` 与 `y_axis`。若同时传入简写参数，`Axis` 中已设置的字段优先。

  ```python
  from utility_viz import Axis, Canvas, Label, Stroke

  cvs = Canvas(
      x_axis=Axis(
          label=Label(text="x_1", fontsize=16),
          label_position="bottom",
          stroke=Stroke(width=1.2),
      ),
      y_axis=Axis(label="x_2"),
  )
  ```
]

=== Marker 与 Label

#api(("Marker",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Marker(color=None, size=None, shape=None, opacity=None)`
])[
  设置标记点的颜色、大小、形状与透明度。`shape` 接受 #pkg("matplotlib") 的标记字符串，例如 `"o"`、`"s"`、`"^"`、`"D"` 与 `"*"`。
]

#api(("Label",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Label(text=None, position=None, offset=None, color=None, fontsize=None, visible=None, opacity=None)`
])[
  设置文字、位置、位移、颜色、字号、可见性与透明度。位置可为上、下、左、右或四个角落；`Label(visible=False)` 隐藏对应文字。

  ```python
  from utility_viz import Label, Marker

  cvs.add_equilibrium(
      eq,
      marker=Marker(shape="s", size=8),
      label=Label(position="bottom-left", offset=8),
  )
  cvs.add_point(
      12, 2,
      marker=Marker(color="black", shape="D"),
      label=Label(text="A", position="left", fontsize=14),
  )
  ```
]

=== Fill

#api(("Fill",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Fill(color=None, opacity=None)`
])[
  设置阴影区域的颜色与透明度。`alpha` 是 `opacity` 的兼容简写；同一次调用不得传入不同的 `alpha` 与 `opacity`。

  ```python
  from utility_viz import Fill

  cvs.add_budget(
      2, 3, 30,
      fill=Fill(color="lightgrey", opacity=0.4),
  )
  ```
]

== 链式调用 <sec-chaining>

`add_*` 方法支持链式调用，最后以 `save()` 导出：

```python
Canvas(x_max=20, y_max=15) \
    .add_utility(model, levels=lvls) \
    .add_budget(2.0, 3.0, 30.0, fill=True) \
    .add_equilibrium(eq, show_ray=True) \
    .save("figure.png")
```

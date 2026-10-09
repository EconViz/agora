#import "/template/manual.typ": *

= 图形 <sec-figures>

#changed("0.10.0", label: "MarketFigure")[图形改为正方形（150 dpi 下 6 × 6 英吋），背景为不透明白色；直线曲线止于价格轴的 92%]
#changed("0.10.0", label: "MarketFigure")[曲线名称标在可见端点旁，不再放进图例]
#changed("0.10.0", label: "MarketFigure")[坐标轴名称默认为 $p$ 与 $Q$，以斜体数学字体放在箭头外侧；标题不再使用粗体]
#changed("0.10.0", label: "MarketFigure")[均衡与政策标签由 #pkg("mosaickit") 放在点旁；拥挤处的数量改标在数量轴上]
#changed("0.10.0", label: "MarketFigure.finalize")[默认不加图例；`finalize(legend=True)` 才会加入]

本手册的每张图都是 `MarketFigure`，或由 `ppf_canvas()` 等函数创建的 #pkg("mosaickit") 画布。两者的绘图区为正方形，坐标轴带箭头、无刻度与格线；曲线名称标在末端，面积名称写在区块内，数值标在坐标轴上，文字不遮住线、点、区块或其他文字。

== MarketFigure

#api(("MarketFigure",), syntax: [
  ```python
  from principle_viz import MarketFigure

  fig = MarketFigure(
      x_max=20.0,
      y_max=20.0,
      x_label="Q",
      y_label="p",
      title="Market Diagram",
      theme=None,       # PlotTheme
      palette=None,     # "default", "nord", ...
      labels=None,      # {layer id: Label}
      visibility=None,  # {layer id: bool}
  )
  ```
])[
  #pkg("mosaickit") 画布上的市场图，坐标轴由 0 延伸到 `x_max` 与 `y_max`。坐标轴名称除非是文字，否则以 LaTeX 数学排版；`title` 为空字符串时不画标题。
]

#param("theme")[颜色与线宽（详见#ref(<sec-palettes>)）。]
#param("palette")[`PlotTheme.from_palette(palette)` 的简写；与 `theme` 同时给定时以 `theme` 为准。]
#param("labels")[依图层 id 覆盖内建标签（详见#ref(<sec-labels>)）。]
#param("visibility")[依图层 id 显示或隐藏图层（详见#ref(<sec-labels>)）。]

#api(("MarketFigure.add_curves", "MarketFigure.add_equilibrium"), syntax: [
  #raw("add_curves(")#meta("demand")#raw(", ")#meta("supply")#raw(", q_max, demand_label=\"$D$\", supply_label=\"$S$\")") \
  #raw("add_equilibrium(")#meta("result")#raw(", label=\"$e^*$\", color=None)")
])[
  由 $Q = 0$ 到 `q_max` 画出需求与供给并在末端命名；以实心点与标签标出均衡。
]

各主题另有专属方法，说明见对应章节（参见#ref(<tab-figure-methods>)）。

#tbl(caption: [`MarketFigure` 的主题方法])[
  #booktabs(
    columns: (auto, auto),
    header: ([方法], [章节]),
    [`add_comparative_statics`], [#ref(<sec-shifts>)],
    [`add_discrete_curves`、`add_discrete_equilibrium`], [#ref(<sec-discrete>)],
    [`add_welfare`、`add_welfare_transition`], [#ref(<sec-welfare>)],
    [`add_tax_transform`、`add_tax_comparison`、`add_subsidy_comparison`], [#ref(<sec-taxes>)],
    [`add_price_control`], [#ref(<sec-controls>)],
    [`add_trade`], [#ref(<sec-trade>)],
    [`add_externality`、`add_common_resource`], [#ref(<sec-failures>)],
    [`add_minimum_wage`、`add_loanable_funds`], [#ref(<sec-factor>)],
  )
] <tab-figure-methods>

#api(("MarketFigure.finalize", "MarketFigure.save"), syntax: [
  #raw("finalize(legend=False)") \
  #raw("save(")#meta("path")#raw(", dpi=150)")
])[
  `finalize()` 隐藏会把福利区块切成两半的辅助线（数值仍标在坐标轴上），只有在 `legend=True` 时才加入图例。`save()` 依扩展名写出 PNG、SVG 或 PDF，并创建不存在的目录。`close()` 不做任何事，仅为兼容而保留。
]

#api(("MarketFigure.add_layer", "MarketFigure.add_layers"), syntax: [
  #raw("add_layer(")#meta("layer")#raw(")") \
  #raw("add_layers(")#meta("layers")#raw(")")
])[
  加入任意 #pkg("mosaickit") 图层，用于主题方法未提供的注记。同一数值的坐标轴标记会取代先前的标记。完成的场景可由 `fig.scene` 获得。
]

#api(("MarketFigure.add_metrics",), syntax: [
  #raw("add_metrics(")#meta("values")#raw(", *, title=None, location=\"upper right\")")
])[
  以名称与数值组成的文字框，供笔记本与调试使用。教学用图不放此框，数值应写在正文中。
]

== 标签与图层 <sec-labels>

#changed("0.10.1", label: "Label")[每个内建标签都可改名、隐藏或移动：新增 `Label`、`labels=`、`configure_label()` 与 `label_ids`]
#changed("0.10.1", label: "MarketFigure.configure_layer")[每个图层都可隐藏或显示：新增 `visibility=`、`configure_layer()`、`hide()`、`show()` 与 `layer_ids`]

图中的每条线、每个点、每个区块与每段文字都是一个图层，各有固定的 id，例如 `market.demand`、`market.demand.label` 或 `market.welfare.dwl`。id 依图形结构命名：坐标轴为 `axes.*`，各元素为 `market.<部分>`，命名该元素的文字再加上 `.label` 后缀。`fig.layer_ids` 列出所有图层；`fig.label_ids` 列出可设置的文字（标签、坐标轴标记与括号）。

#api(("Label",), added: "v0.10.1", syntax: [
  #raw("Label(text=None, visible=None, offset=None)")
])[
  覆盖一个内建标签。值为 `None` 的字段保留软件包的默认值。指定 `offset`（单位为点）时，标签不再自动放置，改为精确移动该距离。
]

#api(("MarketFigure.configure_label", "MarketFigure.configure_layer"), added: "v0.10.1", syntax: [
  #raw("configure_label(")#meta("layer id")#raw(", label=None, *, text=None, visible=None, offset=None)") \
  #raw("configure_layer(")#meta("layer id")#raw(", *, visible)")
])[
  改名、隐藏或移动一个标签（id 可省略结尾的 `.label`），或显示、隐藏任一图层。`hide(*ids)` 与 `show(*ids)` 一次切换多个图层。每个方法都返回图形本身。
]

同样的覆盖也可在创建图形时以 `labels=` 与 `visibility=` 对应表传入，之后加入的图层也会套用。加总图与各画布函数（`ppf_canvas()`、`public_good_canvas()` 等）接受同样的两个参数。

参见#ref(<fig-labels>)：

```python
from principle_viz import Label, MarketFigure

fig = MarketFigure(
    x_max=12, y_max=12,
    labels={
        "market.demand.label": Label(text="Demand"),
        "market.supply.label": Label(text="Supply"),
    },
)
fig.add_curves(demand, supply, q_max=10)
fig.add_equilibrium(eq)
fig.configure_label("market.equilibrium", text="$E$")
fig.hide("axes.origin.label")
fig.finalize()
```

#fig("/figures/figures/labels.svg", width: 46%, caption: [
  改名的曲线与均衡点。
]) <fig-labels>

== 配色与主题 <sec-palettes>

#changed("0.1.0", label: "ColorModel")[`default`、`colorblind`、`nord` 与 `monochrome` 四种配色]
#changed("0.10.0", label: "ColorModel")[`default` 配色改用 #pkg("mosaickit") 的色相：需求蓝、供给红、无谓损失青]
#changed("0.10.0", label: "PlotTheme")[供需曲线宽 3.5 pt、坐标轴 1.0 pt、均衡点直径 6.5 pt]

`ColorModel` 为每个经济角色指定颜色；`PlotTheme` 再加上线宽与坐标轴选项，并将两者编译为 #pkg("mosaickit") 主题。内建的四种配色如#ref(<tab-palettes>)。

#api(("ColorModel",), syntax: [
  #raw("ColorModel(name, axis_color, label_color, demand_color, supply_color, ...)")
])[
  具名的颜色角色：`axis_color`、`label_color`、`demand_color`、`supply_color`、`baseline_color`、`shifted_color`、`tax_color`、`control_color`、`cs_color`、`ps_color`、`tax_revenue_color`、`dwl_color` 与 `arrow_color`。每个值可为 `"#hex"` 或 `"blue"` 等 #pkg("mosaickit") 调色板名称。
]

#tbl(caption: [内建配色])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([名称], [特色]),
    [`default`], [#pkg("mosaickit") 色相：需求蓝、供给红、无谓损失青；剩余沿用曲线色相，透明度 15%],
    [`colorblind`], [色盲友善的质性配色],
    [`nord`], [Nord 配色],
    [`monochrome`], [黑、白与灰阶，供印刷使用],
  )
] <tab-palettes>

`list_color_models()` 返回所有名称，`get_color_model(name)` 返回对应的配色；四种配色也以 `DEFAULT_COLOR_MODEL`、`COLORBLIND_COLOR_MODEL`、`NORD_COLOR_MODEL` 与 `MONOCHROME_COLOR_MODEL` 导出。

#api(("PlotTheme",), syntax: [
  #raw("PlotTheme(color_model=..., demand_linewidth=3.5, supply_linewidth=3.5, ...)") \
  #raw("PlotTheme.from_palette(")#meta("name")#raw(", **options)")
])[
  配色加上线宽（`demand_linewidth`、`supply_linewidth`、`shifted_linewidth`、`tax_linewidth`、`arrow_linewidth`、`dashed_linewidth`）、`equilibrium_marker_size`，以及开关 `show_grid`、`show_ticks`、`show_axis_arrows` 与 `show_origin_label`。`from_palette()` 以内建配色为起点，并可设置上述任一字段。
]

以 `palette` 参数选用配色（参见#ref(<fig-monochrome>)）：

```python
fig = MarketFigure(x_max=12, y_max=12, palette="monochrome")
```

#fig("/figures/figures/monochrome.svg", width: 46%, caption: [
  `monochrome` 配色。
]) <fig-monochrome>

== 画布

#api(("Canvas",))[
  #pkg("mosaickit") 的 `Canvas`，并具备与 `MarketFigure` 相同的 `labels=`、`visibility=`、`configure_label()`、`configure_layer()`、`hide()`、`show()`、`layer_ids` 与 `label_ids`。生产可能性曲线、公共物品与总收益各章的画布函数都返回此类别；以 `save()` 保存，或以 `mosaickit.CanvasGrid` 组合多张画布。
]

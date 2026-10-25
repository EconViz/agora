#import "/template/manual.typ": *

= 标签与位置 <sec-labels>

== 语系表

#pkg("micro-viz") 放进图中的每个字都在 `src/micro_viz/locale/labels.json`，先依稳定的编号（`production.tp`）、再依语言（`en`、`zh-TW`、`zh-CN`）索引。语言来自 `[micro] language`、`PlotTheme.language`，或范例脚本的 `--language`。

含字段的文本在表中使用双层大括号，例如 `$D_{{{index}}}$`；不含字段的文本使用单层大括号。数学式写在 `$...$` 中，不使用 Unicode 下标。

符号在各图之间固定：只有价格 $p$ 用小写，其他变量一律用大写斜体；缩写（MC、ATC）与点名保留原有的大小写。

== 取代文本

调用端传入的文本照原样使用，不会翻译。

```python
unit_cost_canvas(
    analysis,
    title="Unit costs",
    x_label="Quantity",
    labels={"cost.mc": "Marginal cost"},
)
```

`title=None`（缺省）不画标题。要依图层编号修改某张已保存图形的某个标签，使用共用的逐图表，#pkg("mosaickit") 会在保存图形时套用：

```toml
[figure.unit_cost.label."micro.cost.avc.label"]
top = "3pt"
right = "2mm"
```

== 缺省移动标签 <sec-nudges>

`[micro.label.<group>]` 依每一侧（`top`、`bottom`、`left`、`right`；单位 `pt`、`mm`、`cm`、`in`）的长度移动一组中的所有标签。分组依标签所标示的对象而定（参见 @tab-label-groups）。

#tbl(caption: [标签分组])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([分组], [标签]),
    [`point`], [标示的点],
    [`curve`], [曲线末端旁的曲线名称],
    [`region`], [上色区域内的名称，含引出标注],
    [`mark`], [价格线、数量标记与其他带有数值的辅助线],
    [`annotation`], [其他文本],
  )
] <tab-label-groups>

座标轴标题、原点与轴上标记（$L_1$、$Q^*$）不属于任何分组，不能移动。

== 标签放在哪里

- 曲线名称放在曲线末端旁。两条曲线的末端靠近时，绘图函数把其中一条的名称放在曲线中途（`at`），名称才不会相碰。
- 点的标签放在点旁，由 #pkg("mosaickit") 选择不碰到线、标记或其他文本的一侧。
- 找不到空位的文本会使 #pkg("mosaickit") 发出 `LayoutWarning`。测试把版面警告视为错误来绘图，所以标签重叠的图会失败。

== 落在曲在线的辅助线

完全落在一段实线直曲在线的虚线辅助线不会绘出。最常见的是承载虚线价格辅助线的价格线。标示水准的记号，例如 $p$，是另一个图层，会保留。

规则是 `micro_viz.visuals.common` 的 `drop_covered_guides`，在 `Plane` 或竞争图完成时套用一次。虚线曲线（例如 AFC）不会屏蔽辅助线。

#fig("/figures/competition/firm_loss.zh-CN.svg", width: 46%, caption: [
  亏损：保留价格记号
]) <fig-firm-loss>

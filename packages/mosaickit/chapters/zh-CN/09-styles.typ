#import "/template/manual.typ": *

= 样式与颜色 <sec-styles>

== 稀疏样式

每个样式都是冻结的 dataclass，且所有字段都可以是 `None`。`None` 表示继承：字段值取自优先级较低的样式（详见#ref(<sec-themes>)）。假值不等于 `None`，因此 `opacity=0`、`width=0` 与 `LegendStyle(visible=False)` 都是明确的覆盖。

#definition(name: [稀疏合并])[
  设 $a$、$b$ 为同类型、字段集合为 $F$ 的样式。样式 $a triangle.r b$（`a.merged_over(b)`）对每个 $phi in F$ 满足
  $ (a triangle.r b)_phi = cases(a_phi & "if" a_phi != "None", b_phi & "otherwise".) $
  空样式 $epsilon$ 的每个字段都是 `None`。样式组逐槽合并，`None` 槽视同 $epsilon$。
] <def-merge>

#proposition(name: [合并构成幺半群])[
  对同类型的样式 $a, b, c$，
  (i) 结合律为
  $ (a triangle.r b) triangle.r c = a triangle.r (b triangle.r c); $
  (ii) 空样式是单位元，
  $ epsilon triangle.r a = a triangle.r epsilon = a; $
  (iii) 合并具有幂等性，
  $ a triangle.r a = a. $
  逐栏来看，$a_1 triangle.r dots.c triangle.r a_n$ 取第一个不是 `None` 的值。
] <prop-monoid>

因此，多个样式无论如何分组合并，结果都相同。可以将它们视为一份优先级列表：某字段的值取自第一个设置该字段的来源。

#api(("SparseStyle",), syntax: [#raw("style.merged_over(base)")])[
  #ref(<def-merge>)的合并。不同类型的样式引发 `TypeError`。
]

== 样式类型

#api(("Stroke",), syntax: [
  #raw("Stroke(color=None, width=None, dash=None, arrow=None, opacity=None)")
])[
  线条样式。`width` 以点为单位；`dash` 为 `DashStyle`（`SOLID`、`DASHED`、`DOTTED`、`DASHDOT`）；`arrow` 为 `ArrowStyle`（`OPEN`、`TRIANGLE`、`FANCY`、`WEDGE`），画在图层的 `ArrowPlacement`（`START`、`END`、`BOTH`）处。
]

#changed("0.8.0", label: "DashStyle")[`DashStyle` 与 `ArrowStyle` 接受简写，让其他包可直接当作自己的线型与箭头枚举]
#api(("DashStyle",), syntax: [
  `DashStyle.SOLID`, `DASHED`, `DOTTED`, `DASHDOT`
])[
  `Stroke` 的线条类型；也接受简写 `-`、`--`、`:` 与 `-.`。
]

#param("SOLID", type: "DashStyle")[实线。]
#param("DASHED", type: "DashStyle")[虚线。]
#param("DOTTED", type: "DashStyle")[点线。]
#param("DASHDOT", type: "DashStyle")[点划线。]

#api(("ArrowStyle",), syntax: [
  `ArrowStyle.OPEN`, `TRIANGLE`, `FANCY`, `WEDGE`
])[
  `Stroke` 的箭头样式。`SIMPLE` 是 `OPEN` 的另一个名称，也接受 Matplotlib 写法 `->` 与 `-|>`。
]

#param("OPEN", type: "ArrowStyle")[开口箭头。]
#param("TRIANGLE", type: "ArrowStyle")[实心三角形。]
#param("FANCY", type: "ArrowStyle")[弯曲、渐细的箭头。]
#param("WEDGE", type: "ArrowStyle")[细楔形箭头。]

#api(("ArrowPlacement",), syntax: [
  `ArrowPlacement.START`, `END`, `BOTH`
])[
  图层的箭头画在哪里。
]

#param("START", type: "ArrowPlacement")[在第一个点。]
#param("END", type: "ArrowPlacement")[在最后一个点。]
#param("BOTH", type: "ArrowPlacement")[两端都画。]

#api(("Fill",), syntax: [#raw("Fill(color=None, opacity=None, hatch=None)")])[
  区域内部的填色样式；`hatch` 为 Matplotlib 的填充图案，例如 `"//"`，`""` 表示无填充图案。
]

#api(("Marker",), syntax: [#raw("Marker(color=None, size=None, shape=None, opacity=None, edge_color=None, edge_width=None)")])[
  点标记样式。`size` 是以平方点计的面积，与 Matplotlib 的 `scatter` 相同（36 对应 6 pt 圆点）；`shape` 为 Matplotlib 标记，例如 `"o"`、`"s"` 或 `"X"`。
]

#api(("TextStyle",), syntax: [#raw("TextStyle(color=None, size=None, font=None, weight=None, opacity=None, rotation=None)")])[
  文字样式。`size` 以点为单位，`font` 是通用字体（`"sans"`、`"serif"` 或 `"mono"`，见#ref(<sec-fonts>)），`weight` 是 1 到 1000 的整数、`"normal"` 或 `"bold"`，`rotation` 为逆时针旋转的角度（度）。字段请以名称传入。
  #changed("0.9.0", label: "TextStyle")[`weight` 不再弃用]
  #changed("0.9.1", label: "TextStyle")[新增 `font` 字段；`family` 弃用]
  #changed("1.0.0rc1", label: "TextStyle")[移除 `family`；改以 `font` 选择字体，并用 `TextFonts` 换成自己的字体文件。字段请以名称传入；含 `"family": null` 的场景文档仍可加载，指定字体家族名称的则会被拒绝]
]

== 字体 <sec-fonts>

文字由 #pkg("glyphkit") 依字体文件排版。三种通用字体指向字体文件：`"sans"`（默认）、`"serif"` 与 `"mono"`。MosaicKit 默认用 DejaVu Sans、DejaVu Serif 与 DejaVu Sans Mono，也就是 Matplotlib 附的文件。它*不会搜索系统字体*，其他字体一律要自己给文件。

#api(("TextFonts",), syntax: [
  #raw("TextFonts(sans=None, serif=None, mono=None)")
])[
  取代通用字体的字体文件。每个字段可给一个文件或一个列表；需要的字面都要列出，例如常规与粗体两个文件。样式的 `weight` 会选最接近的字面，文件顺序则是第一个文件缺字时依次尝试的顺序。没给的字段沿用 DejaVu 默认。
  #changed("0.9.0", label: "TextFonts")[新增；sans 接一个文件列表]
  #changed("0.9.1", label: "TextFonts")[新增 `serif` 与 `mono`；默认为 DejaVu]
]

#api(("MathFont",), syntax: [
  #raw("MathFont(path, italic=True)")
])[
  OpenType 数学字体，如 STIX Two Math、Libertinus Math 或 Fira Math，文件要有 `MATH` 表。`italic` 让单个拉丁字母与小写希腊字母用斜体字母表，和 TeX 一樣。没有数学字体时，`$...$` 内的数学式由 Matplotlib 排版。
]

```python
from mosaickit import Canvas, CanvasSpec, Config, MathFont, TextFonts, TextLayer, TextStyle, use_config

fonts = TextFonts(serif=["fonts/Pagella-Regular.otf", "fonts/Pagella-Bold.otf"])
config = Config(fonts=fonts, math_font=MathFont("fonts/Pagella-Math.otf"))

with use_config(config):
    canvas = Canvas(CanvasSpec(x_range=(0, 1), y_range=(0, 1)))
    canvas.add(TextLayer((0.5, 0.5), "$u = x^{0.5}$", style=TextStyle(font="serif")))
```

TikZ 渲染器把 `sans`、`serif`、`mono` 对应到 `\sffamily`、`\rmfamily` 与 `\ttfamily`。
#changed("0.9.2", label: "TikZ")[`font` 对应到 TeX 字体家族]

#api(("LegendStyle",), syntax: [#raw("LegendStyle(visible=None, location=None, frame=None, size=None)")])[
  图例：Matplotlib 的位置名称，例如 `"best"` 或 `"upper right"`、外框，以及字号。
]

大小、宽度与不透明度在创建样式时检查：大小必须为有限非负数，不透明度在 $[0, 1]$ 内，旋转角度必须有限。

#tbl(caption: [基本默认值])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([样式], [值]),
    [`Stroke`], [`grey-800`、宽 1.5、实线、不透明度 1],
    [`Fill`], [`grey-200`、不透明度 0.3、无填充图案],
    [`Marker`], [`grey-800`、大小 36、`"o"`、不透明度 1、边框 `grey-800` 宽 0],
    [`TextStyle`], [`grey-900`、12 pt、DejaVu Sans、一般字重、不透明度 1、不旋转],
    [`LegendStyle`], [显示、位置 `"best"`、无外框、10 pt],
  )
] <tab-primitive>

== 颜色

#api(("Color", "TRANSPARENT"), syntax: [
  #raw("Color(red, green, blue, alpha=1.0)") \
  #raw("Color.from_hex(\"#RGB\" | \"#RRGGBB\" | \"#RRGGBBAA\")")
])[
  不可变的 RGBA 颜色，各通道在 $[0, 1]$ 内。`channels` 返回四个值，`from_channels()` 创建颜色，`to_hex(include_alpha=None)` 写出 `#RRGGBB`，当 `include_alpha` 为真、或默认情况下 alpha 不为 1 时加上 `AA`。`TRANSPARENT` 为 `Color(0, 0, 0, 0)`。
]

#proposition(name: [十六进制往返])[
  对每个由十六进制数字组成、形如 `#RRGGBB` 或 `#RRGGBBAA` 的字符串 $h$，`Color.from_hex(h).to_hex(include_alpha=len(h) == 9)` 等于 $h$ 的大写形式。三位数的 `#RGB` 读作 `#RRGGBB`。
] <prop-hex>

样式的 `color` 或 `edge_color` 接受 `Color`、`"#hex"` 字符串（立即解析），或其他任何字符串，后者保留为#emph[调色板名称]。

== 调色板

#api(("Palette", "DEFAULT_PALETTE"), added: "0.2.0", syntax: [#raw("Palette(name, colors)")])[
  命名的颜色表。值可以是 `Color` 或十六进制字符串；`palette[name]` 查询颜色，名称不存在时引发指出该调色板的 `ConfigurationError`，`name in palette` 检查名称是否存在。
]

#tbl(caption: [`DEFAULT_PALETTE`])[
  #booktabs(
    columns: (auto, auto, 1fr),
    header: ([名称], [值], [默认主题中的用途]),
    [`grey-900`], [`#222222`], [文字],
    [`grey-800`], [`#333333`], [线条、标记、坐标轴],
    [`grey-600`], [`#666666`], [坐标轴注释],
    [`grey-400`], [`#999999`], [辅助线],
    [`grey-200`], [`#CCCCCC`], [填色],
    [`grey-100`], [`#E6E6E6`], [],
    [`white`], [`#FFFFFF`], [画布背景],
    [`blue`], [`#01A2D9`], [`primary`],
    [`red`], [`#E3120B`], [`secondary`],
    [`teal`], [`#00887D`], [`accent`],
  )
] <tab-palette>

主题与样式以名称引用颜色，画布创建渲染计划时才在生效的调色板（`Config.palette`）中查询，因此渲染器只会收到具体颜色。在调色板中改一次颜色，所有引用它的角色都随之改变。调色板缺少的名称在绘制时引发 `ConfigurationError`，信息指明角色、样式字段与调色板。Python 的 `Palette` 会取代默认调色板，因此应从 `DEFAULT_PALETTE.colors` 创建，以保留内置主题所用的名称：

```python
from mosaickit import DEFAULT_PALETTE, Canvas, Config, Palette, use_config

brand = Palette("brand", {**DEFAULT_PALETTE.colors, "blue": "#0072B2"})
with use_config(Config(palette=brand)):
    canvas = Canvas()          # primary now draws in #0072B2
```

#changed("0.2.0", label: "DEFAULT_PALETTE")[新增：灰阶、`white`、`blue`、`red` 与 `teal`；默认主题的颜色取自此调色板，`primary`、`secondary` 与 `accent` 改为蓝、红、青绿]
#changed("0.3.0", label: "Palette")[主题与样式以调色板名称引用颜色，在创建渲染计划时按 `Config.palette` 解析；未知名称引发指明角色、字段与调色板的 `ConfigurationError`]

#import "/template/manual.typ": *

= 设置 <sec-settings>

#changed("0.2.0.dev0", label: "Config")[设置读自共用的 `econ-viz.toml`；#pkg("micro-viz") 在 `[micro]` 下声明自己的表]
#changed("0.2.0.dev0", label: "Config")[`[micro.region]` 决定是否为边际报酬区间上色，以及底色填到图顶或只填到曲线]

#pkg("micro-viz") 读取共用的 `econ-viz.toml`。文件由 #pkg("mosaickit") 解析与检查；#pkg("micro-viz") 只在 `[micro]` 下声明自己接受的项目。

#api(("Config",), syntax: [
  ```python
  Config.load(path=None)
  Config.discover()
  Config.from_dict(data)
  config.use()
  ```
])[
  读自 `econ-viz.toml` 的主题。`load()` 读取 `path`，省略时读工作目录中的 `econ-viz.toml`。`use()` 把它设为缺省并回传该设置，之后没有明确指定 `theme` 的图形都使用它。文件中的相对路径相对于文件所在的目录。
]

```python
from micro_viz import Config

Config.load("econ-viz.toml").use()
```

省略的项目保留内置默认值；没有任何文件时，输出与有设置功能之前相同。

```toml
base = "manual"            # 共用外观：白底黑白

[font]
text = "serif"
math = "texgyrepagella-math.otf"

[fonts]
serif = ["texgyrepagella-regular.otf", "texgyrepagella-italic.otf"]

[micro]
language = "en"            # en、zh-TW 或 zh-CN

[micro.stroke]
curve = 3.5                # 点

[micro.region]
fill = true
extent = "top"
```

本手册各版本的图形分别由 `config/econ-viz.toml`、`config/econ-viz.zh-TW.toml` 与 `config/econ-viz.zh-CN.toml` 绘制；三份文件只有字体与语言不同。

== 共用项目

`base`、`[font]`、`[fonts]`、`background`、`axis` 与 `label` 为所有 EconViz 套件共用，说明见 #pkg("mosaickit")。套件没有深色主题，背景一律为白色。

== `[micro]` 表 <sec-micro-tables>

#tbl(caption: [`[micro]` 表的项目])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([项目], [说明], [默认值]),
    [`language`], [内置图形文本的语言], [`en`],
    [`color.<element>`], [单一元素的颜色（见下）], [主题的颜色],
    [`stroke.curve`], [主要曲线的线宽，单位为点], [3.5],
    [`stroke.dashed`], [虚线曲线的线宽], [2.0],
    [`stroke.guide`], [座标轴与辅助线的线宽], [1.0],
    [`stroke.after`], [变动后曲线的线宽（细实线）], [1.5],
    [`stroke.arrow`], [移动箭头的线宽（实线）], [1.2],
    [`marker.diameter`], [标记点的直径], [6.5],
    [`brace.gap`], [上色区域与大括号之间的距离], [4.0],
    [`opacity.region`], [上色区域的不透明度，大于 0 且至多为 1], [0.2],
    [`region.fill`], [是否为图中的区域上色（`false` 只保留大括号与名称）], [`true`],
    [`region.extent`], [`top` 填到图的顶端，`curve` 只填到曲线], [`top`],
    [`label.<group>.<side>`], [移动一组标签（参见 @sec-nudges）], [无],
  )
] <tab-micro>

颜色元素有 `axis`、`label`、`guide`、`marker`、`total`、`average`、`marginal`、`variable`、`fixed`、`price`、`region_light`、`region_mid` 与 `region_dark`。每一项接受一个主题角色，所以 `manual` 给出黑白，`default` 给出彩色。

变动后的曲线一律是细实线，平行移动一律是直箭头，弯箭头只表示转动；设置改变线宽，不改变这些惯例。

== 程序中的主题

#api(("PlotTheme", "shared_theme", "default_theme"), syntax: [
  ```python
  shared_theme(name)
  default_theme(palette=None)
  ```
])[
  `PlotTheme` 保存一张图的外观：颜色、线宽、标记大小、区域底色、字体与语言。`shared_theme(name)` 由 #pkg("mosaickit") 的共用主题名称（例如 `"manual"`）创建；`default_theme()` 回传没有明确指定时图形使用的主题，也就是目前激活的 `Config` 的主题。
]

== 区域底色 <sec-region-fill>

生产图中的边际报酬区间可以上色或不上色，可以填到图顶或只填到曲线，每个区间也可以有自己的颜色。

```python
from dataclasses import replace

from micro_viz import shared_theme, total_product_canvas

theme = replace(shared_theme("manual"), region_extent="curve")
total_product_canvas(
    result,
    theme=theme,
    region_colors={"increasing": "#bbbbbb", "diminishing": "#dddddd"},
)
```

`region_colors` 把区间种类（`increasing`、`diminishing`、`negative`）对应到颜色；没有列出的种类保留主题的底色。

#fig("/figures/production/total_product.zh-CN.svg", width: 46%, caption: [
  底色填到图顶
]) <fig-region-top>

#fig("/figures/production/total_product_under_curve.zh-CN.svg", width: 46%, caption: [
  底色填到曲线
]) <fig-region-curve>

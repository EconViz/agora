#import "/template/manual.typ": *

= 简介 <sec-intro>

#changed("0.1.0")[以 `principle-econ` 名称首次发布：线性市场、税收、福利、绘图与命令行界面]
#changed("0.10.0")[由 `principle-econ` 更名为 #pkg("principle-viz")，加入 EconViz 系列；Python 软件包名称改为 `principle_viz`]
  "0.10.0",
)[由 `principle-econ` 更名为 #pkg("principle-viz")，加入 EconViz 系列；Python 软件包名称改为 `principle_viz`]
#changed("0.10.0")[图形改以 #pkg("mosaickit") 绘制（`mosaickit>=0.5.1,<0.6.0`）]
#changed("0.10.0")[项目工具由 Poetry 改为 #pkg("uv")]
#changed("0.10.1")[CI 测试 Python 3.10–3.13]

#pkg("principle-viz") 是经济学原理的绘图软件包，涵盖供给与需求、均衡及其移动、税收与补贴、价格管制、福利、国际贸易、市场失灵、要素市场与生产可能性曲线。每个主题都有计算与图形两个部分：计算返回数值，图形依教科书惯例绘制。

输出格式包括 PNG、SVG 与 PDF；命令行工具则以 JSON 输出计算结果。

#pkg("principle-viz") 属于 EconViz 系列软件包，绘图使用与领域无关的场景与绘制函数库 #pkg("mosaickit")。同系列的 #pkg("utility-viz") 是个体经济学绘图软件包，涵盖效用模型、最优消费组合求解，以及无异曲线、预算线、消费者均衡、需求曲线与 Edgeworth 箱形图；本软件包不包含这些功能。

== 功能范围

#pkg("principle-viz") 处理线性市场，功能分为市场、政策、应用与工具四个部分。计算与图形可分开使用；同一个结果可以打印、输出为 JSON，也可以交给 `MarketFigure` 绘制。

== 阅读指引

本手册依主题分成市场、政策、应用与工具四个部分（参见#ref(<tab-guide>)）：

#tbl(caption: [章节主题])[
  #booktabs(
    columns: (auto, auto, 1fr, auto),
    header: ([主题], [子主题], [说明], [章节]),
    table.cell(rowspan: 4)[市场],
    [线性市场],
    [直线、均衡与曲线移动],
    [#ref(<sec-markets>)],
    [离散市场],
    [逐单位的需求与供给表],
    [#ref(<sec-discrete>)],
    [市场曲线加总],
    [个人曲线的水平加总],
    [#ref(<sec-aggregation>)],
    [弹性与总收益],
    [点弹性、弧弹性与总收益曲线],
    [#ref(<sec-elasticity>)],
    table.cell(rowspan: 3)[政策],
    [福利],
    [消费者剩余、生产者剩余与无谓损失],
    [#ref(<sec-welfare>)],
    [税收与补贴],
    [税负楔子与补贴成本],
    [#ref(<sec-taxes>)],
    [价格管制],
    [价格上限、价格下限与短缺],
    [#ref(<sec-controls>)],
    table.cell(rowspan: 4)[应用],
    [国际贸易],
    [自由贸易、关税与进口配额],
    [#ref(<sec-trade>)],
    [市场失灵],
    [外部性、公共资源与公共物品],
    [#ref(<sec-failures>)],
    [劳动与可贷资金],
    [最低工资与政府借款],
    [#ref(<sec-factor>)],
    [生产可能性曲线],
    [机会成本、成长与比较优势],
    [#ref(<sec-ppf>)],
    table.cell(rowspan: 2)[工具],
    [图形],
    [标签、图层与配色],
    [#ref(<sec-figures>)],
    [命令行接口],
    [以 JSON 输出计算结果],
    [#ref(<sec-cli>)],
  )
] <tab-guide>

初次使用时，依序阅读#ref(<sec-quickstart>)、#ref(<sec-markets>)与#ref(<sec-figures>)。之后每章说明一个主题，先介绍计算，再介绍图形。查找特定命令的选项时，可直接前往#ref(<sec-cli>)。

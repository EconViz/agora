#import "/template/manual.typ": *

= 简介 <sec-intro>

#changed("0.1.0")[以 `principle-econ` 名称首次发布：线性市场、税收、福利、绘图与命令行界面]
#changed("0.10.0")[由 `principle-econ` 更名为 #pkg("principle-viz")，加入 EconViz 系列；Python 软件包名称改为 `principle_viz`]
#changed("0.10.0")[图形改以 #pkg("mosaickit") 绘制（`mosaickit>=0.5.1,<0.6.0`）]
#changed("0.10.0")[项目工具由 Poetry 改为 #pkg("uv")]
#changed("0.10.1")[CI 测试 Python 3.10–3.13]

#pkg("principle-viz") 是经济学原理课程的市场图形 Python 软件包，涵盖供给与需求、均衡及其移动、税收与补贴、价格管制、福利、国际贸易、市场失灵、要素市场与生产可能性曲线。每个主题都提供计算与图形两部分：计算返回数值；图形按教科书惯例绘制，曲线名称标在曲线末端而非图例中，福利面积的名称写在面积内，数值标在坐标轴上，所有文字都不遮住其他元素。

== 功能范围

本软件包处理*线性*市场。需求或供给曲线以反函数形式表示为直线：
$ p = a + b Q, $
其中 $a$ 为价格截距，$b$ 为斜率（需求 $b < 0$，供给 $b > 0$）。价格一律在纵轴、数量在横轴，沿用 #citet(<marshall1890>) 的画法。有两种情况不是单一直线：离散的逐单位表（详见#ref(<sec-discrete>)），以及由个人曲线加总而成的分段线性市场曲线（详见#ref(<sec-aggregation>)）。

计算与绘图彼此分开。`principle_viz.core`、`principle_viz.policy` 与 `principle_viz.welfare` 中的求解函数返回不可变的 dataclass，不导入任何绘图库；`principle_viz.plot` 中的图形再把这些结果转为 #pkg("mosaickit") 场景。同一个结果可以打印、测试、由命令行工具输出为 JSON，也可以绘制成图。

#pkg("principle-viz") 属于 EconViz 系列软件包，同系列的 #pkg("utility-viz") 负责消费者理论：无差异曲线、预算约束与由效用导出的需求。

== 阅读指引

各章按主题分组如#ref(<tab-guide>)。

#tbl(caption: [章节主题])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([主题], [内容], [章节]),
    table.cell(rowspan: 4)[市场],
    [直线、均衡、曲线移动], [#ref(<sec-markets>)],
    [离散逐单位表], [#ref(<sec-discrete>)],
    [由个人加总的市场曲线], [#ref(<sec-aggregation>)],
    [弹性与总收益], [#ref(<sec-elasticity>)],
    table.cell(rowspan: 3)[政策],
    [剩余与无谓损失], [#ref(<sec-welfare>)],
    [税收与补贴], [#ref(<sec-taxes>)],
    [价格上限与下限], [#ref(<sec-controls>)],
    table.cell(rowspan: 4)[应用],
    [国际贸易], [#ref(<sec-trade>)],
    [外部性、公共物品、公共资源], [#ref(<sec-failures>)],
    [劳动与可贷资金], [#ref(<sec-factor>)],
    [生产可能性曲线], [#ref(<sec-ppf>)],
    table.cell(rowspan: 2)[工具],
    [图形、标签、配色], [#ref(<sec-figures>)],
    [命令行], [#ref(<sec-cli>)],
  )
] <tab-guide>

初次使用时，先读#ref(<sec-quickstart>)，再读#ref(<sec-markets>)与#ref(<sec-figures>)。之后每章说明一个主题，先介绍计算，再介绍图形。

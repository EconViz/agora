#import "/template/manual.typ": *

= 简介 <sec-intro>

#changed("0.1.0")[首次发布：不可变的场景与图层、稀疏样式、具命名空间的主题、画布、可跨格的网格、参数表达式、动画、以任务为范围缓存的 Matplotlib 绘制，以及严格的 TOML 配置]
#changed("0.1.1")[PyPI 上的软件包信息连结首页、仓库、问题追踪、更新记录与发布说明]

#pkg("mosaickit") 软件包以小而不可变的元件组装二维图形：场景是有序的图层列表（路径、填色区域、标记、文字、箭头、标签、大括号），每个图层标明一个语意角色，主题把角色转为样式，渲染器再把结果输出为 PNG、SVG、PDF、GIF 或 MP4。它不涉及任何学科知识。#pkg("principle-viz")、#pkg("utility-viz") 等领域软件包自行定义模型与角色名称，再把要画的图层交给 #pkg("mosaickit")；曲线构造与 TikZ 导出则属于 #pkg("bezierkit") 等几何软件包。

== 设计

整个软件包贯穿四个原则。

/ 不可变的值: 图层、场景、样式、主题与规格都是冻结的 dataclass。`Canvas` 是包住不可变 `Scene` 的流式构建器；`snapshot()`、`copy()` 与 `bind()` 不会改动其他对象持有的场景。
/ 稀疏样式: 每个样式字段都可以是 `None`，表示继承。图层自带的样式位于画布覆盖、配置覆盖、主题与基本默认值之上（详见#ref(<sec-themes>)）。
/ 角色而非颜色: 图层只说明自己是什么（`"primary"`、`"axes.note"`、`"mypkg.boundary"`），外观由主题决定，而颜色是画布绘制时才解析的调色板名称（详见#ref(<sec-styles>)）。
/ 不遮盖任何东西的配置: 区域标签、点标签、大括号与坐标轴注释在其他内容画完后才配置，以显示像素上的纯几何计算，使文字不碰到任何线、标记、区域或其他文字（详见#ref(<sec-geometry>)、#ref(<sec-labels>)）。

== 数学与证明

自动配置创建在一些计算几何之上：方向测试、奇偶规则、到多边形边界的距离、寻找区域最深处的最佳优先搜寻，以及让坐标轴文字互不重叠的最小二乘排列。各章以编号的定义、引理、命题与定理陈述每个程序的保证，证明集中在#ref(<app-proofs>)，因此只读 API 时可略过。样式与主题的代数（稀疏合并、角色解析）以及参数绑定也以同样方式处理。几何部分的标准参考书为 #citet(<deberg2008>)，#ref(<thm-spread>)背后的保序最小二乘问题则参见 #citet(<barlow1972>)。

== 阅读指引

#tbl(caption: [章节指引])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([主题], [内容], [章节]),
    table.cell(rowspan: 3)[构造],
    [画布、规格、场景], [#ref(<sec-canvas>)],
    [路径、填色、标记、文字、坐标轴], [#ref(<sec-layers>)],
    [坐标轴标记、注释与大括号], [#ref(<sec-annotations>)],
    table.cell(rowspan: 2)[配置],
    [配置几何], [#ref(<sec-geometry>)],
    [区域标签与点标签], [#ref(<sec-labels>)],
    table.cell(rowspan: 2)[外观],
    [样式、颜色、调色板], [#ref(<sec-styles>)],
    [主题、角色、配置], [#ref(<sec-themes>)],
    table.cell(rowspan: 2)[输出],
    [参数、网格、动画], [#ref(<sec-parameters>)],
    [渲染器、缓存、保存], [#ref(<sec-rendering>)],
  )
] <tab-guide>

初次使用请先读#ref(<sec-quickstart>)、#ref(<sec-canvas>)与#ref(<sec-layers>)。本手册的图都是 #pkg("mosaickit") 自己的输出：每张图由它所示范的画布或网格绘制，并以印在此处的尺寸存成 PDF。

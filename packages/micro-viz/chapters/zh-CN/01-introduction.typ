#import "/template/manual.typ": *

= 简介 <sec-intro>

#changed("0.2.0.dev0")[开发版的第一版手册：生产者理论、市场结构、要素市场、不确定性与信息]
#changed("0.2.0.dev0")[图形以 #pkg("mosaickit") 绘制（`mosaickit>=1.0.0rc9,<2.0.0`）]

#pkg("micro-viz") 是个体经济学厂商端的 Python 套件：生产、成本、完全竞争、独占与定价、寡占、要素市场、不确定性与信息。每个主题都有一个*模型*，以数字回答问题，也有一张依教科书惯例由模型画出的*图形*。

图形可输出为 PNG、SVG 或 PDF。统计数据图与方块加箭头的流程图不在套件范围内。

#pkg("micro-viz") 属于 EconViz 套件家族，以 #pkg("mosaickit") 绘图；#pkg("mosaickit") 是与领域无关的场景与绘图函数库。消费者理论与一般均衡属于 #pkg("utility-viz")，入门的供需图属于 #pkg("principle-viz")，赛局理论不在本套件范围内。

== 范围

本套件涵盖六组主题，各有一章（参见 @tab-guide）。模型不引入任何绘图器，因此结果可以不画图直接使用；绘图函数只负责安置模型算出的内容。

== 阅读指引

#tbl(caption: [章节指引])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([主题], [说明], [章节]),
    [模型与图形],
    [模型、绘图函数、图层编号与多栏图如何配合],
    [#ref(<sec-model-figure>)],
    [生产与成本],
    [短期生产、成本函数、阶梯与折点成本],
    [#ref(<sec-production-costs>)],
    [竞争],
    [价格接受者厂商、产业供给、长期成本、进入],
    [#ref(<sec-competition>)],
    [独占与定价],
    [独占、独占性竞争、管制、价格歧视、两部定价、搭售、广告、可耗竭资源],
    [#ref(<sec-monopoly>)],
    [寡占],
    [双占、拗折需求、支配厂商、垂直关系],
    [#ref(<sec-oligopoly>)],
    [投入与技术],
    [等产量线、成本最小化、学习与范畴、要素市场、买方独占与工会],
    [#ref(<sec-inputs>)],
    [不确定性与信息],
    [期望效用、风险、拍卖、逆选择、信号、道德风险],
    [#ref(<sec-uncertainty>)],
    [设置],
    [`econ-viz.toml` 的 `[micro]` 表],
    [#ref(<sec-settings>)],
    [标签与位置],
    [语系表、取代文本、移动标签],
    [#ref(<sec-labels>)],
    [添加图形],
    [模型、绘图函数、文本、导出、测试],
    [#ref(<sec-adding>)],
    [动画],
    [让图形随参数变化],
    [#ref(<sec-animation>)],
  )
] <tab-guide>

初次使用时，依序阅读 @sec-quickstart 与 @sec-model-figure。各主题章节先说明模型，再展示图形。

本手册所有图形的绘制脚本依主题整理成一个压缩档：#link("https://econ-viz.org/assets/micro-viz/agora/micro-viz-examples.zip")[micro-viz-examples.zip]。

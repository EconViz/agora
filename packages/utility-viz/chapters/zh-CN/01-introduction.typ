#import "/template/manual.typ": *

= 简介 <sec-intro>

#changed("2.0.0b1")[由 #pkg("econ-viz") 更名为 #pkg("utility-viz")：发行包、导入名称、命令与配置文件一并更名]
#changed("2.0.0b1")[内部结构重整为 `core` 与 `models`；公开 API 为软件包根目录与 `utility_viz.models`]
#changed("2.0.0b1")[添加依赖 #pkg("mosaickit") 与 #pkg("bezierkit")]
#changed("2.0.0b1")[整个仓库通过 `mypy` 检查；Ruff 限制行长、复杂度与语句数量]
#changed("1.7.0")[CI 测试 Python 3.10–3.13，强制分支覆盖率，并对可运行的示例做冒烟测试]
#changed("1.12.0")[添加无差异曲线主次层级、焦点曲线及数值或序数标签]
#changed("1.11.0")[完成主题系统，统一画布、多面板图、需求图、效应分解与 Edgeworth 箱形图的视觉设置]
#changed("1.10.1")[软件包添加 `py.typed`，并在 CI 运行 Ruff 与 Mypy 检查]
#changed("1.7.0")[版本标签须通过测试后才会触发发布]
#changed("1.6.0")[`examples/output/` 的输出文件不再纳入版本控制]
#changed("1.5.0")[添加效应分解、需求图、PCC/ICC 路径、多面板版面与 TikZ 导出的示例脚本]
#changed("1.5.0")[添加 TikZ 导出与价格效应分解的回归测试]
#changed("1.4.0")[添加 `Animator` 与 `WidgetViewer` 的测试]
#changed("1.3.2")[发布流程跳过 PyPI 上已有的版本]
#changed("1.3.1")[软件包根目录的导出改为延迟加载，公开 API 不变]
#changed("1.3.0")[`examples/edgeworth_box.py` 涵盖常见的效用函数组合]
#changed("1.3.0")[添加 Edgeworth 测试]
#changed("1.2.2")[添加 PCC/ICC 示例生成器与测试]

#pkg("utility-viz") 是微观经济学绘图软件包，涵盖效用模型、最优消费组合求解与可视化。Python API 与命令行工具均可生成无差异曲线、预算线、消费者均衡、需求曲线及 Edgeworth 箱形图。

图形默认显示第一象限，坐标轴以箭头表示并隐藏数字刻度，标签支持 TeX 数学语法。输出格式包括 PNG、PDF、SVG、TikZ 与 GIF。

本软件包在 1.12 版以前名为 #pkg("econ-viz")，2.0.0 起更名为 #pkg("utility-viz")；变更内容与旧代码的兼容方式详见#ref(<sec-migrate>)。本手册说明预览版 2.0.0b1。

#pkg("utility-viz") 属于 EconViz 系列软件包：绘图通过与领域无关的场景与渲染库 #pkg("mosaickit")，曲线则以 #pkg("bezierkit") 描绘。经济学原理图形由同系列的 #pkg("principle-viz") 负责。

== 功能范围

#pkg("utility-viz") 的功能分为效用模型、均衡求解、效用水平、图层与导出格式五个部分。模型与求解结果可分开使用；同一模型也可交由画布、多面板图、需求图或分析 API 处理。

== 阅读指引

本手册按主题分成四个部分（参见#ref(<tab-guide>)）：

#tbl(caption: [章节主题])[
  #booktabs(
    columns: (auto, auto, 1fr, auto),
    header: ([主题], [子主题], [说明], [章节]),
    table.cell(rowspan: 4)[绘图与导出],
    [画布与图层],
    [坐标轴、曲线与均衡点],
    [#ref(<sec-canvas>)],
    [多面板图与需求图],
    [并排比较与需求曲线],
    [#ref(<sec-figures>)],
    [主题与配置文件],
    [配色、样式与配置文件],
    [#ref(<sec-themes>)],
    [输出格式],
    [导出图像与 TikZ],
    [#ref(<sec-export>)],
    table.cell(rowspan: 3)[模型与分析],
    [内置模型],
    [常见效用函数],
    [#ref(<sec-models>)],
    [自定义与多商品模型],
    [自定义函数与多商品、场景],
    [#ref(<sec-advanced>)],
    [比较静态与 Slutsky 矩阵],
    [需求导数与齐次性],
    [#ref(<sec-analysis>)],
    table.cell(rowspan: 2)[动画与交互],
    [GIF 动画],
    [参数变动的 GIF],
    [#ref(<sec-animation>)],
    [Jupyter 交互组件],
    [笔记本滑块调参数],
    [#ref(<sec-widgets>)],
    table.cell(rowspan: 2)[其他输入方式],
    [命令行工具],
    [使用命令行出图],
    [#ref(<sec-cli>)],
    [#LaTeX 效用函数解析],
    [从算式创建模型],
    [#ref(<sec-latex>)],
  )
] <tab-guide>

初次使用时，依次阅读#ref(<sec-quickstart>)与#ref(<sec-canvas>)。查询特定 API 时，可直接前往对应章节或命令索引。从 #pkg("econ-viz") 1.x 升级时，请先阅读#ref(<sec-migrate>)。

#import "/template/manual.typ": *

= 模型与图形 <sec-model-figure>

== 先模型，后图形

每个主题分成两层。

- *模型*是冻结的数据类别（frozen dataclass），检查输入，并以方法回答问题：`CubicCost.marginal_cost`、`Monopolist.solve`、`IndustrySupply.quantity`。模型从不引入绘图器，输入不当时抛出自己的例外（`CostError`、`CompetitionError`、`UncertaintyError`）。
- `micro_viz.visuals` 中的*绘图函数*把模型结果转成 #pkg("mosaickit") 的 `Canvas`：`unit_cost_canvas(analysis)`、`monopoly_canvas(outcome, analysis)`。绘图函数不含方程序，只安置模型算出的内容。

```python
from micro_viz import (
    CubicCost, LinearDemand, Monopolist, analyze_costs, monopoly_canvas,
)

demand = LinearDemand(intercept=30, slope=2)
cost = CubicCost(20, 6, -1.5, 0.15)
outcome = Monopolist(demand, cost).solve()
analysis = analyze_costs(cost, output_range=(1, 10))

monopoly_canvas(outcome, analysis, profit=True).save("monopoly.svg")
```

== 共同选项 <sec-options>

每个绘图函数都回传 `Canvas`，并接受相同的关键字选项。本手册的函数签名以 `**options` 表示它们。

#param("title", type: "str | None", default: "None")[标题。`None` 不画标题。]
#param("theme", type: "PlotTheme | None", default: "None")[图形的外观。`None` 使用已加载设置的主题（参见 @sec-settings）。]
#param("labels", type: "Mapping[str, str] | None", default: "None")[依标签编号取代的文本（参见 @sec-labels）。]
#param("x_label", type: "str | None", default: "None")[横轴标题；缺省由绘图函数决定。]
#param("y_label", type: "str | None", default: "None")[纵轴标题；缺省由绘图函数决定。]
#param("x_max", type: "float | None", default: "None")[横轴上界；与 `y_range` 一起固定，动画中的座标轴才不会跳动（参见 @sec-animation）。]
#param("y_range", type: "tuple[float, float] | None", default: "None")[纵轴范围。]
#param("margin", type: "float", default: "0.1")[座标轴在数据最大值之外多留的比例。]
#param("size", type: "tuple[float, float]", default: "(6.0, 6.0)")[图形大小，单位为英寸。]
#param("dpi", type: "int", default: "150")[PNG 输出的分辨率。]

画多栏的绘图函数以 `titles`（每栏一个）取代 `title`。

== 套件结构

#tbl(caption: [文件位置])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([位置], [内容]),
    [`micro_viz/<topic>.py`、`micro_viz/<topic>/`], [模型与求解器，不含绘图],
    [`micro_viz/visuals/`], [回传 `Canvas` 的绘图函数；`plane.py` 是平面图的小工具组（`Plane`）],
    [`micro_viz/locale/labels.json`], [所有内置文本，依编号与语言整理],
    [`micro_viz/theme.py`、`config.py`], [主题与 `[micro]` 设置结构],
    [`micro_viz/animation/`], [选用的参数动画],
    [`examples/scripts/`], [每个主题一支脚本；本手册的图形],
  )
] <tab-layout>

== 图层编号

绘图函数替每个图层指定稳定的编号，格式为 `micro.<prefix>.<kind>.<n>`，例如 `micro.cost.avc.label`。设置档的逐图标签表以这些编号为对象（参见 @sec-labels），动画也以它们在影格之间配对图层（参见 @sec-animation）。

== 多栏图

有数栏的图（市场与厂商、多厂房独占、产业供给）使用 #pkg("mosaickit") 的 `CanvasGrid`。横跨栏间空隙的虚线是从一格中的点连到下一格中的点的 `GridLink`，所以价格或边际成本的水准线保持连续。

== 与其他套件的关系

- #pkg("mosaickit") 负责绘制一切：场景、图层、主题、标签位置、格状排版与输出。#pkg("micro-viz") 运行时只依赖它。
- #pkg("bezierkit") 提供曲线几何。#pkg("micro-viz") 不直接引入它；图形需要其公开的几何 API 时才加入依赖。
- #pkg("kinetickit") 让图形成为动画，只随 `animation` 选用依赖安装（参见 @sec-animation）。
- #pkg("utility-viz") 与 #pkg("principle-viz") 负责消费者理论与入门的市场图。它们的对象可以搭配使用，#pkg("micro-viz") 不重写它们。

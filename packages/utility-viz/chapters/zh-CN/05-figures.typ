#import "/template/manual.typ": *

= 多面板图与需求图 <sec-figures>

== 多面板图

#changed("1.5.0", label: "Figure")[改善共享面板版面中坐标轴标签的位置与可见度]
#changed("1.10.0", label: "Figure")[未指定主题与字体时，使用当前的 `Config`]
#changed("1.11.0", label: "Figure")[面板背景、标签、线条与标记完整应用主题]

#api(("Figure",), added: "v1.2.0", syntax: [
  #raw("Figure(")#meta("layout")#raw(", x_max=")#meta("float")#raw(", y_max=")#meta("float")#raw(
    ", ..., shared_x=False, shared_y=False)",
  )
])[
  创建多面板图，坐标范围与样式参数与 `Canvas` 相同。使用 `fig[idx]` 获取面板，再调用 `add_utility()`、`add_budget()` 等绘图方法。
]

#example([```python
from utility_viz import Figure, Layout, Legend, levels, solve
from utility_viz.models import CobbDouglas

fig = Figure(
    Layout.SIDE_BY_SIDE,
    x_max=20,
    y_max=15,
    x_label="x",
    y_label="y",
    title="Before / After Price Change",
    shared_y=True,
)

cases = [
    (CobbDouglas(alpha=0.5, beta=0.5), 2.0, 3.0, 30.0, r"Before: $p_x=2$"),
    (CobbDouglas(alpha=0.3, beta=0.7), 4.0, 3.0, 30.0, r"After: $p_x=4$"),
]

for idx, (model, px, py, income, title) in enumerate(cases):
    eq = solve(model, px=px, py=py, income=income)
    panel = fig[idx]
    panel.ax.set_title(title)
    panel.add_utility(model, levels=levels.around(eq.utility, n=5), label="IC")
    panel.add_budget(px, py, income, fill=True, label="BC")
    panel.add_equilibrium(eq, show_ray=True)

fig[0].show_legend(legend=Legend(position="upper right"))
fig.save("figure_side_by_side.png")
```])

#fig("/figures/consumer/side_by_side.svg", width: 100%, caption: [
  价格变动前后比较。
])

#changed("1.2.0", label: "Layout")[多面板 `Figure` 版面与 `Layout` 枚举]
#api(("Layout",), added: "v1.2.0")[
  内置版面有 `SINGLE`、`STACKED`、`SIDE_BY_SIDE`、`TOP_TWO_BOTTOM_ONE`、`TOP_ONE_BOTTOM_TWO`、`GRID_2X2` 和 `GRID_3X3`。
]

== 路径

#changed("1.2.2", label: "PricePath")[PCC/ICC 路径默认经过平滑处理，端点略微延长，除非指定否则不显示标记]
#changed("1.2.2", label: "PricePath")[PCC/ICC 路径改用独立配色，并增加需求图商品空间的留白]

#changed("1.2.0", label: "PricePath")[添加 `PricePath`、`IncomePath` 与 `Canvas.add_path()`，支持 PCC/ICC 绘图]
#api(("PricePath", "IncomePath"), added: "v1.2.0", syntax: [
  ```python
  from utility_viz import IncomePath, LinearBudget, PricePath
  from utility_viz.models import CobbDouglas

  model = CobbDouglas(alpha=0.5, beta=0.5)
  budget = LinearBudget(px=2.0, py=2.0, income=40.0)

  price_path = PricePath(
      model,
      budget=budget,
      price="px",
      price_range=(0.8, 6.0),
      n=40,
  )
  income_path = IncomePath(
      model,
      budget=budget,
      income_range=(20.0, 80.0),
      n=30,
  )
  ```
])[
  `PricePath` 与 `IncomePath` 分别计算价格、收入变动时的最优消费组合。使用 `Canvas.add_path()` 绘制价格消费曲线（PCC）或收入消费曲线（ICC）；`PricePath` 也可用于需求图。
]

#api(("Canvas.add_path",), added: "v1.2.0", syntax: [
  ```python
  from utility_viz import Canvas, levels

  eq = price_path.equilibria[len(price_path.equilibria) // 2]
  lvls = levels.around(eq.utility, n=5)

  Canvas(x_max=25, y_max=20) \
      .add_utility(model, levels=lvls) \
      .add_path(price_path, label="PCC") \
      .save("price_path.png")
  ```
])[
  将 `PricePath` 或 `IncomePath` 添加画布。#ref(<fig-price-path>)中，Cobb-Douglas 模型在 $p_x$ 变动时，$y$ 的需求量不变，因此 PCC 为水平线。
]

#fig("/figures/consumer/price_path.svg", width: 42%, caption: [
  价格消费曲线。
]) <fig-price-path>

== 需求图

#changed("1.2.0", label: "DemandDiagram")[添加 `DemandDiagram`，联动显示商品空间与 Marshall 需求]
#changed("1.9.0", label: "DemandDiagram")[支持 `Legend`、`Marker`、`Label` 与各图层的 `Stroke`]
#api(("DemandDiagram",), added: "v1.2.0", syntax: [
  #raw("DemandDiagram(")#meta("price path")#raw(", title=None, ...)") \
  #raw(".add_marshallian_panel(price_markers=None, show_pcc=False, show_demand_guides=True)")
])[
  根据 `PricePath` 绘制两个面板：上方为预算线与最优消费组合，下方为对应的 Marshall 需求曲线（参见#ref(<fig-demand>)）。目前只接受 `PricePath`，并分别处理平滑、折点与角解。`show_pcc=True` 在上方面板显示价格消费曲线。
]

#example([```python
from utility_viz import DemandDiagram, LinearBudget, PricePath
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
budget = LinearBudget(px=2.0, py=2.0, income=40.0)
path = PricePath(
    model,
    budget=budget,
    price="px",
    price_range=(0.8, 6.0),
    n=40,
)

fig = DemandDiagram(path, title="Demand: Cobb-Douglas")
fig.add_marshallian_panel(
    price_markers=[1.5, 4.0],
    show_pcc=False,
    show_demand_guides=True,
)
fig.save("demand_cobb_douglas.png")
```])

#fig("/figures/consumer/demand.svg", width: 46%, caption: [
  需求曲线最优点。
]) <fig-demand>

== 价格效应分解

#changed("1.5.0", label: "decompose_price_effect")[价格效应分解：`decompose_price_effect()`、`PriceEffectDecomposition` 与 `Canvas.add_decomposition()`，可画出 A/B/C 消费组合以及替代与收入效应]
#changed("1.5.0", label: "decompose_price_effect")[效应分解的 API 可以直接从软件包根目录导入]
#changed("1.8.0", label: "Canvas.add_decomposition")[添加 `Effect`、`Marker` 与 `Label` 样式对象]
#changed("1.9.0", label: "Canvas.add_decomposition")[默认绘制 A、B、C 所在的无差异曲线，并支持曲线标签与 `Legend`]
#changed("1.9.0", label: "Canvas.add_decomposition")[横轴下方的效应箭头依 A→B、B→C 方向绘制；效应为零时不绘制箭头]

#api(("decompose_price_effect",), added: "v1.5.0", syntax: [
  #raw("decompose_price_effect(")#meta("model")#raw(", px=(")#meta("old")#raw(", ")#meta("new")#raw("), py=")#meta(
    "float",
  )#raw(", income=")#meta("float")#raw(", method=")#meta("method")#raw(")")
])[
  将价格效应分解为替代效应与收入效应。Hicks 补偿 #citep(<hicks1939>) 维持原效用水平；Slutsky 补偿 #citep(<slutsky1915>) 则使原消费组合在新价格下恰好可负担。返回值包含下列字段：
]

#param("A, B, C")[原始、补偿后与最终的消费组合。]
#param("substitution_effect")[替代效应。]
#param("income_effect")[收入效应。]
#param("total_effect")[总效应。]
#param("compensated_income")[补偿后的收入。]

#api(("Canvas.add_decomposition",), added: "v1.5.0", updated: "v1.9.0")[
  在画布上标示 A、B、C 三个消费组合、预算线、无差异曲线与效应箭头。Hicks 分解绘制通过 A 与 C 的曲线；Slutsky 分解另绘制通过 B 的曲线。
]

#param("show_curves", type: "bool", default: "True")[绘制分解用的无差异曲线；已有自定义无差异曲线时设为 `False`，避免重复。]
#param("curve_stroke", type: "Stroke | None", default: "None")[无差异曲线的样式。]
#param("curve_label", type: "Label | None", default: "None")[显示并设置 $U_0$、$U_1$ 与 $U_B$ 标签。]
#param("substitution, income", type: "Effect | None", default: "None")[替代效应与收入效应的样式（参见下方 `Effect`）。]
#param("point_marker", type: "Marker | None", default: "None")[消费组合的标记。]
#param("point_label", type: "Label | None", default: "None")[消费组合的文字。]
#param("legend", type: "Legend | None", default: "None")[图例位置与样式（参见下方 `Legend`）。]

#api(("Effect",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Effect(color=None, y=None, label=None, label_position="right", label_offset=4, opacity=None)`
])[
  设置替代效应或收入效应的颜色、横轴下方箭头高度、标签及透明度。线条本身仍可由 `substitution_stroke` 或 `income_stroke` 覆盖。
]

#api(("Legend",), added: "v1.9.0", syntax: [
  `Legend(position="auto", fontsize=None, frame=None, columns=None, visible=None, opacity=None)`
])[
  `"auto"` 选择与图形重叠最少的内侧角落；四个角落均与图形重叠时，图例移到右侧。也可指定 `"upper left"` 等内侧角落，或 `"top"`、`"bottom"`、`"left"`、`"right"` 等外侧位置。`Legend(visible=False)` 隐藏图例。
]

#example([```python
from utility_viz import (
    Canvas,
    DecompositionMethod,
    Effect,
    Label,
    Legend,
    decompose_price_effect,
)
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
result = decompose_price_effect(
    model,
    px=(2.0, 4.0),
    py=3.0,
    income=60.0,
    method=DecompositionMethod.HICKS,
)

(
    Canvas(x_max=25, y_max=25, title="Hicks decomposition")
    .add_decomposition(
        result,
        show_arrows=True,
        label_effects=True,
        show_x_projections=True,
        substitution=Effect(label="SE"),
        income=Effect(label="IE", opacity=0.8),
        curve_label=Label(position="right"),
        legend=Legend(position="bottom"),
    )
    .save("hicks.png")
)
```])

#fig("/figures/consumer/hicks.svg", width: 48%, caption: [
  Hicks 分解。
])

== Edgeworth 箱形图

#changed("1.3.2", label: "EdgeworthBox")[Edgeworth 契约曲线与价格线默认为黑色虚线]
#changed("1.3.1", label: "EdgeworthBox")[Edgeworth 的内部实现拆成 compute、state 与 plotter 三个模块]
#changed("1.3.0", label: "EdgeworthBox")[添加 `EdgeworthBox` 与 `EquilibriumFocusConfig`，支持两人交换经济绘图]
#changed("1.3.0", label: "EdgeworthBox")[契约曲线、核、Walras 均衡叠图，以及聚焦于均衡的无差异曲线]
#changed("1.8.0", label: "EdgeworthBox")[标记点、文字与坐标轴接受 `Marker`、`Label` 与 `Axis`]
#changed("1.10.0", label: "EdgeworthBox")[未指定主题与字体时，使用当前的 `Config`]
#changed("1.11.0", label: "EdgeworthBox")[箱框、契约曲线、核、禀赋、价格线与 Walras 均衡完整应用主题]

#api(("EdgeworthBox",), added: "v1.3.0", syntax: [
  #raw("EdgeworthBox(")#meta("utility A")#raw(", ")#meta("utility B")#raw(", total_x=")#meta("float")#raw(
    ", total_y=",
  )#meta("float")#raw(", ...)")
])[
  创建两人交换经济的 Edgeworth 箱形图 #citep(<edgeworth1881>)。$A$ 的原点在左下，$B$ 的原点在右上。使用 `add_*` 方法添加禀赋、契约曲线、核、价格线与 Walras 均衡。

  平滑偏好的契约曲线使用 `method="mrs"`；有折点、角解或自定义分段效用函数时，使用 `method="pareto"`。
]

#example([```python
from utility_viz import EdgeworthBox
from utility_viz.models import CobbDouglas

box = EdgeworthBox(
    CobbDouglas(alpha=0.8, beta=0.2),
    CobbDouglas(alpha=0.2, beta=0.8),
    total_x=12.0,
    total_y=10.0,
    title="Asymmetric Cobb-Douglas",
)

(
    box.add_endowment(5.0, 4.0)
    .add_contract_curve(n=100, method="mrs")
    .add_core()
    .add_price_line(px=1.2, py=1.0)
    .add_walrasian_equilibrium(px=1.2, py=1.0)
    .show_legend(loc="center left", bbox_to_anchor=(1.02, 0.5))
    .save("edgeworth.png")
)
```])

#fig("/figures/consumer/edgeworth.svg", width: 52%, caption: [
  契约曲线与均衡。
])

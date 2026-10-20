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
from utility_viz import Config, Figure, Layout, levels, solve
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # 本手册图形所用的设置

fig = Figure(Layout.SIDE_BY_SIDE, x_max=20, y_max=15, x_label="$x$", y_label="$y$", shared_y=True)

# 价格上涨前后
cases = [
    (CobbDouglas(alpha=0.5, beta=0.5), 2.0, 3.0, 30.0),
    (CobbDouglas(alpha=0.3, beta=0.7), 4.0, 3.0, 30.0),
]
for idx, (model, px, py, income) in enumerate(cases):
    eq = solve(model, px=px, py=py, income=income)
    panel = fig[idx]  # 面板都是 Canvas
    panel.add_utility(model, levels=levels.around(eq.utility, n=5))
    panel.add_budget(px, py, income, fill=True)
    panel.add_equilibrium(eq, show_ray=True)
fig.save("side_by_side.png")
```])

#fig("/figures/consumer/side_by_side.svg", width: 100%, caption: [
  价格变动前后比较。
])

#changed("1.2.0", label: "Layout")[多面板 `Figure` 版面与 `Layout` 枚举]
#api(("Layout",), added: "v1.2.0")[
  内置版面有 `SINGLE`、`STACKED`、`SIDE_BY_SIDE`、`TOP_TWO_BOTTOM_ONE`、`TOP_ONE_BOTTOM_TWO`、`GRID_2X2` 和 `GRID_3X3`。
]

#param("SINGLE", type: "Layout")[单个面板。]
#param("STACKED", type: "Layout")[上下两个面板。]
#param("SIDE_BY_SIDE", type: "Layout")[左右两个面板。]
#param("TOP_TWO_BOTTOM_ONE", type: "Layout")[上方两个、下方一个面板。]
#param("TOP_ONE_BOTTOM_TWO", type: "Layout")[上方一个、下方两个面板。]
#param("GRID_2X2", type: "Layout")[2 × 2 格四个面板。]
#param("GRID_3X3", type: "Layout")[3 × 3 格九个面板。]

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

#example([```python
from utility_viz import Canvas, Config, LinearBudget, PricePath, levels
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # 本手册图形所用的设置

model = CobbDouglas(alpha=0.5, beta=0.5)
budget = LinearBudget(px=2.0, py=2.0, income=40.0)
path = PricePath(model, budget=budget, price="px", price_range=(0.8, 6.0), n=40)

# 围绕路径中段最优点的曲线
eq = path.equilibria[len(path.equilibria) // 2]

cvs = Canvas(x_max=25, y_max=20, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=5))
cvs.add_path(path)  # 价格消费曲线
cvs.save("price_path.png")
```])

#fig("/figures/consumer/price_path.svg", width: 56%, caption: [
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

下图由 MosaicKit 图层画成，标签可逐一手动摆放。

#example([```python
from mosaickit import (
    AxisSpec,
    Canvas,
    CanvasGrid,
    CanvasSpec,
    DashStyle,
    Fill,
    Marker,
    MarkerLayer,
    PathLayer,
    Stroke,
    StyleBundle,
    TextLayer,
    TextStyle,
    build_axes,
)
import numpy as np

from utility_viz import solve
from utility_viz.core.scenes import UTILITY_THEME, budget_layers, indifference_layers
from utility_viz.models import CobbDouglas

INK, DARK, GREY = "#1a1a1a", "#222222", "#8c8c8c"  # 同 manual.toml 的颜色
text = TextStyle(color=INK, size=14)

# Cobb-Douglas 的 x 需求
model = CobbDouglas(alpha=0.5, beta=0.5)
py, income, px_a, px_b = 2.0, 40.0, 1.5, 4.0
points = {"A": px_a, "B": px_b}
optimum = {name: solve(model, px=px, py=py, income=income) for name, px in points.items()}
X = 29.0  # x 都从 0 画到 29


def panel(y_min, y_max, height, y_label):
    """白底、细轴的面板；从点通往坐标轴的辅助线是虚线。"""
    spec = CanvasSpec(
        x_range=(0, X), y_range=(y_min, y_max), width=4.6, height=height, x_label="", y_label=""
    )
    roles = {
        "canvas": StyleBundle(fill=Fill(color="#ffffff", opacity=1.0)),
        "axes": StyleBundle(stroke=Stroke(color=INK, width=1.0), text=text),
        "guide": StyleBundle(stroke=Stroke(color=INK, width=0.8, dash=DashStyle.DASHED)),
    }
    cv = Canvas(spec, theme=UTILITY_THEME, role_overrides=roles)
    cv.extend(
        build_axes(
            AxisSpec((0, X), arrow="end", label="$x$"),
            AxisSpec((0, y_max), arrow="end", label=y_label),
        )
    )
    cv.add(TextLayer((0, 0), "0", offset=(-6, -8), anchor="top-right", style=text, id="origin"))
    return cv


def mark(cv, name, x, y):
    """黑点与斜体字母，以及通往两轴的虚线辅助线。"""
    cv.add(PathLayer([(0, y), (x, y)], id=f"{name}.h", role="guide"))
    cv.add(PathLayer([(x, 0), (x, y)], id=f"{name}.v", role="guide"))
    cv.add(
        MarkerLayer(
            [(x, y)], marker=Marker(color=INK, size=26, edge_width=0), id=f"{name}.dot", z_index=5
        )
    )
    cv.add(
        TextLayer(
            (x, y),
            name,
            math=True,
            offset=(8, 6),
            anchor="bottom-left",
            style=text,
            id=f"{name}.label",
        )
    )


# 上图是商品空间
top = panel(-3.5, 24, 3.9, "$y$")
top.extend(budget_layers(px_a, py, income, layer_id="ba", stroke=Stroke(color=DARK, width=2.6)))
top.extend(
    budget_layers(
        px_b, py, income, layer_id="bb", stroke=Stroke(color=DARK, width=2.2, dash=DashStyle.DASHED)
    )
)
for name, eq in optimum.items():
    curve, _ = indifference_layers(
        model, [eq.utility], X, 24, layer_id=f"u.{name}", stroke=Stroke(color=GREY, width=2.6)
    )
    top.extend(curve)
    mark(top, name, eq.x, eq.y)

# 下图是需求曲线
bottom = panel(-1.2, 7, 3.6, "$p_x$")
prices = np.linspace(0.8, 6.0, 80)
demand = tuple(zip(0.5 * income / prices, prices))
bottom.add(PathLayer(demand, stroke=Stroke(color=GREY, width=2.6), id="demand"))
for name, eq in optimum.items():
    mark(bottom, name, eq.x, points[name])

CanvasGrid([[top], [bottom]]).save("demand.png")
```])

#fig("/figures/consumer/demand.svg", width: 62%, caption: [
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

#api(("DecompositionMethod",), added: "v1.5.0", syntax: [
  `DecompositionMethod.HICKS`, `SLUTSKY`
])[
  决定补偿组合 B 的方式。
]

#param("HICKS", type: "DecompositionMethod")[保持原来的效用水平：B 在原来的无差异曲线上。]
#param("SLUTSKY", type: "DecompositionMethod")[让原来的组合仍买得起：B 是新价格下通过 A 的预算线上的最优组合。]

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

下图同样由 MosaicKit 图层画成，两个效果的名称标在坐标轴下方。

#example([```python
from mosaickit import (
    ArrowLayer,
    ArrowStyle,
    AxisSpec,
    Canvas,
    CanvasSpec,
    DashStyle,
    Fill,
    Marker,
    MarkerLayer,
    PathLayer,
    Stroke,
    StyleBundle,
    TextLayer,
    TextStyle,
    build_axes,
)

from utility_viz import DecompositionMethod
from utility_viz.core.scenes import UTILITY_THEME, budget_layers, indifference_layers
from utility_viz.models import CobbDouglas, decompose_price_effect

INK, DARK, GREY = "#1a1a1a", "#222222", "#8c8c8c"  # 同 manual.toml 的颜色
text = TextStyle(color=INK, size=14)
effect_name = TextStyle(
    color=INK, size=13, family="PingFang SC"
)  # 选用中日韩字体

# x 的价格由 2 涨到 4
# A 旧 C 新 B 为补偿点
model = CobbDouglas(alpha=0.5, beta=0.5)
px0, px1, py, income = 2.0, 4.0, 3.0, 60.0
result = decompose_price_effect(
    model, px=(px0, px1), py=py, income=income, method=DecompositionMethod.HICKS
)
bundles = {"A": result.A, "B": result.B, "C": result.C}
X, Y = 26.0, 24.0

# 白底细轴的画布
spec = CanvasSpec(x_range=(0, X), y_range=(-7.5, Y), width=4.6, height=4.2, x_label="", y_label="")
roles = {
    "canvas": StyleBundle(fill=Fill(color="#ffffff", opacity=1.0)),
    "axes": StyleBundle(stroke=Stroke(color=INK, width=1.0), text=text),
    "guide": StyleBundle(stroke=Stroke(color=INK, width=0.8, dash=DashStyle.DASHED)),
}
cv = Canvas(spec, theme=UTILITY_THEME, role_overrides=roles)
cv.extend(
    build_axes(
        AxisSpec((0, X), arrow="end", label="$x$"), AxisSpec((0, Y), arrow="end", label="$y$")
    )
)
cv.add(TextLayer((0, 0), "0", offset=(-6, -8), anchor="top-right", style=text, id="origin"))

# 三条预算线与两条曲线
cv.extend(budget_layers(px0, py, income, layer_id="b0", stroke=Stroke(color=DARK, width=2.6)))
cv.extend(budget_layers(px1, py, income, layer_id="b1", stroke=Stroke(color=DARK, width=2.6)))
compensated = [(0, result.compensated_income / py), (X, (result.compensated_income - px1 * X) / py)]
cv.add(
    PathLayer(
        compensated, stroke=Stroke(color=INK, width=1.0, dash=DashStyle.DASHED), id="compensated"
    )
)
for name in ("A", "C"):
    curve, _ = indifference_layers(
        model,
        [bundles[name].utility],
        X,
        Y,
        layer_id=f"u.{name}",
        stroke=Stroke(color=GREY, width=2.6),
    )
    cv.extend(curve)

# 三个组合与虚线辅助线
for name, bundle in bundles.items():
    cv.add(PathLayer([(bundle.x, 0), (bundle.x, bundle.y)], id=f"{name}.guide", role="guide"))
    cv.add(
        MarkerLayer(
            [(bundle.x, bundle.y)],
            marker=Marker(color=INK, size=26, edge_width=0),
            id=f"{name}.dot",
            z_index=5,
        )
    )
    cv.add(
        TextLayer(
            (bundle.x, bundle.y),
            name,
            math=True,
            offset=(8, 6),
            anchor="bottom-left",
            style=text,
            id=f"{name}.label",
        )
    )

# x 方向效果画成箭头
# 名称展开到同一水平
gap, row, depth, spread = 0.2, 1.6, -4.4, 3.8
effects = [("A", "B", "替代效应", 1), ("B", "C", "收入效应", -1)]
for i, (start, end, name, direction) in enumerate(effects):
    x0, x1 = bundles[start].x, bundles[end].x
    sign = 1 if x1 > x0 else -1
    arrow = Stroke(color=GREY, width=1.8, arrow=ArrowStyle.TRIANGLE)
    cv.add(
        ArrowLayer((x0 + gap * sign, row), (x1 - gap * sign, row), stroke=arrow, id=f"effect.{i}")
    )
    foot = (x0 + x1) / 2 + direction * spread
    cv.add(
        PathLayer(
            [((x0 + x1) / 2, row - 0.6), (foot, depth + 0.4)],
            stroke=Stroke(color=INK, width=0.8),
            id=f"leader.{i}",
            clip=False,
        )
    )
    cv.add(TextLayer((foot, depth), name, anchor="top", style=effect_name, id=f"effect.label.{i}"))

cv.save("hicks.png")
```])

#fig("/figures/consumer/hicks.zh-CN.svg", width: 72%, caption: [
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

下图同样由 MosaicKit 图层画成，以教科书的图为蓝本，画出两人的无差异曲线。

#example([```python
import numpy as np
from mosaickit import (
    ArrowLayer,
    ArrowStyle,
    AxisSpec,
    Canvas,
    CanvasSpec,
    Fill,
    FillLayer,
    Marker,
    MarkerLayer,
    PathLayer,
    Stroke,
    StyleBundle,
    TextLayer,
    TextStyle,
)
from scipy.interpolate import CubicSpline

from utility_viz.core.scenes import UTILITY_THEME

INK, GREY, LENS = "#1a1a1a", "#8c8c8c", "#ececec"  # 同 manual.toml 的颜色
text = TextStyle(color=INK, size=12)

# 仿教科书的图 箱宽 10 高 6
# J 起于 O_J K 起于 O_K
# 曲线是过控制点的样条
J = {  # J 的控制点 由低到高
    1: (
        [3.80, 3.91, 4.18, 4.59, 5.12, 5.75, 6.46, 7.16, 8.07],
        [5.15, 4.29, 3.49, 2.74, 2.08, 1.52, 1.07, 0.79, 0.58],
    ),
    2: (
        [4.26, 4.37, 4.60, 4.94, 5.25, 5.90, 6.30, 7.15, 7.84],
        [5.28, 4.55, 3.86, 3.22, 2.79, 2.13, 1.83, 1.38, 1.17],
    ),
    3: (
        [5.12, 5.20, 5.38, 5.64, 5.95, 6.35, 6.81, 7.29, 7.80],
        [5.40, 4.88, 4.39, 3.93, 3.50, 3.18, 2.91, 2.73, 2.63],
    ),
}
K = {  # K 的控制点 由外而内
    1: (
        [3.38, 4.17, 4.91, 5.57, 5.95, 6.60, 6.93, 7.16, 7.19],
        [4.86, 4.65, 4.30, 3.83, 3.50, 2.57, 1.83, 0.79, 0.24],
    ),
    2: (
        [3.62, 4.22, 4.77, 5.27, 5.68, 6.03, 6.30, 6.47, 6.54],
        [4.35, 4.14, 3.83, 3.43, 2.97, 2.44, 1.83, 1.26, 0.64],
    ),
    3: (
        [3.64, 4.12, 4.55, 4.93, 5.25, 5.53, 5.73, 5.86, 5.92],
        [3.80, 3.65, 3.41, 3.11, 2.79, 2.33, 1.88, 1.41, 0.92],
    ),
}
# 四个配置 A 到 D
allocations = {"A": (7.16, 0.79), "B": (6.30, 1.83), "C": (5.25, 2.79), "D": (5.95, 3.50)}
# 标签的位置
letters = {"A": (7.41, 0.93), "B": (6.55, 1.90), "C": (5.48, 2.93), "D": (6.14, 3.67)}
curve_labels = {
    "U_J^1": (8.35, 0.48),
    "U_J^2": (8.12, 1.09),
    "U_J^3": (8.05, 2.58),
    "U_K^1": (7.46, 0.25),
    "U_K^2": (6.58, 0.36),
    "U_K^3": (5.95, 0.66),
}


def spline(points, n=240):
    """通过控制点的平滑曲线，取 n 个取样点。"""
    points = np.column_stack(points)  # 转成点的列表
    chord = np.r_[0, np.cumsum(np.hypot(*np.diff(points, axis=0).T))]
    return CubicSpline(chord, points)(np.linspace(0, chord[-1], n))


curves_j = {k: spline(v) for k, v in J.items()}
curves_k = {k: spline(v) for k, v in K.items()}

# 箱子加上放箭头的边界
# 每单位 0.6 英寸
x_range, y_range, unit = (-1.0, 11.15), (-0.8, 6.8), 0.6
spec = CanvasSpec(
    x_range=x_range,
    y_range=y_range,
    x_label="",
    y_label="",
    width=(x_range[1] - x_range[0]) * unit / 0.775,
    height=(y_range[1] - y_range[0]) * unit / 0.77,
)
roles = {"canvas": StyleBundle(fill=Fill(color="#ffffff", opacity=1.0))}
cv = Canvas(spec, theme=UTILITY_THEME, role_overrides=roles)
cv.add(
    PathLayer(
        [(0, 0), (10, 0), (10, 6), (0, 6), (0, 0)],
        stroke=Stroke(color=INK, width=0.6),
        id="box",
        clip=False,
    )
)

# 到配置 A 为止的透镜形
j1, k1 = curves_j[1], curves_k[1]
near = lambda curve, point: int(np.argmin(np.hypot(*(curve - point).T)))
gaps = [
    (np.hypot(*(j1[a] - k1[b])), a, b)
    for a in range(0, 240, 2)
    for b in range(0, 240, 2)
    if j1[a][1] > 4 and k1[b][0] < 4.2
]
_, a_top, b_top = min(gaps)
a_end, b_end = near(j1, allocations["A"]), near(k1, allocations["A"])
lens = [tuple(p) for p in k1[b_top : b_end + 1]] + [tuple(p) for p in j1[a_top : a_end + 1][::-1]]
cv.add(FillLayer(lens, fill=Fill(color=LENS, opacity=1.0), id="lens", z_index=0))

# 线宽与点的直径
for k, points in curves_j.items():
    cv.add(
        PathLayer(
            [tuple(p) for p in points], stroke=Stroke(color=INK, width=2.66), id=f"j{k}", z_index=2
        )
    )
for k, points in curves_k.items():
    cv.add(
        PathLayer(
            [tuple(p) for p in points], stroke=Stroke(color=GREY, width=2.66), id=f"k{k}", z_index=2
        )
    )
for name, point in allocations.items():
    cv.add(
        MarkerLayer(
            [point], marker=Marker(color=INK, size=41.6, edge_width=0), id=f"dot.{name}", z_index=4
        )
    )
    cv.add(
        TextLayer(
            letters[name],
            name,
            math=True,
            anchor="center",
            style=text,
            id=f"letter.{name}",
            z_index=4,
        )
    )
for label, point in curve_labels.items():
    cv.add(TextLayer(point, label, math=True, anchor="center", style=text, id=f"label.{label}"))
cv.add(TextLayer((-0.14, -0.20), "O_J", math=True, anchor="center", style=text, id="origin.j"))
cv.add(TextLayer((10.30, 6.18), "O_K", math=True, anchor="center", style=text, id="origin.k"))

# 沿轴的箭头标出两人的量
arrow, plain = Stroke(color=GREY, width=1.0, arrow=ArrowStyle.TRIANGLE), Stroke(
    color=GREY, width=1.0
)
cv.add(ArrowLayer((3.91, -0.34), (5.96, -0.34), stroke=arrow, id="side.bottom"))
cv.add(TextLayer((3.78, -0.35), "x_J", math=True, anchor="right", style=text, id="name.bottom"))
cv.add(ArrowLayer((5.93, 6.35), (3.98, 6.35), stroke=arrow, id="side.top"))
cv.add(TextLayer((6.07, 6.36), "x_K", math=True, anchor="left", style=text, id="name.top"))
cv.add(PathLayer([(-0.67, 1.91), (-0.67, 2.47)], stroke=plain, id="side.left.line", clip=False))
cv.add(ArrowLayer((-0.67, 3.47), (-0.67, 4.18), stroke=arrow, id="side.left"))
cv.add(TextLayer((-0.67, 2.99), "y_J", math=True, anchor="center", style=text, id="name.left"))
cv.add(PathLayer([(10.67, 3.47), (10.67, 4.04)], stroke=plain, id="side.right.line", clip=False))
cv.add(ArrowLayer((10.67, 2.47), (10.67, 1.78), stroke=arrow, id="side.right"))
cv.add(TextLayer((10.67, 3.01), "y_K", math=True, anchor="center", style=text, id="name.right"))

cv.save("edgeworth.png")
```])

#fig("/figures/consumer/edgeworth.svg", width: 86%, caption: [
  两位消费者通过配置 A 至 D 的无差异曲线；阴影透镜是双方都偏好于 A 的配置。
])

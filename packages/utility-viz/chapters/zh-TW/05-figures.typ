#import "/template/manual.typ": *

= 多面板圖與需求圖 <sec-figures>

== 多面板圖

#changed("1.5.0", label: "Figure")[改善共用面板版面中座標軸標籤的位置與可見度]
#changed("1.10.0", label: "Figure")[未指定主題與字型時，使用目前的 `Config`]
#changed("1.11.0", label: "Figure")[面板背景、標籤、線條與標記完整套用主題]

#api(("Figure",), added: "v1.2.0", syntax: [
  #raw("Figure(")#meta("layout")#raw(", x_max=")#meta("float")#raw(", y_max=")#meta("float")#raw(
    ", ..., shared_x=False, shared_y=False)",
  )
])[
  建立多面板圖，座標範圍與樣式參數與 `Canvas` 相同。使用 `fig[idx]` 取得面板，再呼叫 `add_utility()`、`add_budget()` 等繪圖方法。
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
  價格變動前後比較。
])

#changed("1.2.0", label: "Layout")[多面板 `Figure` 版面與 `Layout` 列舉]
#api(("Layout",), added: "v1.2.0")[
  內建版面有 `SINGLE`、`STACKED`、`SIDE_BY_SIDE`、`TOP_TWO_BOTTOM_ONE`、`TOP_ONE_BOTTOM_TWO`、`GRID_2X2` 和 `GRID_3X3`。
]

== 路徑

#changed("1.2.2", label: "PricePath")[PCC/ICC 路徑預設經過平滑處理，端點略微延長，除非指定否則不顯示標記]
#changed("1.2.2", label: "PricePath")[PCC/ICC 路徑改用獨立配色，並增加需求圖商品空間的留白]

#changed("1.2.0", label: "PricePath")[新增 `PricePath`、`IncomePath` 與 `Canvas.add_path()`，支援 PCC/ICC 繪圖]
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
  `PricePath` 與 `IncomePath` 分別計算價格、所得變動時的最適消費組合。使用 `Canvas.add_path()` 繪製價格消費曲線（PCC）或所得消費曲線（ICC）；`PricePath` 也可用於需求圖。
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
  將 `PricePath` 或 `IncomePath` 加入畫布。#ref(<fig-price-path>)中，Cobb-Douglas 模型在 $p_x$ 變動時，$y$ 的需求量不變，因此 PCC 為水平線。
]

#fig("/figures/consumer/price_path.svg", width: 42%, caption: [
  價格消費曲線。
]) <fig-price-path>

== 需求圖

#changed("1.2.0", label: "DemandDiagram")[新增 `DemandDiagram`，連動顯示商品空間與 Marshall 需求]
#changed("1.9.0", label: "DemandDiagram")[支援 `Legend`、`Marker`、`Label` 與各圖層的 `Stroke`]
#api(("DemandDiagram",), added: "v1.2.0", syntax: [
  #raw("DemandDiagram(")#meta("price path")#raw(", title=None, ...)") \
  #raw(".add_marshallian_panel(price_markers=None, show_pcc=False, show_demand_guides=True)")
])[
  依 `PricePath` 繪製兩個面板：上方為預算線與最適消費組合，下方為對應的 Marshall 需求曲線（參見#ref(<fig-demand>)）。目前只接受 `PricePath`，並分別處理平滑、拗折與角解。`show_pcc=True` 在上方面板顯示價格消費曲線。
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
  需求曲線最適點。
]) <fig-demand>

== 價格效果分解

#changed("1.5.0", label: "decompose_price_effect")[價格效果分解：`decompose_price_effect()`、`PriceEffectDecomposition` 與 `Canvas.add_decomposition()`，可畫出 A/B/C 消費組合以及替代與所得效果]
#changed("1.5.0", label: "decompose_price_effect")[效果分解的 API 可以直接從套件根目錄匯入]
#changed("1.8.0", label: "Canvas.add_decomposition")[新增 `Effect`、`Marker` 與 `Label` 樣式物件]
#changed("1.9.0", label: "Canvas.add_decomposition")[預設繪製 A、B、C 所在的無異曲線，並支援曲線標籤與 `Legend`]
#changed("1.9.0", label: "Canvas.add_decomposition")[橫軸下方的效果箭頭依 A→B、B→C 方向繪製；效果為零時不繪製箭頭]

#api(("decompose_price_effect",), added: "v1.5.0", syntax: [
  #raw("decompose_price_effect(")#meta("model")#raw(", px=(")#meta("old")#raw(", ")#meta("new")#raw("), py=")#meta(
    "float",
  )#raw(", income=")#meta("float")#raw(", method=")#meta("method")#raw(")")
])[
  將價格效果分解為替代效果與所得效果。Hicks 補償 #citep(<hicks1939>) 維持原效用水準；Slutsky 補償 #citep(<slutsky1915>) 則使原消費組合在新價格下恰好可負擔。回傳值包含下列欄位：
]

#param("A, B, C")[原始、補償後與最終的消費組合。]
#param("substitution_effect")[替代效果。]
#param("income_effect")[所得效果。]
#param("total_effect")[總效果。]
#param("compensated_income")[補償後的所得。]

#api(("Canvas.add_decomposition",), added: "v1.5.0", updated: "v1.9.0")[
  在畫布上標示 A、B、C 三個消費組合、預算線、無異曲線與效果箭頭。Hicks 分解繪製通過 A 與 C 的曲線；Slutsky 分解另繪製通過 B 的曲線。
]

#param("show_curves", type: "bool", default: "True")[繪製分解用的無異曲線；已有自訂無異曲線時設為 `False`，避免重複。]
#param("curve_stroke", type: "Stroke | None", default: "None")[無異曲線的樣式。]
#param("curve_label", type: "Label | None", default: "None")[顯示並設定 $U_0$、$U_1$ 與 $U_B$ 標籤。]
#param("substitution, income", type: "Effect | None", default: "None")[替代效果與所得效果的樣式（參見下方 `Effect`）。]
#param("point_marker", type: "Marker | None", default: "None")[消費組合的標記。]
#param("point_label", type: "Label | None", default: "None")[消費組合的文字。]
#param("legend", type: "Legend | None", default: "None")[圖例位置與樣式（參見下方 `Legend`）。]

#api(("Effect",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Effect(color=None, y=None, label=None, label_position="right", label_offset=4, opacity=None)`
])[
  設定替代效果或所得效果的顏色、橫軸下方箭頭高度、標籤及透明度。線條本身仍可由 `substitution_stroke` 或 `income_stroke` 覆寫。
]

#api(("Legend",), added: "v1.9.0", syntax: [
  `Legend(position="auto", fontsize=None, frame=None, columns=None, visible=None, opacity=None)`
])[
  `"auto"` 選擇遮蔽圖形最少的內側角落；四個角落皆與圖形重疊時，圖例移到右側。也可指定 `"upper left"` 等內側角落，或 `"top"`、`"bottom"`、`"left"`、`"right"` 等外側位置。`Legend(visible=False)` 隱藏圖例。
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

== Edgeworth 箱形圖

#changed("1.3.2", label: "EdgeworthBox")[Edgeworth 契約曲線與價格線預設為黑色虛線]
#changed("1.3.1", label: "EdgeworthBox")[Edgeworth 的內部實作拆成 compute、state 與 plotter 三個模組]
#changed("1.3.0", label: "EdgeworthBox")[新增 `EdgeworthBox` 與 `EquilibriumFocusConfig`，支援兩人交換經濟繪圖]
#changed("1.3.0", label: "EdgeworthBox")[契約曲線、核、Walras 均衡疊圖，以及聚焦於均衡的無異曲線]
#changed("1.8.0", label: "EdgeworthBox")[標記點、文字與座標軸接受 `Marker`、`Label` 與 `Axis`]
#changed("1.10.0", label: "EdgeworthBox")[未指定主題與字型時，使用目前的 `Config`]
#changed("1.11.0", label: "EdgeworthBox")[箱框、契約曲線、核、稟賦、價格線與 Walras 均衡完整套用主題]

#api(("EdgeworthBox",), added: "v1.3.0", syntax: [
  #raw("EdgeworthBox(")#meta("utility A")#raw(", ")#meta("utility B")#raw(", total_x=")#meta("float")#raw(
    ", total_y=",
  )#meta("float")#raw(", ...)")
])[
  建立兩人交換經濟的 Edgeworth 箱形圖 #citep(<edgeworth1881>)。$A$ 的原點在左下，$B$ 的原點在右上。使用 `add_*` 方法加入稟賦、契約曲線、核、價格線與 Walras 均衡。

  平滑偏好的契約曲線使用 `method="mrs"`；有拗折點、角解或自訂分段效用函數時，使用 `method="pareto"`。
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
  契約曲線與均衡。
])

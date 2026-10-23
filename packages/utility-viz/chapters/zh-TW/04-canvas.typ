#import "/template/manual.typ": *

= Canvas 畫布 <sec-canvas>

`Canvas` 以 #pkg("matplotlib") 的 `Figure` 與 `Axes` 為基礎，提供無異曲線、預算線與均衡點等圖層。

== 建構函式

#changed("1.7.0", label: "Canvas")[支援個別設定各圖的文字與數學字型，不影響 #pkg("matplotlib") 的全域設定]
#changed("1.8.0", label: "Canvas")[新增 `Axis`、`Marker`、`Label` 與 `Fill` 樣式物件]
#changed("1.9.0", label: "Canvas")[座標軸、原點、標題與其他文字元素接受 `Label`]
#changed("1.11.0", label: "Canvas")[背景、標籤、線條與標記均由主題提供預設值]
#changed("1.12.0", label: "Canvas.add_utility")[新增焦點效用層級、次要曲線樣式及序數標籤]

#api(("Canvas",), updated: "v1.7.0", syntax: [
  ```python
  from mosaickit import TextFonts
from utility_viz import ArrowStyle, Canvas, Stroke, themes

  cvs = Canvas(
      x_max=20,
      y_max=15,
      x_label="x",
      y_label="y",
      title=r"Cobb-Douglas $x^{0.5} y^{0.5}$",
      dpi=300,
      x_label_pos="right",   # top / right / bottom
      y_label_pos="top",     # left / top / right
      font="serif",          # sans / serif / mono
      fonts=TextFonts(serif="MyFont-Regular.otf"),
      math_font="STIXTwoMath-Regular.otf",
      axis_stroke=Stroke(width=1.0, arrow=ArrowStyle.TRIANGLE),
      theme=themes.default,
  )
  ```
])[
  建立畫布，並設定座標範圍、軸標籤、字型、線條樣式與主題。未明確傳入的視覺設定取自目前的 `Config` 與 `Theme`。
]

#param("x_max", type: "float", default: "10")[橫軸上限。]
#param("y_max", type: "float", default: "10")[縱軸上限。]
#param("x_label", type: "str", default: "\"X\"")[橫軸末端的標籤。]
#param("y_label", type: "str", default: "\"Y\"")[縱軸末端的標籤。]
#param("title", type: "str | None", default: "None")[圖形標題。]
#param("dpi", type: "int", default: "300")[點陣圖匯出解析度，限制在 1–1200 之間。]
#param("x_label_pos", type: "str", default: "\"right\"")[
  橫軸標籤相對箭頭的位置，也接受 `LabelPosition`（參見#ref(<tab-x-label-pos>)）。

]
#tbl(caption: [`x_label_pos` 值])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([值], [位置]),
    [`"top"`], [箭頭上方],
    [`"right"`], [箭頭右側],
    [`"bottom"`], [箭頭下方],
  )
] <tab-x-label-pos>
#param("y_label_pos", type: "str", default: "\"top\"")[
  縱軸標籤相對箭頭的位置（參見#ref(<tab-y-label-pos>)）。

]
#tbl(caption: [`y_label_pos` 值])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([值], [位置]),
    [`"left"`], [箭頭左側],
    [`"top"`], [箭頭上方],
    [`"right"`], [箭頭右側],
  )
] <tab-y-label-pos>
#param("font", type: "str", default: "None")[
  所有文字使用的通用字型：`"sans"`（預設）、`"serif"` 或 `"mono"`。已安裝的字型名稱（如 `"Arial"`）會報錯，請改用 `fonts`。
]
#param("fonts", type: "TextFonts", default: "None")[
  取代通用字型的字型檔，如 `TextFonts(serif="MyFont-Regular.otf")`。每個欄位可給一個檔案或檔案清單（一般、粗體等）；沒給的欄位沿用 DejaVu 預設。系統字型不會被搜尋，請直接給路徑。
]
#param("math_font", type: "MathFont | str", default: "None")[
  OpenType 數學字型或其檔案路徑，如 STIX Two Math，經由 #pkg("glyphkit") 排版數學式。未設定時由 #pkg("matplotlib") 排版。舊的字型組名稱（`stix`、`cm`、`dejavusans`）會報錯。
]
#param("axis_stroke", type: "Stroke", default: "theme")[
  同時設定兩軸的粗細、線條樣式、顏色與箭頭（詳見#ref(<sec-styles>)）。
]
#param("x_axis_stroke", type: "Stroke", default: "None")[單獨覆寫橫軸。]
#param("y_axis_stroke", type: "Stroke", default: "None")[單獨覆寫縱軸。]
#param("theme", type: "Theme", default: "themes.default")[配色與樣式主題（詳見#ref(<sec-themes>)）。]

== 繪圖方法

`add_*` 方法在目前的畫布加入圖層，並回傳同一個 `Canvas`，因此可串接呼叫（詳見#ref(<sec-chaining>)）。

#api(("add_utility",), syntax: [
  ```python
  cvs.add_utility(
      func,
      levels=3,          # 曲線條數或效用值清單
      color=None,        # 預設 theme.ic_color
      linewidth=None,    # 預設 theme.ic_linewidth
      show_rays=False,
      show_kinks=False,
      kink_radius=1.0,
      show_bliss=True,   # 標出極樂點
      show_ic_labels=False,
      stroke=None,
      ray_stroke=None,
      ic_label=None,
      highlight_level=None,
      secondary_stroke=None,
      label_style="numeric",
  )
  ```
])[
  繪製無異曲線。
]

#param("levels", type: "int | list", default: "3")[曲線條數或效用值清單；例如 `levels.around(eq.utility, n=5)` 會在均衡效用附近選取五個水準。]
#param("highlight_level", type: "float | None", default: "None")[焦點效用值。實際繪製時選取最接近的曲線，以主要樣式顯示。]
#param("secondary_stroke", type: "Stroke | None", default: "None")[其他曲線的樣式；省略時使用 `theme.secondary_ic_stroke`。]
#param("show_ic_labels", type: "bool", default: "False")[顯示曲線標籤。標籤沿曲線切線旋轉，並保留在可見繪圖區域內。]
#param("label_style", type: "str", default: "\"numeric\"")[`"numeric"` 顯示效用值；`"ordinal"` 依效用遞增順序顯示 $u_1, u_2, dots$。]

```python
lvls = levels.around(eq.utility, n=5)
cvs.add_utility(
    model,
    levels=lvls,
    highlight_level=eq.utility,
    show_ic_labels=True,
    label_style="ordinal",
)
```

#example([```python
from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # 載入圖形設定

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # 斜體的 x 與 y
cvs.add_utility(model, levels=levels.around(eq.utility, n=3))  # 圍繞最適點的三條曲線
cvs.save("add_utility.png")
```])

#fig("/figures/canvas/add_utility.svg", width: 56%, caption: [
  三條無異曲線
]) <fig-add-utility>

#api(("add_budget",), syntax: [
  ```python
  cvs.add_budget(
      px, py, income,
      color=None,
      linewidth=None,
      linestyle="-",
      label=None,        # 圖例標籤 LaTeX
      fill=False,        # 可行集合陰影
      fill_alpha=None,   # 預設 theme.budget_fill_alpha
      stroke=None,
  )
  ```
])[
  繪製預算線 $p_x x + p_y y = I$。
]

#param("fill", type: "bool | Fill", default: "False")[`True` 使用主題的陰影設定；傳入 `Fill` 可覆寫陰影顏色與透明度。]
#param("stroke", type: "Stroke | None", default: "None")[統一設定預算線的顏色、線寬、線型與透明度，優先於 `color`、`linewidth`、`linestyle` 等簡寫參數（詳見#ref(<sec-styles>)）。]
#param("label", type: "str | None", default: "None")[圖例文字；呼叫 `show_legend()` 後才會顯示圖例。]

#example([```python
from utility_viz import Canvas, Config

Config.load("manual.toml").use()  # 載入圖形設定

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # 斜體的 x 與 y
cvs.add_budget(2.0, 3.0, 30.0, fill=True)  # 預算線與可行集合
cvs.save("add_budget.png")
```])

#fig("/figures/canvas/add_budget.svg", width: 56%, caption: [
  預算線與陰影
])

#api(("add_equilibrium",), syntax: [
  ```python
  cvs.add_equilibrium(
      eq,                # solve() 的回傳值
      color=None,
      markersize=None,
      label="x^*",
      drop_dashes=True,  # 到兩軸的虛線
      show_ray=False,    # 擴張路徑
      drop_stroke=None,
      ray_stroke=None,
      marker=None,
  )
  ```
])[
  標記 `solve()` 回傳的最適消費組合。
]

#param("drop_dashes", type: "bool", default: "True")[顯示至兩軸的投影線。]
#param("show_ray", type: "bool", default: "False")[顯示通過原點與均衡點的射線。]
#param("marker", type: "Marker | None", default: "None")[均衡點的標記樣式（詳見#ref(<sec-styles>)）。]

#example([```python
from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # 載入圖形設定

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # 斜體的 x 與 y
cvs.add_utility(model, levels=levels.around(eq.utility, n=3))
cvs.add_budget(2.0, 3.0, 30.0, fill=True)
cvs.add_equilibrium(eq)  # 最適點與兩條輔助虛線
cvs.save("add_equilibrium.png")
```])

#fig("/figures/canvas/add_equilibrium.svg", width: 56%, caption: [
  均衡點與虛線
])

#api(("add_ray",), syntax: [
  ```python
  cvs.add_ray(
      slope,             # dy/dx
      color=None,
      linewidth=None,
      stroke=None,
  )
  ```
])[
  繪製通過原點、斜率為 `slope`（$dif y slash dif x$）的射線，用於標記擴張路徑或固定比例。
]

#example([```python
from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # 載入圖形設定

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # 斜體的 x 與 y
cvs.add_utility(model, levels=levels.around(eq.utility, n=3))
cvs.add_budget(2.0, 3.0, 30.0)
cvs.add_equilibrium(eq)
cvs.add_ray(eq.y / eq.x)  # 過原點與最適點的射線
cvs.save("add_ray.png")
```])

#fig("/figures/canvas/add_ray.svg", width: 56%, caption: [
  擴張路徑射線
])

#api(("add_point",), syntax: [
  ```python
  cvs.add_point(
      x, y,
      label=None,
      color=None,
      markersize=None,
      offset=None,       # 標籤位移 pt
      marker=None,
  )
  ```
])[
  在指定座標標記點。
]

#param("label", type: "str | Label | None", default: "None")[標記文字，可傳入字串或 `Label`。]
#param("offset", type: "tuple | None", default: "None")[文字相對標記點的位移，單位為 pt。]
#param("marker", type: "Marker | None", default: "None")[標記樣式。]

#example([```python
from utility_viz import Canvas, Config, Label, levels, solve
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # 載入圖形設定

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # 斜體的 x 與 y
cvs.add_utility(model, levels=[5.0])  # 一條無異曲線 u = 5
cvs.add_budget(2.0, 3.0, 30.0)
# 與預算線交於兩點
# 以 Label 放在點旁
cvs.add_point(3.17, 7.89, label=Label(text="A", position="top-right"))
cvs.add_point(11.83, 2.11, label=Label(text="B", position="top-right"))
cvs.save("add_point.png")
```])

#fig("/figures/canvas/add_point.svg", width: 56%, caption: [
  無異曲線交預算線於兩點
])

#api(("show", "save"), syntax: [
  ```python
  cvs.show()               # 互動視窗
  cvs.save("figure.png")   # .png / .pdf / .svg / .tex
  ```
])[
  `show()` 開啟互動視窗；`save()` 依副檔名匯出檔案（詳見#ref(<sec-export>)），並釋放對應的 #pkg("matplotlib") 圖形，因此應最後呼叫。
]

#example([```python
from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # 載入圖形設定

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # 斜體的 x 與 y
cvs.add_utility(model, levels=levels.around(eq.utility, n=3))
cvs.add_budget(2.0, 3.0, 30.0, fill=True)
cvs.add_equilibrium(eq, show_ray=True)  # 均衡點與擴張路徑
cvs.save("show_save.png")
```])

#fig("/figures/canvas/show_save.svg", width: 56%, caption: [
  完整畫布
]) <fig-show-save>

== 樣式 <sec-styles>

#changed("1.7.0", label: "Canvas")[`Canvas` 與 `Figure` 支援分別設定座標軸標籤位置、線條樣式與箭頭樣式]
#changed("1.7.0", label: "Stroke")[統一控制畫布、多面板圖、需求圖與 Edgeworth 箱形圖中線條的粗細、樣式、顏色與箭頭]
#changed("1.8.0", label: "Stroke")[線條樣式統一由 `Stroke` 表示；個別樣式參數保留為簡寫]
#changed("1.9.0", label: "Stroke")[新增 `opacity` 透明度]
#changed("1.6.0", label: "Canvas")[無異曲線的預設線寬從 `2.0` 降為 `1.8`]
#changed("1.0.2", label: "Canvas")[數學式的座標軸標籤不再被重複包裝]
#changed("1.3.1", label: "Canvas")[Canvas 的繪製拆成 `canvas.renderers` 與 `canvas.primitives`]

`LineStyle` 定義線型，`ArrowStyle` 定義箭頭樣式，`Stroke` 統一設定線寬、線型、顏色與箭頭，可套用於座標軸、預算線、路徑與投影線。

=== 線條樣式

#api(("LineStyle",), added: "v1.7.0", syntax: [
  `LineStyle.SOLID`、`DASHED`、`DOTTED`、`DASHDOT`
])[
  提供實線、虛線、點線與點畫線（參見#ref(<fig-line-styles>)）。座標軸接受列舉值或對應字串；其他線條透過 `Stroke(style=...)` 設定。
  `LineStyle` 就是 MosaicKit 的 `DashStyle`，沿用舊名稱。
]

#param("SOLID", type: "LineStyle")[實線。]
#param("DASHED", type: "LineStyle")[虛線。]
#param("DOTTED", type: "LineStyle")[點線。]
#param("DASHDOT", type: "LineStyle")[點劃線。]

#example([```python
from mosaickit import CanvasGrid

from utility_viz import Canvas, Config, LineStyle

Config.load("manual.toml").use()  # 載入圖形設定

styles = [LineStyle.SOLID, LineStyle.DASHED, LineStyle.DOTTED, LineStyle.DASHDOT]
titles = ["實線", "虛線", "點線", "點劃線"]
panels = [
    Canvas(title=title, x_label="$x$", y_label="$y$", x_label_pos="bottom", x_line_style=style, y_line_style=style)
    for style, title in zip(styles, titles)
]
for panel in panels:
    panel.spec = panel.spec.replace(width=2.2, height=2.0)  # 小畫布
CanvasGrid([panels]).save("line_styles.png")
```])

#fig("/figures/canvas/line_styles.zh-TW.svg", width: 56%, caption: [
  四種線條樣式
]) <fig-line-styles>

=== 箭頭樣式

#api(("ArrowStyle",), added: "v1.7.0", syntax: [
  `ArrowStyle.SIMPLE`、`TRIANGLE`、`FANCY`、`WEDGE`
])[
  提供四種箭頭樣式（參見#ref(<fig-arrow-styles>)）。座標軸透過 `x_arrow_style`、`y_arrow_style` 設定；其他線條透過 `Stroke(arrow=...)` 設定。
  `ArrowStyle` 是 MosaicKit 的；`SIMPLE` 即 `OPEN`，仍接受 `"->"` 與 `"-|>"`。
]

#param("SIMPLE", type: "ArrowStyle")[開口箭頭（`->`）。]
#param("TRIANGLE", type: "ArrowStyle")[實心三角形（`-|>`），預設值。]
#param("FANCY", type: "ArrowStyle")[彎曲、漸細的箭頭。]
#param("WEDGE", type: "ArrowStyle")[細楔形箭頭。]

#example([```python
from mosaickit import CanvasGrid

from utility_viz import ArrowStyle, Canvas, Config

Config.load("manual.toml").use()  # 載入圖形設定

styles = [ArrowStyle.SIMPLE, ArrowStyle.TRIANGLE, ArrowStyle.FANCY, ArrowStyle.WEDGE]
titles = ["簡單", "三角形", "花式", "楔形"]
panels = [
    Canvas(title=title, x_label="$x$", y_label="$y$", x_label_pos="bottom", x_arrow_style=style, y_arrow_style=style)
    for style, title in zip(styles, titles)
]
for panel in panels:
    panel.spec = panel.spec.replace(width=2.2, height=2.0)  # 小畫布
CanvasGrid([panels]).save("arrow_styles.png")
```])

#fig("/figures/canvas/arrow_styles.zh-TW.svg", width: 56%, caption: [
  四種箭頭樣式
]) <fig-arrow-styles>

=== Stroke

#api(("Stroke",), added: "v1.7.0", updated: "v1.9.0", syntax: [
  #raw("Stroke(width=")#meta("float")#raw(", style=")#meta("LineStyle")#raw(", color=")#meta("str")#raw(
    ", arrow=",
  )#meta("ArrowStyle")#raw(", opacity=")#meta("float")#raw(")")
])[
  設定線寬、線型、顏色、箭頭與透明度。未指定的欄位沿用目前主題。`opacity` 的有效範圍為 0 至 1。
]

=== Axis

#api(("Axis",), added: "v1.8.0", syntax: [
  `Axis(label=None, label_position=None, stroke=None)`
])[
  集中設定單一座標軸的標籤、標籤位置與線條。`Canvas`、`Figure`、`DemandDiagram` 與 `EdgeworthBox` 均接受 `x_axis` 與 `y_axis`。若同時傳入簡寫參數，`Axis` 中已設定的欄位優先。

  ```python
  from utility_viz import Axis, Canvas, Label, Stroke

  cvs = Canvas(
      x_axis=Axis(
          label=Label(text="x_1", fontsize=16),
          label_position="bottom",
          stroke=Stroke(width=1.2),
      ),
      y_axis=Axis(label="x_2"),
  )
  ```
]

=== Marker 與 Label

#api(("Marker",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Marker(color=None, size=None, shape=None, opacity=None)`
])[
  設定標記點的顏色、大小、形狀與透明度。`shape` 接受 #pkg("matplotlib") 的標記字串，例如 `"o"`、`"s"`、`"^"`、`"D"` 與 `"*"`。
]

#api(("Label",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Label(text=None, position=None, offset=None, color=None, fontsize=None, visible=None, opacity=None)`
])[
  設定文字、位置、位移、顏色、字級、可見性與透明度。位置可為上、下、左、右或四個角落；`Label(visible=False)` 隱藏對應文字。

  ```python
  from utility_viz import Label, Marker

  cvs.add_equilibrium(
      eq,
      marker=Marker(shape="s", size=8),
      label=Label(position="bottom-left", offset=8),
  )
  cvs.add_point(
      12, 2,
      marker=Marker(color="black", shape="D"),
      label=Label(text="A", position="left", fontsize=14),
  )
  ```
]

=== Fill

#api(("Fill",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Fill(color=None, opacity=None)`
])[
  設定陰影區域的顏色與透明度。`alpha` 是 `opacity` 的相容簡寫；同一次呼叫不得傳入不同的 `alpha` 與 `opacity`。

  ```python
  from utility_viz import Fill

  cvs.add_budget(
      2, 3, 30,
      fill=Fill(color="lightgrey", opacity=0.4),
  )
  ```
]

== 串接呼叫 <sec-chaining>

`add_*` 方法支援串接呼叫，最後以 `save()` 匯出：

```python
Canvas(x_max=20, y_max=15) \
    .add_utility(model, levels=lvls) \
    .add_budget(2.0, 3.0, 30.0, fill=True) \
    .add_equilibrium(eq, show_ray=True) \
    .save("figure.png")
```

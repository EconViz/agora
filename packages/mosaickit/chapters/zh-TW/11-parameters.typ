#import "/template/manual.typ": *

= 參數、網格與動畫 <sec-parameters>

== 參數與運算式

圖層座標可以是以具名參數表示的運算式，而不是數字。此時場景描述的是一族圖形，參數的每組值對應一張；綁定就是從中選出一張。

#api(("Parameter",), syntax: [#raw("Parameter(name, value_type=None)")])[
  具名的佔位符。設定 `value_type` 時，綁定的值必須是該型別的實例；所有綁定的值都必須可雜湊。`values(seq)` 回傳 `ParameterValues`，並立即檢查每個值。
]

#api(("Expression", "Constant"), syntax: [#raw("Constant(value)")])[
  不可變的運算式樹。參數與常數可用 `+`、`-`、`*`、`/`、`**`、一元 `-`，以及比較運算 `<`、`<=`、`>`、`>=` 與 `equals()` 組合；一般數字會包裝成常數。運算式的相等是結構相等（`==` 比較兩棵樹，因此改用 `equals()` 建立比較運算式），把運算式當成真假值使用會引發 `BindingError`：須先求值。`evaluate(bindings)` 依參數到值的對應計算結果；`free_parameters()` 是樹中所含參數的集合。
]

#definition(name: [運算式與綁定])[
  #emph[運算式]是常數、參數，或對運算式 $e_1, e_2$ 與運算 $circle.small$ 而言的 $e_1 circle.small e_2$。其自由參數為 $"free"(c) = emptyset$、$"free"(p) = {p}$、$"free"(e_1 circle.small e_2) = "free"(e_1) union "free"(e_2)$。#emph[綁定] $beta$ 是從參數到值的有限對應，而 $"bind"(e, beta)$ 定義為：若 $"free"(e) subset.eq "dom" beta$，則為值 $e(beta)$；否則若 $e$ 為參數，則為 $e$ 本身；否則為 $"bind"(e_1, beta) circle.small "bind"(e_2, beta)$。一般值 $v$ 沒有自由參數，求值結果為其本身。
] <def-binding>

#theorem(name: [部分綁定])[
  對每個運算式 $e$ 與綁定 $beta$，
  (i) $"free"("bind"(e, beta)) = "free"(e) without "dom" beta$；
  (ii) 對每個滿足 $"dom" gamma inter "dom" beta = emptyset$ 且 $"dom" gamma supset.eq "free"(e) without "dom" beta$ 的綁定 $gamma$，$"bind"(e, beta)(gamma) = e(beta union gamma)$。
] <thm-binding>

#corollary(name: [分階段綁定])[
  對定義域不相交的綁定 $beta_1, beta_2$，$"bind"("bind"(e, beta_1), beta_2)$ 與 $"bind"(e, beta_1 union beta_2)$ 有相同的自由參數，且在這些參數的每個綁定下有相同的值。特別地，`canvas.bind(p, 1).bind(q, 2)` 與 `canvas.bind({p: 1, q: 2})` 畫出相同的圖。
] <cor-stages>

`bind` 會走訪 tuple、mapping 與所有 `mosaickit` dataclass，因此整個場景一次綁定；圖層的 `model` 保持不變。繪製仍含自由參數的場景時，引發指名這些參數的 `BindingError`。

```python
from mosaickit import Canvas, Parameter, TextLayer

x = Parameter("x", value_type=float)
template = Canvas().add(TextLayer((x, 2 * x + 1), "moving"))
frame = template.bind(x, 3.0)
print(frame.snapshot().layers[0].position)    # (3.0, 7.0)
```

== 網格

#api(("CanvasGrid", "Span"), syntax: [
  #raw("CanvasGrid(cells, rows=None, cols=None, shape=None, links=())") \
  #raw("Span(canvas, rows=1, cols=1)")
])[
  在一張圖中放多個畫布。`cells` 可以是畫布、`Span` 與 `None`（空格）組成的平面清單，逐列填入；也可以是列的清單，此時允許跨列，且每列必須涵蓋所有欄。`shape=(rows, cols)` 等同同時傳入兩者。每個畫布都會複製，之後修改它不影響網格。跨格重疊、跨格超出邊界、格子過多，或混用平面與巢狀格子，都引發 `ConfigurationError`。`render()` 與 `save()` 的用法與畫布相同。
]

#proposition(name: [推斷的網格形狀])[
  對 $n >= 1$ 個一般格子組成的平面清單，若未給 `rows` 與 `cols`，網格有 $c = ceil(sqrt(n))$ 欄、$r = ceil(n slash c)$ 列。此時 $r c >= n$、$r <= c$，且空格少於 $c$ 個，全部位於最後一列。
] <prop-grid-shape>

只給 `cols` 時 $r = ceil(n slash c)$；只給 `rows` 時 $c = ceil(n slash r)$。

#api(("Layout", "CanvasGrid.from_layout"), syntax: [#raw("CanvasGrid.from_layout(canvases, layout)")])[
  常見的排列：`SINGLE`、`STACKED`（兩列）、`SIDE_BY_SIDE`、`GRID_2X2`、`GRID_3X3`，以及三個畫布的 `TOP_TWO_BOTTOM_ONE` 與 `TOP_ONE_BOTTOM_TWO`，其中單獨的畫布橫跨兩欄。
]

#api(("CanvasGrid.sweep",), syntax: [#raw("CanvasGrid.sweep(template, values, *, cols=None)")])[
  `ParameterValues` 的每個值一格，每格是綁定該值的範本。
]

#api(("GridLink",), added: "0.5.0", syntax: [#raw("GridLink(start_cell, start, end_cell, end, role=\"link\", stroke=None)")])[
  從某格的 `start` 到另一格的 `end` 的直線，兩點各以所在格子的資料座標表示，畫在整張圖上、橫越格子間的空隙。格子依配置順序編號。樣式是在起點格子的主題中解析的 `role`，再疊上 `stroke`。格子編號超出範圍時，在建立網格時引發 `ConfigurationError`。
  #changed("0.5.0", label: "CanvasGrid")[新增 `links`]
]

```python
from mosaickit import Canvas, CanvasGrid, GridLink, MarkerLayer, Parameter, Stroke

shift = Parameter("shift", value_type=float)
template = Canvas().add(MarkerLayer([(5, 2.5 + shift)]))
cells = [template.bind(shift, v) for v in (0.0, 2.0, 4.0)]
link = GridLink(0, (5, 2.5), 2, (5, 6.5), stroke=Stroke(dash="dashed"))
CanvasGrid(cells, cols=3, links=[link]).save("sweep.pdf")
```

#fig("/figures/grids/sweep.pdf", width: auto, caption: [
  三個值的掃描與跨格連線。
]) <fig-sweep>

== 動畫

#api(("Animation",), syntax: [
  #raw("Animation(template, parameter, values, fps=30)") \
  #raw("Animation.sweep(canvas, values, *, fps=30)")
])[
  每個值一格畫面：綁定該參數值的範本。`frames()` 以與繪製器無關的場景逐一產生畫面；`save(path)` 寫出 GIF（透過 Pillow）或 MP4（透過 `ffmpeg`）。建立動畫時即依參數檢查各值；值清單為空或 `fps` 非正時引發 `ConfigurationError`。
]

```python
from mosaickit import Animation

values = shift.values([0.0, 1.0, 2.0, 3.0])
Animation.sweep(template, values, fps=4).save("sweep.gif")
```

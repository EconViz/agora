#import "/template/manual.typ": *

= 座標軸註記 <sec-annotations>

#changed("0.3.0", label: "mosaickit")[座標軸外的文字依欄排列：標記、外側大括號（每條軌道一欄）、註記；標記與註記會沿軸分散，互不重疊]

y 軸是繪圖區的左緣，x 軸是下緣，兩軸外側的空間稱為#emph[邊欄]。三種圖層寫在邊欄，第四種在繪圖區內畫大括號。

== 標記、註記與大括號

#api(("AxisMarkLayer",), added: "0.3.0", syntax: [#raw("AxisMarkLayer(axis, value, label, math=False, style=None, *, role=\"axes\", ...)")])[
  在軸 `"x"` 或 `"y"` 的 `value` 處、繪圖區外的短符號，例如 $a_0$ 或 $p^*$。
]

#api(("AxisNoteLayer",), added: "0.3.0", syntax: [#raw("AxisNoteLayer(axis, value, text, style=None, *, role=\"axes.note\", ...)")])[
  說明 `value` 的文字，可跨多行，位於邊欄最外側的欄。在預設主題中，`axes.note` 角色使註記比標記小且淡（9 pt、`grey-600`）。
  #changed("0.3.0")[預設主題新增 `axes.note` 角色]
]

#api(("BraceLayer",), added: "0.3.0", syntax: [#raw("BraceLayer(axis, start, end, label=None, side=\"inside\", *, role=\"axes\", math=False, style=None, stroke=None, ...)")])[
  覆蓋軸上 `start`..`end` 的大括號，可加標籤。`side="outside"` 畫在邊欄、標記之外；`"inside"` 畫在繪圖區內側，標籤配置在不遮蓋任何線、點、區域或文字之處，尖端外沒有空位時改以引線拉出。
  #changed("0.4.0")[內側大括號的標籤在尖端外沒有空位時改以引線拉出（先前會重疊並發出警告）]
]

#api(("SpanBraceLayer",), added: "0.4.0", syntax: [#raw("SpanBraceLayer(start, end, label=None, side=\"below\", *, role=\"axes\", math=False, style=None, stroke=None, ...)")])[
  繪圖區內兩點之間的大括號。跨距必須是水平（`side` 為 `"above"` 或 `"below"`）或垂直（`"left"` 或 `"right"`）；大括號往 `side` 凸出，離兩點 4 pt、深 8 pt，標籤位於尖端之外，配置在不遮蓋任何東西之處（詳見#ref(<sec-labels>)）。
]

```python
from mosaickit import AxisMarkLayer, AxisNoteLayer, BraceLayer, Canvas, quadrant_axes

canvas = Canvas().extend(quadrant_axes(10, 10))
for value, symbol, note in [(7, "a_1", "Upper\nvalue"), (5, "a_0", "Lower\nvalue")]:
    canvas.add(AxisMarkLayer("y", value, symbol, math=True))
    canvas.add(AxisNoteLayer("y", value, note))
canvas.add(BraceLayer("y", 5, 7, "Span", side="outside"))
canvas.add(AxisMarkLayer("x", 6, "b", math=True))
```

#fig("/figures/annotations/gutter.pdf", width: auto, caption: [
  y 軸邊欄的標記、註記與大括號。
]) <fig-gutter>

#fig("/figures/annotations/span.pdf", width: auto, caption: [
  兩點之間的跨距大括號。
]) <fig-span>

== 邊欄的欄位

各欄從軸線向外排列，與軸線相距 5 pt，彼此相距 8 pt：標記、每條外側大括號軌道一欄、註記。每欄寬度等於其中最寬的內容，空欄不占空間也不加間距（參見#ref(<fig-gutter>)，圖中另加了輔助線）。剩下兩個問題：同一欄中相鄰的文字不可重疊，以及哪些大括號可以共用一條軌道。

== 沿軸分散文字

一欄中的每段文字都是沿軸的一個區間，以它所標示的值為中心。區間重疊時將它們分開，保持順序，並在最小平方意義下移動最少。

#definition(name: [保序排列])[
  設 $c_1, dots, c_n$ 為中心、$s_1, dots, s_n >= 0$ 為大小、$g >= 0$ 為間距，編號使 $c_1 <= dots.c <= c_n$（相等者依輸入順序）。#emph[排列]是滿足
  $ x_(k+1) - x_k >= (s_k + s_(k+1)) / 2 + g, quad k = 1, dots, n - 1 $
  的向量 $x in RR^n$；#emph[保序排列問題]是在所有排列中最小化 $sum_k (x_k - c_k)^2$。
] <def-packing>

#api(("spread",), added: "0.3.0", syntax: [#raw("mosaickit.layout.stack1d.spread(centers, sizes, gap=0.0) -> tuple[float, ...]")])[
  求解此問題：把重疊的連續項目合併成群，每群緊密排列在其成員目標的平均值周圍，只要某群撞上前一群就再合併。結果依輸入順序回傳。長度不一致或大小為負時引發 `ValueError`。
]

#theorem(name: [分散為最佳解])[
  `spread` 回傳#ref(<def-packing>)保序排列問題的唯一解。
] <thm-spread>

這個程序其實是保序迴歸的相鄰違反者合併演算法 #citep(<ayer1955>)：扣除緊密排列的位移後，間距限制就變成 $y_1 <= dots.c <= y_n$。

#corollary(name: [分散結果的性質])[
  設 $x$ 為 `spread` 的結果，則
  (i) 任兩項 $i != j$ 滿足 $|x_i - x_j| >= (s_i + s_j) / 2 + g$；
  (ii) 若各中心本身已構成排列，則 $x = c$；
  (iii) 每群的位移總和為零，因此群的平均位置等於其成員的平均目標。
] <cor-spread>

#fig("/figures/geometry/spread.pdf", width: auto, caption: [
  目標（上）與分散結果（下）。
]) <fig-spread>

#ref(<fig-spread>)中前三項重疊而形成一群，群的位置以它們想要的位置平均為中心；其餘兩項本來就分開，不會移動。

== 大括號的軌道

跨距（連同標籤）彼此太近的大括號必須放在不同軌道，也就是與軸線不同的距離。

#definition(name: [衝突區間])[
  對間距 $g >= 0$，若 $b + g <= a'$ 與 $b' + g <= a$ 都不成立，則區間 $[a, b]$ 與 $[a', b']$ #emph[衝突]。#emph[軌道指派]為每個區間指定一個軌道編號，使衝突的區間不共用軌道。
] <def-conflict>

#api(("assign_lanes",), added: "0.3.0", syntax: [#raw("mosaickit.layout.stack1d.assign_lanes(intervals, gap=0.0) -> tuple[int, ...]")])[
  首次適配：依輸入順序處理區間，把每個區間放進與已有區間都不衝突的最低軌道。端點可依任一順序給出。
]

#theorem(name: [首次適配使用最少軌道])[
  `assign_lanes` 一定回傳軌道指派。若區間依下端遞增的順序給出，且每個都滿足 $b - a + g > 0$，則它恰好使用 $omega$ 條軌道，其中 $omega$ 為兩兩衝突的區間數的最大值；沒有任何軌道指派能用得更少。
] <thm-lanes>

其他順序下，首次適配可能用到多於必要的軌道，因此可能重疊的大括號應依數值由低到高加入。

#api(("gutter_columns",), added: "0.3.0", syntax: [#raw("mosaickit.layout.gutter.gutter_columns(mark_width, brace_widths, note_width, *, start, gap)")])[
  邊欄背後的純欄位配置：回傳 `GutterColumns`，含 `marks`、`braces`（每條軌道一個 `Band`，由內而外）與 `notes`，各為從軸線向外量的 `Band(near, far)`，以及最遠邊緣 `extent`。
]

#import "/template/manual.typ": *

= 樣式與顏色 <sec-styles>

== 稀疏樣式

每個樣式都是凍結的 dataclass，所有欄位都可以是 `None`。`None` 表示繼承：值來自其下層的樣式（詳見#ref(<sec-themes>)）。假值不等於 `None`，因此 `opacity=0`、`width=0` 與 `LegendStyle(visible=False)` 都是明確的覆寫。

#definition(name: [稀疏合併])[
  設 $a$、$b$ 為同型別、欄位集合為 $F$ 的樣式。樣式 $a triangle.r b$（`a.merged_over(b)`）對每個 $phi in F$ 滿足
  $ (a triangle.r b)_phi = cases(a_phi & "if" a_phi != "None", b_phi & "otherwise".) $
  空樣式 $epsilon$ 的每個欄位都是 `None`。樣式組逐槽合併，`None` 槽視同 $epsilon$。
] <def-merge>

#proposition(name: [合併構成么半群])[
  對同型別的樣式 $a, b, c$，
  (i) $(a triangle.r b) triangle.r c = a triangle.r (b triangle.r c)$；
  (ii) $epsilon triangle.r a = a triangle.r epsilon = a$；
  (iii) $a triangle.r a = a$。
  逐欄來看，$a_1 triangle.r dots.c triangle.r a_n$ 取第一個不是 `None` 的值。
] <prop-monoid>

因此一疊樣式可以任意分組合併，結果可視為優先順序清單：第一個設定某欄位的來源勝出。

#api(("SparseStyle",), syntax: [#raw("style.merged_over(base)")])[
  #ref(<def-merge>)的合併。不同型別的樣式引發 `TypeError`。
]

== 樣式型別

#api(("Stroke", "DashStyle", "ArrowStyle", "ArrowPlacement"), syntax: [
  #raw("Stroke(color=None, width=None, dash=None, arrow=None, opacity=None)")
])[
  線條。`width` 以點為單位；`dash` 為 `DashStyle`（`SOLID`、`DASHED`、`DOTTED`、`DASHDOT`）；`arrow` 為 `ArrowStyle`（`OPEN`、`TRIANGLE`、`FANCY`、`WEDGE`），畫在圖層的 `ArrowPlacement`（`START`、`END`、`BOTH`）處。
]

#api(("Fill",), syntax: [#raw("Fill(color=None, opacity=None, hatch=None)")])[
  區域內部；`hatch` 為 Matplotlib 的網紋樣式，例如 `"//"`，`""` 表示無網紋。
]

#api(("Marker",), syntax: [#raw("Marker(color=None, size=None, shape=None, opacity=None, edge_color=None, edge_width=None)")])[
  點標記。`size` 是以平方點計的面積，與 Matplotlib 的 `scatter` 相同（36 為 6 pt 圓點）；`shape` 為 Matplotlib 標記，例如 `"o"`、`"s"` 或 `"X"`。
]

#api(("TextStyle",), syntax: [#raw("TextStyle(color=None, size=None, family=None, weight=None, opacity=None, rotation=None)")])[
  文字。`size` 以點為單位，`family` 為字型家族名稱，`weight` 例如 `"bold"`，`rotation` 為逆時針角度（度）。
]

#api(("LegendStyle",), syntax: [#raw("LegendStyle(visible=None, location=None, frame=None, size=None)")])[
  圖例：Matplotlib 的位置名稱，例如 `"best"` 或 `"upper right"`、外框，以及字級。
]

大小、寬度與透明度在建立樣式時檢查：大小必須為有限非負數，透明度在 $[0, 1]$ 內，旋轉角度必須有限。

#tbl(caption: [基本預設值])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([樣式], [值]),
    [`Stroke`], [`grey-800`、寬 1.5、實線、透明度 1],
    [`Fill`], [`grey-200`、透明度 0.3、無網紋],
    [`Marker`], [`grey-800`、大小 36、`"o"`、透明度 1、邊框 `grey-800` 寬 0],
    [`TextStyle`], [`grey-900`、12 pt、DejaVu Sans、一般字重、透明度 1、不旋轉],
    [`LegendStyle`], [顯示、位置 `"best"`、無外框、10 pt],
  )
] <tab-primitive>

== 顏色

#api(("Color", "TRANSPARENT"), syntax: [
  #raw("Color(red, green, blue, alpha=1.0)") \
  #raw("Color.from_hex(\"#RGB\" | \"#RRGGBB\" | \"#RRGGBBAA\")")
])[
  不可變的 RGBA 顏色，各通道在 $[0, 1]$ 內。`channels` 回傳四個值，`from_channels()` 建立顏色，`to_hex(include_alpha=None)` 寫出 `#RRGGBB`，當 `include_alpha` 為真、或預設情況下 alpha 不為 1 時加上 `AA`。`TRANSPARENT` 為 `Color(0, 0, 0, 0)`。
]

#proposition(name: [十六進位往返])[
  對每個由十六進位數字組成、形如 `#RRGGBB` 或 `#RRGGBBAA` 的字串 $h$，`Color.from_hex(h).to_hex(include_alpha=len(h) == 9)` 等於 $h$ 的大寫形式。三位數的 `#RGB` 讀作 `#RRGGBB`。
] <prop-hex>

樣式的 `color` 或 `edge_color` 接受 `Color`、`"#hex"` 字串（立即解析），或其他任何字串，後者保留為#emph[色盤名稱]。

== 色盤

#api(("Palette", "DEFAULT_PALETTE"), added: "0.2.0", syntax: [#raw("Palette(name, colors)")])[
  具名的顏色表。值可以是 `Color` 或十六進位字串；`palette[name]` 查詢顏色，名稱不存在時引發指名該色盤的 `ConfigurationError`，`name in palette` 檢查名稱是否存在。
]

#tbl(caption: [`DEFAULT_PALETTE`])[
  #booktabs(
    columns: (auto, auto, 1fr),
    header: ([名稱], [值], [預設主題中的用途]),
    [`grey-900`], [`#222222`], [文字],
    [`grey-800`], [`#333333`], [線條、標記、座標軸],
    [`grey-600`], [`#666666`], [座標軸註記],
    [`grey-400`], [`#999999`], [輔助線],
    [`grey-200`], [`#CCCCCC`], [填色],
    [`grey-100`], [`#E6E6E6`], [],
    [`white`], [`#FFFFFF`], [畫布背景],
    [`blue`], [`#01A2D9`], [`primary`],
    [`red`], [`#E3120B`], [`secondary`],
    [`teal`], [`#00887D`], [`accent`],
  )
] <tab-palette>

主題與樣式以名稱指稱顏色，畫布建立繪製計畫時才在生效的色盤（`Config.palette`）中查詢，因此繪製器只會收到具體顏色。在色盤中改一次顏色，所有指名它的角色都隨之改變。色盤缺少的名稱在繪製時引發 `ConfigurationError`，訊息指明角色、樣式欄位與色盤。Python 的 `Palette` 會取代預設色盤，因此應從 `DEFAULT_PALETTE.colors` 建立，以保留內建主題所用的名稱：

```python
from mosaickit import DEFAULT_PALETTE, Canvas, Config, Palette, use_config

brand = Palette("brand", {**DEFAULT_PALETTE.colors, "blue": "#0072B2"})
with use_config(Config(palette=brand)):
    canvas = Canvas()          # primary now draws in #0072B2
```

#changed("0.2.0", label: "DEFAULT_PALETTE")[新增：灰階、`white`、`blue`、`red` 與 `teal`；預設主題的顏色取自此色盤，`primary`、`secondary` 與 `accent` 改為藍、紅、青綠]
#changed("0.3.0", label: "Palette")[主題與樣式以色盤名稱指稱顏色，在建立繪製計畫時依 `Config.palette` 解析；未知名稱引發指明角色、欄位與色盤的 `ConfigurationError`]

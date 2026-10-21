#import "/template/manual.typ": *

= 樣式與顏色 <sec-styles>

== 稀疏樣式

每個樣式都是凍結的 dataclass，且所有欄位都可以是 `None`。`None` 表示繼承：欄位值取自較低優先序的樣式（詳見#ref(<sec-themes>)）。假值不等於 `None`，因此 `opacity=0`、`width=0` 與 `LegendStyle(visible=False)` 都是明確的覆寫。

#definition(name: [稀疏合併])[
  設 $a$、$b$ 為同型別、欄位集合為 $F$ 的樣式。樣式 $a triangle.r b$（`a.merged_over(b)`）對每個 $phi in F$ 滿足
  $ (a triangle.r b)_phi = cases(a_phi & "if" a_phi != "None", b_phi & "otherwise".) $
  空樣式 $epsilon$ 的每個欄位都是 `None`。樣式組逐槽合併，`None` 槽視同 $epsilon$。
] <def-merge>

#proposition(name: [合併構成么半群])[
  對同型別的樣式 $a, b, c$，
  (i) 結合律為
  $ (a triangle.r b) triangle.r c = a triangle.r (b triangle.r c); $
  (ii) 空樣式是單位元，
  $ epsilon triangle.r a = a triangle.r epsilon = a; $
  (iii) 合併具冪等性，
  $ a triangle.r a = a. $
  逐欄來看，$a_1 triangle.r dots.c triangle.r a_n$ 取第一個不是 `None` 的值。
] <prop-monoid>

因此，多個樣式無論如何分組合併，結果都一樣。可將它們視為一份優先順序清單：某欄位的值取自第一個設定該欄位的來源。

#api(("SparseStyle",), syntax: [#raw("style.merged_over(base)")])[
  #ref(<def-merge>)的合併。不同型別的樣式引發 `TypeError`。
]

== 樣式型別

#api(("Stroke",), syntax: [
  #raw("Stroke(color=None, width=None, dash=None, arrow=None, opacity=None)")
])[
  線條樣式。`width` 以點為單位；`dash` 為 `DashStyle`（`SOLID`、`DASHED`、`DOTTED`、`DASHDOT`）；`arrow` 為 `ArrowStyle`（`OPEN`、`TRIANGLE`、`FANCY`、`WEDGE`），畫在圖層的 `ArrowPlacement`（`START`、`END`、`BOTH`）處。
]

#changed("0.8.0", label: "DashStyle")[`DashStyle` 與 `ArrowStyle` 接受簡寫，讓其他套件可直接當作自己的線型與箭頭列舉]
#api(("DashStyle",), syntax: [
  `DashStyle.SOLID`, `DASHED`, `DOTTED`, `DASHDOT`
])[
  `Stroke` 的線條型態；也接受簡寫 `-`、`--`、`:` 與 `-.`。
]

#param("SOLID", type: "DashStyle")[實線。]
#param("DASHED", type: "DashStyle")[虛線。]
#param("DOTTED", type: "DashStyle")[點線。]
#param("DASHDOT", type: "DashStyle")[點劃線。]

#api(("ArrowStyle",), syntax: [
  `ArrowStyle.OPEN`, `TRIANGLE`, `FANCY`, `WEDGE`
])[
  `Stroke` 的箭頭樣式。`SIMPLE` 是 `OPEN` 的另一個名稱，也接受 Matplotlib 寫法 `->` 與 `-|>`。
]

#param("OPEN", type: "ArrowStyle")[開口箭頭。]
#param("TRIANGLE", type: "ArrowStyle")[實心三角形。]
#param("FANCY", type: "ArrowStyle")[彎曲、漸細的箭頭。]
#param("WEDGE", type: "ArrowStyle")[細楔形箭頭。]

#api(("ArrowPlacement",), syntax: [
  `ArrowPlacement.START`, `END`, `BOTH`
])[
  圖層的箭頭畫在哪裡。
]

#param("START", type: "ArrowPlacement")[在第一個點。]
#param("END", type: "ArrowPlacement")[在最後一個點。]
#param("BOTH", type: "ArrowPlacement")[兩端都畫。]

#api(("Fill",), syntax: [#raw("Fill(color=None, opacity=None, hatch=None)")])[
  區域內部的填色樣式；`hatch` 為 Matplotlib 的網紋樣式，例如 `"//"`，`""` 表示無網紋。
]

#api(("Marker",), syntax: [#raw("Marker(color=None, size=None, shape=None, opacity=None, edge_color=None, edge_width=None)")])[
  點標記樣式。`size` 是以平方點計的面積，與 Matplotlib 的 `scatter` 相同（36 對應 6 pt 圓點）；`shape` 為 Matplotlib 標記，例如 `"o"`、`"s"` 或 `"X"`。
]

#api(("TextStyle",), syntax: [#raw("TextStyle(color=None, size=None, font=None, weight=None, opacity=None, rotation=None)")])[
  文字樣式。`size` 以點為單位，`font` 是通用字型（`"sans"`、`"serif"` 或 `"mono"`，見#ref(<sec-fonts>)），`weight` 是 1 到 1000 的整數、`"normal"` 或 `"bold"`，`rotation` 為逆時針旋轉的角度（度）。`family`（字型家族名稱）仍可用但已棄用：它走 Matplotlib 繪製，不經過 #pkg("glyphkit")，1.0 會移除。
  #changed("0.9.0", label: "TextStyle")[`weight` 不再棄用]
  #changed("0.9.1", label: "TextStyle")[新增 `font` 欄位；`family` 棄用]
]

== 字型 <sec-fonts>

文字由 #pkg("glyphkit") 依字型檔排版。三種通用字型指向字型檔：`"sans"`（預設）、`"serif"` 與 `"mono"`。MosaicKit 預設用 DejaVu Sans、DejaVu Serif 與 DejaVu Sans Mono，也就是 Matplotlib 附的檔案。它*不會搜尋系統字型*，其他字型一律要自己給檔案。

#api(("TextFonts",), syntax: [
  #raw("TextFonts(sans=None, serif=None, mono=None)")
])[
  取代通用字型的字型檔。每個欄位可給一個檔案或一份清單；需要的字面都要列出，例如一般與粗體兩個檔案。樣式的 `weight` 會選最接近的字面，檔案順序則是第一個檔案缺字時依序嘗試的順序。沒給的欄位沿用 DejaVu 預設。
  #changed("0.9.0", label: "TextFonts")[新增；sans 接一份檔案清單]
  #changed("0.9.1", label: "TextFonts")[新增 `serif` 與 `mono`；預設為 DejaVu]
]

#api(("MathFont",), syntax: [
  #raw("MathFont(path, italic=True)")
])[
  OpenType 數學字型，如 STIX Two Math、Libertinus Math 或 Fira Math，檔案要有 `MATH` 表。`italic` 讓單一拉丁字母與小寫希臘字母用斜體字母表，和 TeX 一樣。沒有數學字型時，`$...$` 內的數學式由 Matplotlib 排版。
]

```python
from mosaickit import Canvas, CanvasSpec, Config, MathFont, TextFonts, TextLayer, TextStyle, use_config

fonts = TextFonts(serif=["fonts/Pagella-Regular.otf", "fonts/Pagella-Bold.otf"])
config = Config(fonts=fonts, math_font=MathFont("fonts/Pagella-Math.otf"))

with use_config(config):
    canvas = Canvas(CanvasSpec(x_range=(0, 1), y_range=(0, 1)))
    canvas.add(TextLayer((0.5, 0.5), "$u = x^{0.5}$", style=TextStyle(font="serif")))
```

TikZ 渲染器把 `sans`、`serif`、`mono` 對應到 `\sffamily`、`\rmfamily` 與 `\ttfamily`。
#changed("0.9.2", label: "TikZ")[`font` 對應到 TeX 字型家族]

#api(("LegendStyle",), syntax: [#raw("LegendStyle(visible=None, location=None, frame=None, size=None)")])[
  圖例樣式：包括 Matplotlib 的位置名稱（例如 `"best"` 或 `"upper right"`）、外框與字級。
]

建立樣式時會檢查大小、寬度與透明度：大小必須是有限的非負數，透明度必須在 $[0, 1]$ 內，旋轉角度也必須是有限值。

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
  具名的顏色表。值可以是 `Color` 或十六進位字串；`palette[name]` 用來查詢顏色，名稱不存在時會引發指名該色盤的 `ConfigurationError`；`name in palette` 用來檢查名稱是否存在。
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

主題與樣式以名稱指定顏色。畫布建立繪製計畫時，才會從生效的色盤（`Config.palette`）中查詢這些名稱，因此繪製器只會收到具體顏色。只要在色盤中修改一次顏色，所有指定該顏色的角色都會隨之改變。色盤若缺少某個名稱，繪製時會引發 `ConfigurationError`，訊息會指明角色、樣式欄位與色盤。Python 的 `Palette` 會取代預設色盤，因此應以 `DEFAULT_PALETTE.colors` 為基礎建立，才能保留內建主題所用的名稱：

```python
from mosaickit import DEFAULT_PALETTE, Canvas, Config, Palette, use_config

brand = Palette("brand", {**DEFAULT_PALETTE.colors, "blue": "#0072B2"})
with use_config(Config(palette=brand)):
    canvas = Canvas()          # primary now draws in #0072B2
```

#changed("0.2.0", label: "DEFAULT_PALETTE")[新增：灰階、`white`、`blue`、`red` 與 `teal`；預設主題的顏色取自此色盤，`primary`、`secondary` 與 `accent` 改為藍、紅、青綠]
#changed("0.3.0", label: "Palette")[主題與樣式以色盤名稱指稱顏色，在建立繪製計畫時依 `Config.palette` 解析；未知名稱引發指明角色、欄位與色盤的 `ConfigurationError`]

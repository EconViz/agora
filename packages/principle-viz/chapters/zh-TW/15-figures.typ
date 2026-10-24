#import "/template/manual.typ": *

= 圖形 <sec-figures>

#changed("0.10.0", label: "MarketFigure")[圖形改為正方形（150 dpi 下 6 × 6 英吋），背景為不透明白色；直線曲線止於價格軸的 92%]
#changed("0.10.0", label: "MarketFigure")[曲線名稱標在可見端點旁，不再放進圖例]
#changed("0.10.0", label: "MarketFigure")[座標軸名稱預設為 $p$ 與 $Q$，以斜體數學字放在箭頭外側；標題不再使用粗體]
#changed("0.10.0", label: "MarketFigure")[均衡與政策標籤由 #pkg("mosaickit") 放在點旁；擁擠處的數量改標在數量軸上]
#changed("0.10.0", label: "MarketFigure.finalize")[預設不加圖例；`finalize(legend=True)` 才會加入]

本手冊的每張圖都是 `MarketFigure`，或由 `ppf_canvas()` 等函式建立的 #pkg("mosaickit") 畫布。兩者的繪圖區為正方形，座標軸帶箭頭、無刻度與格線；曲線名稱標在末端，面積名稱寫在區塊內，數值標在座標軸上，文字不遮住線、點、區塊或其他文字。

== MarketFigure

#api(("MarketFigure",), syntax: [
  ```python
  from principle_viz import MarketFigure

  fig = MarketFigure(
      x_max=20.0,
      y_max=20.0,
      x_label="Q",
      y_label="p",
      title="Market Diagram",
      theme=None,       # PlotTheme
      palette=None,     # "default", "nord", ...
      labels=None,      # {layer id: Label}
      visibility=None,  # {layer id: bool}
  )
  ```
])[
  #pkg("mosaickit") 畫布上的市場圖，座標軸由 0 延伸到 `x_max` 與 `y_max`。座標軸名稱除非是文字，否則以 LaTeX 數學排版；`title` 為空字串時不畫標題。
]

#param("theme")[顏色與線寬（詳見#ref(<sec-palettes>)）。]
#param("palette")[`PlotTheme.from_palette(palette)` 的簡寫；與 `theme` 同時給定時以 `theme` 為準。]
#param("labels")[依圖層 id 覆寫內建標籤（詳見#ref(<sec-labels>)）。]
#param("visibility")[依圖層 id 顯示或隱藏圖層（詳見#ref(<sec-labels>)）。]

#api(("MarketFigure.add_curves", "MarketFigure.add_equilibrium"), syntax: [
  #raw("add_curves(")#meta("demand")#raw(", ")#meta("supply")#raw(", q_max, demand_label=\"$D$\", supply_label=\"$S$\")") \
  #raw("add_equilibrium(")#meta("result")#raw(", label=\"$e^*$\", color=None)")
])[
  由 $Q = 0$ 到 `q_max` 畫出需求與供給並在末端命名；以實心點與標籤標出均衡。
]

各主題另有專屬方法，說明見對應章節（參見#ref(<tab-figure-methods>)）。

#tbl(caption: [`MarketFigure` 的主題方法])[
  #booktabs(
    columns: (auto, auto),
    header: ([方法], [章節]),
    [`add_comparative_statics`], [#ref(<sec-shifts>)],
    [`add_discrete_curves`、`add_discrete_equilibrium`], [#ref(<sec-discrete>)],
    [`add_welfare`、`add_welfare_transition`], [#ref(<sec-welfare>)],
    [`add_tax_transform`、`add_tax_comparison`、`add_subsidy_comparison`], [#ref(<sec-taxes>)],
    [`add_price_control`], [#ref(<sec-controls>)],
    [`add_trade`], [#ref(<sec-trade>)],
    [`add_externality`、`add_common_resource`], [#ref(<sec-failures>)],
    [`add_minimum_wage`、`add_loanable_funds`], [#ref(<sec-factor>)],
  )
] <tab-figure-methods>

#api(("MarketFigure.finalize", "MarketFigure.save"), syntax: [
  #raw("finalize(legend=False)") \
  #raw("save(")#meta("path")#raw(", dpi=150)")
])[
  `finalize()` 隱藏會把福利區塊切成兩半的輔助線（數值仍標在座標軸上），只有在 `legend=True` 時才加入圖例。`save()` 依副檔名寫出 PNG、SVG 或 PDF，並建立不存在的目錄。`close()` 不做任何事，僅為相容而保留。
]

#api(("MarketFigure.add_layer", "MarketFigure.add_layers"), syntax: [
  #raw("add_layer(")#meta("layer")#raw(")") \
  #raw("add_layers(")#meta("layers")#raw(")")
])[
  加入任意 #pkg("mosaickit") 圖層，用於主題方法未提供的註記。同一數值的座標軸標記會取代先前的標記。完成的場景可由 `fig.scene` 取得。
]

#api(("MarketFigure.add_metrics",), syntax: [
  #raw("add_metrics(")#meta("values")#raw(", *, title=None, location=\"upper right\")")
])[
  以名稱與數值組成的文字框，供筆記本與除錯使用。教學用圖不放此框，數值應寫在正文中。
]

== 標籤與圖層 <sec-labels>

#changed("0.10.1", label: "Label")[每個內建標籤都可改名、隱藏或移動：新增 `Label`、`labels=`、`configure_label()` 與 `label_ids`]
#changed("0.12.1", label: "Label")[新增 `top`、`bottom`、`left` 與 `right`，可在標籤定位後微調單一標籤]
#changed("0.10.1", label: "MarketFigure.configure_layer")[每個圖層都可隱藏或顯示：新增 `visibility=`、`configure_layer()`、`hide()`、`show()` 與 `layer_ids`]

圖中的每條線、每個點、每個區塊與每段文字都是一個圖層，各有固定的 id，例如 `market.demand`、`market.demand.label` 或 `market.welfare.dwl`。id 依圖形結構命名：座標軸為 `axes.*`，各元素為 `market.<部分>`，命名該元素的文字再加上 `.label` 後綴。`fig.layer_ids` 列出所有圖層；`fig.label_ids` 列出可設定的文字（標籤、座標軸標記與括號）。

#api(("Label",), added: "v0.10.1", updated: "v0.12.1", syntax: [
  #raw("Label(text=None, visible=None, offset=None, top=None, bottom=None, left=None, right=None)")
])[
  覆寫一個內建標籤。值為 `None` 的欄位保留套件的預設值。指定 `offset`（單位為點）時，標籤不再自動放置，改為精確移動該距離。`top`、`bottom`、`left` 與 `right` 則在標籤定位之後再移動，位置仍由 principle-viz 決定，只做細部調整。
]

#api(("MarketFigure.configure_label", "MarketFigure.configure_layer"), added: "v0.10.1", syntax: [
  #raw("configure_label(")#meta("layer id")#raw(", label=None, *, text=None, visible=None, offset=None, top=None, bottom=None, left=None, right=None)") \
  #raw("configure_layer(")#meta("layer id")#raw(", *, visible)")
])[
  改名、隱藏或移動一個標籤（id 可省略結尾的 `.label`），或顯示、隱藏任一圖層。`hide(*ids)` 與 `show(*ids)` 一次切換多個圖層。每個方法都回傳圖形本身。
]

同樣的覆寫也可在建立圖形時以 `labels=` 與 `visibility=` 對應表傳入，之後加入的圖層也會套用。加總圖與各畫布函式（`ppf_canvas()`、`public_good_canvas()` 等）接受同樣的兩個參數。

參見#ref(<fig-labels>)：

```python
from principle_viz import Label, MarketFigure

fig = MarketFigure(
    x_max=12, y_max=12,
    labels={
        "market.demand.label": Label(text="Demand"),
        "market.supply.label": Label(text="Supply"),
    },
)
fig.add_curves(demand, supply, q_max=10)
fig.add_equilibrium(eq)
fig.configure_label("market.equilibrium", text="$e^*$")
fig.hide("axes.origin.label")
fig.finalize()
```

#fig("/figures/figures/labels.zh-TW.svg", width: 46%, caption: [
  改名的曲線與均衡點
]) <fig-labels>

=== 微調標籤

距離可為點數，或帶單位的字串：`"10pt"`、`"0.5em"`（以標籤字級為單位）或 `"2mm"`。`top` 與 `bottom` 可以合併使用，`right` 與 `left` 亦同。微調在自動定位或 `offset` 之後套用；之後加入的標籤仍會避開移動後的標籤，未設定微調的圖形維持不變。座標軸刻度標籤不支援微調。均衡點標籤的 id 為 `market.equilibrium`：

```python
from principle_viz import Label, MarketFigure

fig = MarketFigure(labels={"market.equilibrium": Label(top="4pt")})
fig.configure_label("market.supply", Label(right="8pt"))
fig.configure_label("market.demand", text="$D_0$", left="0.5em")
```

== 配色與主題 <sec-palettes>

#changed("0.1.0", label: "ColorModel")[`default`、`colorblind`、`nord` 與 `monochrome` 四種配色]
#changed("0.10.0", label: "ColorModel")[`default` 配色改用 #pkg("mosaickit") 的色相：需求藍、供給紅、無謂損失青]
#changed("0.10.0", label: "PlotTheme")[供需曲線寬 3.5 pt、座標軸 1.0 pt、均衡點直徑 6.5 pt]
#changed("0.11.2", label: "ColorModel")[新增 `manual` 配色，即本手冊的灰階]
#changed("0.12.1", label: "ColorModel")[配色改為 EconViz 共用主題，同一名稱在各 EconViz 套件中外觀一致；新增 `paper` 與 `presentation`]

`ColorModel` 為每個經濟角色指定顏色；`PlotTheme` 再加上線寬與座標軸選項，並將兩者編譯為 #pkg("mosaickit") 主題。內建配色就是所有 EconViz 套件共用的主題（#ref(<tab-palettes>)），同一名稱在 utility-viz 與 principle-viz 中外觀一致。

#api(("ColorModel",), syntax: [
  #raw("ColorModel(name, axis_color, label_color, demand_color, supply_color, ...)")
])[
  具名的顏色角色：`axis_color`、`label_color`、`demand_color`、`supply_color`、`baseline_color`、`shifted_color`、`tax_color`、`control_color`、`cs_color`、`ps_color`、`tax_revenue_color`、`dwl_color` 與 `arrow_color`。每個值可為 `"#hex"` 或 `"blue"` 等 #pkg("mosaickit") 調色盤名稱。
]

#tbl(caption: [內建配色])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([名稱], [特色與用途]),
    [`manual`], [EconViz 手冊的灰階：黑色座標軸、供給曲線與箭頭，灰色需求曲線與剩餘區域，適合列印與講義],
    [`default`], [需求藍、供給綠、無謂損失紅，租稅與價格管制橙；剩餘區域沿用曲線顏色，適合一般用途],
    [`colorblind`], [與 `default` 相同的配色，以明確名稱標示],
    [`monochrome`], [黑色曲線搭配灰階區域，適合黑白列印],
    [`nord`], [採用 Nord 色盤的冷色系，適合螢幕與投影片],
    [`paper`], [柔和色彩，適合論文],
    [`presentation`], [色彩較鮮明，線條放大為 1.5 倍、均衡點放大為 1.3 倍，適合投影],
  )
] <tab-palettes>

共用主題為各個角色指定顏色，`principle_viz.visuals.roles` 則決定各元素使用的角色：座標軸、標籤、基準線與箭頭使用 ink，需求使用 primary，供給使用 secondary，移動後的曲線使用 tertiary，租稅與價格管制使用 intervention，消費者剩餘、生產者剩餘、無謂損失與租稅收入分別使用 light、mid、dark 與 faint 填色。主題的線條與標記比例會乘上 principle-viz 自身的線寬與均衡點大小。內建主題不含深色主題。

`list_color_models()` 回傳所有名稱，`get_color_model(name)` 回傳對應的配色；另匯出 `DEFAULT_COLOR_MODEL`、`COLORBLIND_COLOR_MODEL`、`NORD_COLOR_MODEL` 與 `MONOCHROME_COLOR_MODEL`。

#api(("PlotTheme",), syntax: [
  #raw("PlotTheme(color_model=..., demand_linewidth=3.5, supply_linewidth=3.5, ...)") \
  #raw("PlotTheme.from_palette(")#meta("name")#raw(", **options)")
])[
  配色加上線寬（`demand_linewidth`、`supply_linewidth`、`shifted_linewidth`、`tax_linewidth`、`arrow_linewidth`、`dashed_linewidth`）、`equilibrium_marker_size`，以及開關 `show_grid`、`show_ticks`、`show_axis_arrows` 與 `show_origin_label`。`from_palette()` 以內建配色為起點，並可設定上述任一欄位。
]

字型有三個欄位。`font` 是 `"sans"`（預設）、`"serif"` 或 `"mono"`，已安裝的字型名稱（如 `"Arial"`）會報錯。`fonts` 是 `mosaickit.TextFonts`，用字型檔取代三者之一，沒給的沿用 #pkg("mosaickit") 的 DejaVu 預設。`math_font` 是 `MathFont` 或 OpenType 數學字型的路徑，經由 #pkg("glyphkit") 排版 `$...$`。`font_roles` 把樣式角色對應到通用字型，例如 `{"axes": "mono"}`。系統字型不會被搜尋，請直接給路徑。
#changed("0.11.0", label: "PlotTheme")[新增 `font`、`fonts`、`math_font` 與 `font_roles`]

```python
from mosaickit import TextFonts
from principle_viz import MarketFigure, PlotTheme

theme = PlotTheme(
    font="serif",
    fonts=TextFonts(serif=["fonts/Pagella-Regular.otf", "fonts/Pagella-Bold.otf"]),
    math_font="fonts/Pagella-Math.otf",
)
fig = MarketFigure(x_max=12, y_max=12, theme=theme)
```

以 `palette` 參數選用配色（參見#ref(<fig-monochrome>)）：

```python
fig = MarketFigure(x_max=12, y_max=12, palette="monochrome")
```

#fig("/figures/figures/monochrome.zh-TW.svg", width: 46%, caption: [
  `monochrome` 配色
]) <fig-monochrome>

== 設定檔 <sec-settings>

#changed("0.12.0", label: "Config")[`Config.load("econ-viz.toml").use()` 讀取所有 EconViz 套件共用的設定檔]
#changed("0.12.1", label: "Config")[改由 #pkg("mosaickit") 依 principle-viz 宣告的結構讀取並檢查檔案；共用的 `base` 決定起始主題]
#changed("0.14.0", label: "Config")[`econ-viz.toml` 新增 `[principle.label.<group>]`，可依群組預設移動整批標籤]

principle-viz 讀取所有 EconViz 套件共用的設定檔 `econ-viz.toml`，並由 #pkg("mosaickit") 讀取與檢查。頂層放置所有套件共用的設定：起始主題（`base`，可選#ref(<tab-palettes>)中的名稱）、字型，以及座標軸與標籤顏色。principle-viz 自身的設定放在 `[principle]` 表格中；其他套件的表格（例如 `[utility]`）會被略過。

```toml
base = "manual"      # 共用主題名稱

[font]
text = "serif"
math = "fonts/texgyrepagella-math.otf"

[fonts]
serif = ["fonts/NotoSerifTC-Regular.otf", "fonts/NotoSerifTC-Bold.otf"]

[principle]
language = "zh-TW"   # 內建圖形文字

[principle.color]    # 配色角色名稱
demand = "#8c8c8c"

[principle.stroke]   # 線寬以點為單位
demand = 3.5

[principle.marker]
equilibrium = 6.5    # 均衡點直徑
```

`base = "manual"` 即為本手冊的黑白樣式，不必逐一寫出顏色與線寬。`[principle] palette` 仍可只為 principle-viz 設定配色，並優先於 `base`；`[principle.color]` 則設定單一元素。相對路徑以設定檔所在資料夾為準。

#api(("Config.load", "Config.use", "default_theme"), added: "v0.12.0", syntax: [
  ```python
  from principle_viz import Config

  Config.load("econ-viz.toml").use()
  ```
])[
  `Config.load()` 讀取設定檔，`use()` 將其設為預設值：未傳入 `theme=` 或 `palette=` 的圖形都會採用，`default_theme()` 則回傳這些圖形使用的主題。直接傳入圖形的 `theme=` 或 `palette=` 仍優先。`mosaickit.econ_toml.use("econ-viz.toml")` 會一次為所有已安裝的 EconViz 套件載入此檔。
]

設定檔寫錯時會拋出 `mosaickit.ConfigurationError`，指出檔案與表格，並在有相近名稱時提示可能的正確寫法：

```text
econ-viz.toml: [principle.color] unknown key 'demnad'; did you mean 'demand'?
```

=== 標籤預設值 <sec-label-groups>

`[principle.label.<group>]` 預設移動同一群組的所有標籤，因此在設定檔中設定一次，即可取代在每張圖上分別寫 `Label(top=...)`。標籤依其命名的對象分為五個群組，每個群組都有 `top`、`bottom`、`left` 與 `right` 四個鍵（#ref(<tab-label-groups>)）。

#tbl(caption: [標籤群組])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([群組], [標籤]),
    [`point`], [均衡點（`e_0`、`e^*`、`e_1`、`e_t`、`L^*`，以及離散情形的 `Q^* = ..., p^* = ...`）與生產可能曲線上的點],
    [`curve`], [標在曲線末端的曲線名稱：`D`、`S`、`D_1`、`S + t`、`MSB`、`MSC`、`MC`、`\Sigma MB`、`PPF`、`PPF_0`、`PPF_1`],
    [`region`], [填色區域內的名稱，含以引線標示的說明：消費者剩餘、生產者剩餘、無謂損失、租稅收入、補貼成本、關稅收入],
    [`mark`], [價格線與政策標記：`p_c`、`p_f`、`w_min`、`p_w`、`p_w + t`，以及 `t = ...`、`s = ...` 與 `f = ...` 的價差標示],
    [`annotation`], [其他文字：括號標籤（Shortage、Tax、Subsidy、Imports、Unemployment）、價格區間、指標值與彈性區段名稱],
  )
] <tab-label-groups>

座標軸標籤（軸名稱、原點、軸上的 `Q_0`、`p_1` 等標記及其註記）不屬於任何群組，也無法微調。距離可為點數，或帶單位 `pt`、`mm`、`cm`、`in` 的字串；設定檔沒有字級，因此不接受 `em`。`top` 與 `bottom` 可以合併使用，`right` 與 `left` 亦同。未設定的鍵表示不移動；沒有 `[principle.label.*]` 設定的圖形維持不變：

```toml
[principle.label.point]
top = "2pt"          # 均衡點標籤上移

[principle.label.curve]
right = "4pt"        # 曲線名稱右移

[principle.label.region]
bottom = "1mm"
left = "0.5mm"
```

單一標籤若自行指定 `top`、`bottom`、`left` 或 `right`（透過 `Label(top=...)`、`labels=` 或 `configure_label()`），就只依這些值移動，#strong[不會]再套用所屬群組的預設值：單一標籤的微調會取代預設值，兩者不會相加。只改名、隱藏或指定 `offset` 的 `Label` 則仍保留預設的微調。帶引線的說明，其引線會持續指向移動後的標籤。

各群組的預設值以 `mosaickit.Nudge` 存放在 `PlotTheme.label_nudges`，鍵為群組名稱；`principle_viz.label_groups.label_group(layer)` 回傳某個標籤圖層所屬的群組，不套用預設值的標籤則回傳 `None`。

== 畫布

#api(("Canvas",))[
  #pkg("mosaickit") 的 `Canvas`，並具備與 `MarketFigure` 相同的 `labels=`、`visibility=`、`configure_label()`、`configure_layer()`、`hide()`、`show()`、`layer_ids` 與 `label_ids`。生產可能曲線、公共財與總收益各章的畫布函式都回傳此類別；以 `save()` 儲存，或以 `mosaickit.CanvasGrid` 組合多張畫布。
]

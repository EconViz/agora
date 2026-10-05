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
#changed("0.10.1", label: "MarketFigure.configure_layer")[每個圖層都可隱藏或顯示：新增 `visibility=`、`configure_layer()`、`hide()`、`show()` 與 `layer_ids`]

圖中的每條線、每個點、每個區塊與每段文字都是一個圖層，各有固定的 id，例如 `market.demand`、`market.demand.label` 或 `market.welfare.dwl`。id 依圖形結構命名：座標軸為 `axes.*`，各元素為 `market.<部分>`，命名該元素的文字再加上 `.label` 後綴。`fig.layer_ids` 列出所有圖層；`fig.label_ids` 列出可設定的文字（標籤、座標軸標記與括號）。

#api(("Label",), added: "v0.10.1", syntax: [
  #raw("Label(text=None, visible=None, offset=None)")
])[
  覆寫一個內建標籤。值為 `None` 的欄位保留套件的預設值。指定 `offset`（單位為點）時，標籤不再自動放置，改為精確移動該距離。
]

#api(("MarketFigure.configure_label", "MarketFigure.configure_layer"), added: "v0.10.1", syntax: [
  #raw("configure_label(")#meta("layer id")#raw(", label=None, *, text=None, visible=None, offset=None)") \
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
fig.configure_label("market.equilibrium", text="$E$")
fig.hide("axes.origin.label")
fig.finalize()
```

#fig("/figures/figures/labels.svg", width: 46%, caption: [
  改名的曲線與均衡點。
]) <fig-labels>

== 配色與主題 <sec-palettes>

#changed("0.1.0", label: "ColorModel")[`default`、`colorblind`、`nord` 與 `monochrome` 四種配色]
#changed("0.10.0", label: "ColorModel")[`default` 配色改用 #pkg("mosaickit") 的色相：需求藍、供給紅、無謂損失青]
#changed("0.10.0", label: "PlotTheme")[供需曲線寬 3.5 pt、座標軸 1.0 pt、均衡點直徑 6.5 pt]

`ColorModel` 為每個經濟角色指定顏色；`PlotTheme` 再加上線寬與座標軸選項，並將兩者編譯為 #pkg("mosaickit") 主題。內建的四種配色如#ref(<tab-palettes>)。

#api(("ColorModel",), syntax: [
  #raw("ColorModel(name, axis_color, label_color, demand_color, supply_color, ...)")
])[
  具名的顏色角色：`axis_color`、`label_color`、`demand_color`、`supply_color`、`baseline_color`、`shifted_color`、`tax_color`、`control_color`、`cs_color`、`ps_color`、`tax_revenue_color`、`dwl_color` 與 `arrow_color`。每個值可為 `"#hex"` 或 `"blue"` 等 #pkg("mosaickit") 調色盤名稱。
]

#tbl(caption: [內建配色])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([名稱], [特色]),
    [`default`], [#pkg("mosaickit") 色相：需求藍、供給紅、無謂損失青；剩餘沿用曲線色相，透明度 15%],
    [`colorblind`], [色盲友善的質性配色],
    [`nord`], [Nord 配色],
    [`monochrome`], [黑、白與灰階，供印刷使用],
  )
] <tab-palettes>

`list_color_models()` 回傳所有名稱，`get_color_model(name)` 回傳對應的配色；四種配色也以 `DEFAULT_COLOR_MODEL`、`COLORBLIND_COLOR_MODEL`、`NORD_COLOR_MODEL` 與 `MONOCHROME_COLOR_MODEL` 匯出。

#api(("PlotTheme",), syntax: [
  #raw("PlotTheme(color_model=..., demand_linewidth=3.5, supply_linewidth=3.5, ...)") \
  #raw("PlotTheme.from_palette(")#meta("name")#raw(", **options)")
])[
  配色加上線寬（`demand_linewidth`、`supply_linewidth`、`shifted_linewidth`、`tax_linewidth`、`arrow_linewidth`、`dashed_linewidth`）、`equilibrium_marker_size`，以及開關 `show_grid`、`show_ticks`、`show_axis_arrows` 與 `show_origin_label`。`from_palette()` 以內建配色為起點，並可設定上述任一欄位。
]

以 `palette` 參數選用配色（參見#ref(<fig-monochrome>)）：

```python
fig = MarketFigure(x_max=12, y_max=12, palette="monochrome")
```

#fig("/figures/figures/monochrome.svg", width: 46%, caption: [
  `monochrome` 配色。
]) <fig-monochrome>

== 畫布

#api(("Canvas",))[
  #pkg("mosaickit") 的 `Canvas`，並具備與 `MarketFigure` 相同的 `labels=`、`visibility=`、`configure_label()`、`configure_layer()`、`hide()`、`show()`、`layer_ids` 與 `label_ids`。生產可能曲線、公共財與總收益各章的畫布函式都回傳此類別；以 `save()` 儲存，或以 `mosaickit.CanvasGrid` 組合多張畫布。
]

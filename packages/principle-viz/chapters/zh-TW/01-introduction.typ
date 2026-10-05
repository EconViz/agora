#import "/template/manual.typ": *

= 簡介 <sec-intro>

#changed("0.1.0")[以 `principle-econ` 名稱首次發布：線性市場、租稅、福利、繪圖與命令列介面]
#changed(
  "0.10.0",
)[由 `principle-econ` 更名為 #pkg("principle-viz")，加入 EconViz 系列；Python 套件名稱改為 `principle_viz`]
#changed("0.10.0")[圖形改以 #pkg("mosaickit") 繪製（`mosaickit>=0.5.1,<0.6.0`）]
#changed("0.10.0")[專案工具由 Poetry 改為 #pkg("uv")]
#changed("0.10.1")[CI 測試 Python 3.10–3.13]

#pkg("principle-viz") 是經濟學原理的繪圖套件，涵蓋供給與需求、均衡及其移動、租稅與補貼、價格管制、福利、國際貿易、市場失靈、要素市場與生產可能曲線。每個主題都有計算與圖形兩個部分：計算回傳數值，圖形依教科書慣例繪製。

圖形的曲線名稱標在末端而不放進圖例，面積名稱寫在區塊內，數值標在座標軸上，所有文字都不遮住線、點或其他文字。輸出格式包括 PNG、SVG 與 PDF；命令列工具則以 JSON 輸出計算結果。

#pkg("principle-viz") 屬於 EconViz 系列套件，繪圖使用與領域無關的場景與繪製函式庫 #pkg("mosaickit")。同系列的 #pkg("utility-viz") 是個體經濟學繪圖套件，涵蓋效用模型、最適消費組合求解，以及無異曲線、預算線、消費者均衡、需求曲線與 Edgeworth 箱形圖；本套件不包含這些功能。

== 功能範圍

#pkg("principle-viz") 處理線性市場，功能分為市場、政策、應用與工具四個部分。計算與圖形可分開使用；同一個結果可以印出、輸出為 JSON，也可以交給 `MarketFigure` 繪製。

== 閱讀指引

本手冊依主題分成市場、政策、應用與工具四個部分（參見#ref(<tab-guide>)）：

#tbl(caption: [章節主題])[
  #booktabs(
    columns: (auto, auto, 1fr, auto),
    header: ([主題], [子主題], [說明], [章節]),
    table.cell(rowspan: 4)[市場],
    [線性市場],
    [直線、均衡與曲線移動],
    [#ref(<sec-markets>)],
    [離散市場],
    [逐單位的需求與供給表],
    [#ref(<sec-discrete>)],
    [市場曲線加總],
    [個人曲線的水平加總],
    [#ref(<sec-aggregation>)],
    [彈性與總收益],
    [點彈性、弧彈性與總收益曲線],
    [#ref(<sec-elasticity>)],
    table.cell(rowspan: 3)[政策],
    [福利],
    [消費者剩餘、生產者剩餘與無謂損失],
    [#ref(<sec-welfare>)],
    [租稅與補貼],
    [稅負楔差與補貼成本],
    [#ref(<sec-taxes>)],
    [價格管制],
    [價格上限、價格下限與短缺],
    [#ref(<sec-controls>)],
    table.cell(rowspan: 4)[應用],
    [國際貿易],
    [自由貿易、關稅與進口配額],
    [#ref(<sec-trade>)],
    [市場失靈],
    [外部性、共有資源與公共財],
    [#ref(<sec-failures>)],
    [勞動與可貸資金],
    [最低工資與政府借款],
    [#ref(<sec-factor>)],
    [生產可能曲線],
    [機會成本、成長與比較利益],
    [#ref(<sec-ppf>)],
    table.cell(rowspan: 2)[工具],
    [圖形],
    [標籤、圖層與配色],
    [#ref(<sec-figures>)],
    [命令列介面],
    [以 JSON 輸出計算結果],
    [#ref(<sec-cli>)],
  )
] <tab-guide>

初次使用時，依序閱讀#ref(<sec-quickstart>)、#ref(<sec-markets>)與#ref(<sec-figures>)。之後每章說明一個主題，先介紹計算，再介紹圖形。查詢特定指令的選項時，可直接前往#ref(<sec-cli>)。

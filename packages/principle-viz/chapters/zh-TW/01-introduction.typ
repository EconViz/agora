#import "/template/manual.typ": *

= 簡介 <sec-intro>

#changed("0.1.0")[以 `principle-econ` 名稱首次發布：線性市場、租稅、福利、繪圖與命令列介面]
#changed("0.10.0")[由 `principle-econ` 更名為 #pkg("principle-viz")，加入 EconViz 系列；Python 套件名稱改為 `principle_viz`]
#changed("0.10.0")[圖形改以 #pkg("mosaickit") 繪製（`mosaickit>=0.5.1,<0.6.0`）]
#changed("0.10.0")[專案工具由 Poetry 改為 #pkg("uv")]
#changed("0.10.1")[CI 測試 Python 3.10–3.13]

#pkg("principle-viz") 是經濟學原理課程的市場圖形 Python 套件，涵蓋供給與需求、均衡及其移動、租稅與補貼、價格管制、福利、國際貿易、市場失靈、要素市場與生產可能曲線。每個主題都提供計算與圖形兩部分：計算回傳數值；圖形依教科書慣例繪製，曲線名稱標在曲線末端而非圖例中，福利面積的名稱寫在面積內，數值標在座標軸上，所有文字都不遮住其他元素。

== 功能範圍

本套件處理*線性*市場。需求或供給曲線以反函數形式表示為直線：
$ p = a + b Q, $
其中 $a$ 為價格截距，$b$ 為斜率（需求 $b < 0$，供給 $b > 0$）。價格一律在縱軸、數量在橫軸，沿用 #citet(<marshall1890>) 的畫法。有兩種情況不是單一直線：離散的逐單位表（詳見#ref(<sec-discrete>)），以及由個人曲線加總而成的分段線性市場曲線（詳見#ref(<sec-aggregation>)）。

計算與繪圖彼此分開。`principle_viz.core`、`principle_viz.policy` 與 `principle_viz.welfare` 中的求解函式回傳不可變的 dataclass，不匯入任何繪圖函式庫；`principle_viz.plot` 中的圖形再把這些結果轉為 #pkg("mosaickit") 場景。同一個結果可以印出、測試、由命令列工具輸出為 JSON，也可以繪製成圖。

#pkg("principle-viz") 屬於 EconViz 系列套件，同系列的 #pkg("utility-viz") 負責消費者理論：無異曲線、預算限制與由效用導出的需求。

== 閱讀指引

各章依主題分組如#ref(<tab-guide>)。

#tbl(caption: [章節主題])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([主題], [內容], [章節]),
    table.cell(rowspan: 4)[市場],
    [直線、均衡、曲線移動], [#ref(<sec-markets>)],
    [離散逐單位表], [#ref(<sec-discrete>)],
    [由個人加總的市場曲線], [#ref(<sec-aggregation>)],
    [彈性與總收益], [#ref(<sec-elasticity>)],
    table.cell(rowspan: 3)[政策],
    [剩餘與無謂損失], [#ref(<sec-welfare>)],
    [租稅與補貼], [#ref(<sec-taxes>)],
    [價格上限與下限], [#ref(<sec-controls>)],
    table.cell(rowspan: 4)[應用],
    [國際貿易], [#ref(<sec-trade>)],
    [外部性、公共財、共有資源], [#ref(<sec-failures>)],
    [勞動與可貸資金], [#ref(<sec-factor>)],
    [生產可能曲線], [#ref(<sec-ppf>)],
    table.cell(rowspan: 2)[工具],
    [圖形、標籤、配色], [#ref(<sec-figures>)],
    [命令列], [#ref(<sec-cli>)],
  )
] <tab-guide>

初次使用時，先讀#ref(<sec-quickstart>)，再讀#ref(<sec-markets>)與#ref(<sec-figures>)。之後每章說明一個主題，先介紹計算，再介紹圖形。

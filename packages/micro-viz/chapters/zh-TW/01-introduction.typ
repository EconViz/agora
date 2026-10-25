#import "/template/manual.typ": *

= 簡介 <sec-intro>

#changed("0.2.0.dev0")[開發版的第一版手冊：生產者理論、市場結構、要素市場、不確定性與資訊]
#changed("0.2.0.dev0")[圖形以 #pkg("mosaickit") 繪製（`mosaickit>=1.0.0rc9,<2.0.0`）]

#pkg("micro-viz") 是個體經濟學廠商端的 Python 套件：生產、成本、完全競爭、獨占與定價、寡占、要素市場、不確定性與資訊。每個主題都有一個*模型*，以數字回答問題，也有一張依教科書慣例由模型畫出的*圖形*。

圖形可輸出為 PNG、SVG 或 PDF。統計資料圖與方塊加箭頭的流程圖不在套件範圍內。

#pkg("micro-viz") 屬於 EconViz 套件家族，以 #pkg("mosaickit") 繪圖；#pkg("mosaickit") 是與領域無關的場景與繪圖函式庫。消費者理論與一般均衡屬於 #pkg("utility-viz")，入門的供需圖屬於 #pkg("principle-viz")，賽局理論不在本套件範圍內。

== 範圍

本套件涵蓋六組主題，各有一章（參見 @tab-guide）。模型不引入任何繪圖器，因此結果可以不畫圖直接使用；繪圖函式只負責安置模型算出的內容。

== 閱讀指引

#tbl(caption: [章節指引])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([主題], [說明], [章節]),
    [模型與圖形],
    [模型、繪圖函式、圖層編號與多欄圖如何配合],
    [#ref(<sec-model-figure>)],
    [生產與成本],
    [短期生產、成本函式、階梯與折點成本],
    [#ref(<sec-production-costs>)],
    [競爭],
    [價格接受者廠商、產業供給、長期成本、進入],
    [#ref(<sec-competition>)],
    [獨占與定價],
    [獨占、獨占性競爭、管制、價格歧視、兩部定價、搭售、廣告、可耗竭資源],
    [#ref(<sec-monopoly>)],
    [寡占],
    [雙占、拗折需求、支配廠商、垂直關係],
    [#ref(<sec-oligopoly>)],
    [投入與技術],
    [等產量線、成本最小化、學習與範疇、要素市場、買方獨佔與工會],
    [#ref(<sec-inputs>)],
    [不確定性與資訊],
    [期望效用、風險、拍賣、逆選擇、訊號、道德風險],
    [#ref(<sec-uncertainty>)],
    [設定],
    [`econ-viz.toml` 的 `[micro]` 表],
    [#ref(<sec-settings>)],
    [標籤與位置],
    [語系表、取代文字、移動標籤],
    [#ref(<sec-labels>)],
    [新增圖形],
    [模型、繪圖函式、文字、匯出、測試],
    [#ref(<sec-adding>)],
    [動畫],
    [讓圖形隨參數變化],
    [#ref(<sec-animation>)],
  )
] <tab-guide>

初次使用時，依序閱讀 @sec-quickstart 與 @sec-model-figure。各主題章節先說明模型，再展示圖形。

本手冊所有圖形的繪製腳本依主題整理成一個壓縮檔：#link("https://econ-viz.org/assets/micro-viz/agora/micro-viz-examples.zip")[micro-viz-examples.zip]。

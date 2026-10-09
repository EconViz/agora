#import "/template/manual.typ": *

= 簡介 <sec-intro>

#changed("0.1.0")[首次發布：不可變的場景與圖層、稀疏樣式、具命名空間的主題、畫布、可跨格的網格、參數運算式、動畫、以工作為範圍快取的 Matplotlib 繪製，以及嚴格的 TOML 設定]
#changed("0.1.1")[PyPI 上的套件資訊連結首頁、儲存庫、問題追蹤、更新紀錄與發布說明]

#pkg("mosaickit") 套件以小型且不可變的元件組裝二維圖形：場景是一份有序的圖層清單（路徑、填色區域、標記、文字、箭頭、標籤、大括號）；每個圖層標明一個語意角色，主題將角色轉成樣式，繪製器再將結果輸出為 PNG、SVG、PDF、GIF 或 MP4。它不含任何特定領域的知識。#pkg("principle-viz")、#pkg("utility-viz") 等領域套件自行定義模型與角色名稱，再將要繪製的圖層交給 #pkg("mosaickit")；曲線建構與 TikZ 匯出則由 #pkg("bezierkit") 等幾何套件負責。

== 設計

套件設計遵循四項原則。

/ 不可變的值: 圖層、場景、樣式、主題與規格都是凍結的 dataclass。`Canvas` 是封裝不可變 `Scene` 的流暢建構器；`snapshot()`、`copy()` 與 `bind()` 不會改動其他物件持有的場景。
/ 稀疏樣式: 每個樣式欄位都可以是 `None`，表示繼承。圖層自帶的樣式位於畫布覆寫、設定覆寫、主題與基本預設值之上（詳見#ref(<sec-themes>)）。
/ 角色而非顏色: 圖層只說明自己是什麼（`"primary"`、`"axes.note"`、`"mypkg.boundary"`），外觀由主題決定，而顏色是畫布繪製時才解析的色盤名稱（詳見#ref(<sec-styles>)）。
/ 避讓所有內容的配置: 區域標籤、點標籤、大括號與座標軸註記會等其他內容畫完後再配置。配置僅依顯示像素進行幾何計算，讓文字不碰到任何線、標記、區域或其他文字（詳見#ref(<sec-geometry>)、#ref(<sec-labels>)）。

== 數學與證明

自動配置以多種計算幾何方法為基礎。方向測試用來判斷點位於有向直線的哪一側，奇偶規則則依射線穿越邊界的次數判斷內外；此外還會計算到多邊形邊界的距離，並以每次優先檢查上界最高候選區域的最佳優先搜尋找出區域最深處。座標軸文字則會排列成互不重疊且位移平方和最小的位置。各章以編號的定義、引理、命題與定理說明每個程序的保證，證明則集中在#ref(<app-proofs>)；若只想查閱 API，可以略過。樣式與主題的代數（稀疏合併、角色解析）以及參數綁定也採取相同的處理方式。幾何部分的標準參考書為 #citet(<deberg2008>)，#ref(<thm-spread>)背後的保序最小平方問題則參見 #citet(<barlow1972>)。

== 閱讀指引

#tbl(caption: [章節指引])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([主題], [內容], [章節]),
    table.cell(rowspan: 3)[建構],
    [畫布、規格、場景], [#ref(<sec-canvas>)],
    [路徑、填色、標記、文字、座標軸], [#ref(<sec-layers>)],
    [座標軸標記、註記與大括號], [#ref(<sec-annotations>)],
    table.cell(rowspan: 2)[配置],
    [配置幾何], [#ref(<sec-geometry>)],
    [區域標籤與點標籤], [#ref(<sec-labels>)],
    table.cell(rowspan: 2)[外觀],
    [樣式、顏色、色盤], [#ref(<sec-styles>)],
    [主題、角色、設定], [#ref(<sec-themes>)],
    table.cell(rowspan: 2)[輸出],
    [參數、網格、動畫], [#ref(<sec-parameters>)],
    [繪製器、快取、儲存], [#ref(<sec-rendering>)],
  )
] <tab-guide>

初次使用請先讀#ref(<sec-quickstart>)、#ref(<sec-canvas>)與#ref(<sec-layers>)。本手冊的圖都是 #pkg("mosaickit") 自己的輸出：每張圖由它所示範的畫布或網格繪製，並以印在此處的尺寸存成 PDF。

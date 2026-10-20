#import "/template/manual.typ": *

= 輸出格式 <sec-outputs>

#tbl(caption: [內建輸出])[
  #booktabs(
    columns: (auto, auto, 1fr),
    header: ([格式], [能力], [保留內容]),
    [動態 SVG], [`vector`], [原生 2D 向量；可重現的 3D 投影],
    [GIF], [`raster`], [串流影格，最高 1200 DPI],
    [HTML], [`interactive`], [播放器控制、互動，以及原生 2D 或 3D 顯示],
  )
]

#api(("ExportManifest",))[不可變的匯出報告，記錄格式、產生的檔案、尺寸、長度、保留的語意、降級功能、警告與網路依賴。]
#api(("available_formats",))[回傳目前已安裝選用依賴所能提供的輸出格式。]
#api(("export",))[透過匯出器登錄表輸出動畫的底層入口；一般使用者通常呼叫 `Animation.save()`。]

#api(("RendererCapabilities",))[宣告繪圖端支援哪些場景維度、互動、字型功能與封裝方式。]
#api(("Requirements",))[KineticKit 分析場景、動作、互動與無障礙資料後，整理出的動畫需求。]
#api(("requirements_for",))[在寫入任何目的檔之前，計算動畫所需的 `Requirements`。]

動態 SVG 採用 SVG 的向量場景模型 #citep(<svg2>) 與宣告式 SMIL 時序元素 #citep(<smil3>)。KineticKit 會寫入明確的數值與時間，播放時不需要 Python。

== GIF 設定

#api(("GifSettings",))[控制 GIF 的影格率、調色盤、遞色、循環、處置方式、尺寸與 DPI。]
#api(("export_png_frames",))[把已編碼的 PNG 影格串流寫入 GIF，不必把所有解碼後的影格留在記憶體。]

GIF 不接受短於 10 毫秒的影格間隔。時間會分配到整數百分之一秒，同時維持指定的總長度。點陣工作量過大時會發出 `RenderCostWarning`，不會暗中降低尺寸或 DPI。

== HTML 封裝

`packaging="offline"` 會內嵌執行環境，不需要網路；`packaging="compact"` 會引用固定版本的 CDN 資源，並把網址寫進清單。沒有 JavaScript 時仍有替代內容：2D 使用內嵌 SVG，3D 則顯示最後狀態的靜態 SVG。

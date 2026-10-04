#import "/template/manual.typ": *

= 簡介 <sec-intro>

#changed("2.0.0b1")[#modify[由 #pkg("econ-viz") 更名為 #pkg("utility-viz")：發行套件、匯入名稱、指令與設定檔一併更名]]
#changed("2.0.0b1")[#modify[內部結構重整為 `core` 與 `models`；公開 API 為套件根目錄與 `utility_viz.models`]]
#changed("2.0.0b1")[#modify[新增依賴 #pkg("mosaickit") 與 #pkg("bezierkit")]]
#changed("2.0.0b1")[#modify[整個儲存庫通過 `mypy` 檢查；Ruff 限制行長、複雜度與陳述式數量]]
#changed("1.7.0")[CI 測試 Python 3.10–3.13，強制分支覆蓋率，並對可執行的範例做冒煙測試]
#changed("1.12.0")[新增無異曲線主次層級、焦點曲線及數值或序數標籤]
#changed("1.11.0")[完成主題系統，統一畫布、多面板圖、需求圖、效果分解與 Edgeworth 箱形圖的視覺設定]
#changed("1.10.1")[套件加入 `py.typed`，並在 CI 執行 Ruff 與 Mypy 檢查]
#changed("1.7.0")[版本標籤須通過測試後才會觸發發布]
#changed("1.6.0")[`examples/output/` 的產出檔案不再納入版本控制]
#changed("1.5.0")[新增效果分解、需求圖、PCC/ICC 路徑、多面板版面與 TikZ 匯出的範例腳本]
#changed("1.5.0")[新增 TikZ 匯出與價格效果分解的回歸測試]
#changed("1.4.0")[新增 `Animator` 與 `WidgetViewer` 的測試]
#changed("1.3.2")[發布流程略過 PyPI 上已有的版本]
#changed("1.3.1")[套件根目錄的匯出改為延遲載入，公開 API 不變]
#changed("1.3.0")[`examples/edgeworth_box.py` 涵蓋常見的效用函數組合]
#changed("1.3.0")[新增 Edgeworth 測試]
#changed("1.2.2")[新增 PCC/ICC 範例產生器與測試]

#modify[#pkg("utility-viz")] 是個體經濟學繪圖套件，涵蓋效用模型、最適消費組合求解與視覺化。Python API 與命令列工具均可產生無異曲線、預算線、消費者均衡、需求曲線及 Edgeworth 箱形圖。

圖形預設顯示第一象限，座標軸以箭頭表示並隱藏數字刻度，標籤支援 TeX 數學語法。輸出格式包括 PNG、PDF、SVG、TikZ 與 GIF。

#modify[本套件在 1.12 版以前名為 #pkg("econ-viz")，2.0.0 起更名為 #pkg("utility-viz")；變更內容與舊程式碼的相容方式詳見#ref(<sec-migrate>)。本手冊說明預覽版 2.0.0b1。]

#modify[#pkg("utility-viz") 屬於 EconViz 系列套件：繪圖透過與領域無關的場景與繪製函式庫 #pkg("mosaickit")，曲線則以 #pkg("bezierkit") 描繪。經濟學原理圖形由同系列的 #pkg("principle-viz") 負責。]

== 功能範圍

#modify[#pkg("utility-viz")] 的功能分為效用模型、均衡求解、效用水準、圖層與匯出格式五個部分。模型與求解結果可分開使用；同一模型也可交由畫布、多面板圖、需求圖或分析 API 處理。

== 閱讀指引

本手冊依主題分成四個部分（參見#ref(<tab-guide>)）：

#tbl(caption: [章節主題])[
  #booktabs(
    columns: (auto, auto, 1fr, auto),
    header: ([主題], [子主題], [說明], [章節]),
    table.cell(rowspan: 4)[繪圖與匯出],
    [畫布與圖層],
    [座標軸、曲線與均衡點],
    [#ref(<sec-canvas>)],
    [多面板圖與需求圖],
    [並排比較與需求曲線],
    [#ref(<sec-figures>)],
    [主題與設定檔],
    [配色、樣式與設定檔],
    [#ref(<sec-themes>)],
    [輸出格式],
    [匯出圖檔與 TikZ],
    [#ref(<sec-export>)],
    table.cell(rowspan: 3)[模型與分析],
    [內建模型],
    [常見效用函數],
    [#ref(<sec-models>)],
    [自訂與多商品模型],
    [自訂函數與多商品#modify[、場景]],
    [#ref(<sec-advanced>)],
    [比較靜態與 Slutsky 矩陣],
    [需求導數與齊次性],
    [#ref(<sec-analysis>)],
    table.cell(rowspan: 2)[動畫與互動],
    [GIF 動畫],
    [參數變動的 GIF],
    [#ref(<sec-animation>)],
    [Jupyter 互動元件],
    [筆記本滑桿調參數],
    [#ref(<sec-widgets>)],
    table.cell(rowspan: 2)[其他輸入方式],
    [命令列工具],
    [使用命令列產圖],
    [#ref(<sec-cli>)],
    [#LaTeX 效用函數解析],
    [從算式建立模型],
    [#ref(<sec-latex>)],
  )
] <tab-guide>

初次使用時，依序閱讀#ref(<sec-quickstart>)與#ref(<sec-canvas>)。查詢特定 API 時，可直接前往對應章節或指令索引。#modify[從 #pkg("econ-viz") 1.x 升級時，請先閱讀#ref(<sec-migrate>)。]

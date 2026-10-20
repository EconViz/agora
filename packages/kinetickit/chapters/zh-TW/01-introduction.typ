#import "/template/manual.typ": *

= 簡介 <sec-intro>

#changed("1.0.0b1")[第一個公開 Beta 版：可重現時間軸、2D 與 3D 場景、變形、SVG、GIF 與 HTML 輸出、互動、無障礙資訊、字型介面與相容性測試工具]
#changed("1.0.0b2")[GlyphKit 改為必要依賴；加入由已編碼 PNG 影格串流組裝 GIF 的功能]

#pkg("kinetickit") 是不綁定特定用途的動畫引擎。它負責場景、動作、可重現的影格排程、繪圖端能力、互動、無障礙中繼資料與檔案匯出。經濟學套件和其他應用程式只要把自己的物件轉成一般 KineticKit 節點即可。

同一個不可變場景和一段動作，可以輸出成動態 SVG、串流 GIF 與單檔互動 HTML。同一場景在同一時間一定得到相同快照，不受系統時間或特定繪圖端影響。

KineticKit 不會匯入 #pkg("mosaickit")、#pkg("utility-viz") 或其他特定用途的套件。字型處理由 #pkg("glyphkit") 負責，並透過#ref(<sec-typography-accessibility>)介紹的單一轉接器接入。

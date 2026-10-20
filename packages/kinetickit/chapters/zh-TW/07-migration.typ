#import "/template/manual.typ": *

= 遷移既有動畫程式 <sec-migration>

MosaicKit 與 utility-viz 過去各自帶有小型動畫工具。棄用入口會保留一個版本週期；新的動畫程式應直接建立 KineticKit 場景與動作。

== 從參數掃描遷移

1. 替每個來源圖層設定穩定識別碼。
2. 寫一個轉換函式，把圖層轉成 KineticKit 節點。
3. 把相鄰快照轉成 `SceneTransition`，再用 `then()` 接起各段動作。
4. 透過 `Animation.save()` 匯出。

KineticKit 刻意不提供 MosaicKit 相容匯入。轉接器應放在使用端套件內，因為只有那裡清楚領域物件的含義。

== 從工廠式 Animator 遷移

用 `adapt(objects, depict)` 轉換工廠回傳的物件，再以 `node.animate.<property>.to(...)` 或 `SceneTransition.between()` 表達變化。檔案路徑、影格率、DPI 與各格式替代方案都交給匯出器。

== 字體處理

把繪圖端專用字型路徑改為由呼叫端持有的 `FontSource` 與 `FontLibrary`，再透過 `GlyphKitTypography` 轉換排版。不要讓場景模型或選用繪圖端自行搜尋字型。

#import "/template/manual.typ": *

= 標籤與位置 <sec-labels>

== 語系表

#pkg("micro-viz") 放進圖中的每個字都在 `src/micro_viz/locale/labels.json`，先依穩定的編號（`production.tp`）、再依語言（`en`、`zh-TW`、`zh-CN`）索引。語言來自 `[micro] language`、`PlotTheme.language`，或範例腳本的 `--language`。

含欄位的文字在表中使用雙層大括號，例如 `$D_{{{index}}}$`；不含欄位的文字使用單層大括號。數學式寫在 `$...$` 中，不使用 Unicode 下標。

符號在各圖之間固定：只有價格 $p$ 用小寫，其他變數一律用大寫斜體；縮寫（MC、ATC）與點名保留原有的大小寫。

== 取代文字

呼叫端傳入的文字照原樣使用，不會翻譯。

```python
unit_cost_canvas(
    analysis,
    title="Unit costs",
    x_label="Quantity",
    labels={"cost.mc": "Marginal cost"},
)
```

`title=None`（預設）不畫標題。要依圖層編號修改某張已儲存圖形的某個標籤，使用共用的逐圖表，#pkg("mosaickit") 會在儲存圖形時套用：

```toml
[figure.unit_cost.label."micro.cost.avc.label"]
top = "3pt"
right = "2mm"
```

== 預設移動標籤 <sec-nudges>

`[micro.label.<group>]` 依每一側（`top`、`bottom`、`left`、`right`；單位 `pt`、`mm`、`cm`、`in`）的長度移動一組中的所有標籤。分組依標籤所標示的對象而定（參見 @tab-label-groups）。

#tbl(caption: [標籤分組])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([分組], [標籤]),
    [`point`], [標示的點],
    [`curve`], [曲線末端旁的曲線名稱],
    [`region`], [上色區域內的名稱，含引出標註],
    [`mark`], [價格線、數量標記與其他帶有數值的輔助線],
    [`annotation`], [其他文字],
  )
] <tab-label-groups>

座標軸標題、原點與軸上標記（$L_1$、$Q^*$）不屬於任何分組，不能移動。

== 標籤放在哪裡

- 曲線名稱放在曲線末端旁。兩條曲線的末端靠近時，繪圖函式把其中一條的名稱放在曲線中途（`at`），名稱才不會相碰。
- 點的標籤放在點旁，由 #pkg("mosaickit") 選擇不碰到線、標記或其他文字的一側。
- 找不到空位的文字會使 #pkg("mosaickit") 發出 `LayoutWarning`。測試把版面警告視為錯誤來繪圖，所以標籤重疊的圖會失敗。

== 落在曲線上的輔助線

完全落在一段實線直曲線上的虛線輔助線不會繪出。最常見的是承載虛線價格輔助線的價格線。標示水準的記號，例如 $p$，是另一個圖層，會保留。

規則是 `micro_viz.visuals.common` 的 `drop_covered_guides`，在 `Plane` 或競爭圖完成時套用一次。虛線曲線（例如 AFC）不會遮蔽輔助線。

#fig("/figures/competition/firm_loss.zh-TW.svg", width: 46%, caption: [
  虧損：保留價格記號
]) <fig-firm-loss>

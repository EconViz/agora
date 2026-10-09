#import "/template/manual.typ": *

= 快速入門 <sec-quickstart>

一張圖由畫布、一組圖層與一次儲存構成：

#example(```python
from mosaickit import (
    Canvas, Fill, FillLayer, MarkerLayer, PathLayer, Stroke, TextLayer,
    quadrant_axes,
)

canvas = Canvas().extend(quadrant_axes(10, 10))
canvas.add(
    FillLayer(
        [(1, 1), (1, 7), (8, 1)],
        fill=Fill(color="#377EB8", opacity=0.12),
        z_index=-1,
    )
)
canvas.add(
    PathLayer(
        [(1, 8), (2, 5), (4, 3), (7, 1.5), (9, 1)],
        stroke=Stroke(color="#984EA3", width=2),
        id="curve",
    )
)
canvas.add(MarkerLayer([(4, 3)], id="point"))
canvas.add(TextLayer((4, 3), "A", offset=(6, 6)))
canvas.save("diagram.pdf")
```)

#fig("/figures/quickstart/diagram.pdf", width: auto, caption: [
  快速入門的圖。
]) <fig-quickstart>

`quadrant_axes(10, 10)` 回傳一般圖層：兩條帶箭頭的路徑及其標題。填色圖層以 `z_index=-1` 放在最底層。路徑是通過各點的折線；#pkg("mosaickit") 本身不直接繪製曲線。若要呈現平滑曲線，必須傳入大量取樣點，或先用幾何套件建構曲線再取樣。文字從該點向右上偏移 6 pt。呼叫 `save()` 之前不會進行任何繪製；`save()` 會用畫布的繪製器（未另行設定時為 Matplotlib）繪製場景、寫出檔案，並回傳輸出路徑。

同一個畫布可在修改後再次儲存：`add()`、`extend()`、`remove()` 與 `clear()` 都會回傳畫布本身，因此可以串接呼叫；先前取得的快照則維持原狀（詳見#ref(<sec-canvas>)）。能自動避讓其他內容的標籤也是圖層：將 `TextLayer` 換成 `PointLabelLayer((4, 3), "A")`，繪製器就會自行選擇擺放方向（詳見#ref(<sec-labels>)）。

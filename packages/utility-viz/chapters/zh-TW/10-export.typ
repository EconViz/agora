#import "/template/manual.typ": *

= 匯出 <sec-export>

== 輸出格式

#changed("1.5.0", label: "Canvas.save")[純 TikZ 匯出後端；`Canvas.save()` 與 `Figure.save()` 接受 `.tex`]
#changed("1.6.0", label: "Canvas.save")[TikZ 座標軸的回歸測試不再依賴顏色索引]
#changed("1.3.1", label: "Canvas.save")[`Canvas`、`Figure` 與 `EdgeworthBox` 共用同一個圖形匯出器（`io.exporter`）]

#api(("Canvas.save",), syntax: [#raw("cvs.save(")#meta("path")#raw(")")])[
  依 `path` 的副檔名決定輸出格式。`Figure`、`DemandDiagram` 與 `EdgeworthBox` 使用相同介面。
]

- PNG：點陣圖，解析度由畫布的 `dpi` 設定，預設為 300。
- PDF、SVG：向量圖，可在列印或縮放時保留線條品質。
- TeX：TikZ 原始碼（`.tex`），可嵌入 #LaTeX 文件。透過關鍵字參數 `tikz_scale` 與 `tikz_standalone` 調整輸出。

```python
cvs.save("figure.png")   # PNG，依畫布 DPI（預設 300）
cvs.save("figure.pdf")   # PDF（向量）
cvs.save("figure.svg")   # SVG（向量）
cvs.save("figure.tex")   # TikZ
```

`dpi` 僅影響點陣圖。預覽時可降低解析度：

```python
cvs = Canvas(x_max=20, y_max=15, dpi=150)   # 降低 DPI，加快預覽
```

== GIF 動畫

#changed("1.4.0", label: "Animator.save")[匯出前將影格合成至不透明背景，改善 GIF 匯出穩定性]

使用 `Animator.save()` 匯出 GIF，完整範例詳見#ref(<sec-animation>)。

```python
from utility_viz.core.animation import Animator

Animator(draw_frame, frames=frames).save("animation.gif", fps=12, dpi=120)
```

== 互動視窗

`cvs.show()` 開啟 #pkg("matplotlib") 互動視窗，不會儲存檔案。命令列的 `plot` 省略 `--output` 時也會開啟視窗（詳見#ref(<sec-cli-plot>)）：

```bash
utility-viz plot --model cobb-douglas --px 2 --py 3 --income 30
```

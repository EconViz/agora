#import "/template/manual.typ": *

= 繪製 <sec-rendering>

== 繪製器

#api(("Renderer",), syntax: [
  #raw("name: str") \
  #raw("render(scene, context) -> Any") \
  #raw("save(result, target, options) -> list[Path]")
])[
  所有後端都必須實作的協定。繪製器接收不可變的場景與私有的繪製情境（規格、主題、覆寫、色盤、快取與綁定），並回傳由 `save` 寫出的結果。網格與動畫另需 `render_grid` 與 `save_animation`；繪製器若沒有實作它們，會引發 `RenderError`。內建後端仍在演進，因此繪製計畫與情境維持私有。
]

#api(("RendererRegistry",), syntax: [#raw("RendererRegistry()")])[
  `register(renderer)` 以 `name` 登錄後端；若物件缺少 `name`、`render` 或 `save`，或名稱已被使用，會引發 `RenderError`。`get(name)` 回傳已登錄的繪製器，或載入內建繪製器。唯一的內建繪製器是 `"matplotlib"`，在第一次使用時才匯入 #citep(<hunter2007>)。
]

== Matplotlib 繪製器

繪製畫布時，會先建立繪製計畫：綁定場景（有自由參數時引發 `BindingError`）、展開群組、依 `z_index` 排序圖層、解析每個圖層的樣式（參見#ref(<thm-resolution>)），並把色盤名稱換成具體顏色。圖形採用畫布的尺寸與 DPI，背景採用 `canvas` 角色的填色；座標軸範圍來自規格，並會關閉 Matplotlib 本身的軸線。#pkg("mosaickit") 中的座標軸是圖層。

接著，各圖層型別的建構函式會依序繪製圖層。工作需參照其他所有內容的圖層型別（圖例、點標籤、區域標籤、邊欄文字、跨距大括號），會在後續的延後處理程序中繪製。各程序依登錄順序執行，一次接收該型別的所有圖層。

#api(("register_builder", "register_pass"), added: "0.2.0", syntax: [
  #raw("register_builder(layer_type, builder)") \
  #raw("register_pass(layer_type, run)")
])[
  這兩個函式位於 `mosaickit.rendering.matplotlib`，可在不修改 #pkg("mosaickit") 的情況下，讓繪製器認得新的圖層型別。建構函式以 `builder(ax, resolved)` 呼叫，並回傳 Matplotlib artist；處理程序以 `run(ax, layers, context)` 呼叫，`PassContext` 的 `handles` 會將圖層 id 對應到圖例用的 artist。`resolved.layer` 是圖層，`resolved.style` 是解析後的 `StyleBundle`。查詢依方法解析順序進行，因此子類別會繼承父類別的登錄。圖層透過類別變數 `style_slots` 宣告各槽位的自帶樣式存於哪個欄位，再以 `fallback_category` 宣告作為最後依據的角色。
  #changed("0.2.0", label: "Layer")[圖層宣告 `style_slots`；Matplotlib 繪製改由各型別的登錄表驅動]
]

區域標籤的引線標註會避開座標軸上的所有內容，包括第三方登錄的建構函式所畫的物件。

== 結果與儲存

#api(("SaveOptions",), syntax: [#raw("SaveOptions(transparent=False, expand=True)")])[
  設定結果的寫出方式；`canvas.save(path, **options)` 會把關鍵字引數傳到這裡。`transparent` 去除背景。`expand=True` 時，儲存會把畫布擴大到恰好容納畫到邊緣外的內容（例如邊欄文字），另加 4 pt 留白。儲存時絕不會裁切畫面，因此原本就放得下的圖，會維持 `CanvasSpec` 指定的尺寸。`expand=False` 則保持指定尺寸。
  #changed("0.3.0")[新增 `expand`（預設 `True`）]
]

```python
result = canvas.render()
try:
    result.show()          # an interactive window
finally:
    result.close()
```

`render()` 回傳 `MatplotlibResult`，提供 `figure`、`axes`、`show()`、`save(target, **options)` 與 `close()`。`canvas.save()` 會自行關閉暫時結果。檔案格式由副檔名決定：`.png`、`.pdf` 或 `.svg`；其他副檔名會引發 `RenderError`。動畫接受 `.gif` 或 `.mp4`。網格中每格大小相同：寬度取「各畫布寬度除以所跨欄數」的最大值，高度取「各畫布高度除以所跨列數」的最大值；DPI 取各畫布中的最高值。

== 快取

#api(("RenderCache", "CacheKey"), syntax: [#raw("RenderCache(max_entries=256)")])[
  有容量上限且執行緒安全的最近最少使用快取，用來存放解析後的圖層，並以圖層 id、綁定、模型、規格與樣式為鍵。除非以 `cache=` 傳入快取，否則每次繪製、網格或動畫工作都會建立自己的快取，因此工作之間不會意外共用狀態。要在多個工作間重用結果，請傳入同一個快取。無法雜湊的模型會繞過快取直接繪製；每種模型型別在每個快取中只會發出一次 `CacheBypassWarning`。模型請使用凍結的 dataclass。`clear()` 清空快取。
]

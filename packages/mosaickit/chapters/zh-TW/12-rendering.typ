#import "/template/manual.typ": *

= 繪製 <sec-rendering>

== 繪製器

#api(("Renderer",), syntax: [
  #raw("name: str") \
  #raw("render(scene, context) -> Any") \
  #raw("save(result, target, options) -> list[Path]")
])[
  所有後端實作的協定。繪製器接收不可變的場景與私有的繪製情境（規格、主題、覆寫、色盤、快取與綁定），回傳交給 `save` 寫出的結果。網格與動畫另需 `render_grid` 與 `save_animation`；缺少它們的繪製器引發 `RenderError`。在內建後端持續演進期間，繪製計畫與情境維持私有。
]

#api(("RendererRegistry",), syntax: [#raw("RendererRegistry()")])[
  `register(renderer)` 以 `name` 加入後端（缺少 `name`、`render` 或 `save` 的物件，或名稱已被使用時，引發 `RenderError`）；`get(name)` 回傳已登錄的繪製器，或載入內建繪製器。唯一的內建繪製器是 `"matplotlib"`，在第一次使用時匯入 #citep(<hunter2007>)。
]

== Matplotlib 繪製器

繪製畫布時先建立繪製計畫：綁定場景（有自由參數時引發 `BindingError`）、展開群組、依 `z_index` 排序圖層、解析每個圖層的樣式（參見#ref(<thm-resolution>)），並把色盤名稱換成顏色。圖形採用畫布的尺寸與 DPI，背景為 `canvas` 角色的填色，座標軸設為規格的範圍並關閉 Matplotlib 自身的軸線；#pkg("mosaickit") 中的座標軸是圖層。

接著由各圖層型別的建構函式依序繪製圖層。工作取決於其他所有內容的圖層型別（圖例、點標籤、區域標籤、邊欄文字、跨距大括號）在之後的延後處理階段繪製，依登錄順序執行，每個階段一次收到該型別的所有圖層。

#api(("register_builder", "register_pass"), added: "0.2.0", syntax: [
  #raw("register_builder(layer_type, builder)") \
  #raw("register_pass(layer_type, run)")
])[
  位於 `mosaickit.rendering.matplotlib`：不修改 #pkg("mosaickit") 就讓繪製器認得新的圖層型別。建構函式以 `builder(ax, resolved)` 呼叫並回傳 Matplotlib artist；處理階段以 `run(ax, layers, context)` 呼叫，`PassContext` 的 `handles` 把圖層 id 對應到圖例用的 artist。`resolved.layer` 是圖層，`resolved.style` 是解析後的 `StyleBundle`。查詢依方法解析順序進行，子類別因此繼承父類別的登錄。圖層以類別變數 `style_slots` 宣告每個槽的自帶樣式存於哪個欄位，以 `fallback_category` 宣告最後依據的角色。
  #changed("0.2.0", label: "Layer")[圖層宣告 `style_slots`；Matplotlib 繪製改由各型別的登錄表驅動]
]

區域標籤的引線標註會避開座標軸上的所有內容，包括第三方登錄的建構函式所畫的東西。

== 結果與儲存

#api(("SaveOptions",), syntax: [#raw("SaveOptions(transparent=False, expand=True)")])[
  結果的寫出方式；`canvas.save(path, **options)` 把關鍵字引數傳到這裡。`transparent` 去除背景。`expand=True` 時，儲存會把畫布擴大到恰好容納畫到邊緣外的內容（例如邊欄文字），另加 4 pt 留白；它從不裁切，因此放得下的圖維持 `CanvasSpec` 指定的尺寸。`expand=False` 保持指定尺寸。
  #changed("0.3.0")[新增 `expand`（預設 `True`）]
]

```python
result = canvas.render()
try:
    result.show()          # an interactive window
finally:
    result.close()
```

`render()` 回傳 `MatplotlibResult`，提供 `figure`、`axes`、`show()`、`save(target, **options)` 與 `close()`。`canvas.save()` 會自行關閉暫時的結果。檔案格式依副檔名決定：`.png`、`.pdf` 或 `.svg`（其他副檔名引發 `RenderError`）；動畫接受 `.gif` 或 `.mp4`。網格中每格大小相同：寬為各畫布寬度除以所跨欄數的最大值，高為各畫布高度除以所跨列數的最大值；DPI 取各畫布中的最高者。

== 快取

#api(("RenderCache", "CacheKey"), syntax: [#raw("RenderCache(max_entries=256)")])[
  有容量上限、執行緒安全的最近最少使用快取，存放解析後的圖層，以圖層 id、綁定、模型、規格與樣式為鍵。除非以 `cache=` 傳入，每次繪製、網格或動畫都建立自己的快取，因此工作之間不會意外共用狀態；要在多個工作間重用結果時，傳入同一個快取。無法雜湊的模型不經快取繪製，每種模型型別在每個快取中只發出一次 `CacheBypassWarning`；模型請使用凍結的 dataclass。`clear()` 清空快取。
]

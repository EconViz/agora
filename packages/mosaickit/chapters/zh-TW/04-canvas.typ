#import "/template/manual.typ": *

= 畫布與場景 <sec-canvas>

== 畫布規格

#api(("CanvasSpec",), syntax: [
  #raw("CanvasSpec(x_range=(0, 10), y_range=(0, 10), width=6.0, height=6.0,") \
  #raw("           dpi=300, x_label=\"X\", y_label=\"Y\", title=None)")
])[
  圖形的實體尺寸與座標範圍。`x_range` 與 `y_range` 是顯示的資料範圍；`width` 與 `height` 是以英寸計算的圖形尺寸；`dpi` 是 $[1, 1200]$ 內的整數。屬性 `x_min`、`x_max`、`y_min`、`y_max` 可讀取範圍，`replace(**changes)` 則回傳只修改指定欄位的副本。範圍必須有限且 `lo < hi`，尺寸必須是有限正數，否則會引發 `ConfigurationError`。
]

#api(("Interval",), syntax: [#raw("Interval(")#meta("lo")#raw(", ")#meta("hi")#raw(")")])[
  有限的遞增區間，`lo < hi`，供規格與座標軸共用。
]

== 畫布

#api(("Canvas",), syntax: [
  #raw("Canvas(spec=None, theme=None, config=None, renderer=None, *,") \
  #raw("       role_overrides=None)")
])[
  封裝不可變場景的流暢建構器。若引數為 `None`，便採用建立畫布當下生效的設定（詳見#ref(<sec-config>)），分別是其中的 `canvas_spec`、`theme` 與 `renderer`。`role_overrides` 將角色名稱對應至 `StyleBundle`，並套用在主題與設定之上（參見#ref(<thm-resolution>)）。
]

#param("add(layer), extend(layers)")[加入一個或多個圖層；回傳畫布。]
#param("remove(layer_id), clear()")[移除該 id 的圖層（含群組內）或所有圖層；回傳畫布。未知的 id 引發 `ConfigurationError`。]
#param("snapshot()")[目前的 `Scene`。之後呼叫 `add()` 不會改變它。]
#param("copy()")[規格、主題、設定、繪製器、覆寫、場景與綁定都相同的新畫布。]
#param("bind(parameter, value), bind(mapping)")[新畫布，其場景中的這些參數換成數值（詳見#ref(<sec-parameters>)）；原畫布保留參數。]
#param("render(*, renderer=None, cache=None)")[繪製場景並回傳繪製器的結果（詳見#ref(<sec-rendering>)）。]
#param("save(target, *, renderer=None, cache=None, **options)")[繪製、寫出 `.png`、`.pdf` 或 `.svg`、關閉結果並回傳寫出的路徑。選項即 `SaveOptions` 的欄位。]

建構方法會修改畫布，但不會就地改動場景：每次呼叫都以新場景取代畫布中的場景，因此先前取得的快照、副本或綁定後的畫布都會維持原有內容。

```python
from mosaickit import Canvas, PathLayer

canvas = Canvas()
before = canvas.snapshot()
canvas.add(PathLayer([(0, 0), (1, 1)], id="line"))
assert before.layers == ()             # the old snapshot is unchanged
assert canvas.snapshot().layers[0].id == "line"
```

== 場景

#api(("Scene",), syntax: [#raw("Scene(layers=(), metadata={})")])[
  具持久性且有序的圖層集合，也就是每次操作都會保留舊版本。`add()`、`extend()`、`remove()` 與 `clear()` 都會回傳新場景；`Scene.empty()` 是空場景。圖層 id 在整個場景（包括群組）中必須唯一，若有重複便引發 `ConfigurationError`。`ordered_layers` 依 `z_index` 排序頂層圖層；值相同時維持加入順序，而這個順序就是繪製順序。
]

== 錯誤與警告

#tbl(caption: [例外與警告])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([類別], [引發或發出的時機]),
    [`MosaicKitError`], [以下三個錯誤的基礎類別],
    [`ConfigurationError`], [模型、樣式、主題、規格或設定值無效],
    [`BindingError`], [參數缺少值、型別錯誤，或運算式無法求值],
    [`RenderError`], [繪製器無法完成要求：未知的格式或繪製器、缺少的圖例項目],
    [`LayoutWarning`], [自動配置無法避開所有障礙物（詳見#ref(<sec-labels>)）],
    [`CacheBypassWarning`], [圖層的模型無法雜湊，因此不經快取繪製],
  )
]

#changed("0.2.0", label: "LayoutWarning")[新增，在沒有任何引線標註位置能避開所有障礙物時發出]

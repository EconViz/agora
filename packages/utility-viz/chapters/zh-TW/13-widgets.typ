#import "/template/manual.typ": *

= 互動元件 <sec-widgets>

#changed("1.4.0", label: "WidgetViewer")[`WidgetViewer` 在 Jupyter 筆記本中提供滑桿控制]
#changed("1.4.0", label: "WidgetViewer")[筆記本互動元件新增數值輸入欄位]
#changed("2.0.0b1", label: "WidgetViewer")[移至 `utility_viz.core.interactive`]

`WidgetViewer` 在 Jupyter 中提供滑桿與數值輸入欄位，調整參數後會更新圖形。使用前需安裝 `interactive` 選用依賴（詳見#ref(<sec-extras>)）。從 `utility_viz.core.interactive` 匯入；1.x 為 `econ_viz.interactive`。

#api(("WidgetViewer",), added: "v1.4.0", syntax: [
  #raw("WidgetViewer(")#meta("draw")#raw(", ")#meta("name")#raw("=(")#meta("min")#raw(", ")#meta("max")#raw(", ")#meta("step")#raw("), ...).show()")
])[
  傳入繪圖函數 `draw`，並以 `(最小值, 最大值, 步長)` 指定各參數範圍。每個參數會產生同步的 `FloatSlider` 與 `FloatText`；數值變更後重新呼叫 `draw`，並取代儲存格中的舊圖。
]

`draw` 的寫法與 `Animator` 相同（詳見#ref(<sec-animation>)），只是可同時接收多個參數。以#ref(<sec-animation>)的價格變動範例為基礎，讓 `draw()` 另外接收 `alpha`：

#example([```python
from utility_viz.core.interactive import WidgetViewer

def draw(alpha: float, px: float) -> Canvas:
    model = CobbDouglas(alpha=alpha, beta=1.0 - alpha)
    ...  # 其餘與動畫範例相同

WidgetViewer(
    draw,
    alpha=(0.2, 0.8, 0.05),
    px=(1.0, 6.0, 0.25),
).show()
```])

== 筆記本設定

在新的 Jupyter 或 Colab 環境中，依下列順序執行#footnote[utility-viz repo 中的 `notebook/econ-viz Playground.ipynb`（沿用舊檔名）已採用此流程，可在 Jupyter、VS Code 或 Colab 開啟；環境中已有 #pkg("utility-viz") 時，會自動略過安裝。]：

+ 執行安裝儲存格。
+ 若安裝過程升級 #pkg("ipywidgets")、#pkg("traitlets") 或 #pkg("IPython")，重新啟動執行環境。
+ 重新啟動後，從匯入套件的儲存格繼續執行，無須再次安裝。

== 選擇互動元件或 GIF

需要由使用者調整參數時，使用 `WidgetViewer`；需要在簡報或網頁中播放固定的變動過程時，使用 `Animator` 匯出 GIF（詳見#ref(<sec-animation>)）。

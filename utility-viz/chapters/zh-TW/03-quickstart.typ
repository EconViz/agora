#import "/template/manual.typ": *

= 快速開始 <sec-quickstart>

== 基本範例

本章以 Cobb-Douglas 消費者問題說明完整流程：

$
  max_(x, y) & u(x, y) = x^(1/2) y^(1/2) \
      "s.t." & 2x + 3y = 30
$

程式先求解最適消費組合，再繪製無異曲線、預算集合與均衡點（參見#ref(<fig-quickstart>)）。

#example(modify[```python
from utility_viz import Canvas, levels, solve
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
eq    = solve(model, px=2.0, py=3.0, income=30.0)
lvls  = levels.around(eq.utility, n=5)

cvs = Canvas(
    x_max=20, y_max=15,
    x_label="x", y_label="y",
    title=r"Cobb-Douglas $x^{0.5} y^{0.5}$"
)
cvs.add_utility(model, levels=lvls)
cvs.add_budget(2.0, 3.0, 30.0, fill=True)
cvs.add_equilibrium(eq, show_ray=True)
cvs.save("cobb_douglas.png")
```])

#fig("/figures/models/cobb_douglas.svg", caption: [
  消費者均衡。
]) <fig-quickstart>

執行主程式 `main.py` 後，會在目前工作目錄建立 `cobb_douglas.png`。本例的最適消費量為 $x^* = 7.5$、$y^* = 5$，支出為 $2 times 7.5 + 3 times 5 = 30$，恰好等於所得。預算線的兩個軸截距則為 $I / p_x = 15$ 與 $I / p_y = 10$。

== 逐步說明

繪圖流程依序為：建立模型、求解均衡、選取效用水準、建立畫布、加入圖層與匯出。

#api(("utility_viz.models",), syntax: [
  #modify[```python
  from utility_viz.models import CobbDouglas
  model = CobbDouglas(alpha=0.5, beta=0.5)
  ```]
])[
  建立效用模型。內建模型詳見#ref(<sec-models>)；自訂函數使用 `CustomUtility`，詳見#ref(<sec-advanced>)。
]

#api(("solve",), syntax: [
  #raw("solve(")#meta("model")#raw(", px=")#meta("float")#raw(", py=")#meta("float")#raw(", income=")#meta("float")#raw(
    ")",
  )
])[
  依價格與所得求解，回傳不可變的 `Equilibrium` 物件。

  #param("x", type: "float")[最適消費量 $x^*$。]
  #param("y", type: "float")[最適消費量 $y^*$。]
  #param("utility", type: "float")[模型在最適點的效用值。]
  #param("bundle_type", type: "str")[
    解的類型：`"interior"` 為內部解、`"boundary"` 為數值解落在數量下界（例如 Stone-Geary 的最低消費限制）、`"kink"` 為完全互補的拗折解、`"corner"` 為完全替代的角解。
  ]

  #modify[```python
  from utility_viz import solve
  eq = solve(model, px=2.0, py=3.0, income=30.0)
  print(eq.x, eq.y, round(eq.utility, 3))

  # 7.5 5.0 6.124
  ```]
]

#api(("levels.around",), syntax: [
  #raw("levels.around(")#meta("utility")#raw(", n=")#meta("int")#raw(")")
])[
  以指定效用值為中心，產生 $n$ 個效用水準。#ref(<fig-quickstart>) 使用 `n=5`，因此繪製五條無異曲線。

  `levels.around()` 會保留指定的效用值，均衡點會落在其中一條無異曲線上。若直接傳入 `levels=5`，畫布會依取樣到的效用範圍選取水準，不保證包含均衡效用。要比較多張圖上的同一組偏好，可先計算一次 `lvls`，再讓各張圖使用相同水準。
]

#api(("Canvas",), syntax: [
  #raw("Canvas(x_max=")#meta("float")#raw(", y_max=")#meta("float")#raw(", ...)")
])[
  建立畫布並設定座標範圍，其餘參數詳見#ref(<sec-canvas>)。

  座標範圍只控制顯示區域，不參與 `solve()` 的計算。均衡點未出現在圖中時，檢查 `eq.x` 與 `eq.y` 是否超出範圍，再調整座標上限。
]

#api(("Canvas.add_*",))[
  在同一張畫布上加入無異曲線、預算線或均衡點。這些方法可以串接呼叫（詳見#ref(<sec-chaining>)）。`add_equilibrium()` 使用既有的求解結果，不會重新求解；若之後修改價格、所得或模型，需重新呼叫 `solve()`，並建立對應的新圖。
]

#api(("Canvas.save", "Canvas.show"))[
  `save()` 依副檔名匯出檔案（詳見#ref(<sec-export>)）；`show()` 開啟 #pkg("matplotlib") 互動視窗。輸出路徑以執行程式時的工作目錄為準，若需指定子目錄，請事先建立目錄。
]

=== 檢查輸入與求解失敗

價格與所得必須為正；輸入不符合條件時，`solve()` 拋出 `InvalidParameterError`#footnote[一般平滑模型使用#term("序列最小平方法", english: "sequential least squares programming, SLSQP") 求解。]。

求解未收斂時，`solve()` 拋出 `OptimizationError`，不會回傳無效的均衡點。

#modify[```python
from utility_viz import InvalidParameterError, OptimizationError, solve

try:
    eq = solve(model, px=2.0, py=3.0, income=30.0)
except (InvalidParameterError, OptimizationError) as error:
    print(error)
else:
    print(round(eq.x, 3), round(eq.y, 3), eq.bundle_type)
```]

#changed("2.0.0b1", label: "UtilityVizError")[#modify[`UtilityVizError` 成為基礎例外類別；`EconVizError` 保留為同一類別的別名]]
#modify[套件拋出的所有例外都繼承自 `UtilityVizError`，捕捉它即可一併處理。1.x 的名稱 `EconVizError` 是同一個類別。]

數值解可能有微小誤差，例如結果接近但不恰好等於 `7.5`。驗證時應使用適當容許誤差；顯示結果時再用 `round()` 格式化，避免過早四捨五入影響後續計算。

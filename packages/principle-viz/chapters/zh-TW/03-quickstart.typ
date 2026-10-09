#import "/template/manual.typ": *

= 快速開始 <sec-quickstart>

== 基本範例

本章以一個市場說明完整流程，後續各章也沿用這個市場：
$
  "需求：" & quad p = 10 - Q, \
  "供給：" & quad p = 2 + Q.
$

#example(```python
from principle_viz import MarketFigure, line_from_inverse, solve_equilibrium

demand = line_from_inverse(10.0, -1.0)   # p = 10 - Q
supply = line_from_inverse(2.0, 1.0)     # p = 2 + Q
eq = solve_equilibrium(demand, supply)
print(eq.q_star, eq.p_star)              # 4.0 6.0

fig = MarketFigure(x_max=12, y_max=12, title="Basic Equilibrium")
fig.add_curves(demand, supply, q_max=10)
fig.add_equilibrium(eq)
fig.finalize()
fig.save("basic_equilibrium.png")
```)

#fig("/figures/quickstart/equilibrium.svg", width: 46%, caption: [
  本章的市場（省略標題）。
]) <fig-quickstart>

由 $10 - Q = 2 + Q$ 得 $Q^* = 4$、$p^* = 6$。輸出參見#ref(<fig-quickstart>)。

== 逐步說明

每張圖依序經過描述市場、求解、繪圖、完成並儲存四個步驟。

#api(("line_from_inverse",), syntax: [
  #raw("line_from_inverse(")#meta("float")#raw(", ")#meta("float")#raw(")")
])[
  描述市場。`line_from_inverse(a, b)` 建立直線 $p = a + b Q$（詳見#ref(<sec-markets>)）。
]

#api(("solve_equilibrium",), syntax: [
  #raw("solve_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(")")
])[
  求解。`solve_equilibrium()` 等求解函式回傳由數值組成的不可變 dataclass，此時尚未繪圖。
]

#api(("MarketFigure",), syntax: [
  #raw("MarketFigure(x_max=")#meta("float")#raw(", y_max=")#meta("float")#raw(", ...)")
])[
  繪圖。`MarketFigure` 是含價格軸與數量軸的正方形圖。座標範圍只控制顯示區域，不參與計算；均衡點未出現在圖中時，檢查 `eq.q_star` 與 `eq.p_star` 是否超出範圍，再調整座標上限。
]

#api(("MarketFigure.add_*",))[
  `add_*` 方法接收曲線與結果，加入對應的圖層；每個方法都回傳圖形本身，可串接呼叫。
]

#api(("MarketFigure.finalize", "MarketFigure.save"))[
  完成並儲存。`finalize()` 隱藏會把陰影面積切成兩半的輔助線；`save()` 依副檔名寫出 PNG、SVG 或 PDF，並建立不存在的目錄（詳見#ref(<sec-figures>)）。
]

計算與繪圖互不依賴：結果可以不經繪圖直接印出、比較或匯出，同一個結果也可以畫在多張圖上。

== 結果

結果是不可變的 dataclass，欄位為浮點數、字串與 tuple。`solve_equilibrium()` 回傳 `EquilibriumResult`：

#param("q_star", type: "float")[均衡數量 $Q^*$。]
#param("p_star", type: "float")[均衡價格 $p^*$。]
#param("is_valid_market", type: "bool")[均衡數量為負時為 `False`；價格為負只會加入一則說明。]
#param("notes", type: "tuple[str, ...]")[說明解的特殊情況。]

== 檢查輸入與求解失敗

#api(("PrincipleVizError",))[
  套件拋出的所有例外都繼承自 `principle_viz.exceptions` 中的 `PrincipleVizError`，捕捉它即可一併處理（各例外詳見#ref(<sec-errors>)）。
]

兩條直線平行時沒有均衡，`solve_equilibrium()` 拋出 `ParallelLinesError`，不會回傳無效的結果：

```python
from principle_viz import line_from_inverse, solve_equilibrium
from principle_viz.exceptions import PrincipleVizError

demand = line_from_inverse(10.0, -1.0)
supply = line_from_inverse(8.0, -1.0)   # parallel to demand

try:
    eq = solve_equilibrium(demand, supply)
except PrincipleVizError as error:
    print(type(error).__name__)
else:
    print(eq.q_star, eq.p_star)

# ParallelLinesError
```

均衡數量為負時不拋出例外，而是將 `is_valid_market` 設為 `False`。使用結果前，先檢查 `is_valid_market` 與 `notes`。

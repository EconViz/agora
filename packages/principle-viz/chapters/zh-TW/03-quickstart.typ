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

由 $10 - Q = 2 + Q$ 得 $Q^* = 4$、$p^* = 6$。結果如#ref(<fig-quickstart>)：曲線名稱標在末端，均衡點為實心點並標為 $e^*$，座標軸名稱 $p$ 與 $Q$ 位於箭頭外側。

== 步驟說明

每張圖都依以下四個步驟建立。

+ *描述市場。*`line_from_inverse(a, b)` 建立直線 $p = a + b Q$（詳見#ref(<sec-markets>)）。
+ *求解。*`solve_equilibrium()` 等求解函式回傳由數值組成的不可變 dataclass，此時尚未繪圖。
+ *繪圖。*`MarketFigure` 是含價格軸與數量軸的正方形圖。其 `add_*` 方法接收曲線與結果，加入對應的圖層；每個方法都回傳圖形本身，可串接呼叫。
+ *完成並儲存。*`finalize()` 隱藏會把陰影面積切成兩半的輔助線；`save()` 依副檔名寫出 PNG、SVG 或 PDF。

計算與繪圖互不依賴：結果可以不經繪圖直接印出、比較或匯出，同一個結果也可以畫在多張圖上。

== 結果

結果是不可變的 dataclass，欄位為浮點數、字串與 tuple。`solve_equilibrium()` 回傳 `EquilibriumResult`：

#param("q_star", type: "float")[均衡數量 $Q^*$。]
#param("p_star", type: "float")[均衡價格 $p^*$。]
#param("is_valid_market", type: "bool")[均衡數量為負時為 `False`；價格為負只會加入一則說明。]
#param("notes", type: "tuple[str, ...]")[說明解的特殊情況。]

無效的輸入會拋出繼承自 `PrincipleVizError` 的例外（詳見#ref(<sec-errors>)），求解失敗不會被誤當成結果。

#import "/template/manual.typ": *

= 等值線 <sec-implicit>

無異曲線、等產量曲線與等高線，都是二元函數的等值集。

#definition(name: [等值集])[
  對 $F: RR^2 -> RR$ 與水準 $c in RR$，等值集為
  $ L_c = {(x, y) : F(x, y) = c}. $
] <def-level-set>

`trace_implicit` 不需解出 $y$ 就能把等值集轉為三次路徑，因此可以處理會折返、封閉或分成數段的曲線。

#api(("trace_implicit",), syntax: [
  #raw("trace_implicit(")#meta("function")#raw(", *, levels, viewport, resolution=(101, 101), tolerance=1e-2, gradient=None)")
])[
  在矩形 `viewport` $= (x_min, x_max, y_min, y_max)$ 內，描繪每個水準 $c$ 的 $F(x, y) = c$，位於 `bezierkit.implicit`。
]

#param("function")[$F$，以兩個浮點數呼叫；在每個網格點都必須為有限值，否則拋出 `ValueError`。]
#param("levels")[單一水準，或由有限水準值組成的可迭代物件。]
#param("resolution", type: "(int, int)", default: "(101, 101)")[沿 $x$ 與 $y$ 的網格點數，各至少 2。]
#param("tolerance", type: "float", default: "1e-2")[簡化與彎曲線段的容許偏差，單位同座標。]
#param("gradient", type: "callable | None", default: "None")[$nabla F = (F_x, F_y)$，以 tuple 或 `Vector` 回傳。提供時，直線段會彎成沿曲線切線方向的三次曲線。]

== 演算法

+ *取樣。*在 viewport 的規則網格上計算 $F$。
+ *行進。*在每個網格格子中標出 $F >= c$ 的角點。兩端標記不同的邊與等值集相交，交點即#ref(<def-crossing>)所定義的點 #citep(<lorensen1987>)。有兩個交點的格子貢獻一條線段。有四個交點的格子是鞍點，由四個角點值的平均決定如何連接（參見#ref(<fig-saddle>)）。
+ *縫合。*把端點相同的線段串成鏈。回到起點的鏈是封閉的；抵達 viewport 邊界或分支點的鏈是開放的。互不相連的部分保持為不同的路徑。
+ *簡化。*以 `tolerance` 對每條鏈呼叫 `fit_polyline`（詳見#ref(<sec-fitting>)），不保留轉角。
+ *彎曲*（提供 `gradient` 時）。把每條直線段換成端點切線沿等值集方向的三次曲線（詳見#ref(<thm-gradient>)），控制柄長為弦長的三分之一。只有當三次曲線與弦的距離不超過 `tolerance` 時才採用；任一端 $nabla F = 0$ 時維持直線。

#definition(name: [邊上的交點])[
  設網格的一條邊由 $p$ 到 $q$，且 $F(p) >= c > F(q)$ 或 $F(q) >= c > F(p)$。其交點為 $p + lambda (q - p)$，其中
  $ lambda = (c - F(p)) / (F(q) - F(p)), $
  即 $F - c$ 沿該邊的線性插值之零點。
] <def-crossing>

#fig("/figures/implicit/saddle.pdf", width: auto, caption: [
  鞍點格子：(a) 中心高、(b) 中心低。
]) <fig-saddle>

#ref(<fig-saddle>)中實心角點代表 $F >= c$。

#theorem(name: [等值集的切線])[
  設 $F$ 在點 $p$ 附近連續可微，$F(p) = c$ 且 $nabla F(p) != 0$。則在 $p$ 附近等值集 $F = c$ 是一條 $C^1$ 曲線，其在 $p$ 的切線平行於 $(F_y(p), -F_x(p))$。
] <thm-gradient>

切線 $(F_y, -F_x)$ 不需除法，因此垂直切線（$F_y = 0$）與其他情況一樣容易處理；圖形形式的斜率 $dif y slash dif x = -F_x slash F_y$ 在該處則為無窮大。

```python
from bezierkit.implicit import trace_implicit

contours = trace_implicit(
    lambda x, y: x**2 * y,
    levels=[1, 2, 4],
    viewport=(0.5, 4, 0, 6),
    resolution=(121, 121),
    tolerance=0.01,
    gradient=lambda x, y: (2 * x * y, x**2),
)
print(contours.level_values)                     # (1.0, 2.0, 4.0)
print(len(contours.for_level(4)[0].segments))    # 15
```

#fig("/figures/implicit/contours.pdf", width: auto, caption: [
  $x^2 y = c$，$c = 1, 2, 4$ 由內而外。
]) <fig-contours>

== 結果

#api(("ContourSet", "LevelContours"))[
  `trace_implicit` 回傳 `ContourSet`，其 `contours` 依給定順序為每個水準保存一個 `LevelContours`：水準值 `level` 與路徑 `paths`，每個連通部分一條 `PiecewiseBezier`。`level_values` 列出各水準，`paths` 匯集所有路徑，`for_level(c)` 回傳某一水準的路徑（未描繪的水準拋出 `KeyError`）。
]

== 限制

描繪出的曲線只在網格交點上精確；交點之間是行進方格法得到的折線，再於 `tolerance` 內簡化與彎曲。需要更貼近時，請提高 `resolution` 並降低 `tolerance`。比網格格子小的特徵可能遺漏，鞍點規則也只會選擇兩種可能連接方式之一。Leontief 無異曲線的折角等尖點會在網格間距內被圓滑化，因為網格看不到精確的轉角。

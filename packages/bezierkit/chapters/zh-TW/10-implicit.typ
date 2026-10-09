#import "/template/manual.typ": *

= 等值線 <sec-implicit>

無異曲線、等產量曲線與等高線，都是二元函數的等值集。

== 等值集與切線

#definition(name: [等值集])[
  對 $F : RR^2 -> RR$ 與水準 $c in RR$，等值集為
  $ L_c = {(x, y) : F(x, y) = c}. $
] <def-level-set>

對連續可微的 $F$，以 $F_x$、$F_y$ 表示偏導數，$nabla F = (F_x, F_y)$ 為梯度。在 $nabla F != 0$ 的點附近，等值集是一條曲線，這由隱函數定理得出；以下引述所需的形式。

#theorem(name: [隱函數定理])[
  設 $Omega subset RR^2$ 為開集，$F : Omega -> RR$ 連續可微，$p in Omega$，$F(p) = c$ 且 $F_y (p) != 0$。則存在開區間 $I$、$J$ 滿足 $p_x in I$、$p_y in J$、$I times J subset Omega$，以及連續可微的 $phi : I -> J$、$phi(p_x) = p_y$，使得對 $(x, y) in I times J$，
  $ F(x, y) = c quad "若且唯若" quad y = phi(x). $
] <thm-ift>

此定理對任意個變數都成立，見 #citet(<rudin1976>) 的定理 9.28、#citet(<apostol1974>) 第二版的定理 13.7 與 #citet(<munkres1991>) 的定理 9.2。此處不予證明。

#theorem(name: [等值集的切線])[
  設 $F$ 在開集 $Omega subset RR^2$ 上連續可微，$p in Omega$，$F(p) = c$ 且 $nabla F(p) != 0$。則存在 $p$ 的開鄰域 $N$ 與開區間 $I$ 上的連續可微曲線 $gamma : I -> RR^2$，滿足 $gamma(I) = L_c inter N$、某個 $u_0 in I$ 使 $gamma(u_0) = p$、對所有 $u in I$ 有 $gamma'(u) != 0$，且 $gamma'(u)$ 平行於 $gamma(u)$ 處的 $(F_y, -F_x)$。向量 $(F_y, -F_x)$ 與 $nabla F$ 正交。
] <thm-gradient>

切線 $(F_y, -F_x)$ 不需除法，因此垂直切線（$F_y = 0$）與其他情況一樣容易處理；圖形形式的斜率 $dif y slash dif x = -F_x slash F_y$ 在該處則為無窮大。

== 描繪

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

演算法是行進方格法，即 #citet(<lorensen1987>) 行進立方體法的二維類比。網格格子的角點為 $v_(00), v_(10), v_(11), v_(01)$，由左下角起逆時針排列，$F$ 的值分別為 $f_(00), f_(10), f_(11), f_(01)$。角點的值不小於水準 $c$ 時稱為高。

#definition(name: [邊上的交點])[
  設網格的一條邊由 $p$ 到 $q$，且 $F(p) >= c > F(q)$ 或 $F(q) >= c > F(p)$。其交點為 $p + lambda (q - p)$，其中
  $ lambda = (c - F(p)) / (F(q) - F(p)), $
  即 $F - c$ 沿該邊的線性插值之零點。
] <def-crossing>

一條邊有交點，若且唯若它的兩個角點高低不同。

+ *取樣。*在 viewport 的規則網格上計算 $F$。
+ *行進。*在每個網格格子中找出四條邊的交點（詳見#ref(<def-crossing>)）。有兩個交點的格子貢獻一條線段。有四個交點的格子是鞍點：兩個對角角點為高、另兩個為低，由下述規則決定如何連接（參見#ref(<fig-saddle>)）。
+ *縫合。*把端點相同的線段串成鏈。回到起點的鏈是封閉的；抵達 viewport 邊界或分支點的鏈是開放的。互不相連的部分保持為不同的路徑。
+ *簡化。*以 `tolerance` 對每條鏈呼叫 `fit_polyline`（詳見#ref(<sec-fitting>)），不保留轉角。
+ *彎曲*（提供 `gradient` 時）。把每條直線段換成端點切線沿等值集方向的三次曲線（詳見#ref(<thm-gradient>)），控制柄長為弦長的三分之一。只有當三次曲線與弦的距離不超過 `tolerance` 時才採用；任一端 $nabla F = 0$ 時維持直線。

#fig("/figures/implicit/saddle.pdf", width: auto, caption: [
  鞍點格子：(a) 中心高、(b) 中心低；實心角點的 $F >= c$。
]) <fig-saddle>

鞍點規則使用四個角點值的雙線性插值
$ u(s, t) = (1 - s)(1 - t) f_(00) + s (1 - t) f_(10) + s t f_(11) + (1 - s) t f_(01), quad (s, t) in [0, 1]^2. $

#proposition(name: [雙線性插值的中心值])[
  插值 $u$ 在角點取角點值，在格子中心的值等於四個角點值的平均：
  $ u(1/2, 1/2) = (f_(00) + f_(10) + f_(11) + f_(01)) / 4. $
] <prop-center>

此平均值不小於 $c$ 時，套件將中心視為高。在鞍點格子中，與中心同側的兩個角點在格內相連，另外兩個角點各自被一條線段切開（參見#ref(<fig-saddle>)）。這就是中點決定法（midpoint decider）#citep(<athawale2019>)。#citet(<nielson1991>) 的漸近決定法（asymptotic decider）則比較 $u$ 在其鞍點的值
$ u^* = (f_(00) f_(11) - f_(10) f_(01)) / (f_(00) - f_(10) - f_(01) + f_(11)), $
兩種規則只在 $u^*$ 與平均值落在 $c$ 兩側時才不同。

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

#api(("ContourSet",))[
  `trace_implicit` 回傳 `ContourSet`，其 `contours` 依給定順序為每個水準保存一個 `LevelContours`。`level_values` 列出各水準，`paths` 匯集所有路徑，`for_level(c)` 回傳某一水準的路徑（未描繪的水準拋出 `KeyError`）。
]

#api(("LevelContours",))[
  水準值 `level` 與路徑 `paths`，每個連通部分一條 `PiecewiseBezier`。
]

== 限制

描繪出的曲線只在網格交點上精確；交點之間是行進方格法得到的折線，再於 `tolerance` 內簡化與彎曲。需要更貼近時，請提高 `resolution` 並降低 `tolerance`。比網格格子小的特徵可能遺漏，鞍點規則也只會選擇兩種可能連接方式之一。Leontief 無異曲線的折角等尖點會在網格間距內被圓滑化，因為網格看不到精確的轉角。

#import "/template/manual.typ": *

= Bézier 曲線 <sec-curves>

== Bernstein 基底

#definition(name: [Bernstein 多項式])[
  $n >= 0$ 次 Bernstein 多項式為
  $ b_(i,n)(t) = binom(n, i) t^i (1-t)^(n-i), quad i = 0, dots, n. $
  其他的 $i$ 令 $b_(i,n) = 0$。
] <def-bernstein>

它們構成次數不超過 $n$ 的多項式空間的一組基底 #citep(<farouki2012>)；三次的情形如#ref(<fig-basis>)。

#definition(name: [Bézier 曲線])[
  設 $P_0, dots, P_n in RR^d$。以 $P_0, dots, P_n$ 為控制點的 $n$ 次 Bézier 曲線為
  $ B(t) = sum_(i=0)^n b_(i,n)(t) P_i, quad t in [0, 1], $
  其控制多邊形為折線 $P_0 P_1 dots P_n$。
] <def-curve>

以下的證明依賴兩個二項式係數恆等式。

#lemma(name: [二項式恆等式])[
  對整數 $n >= 1$ 與 $i$、$j$，
  $ binom(n-1, j) + binom(n-1, j-1) = binom(n, j), quad
    i binom(n, i) = n binom(n-1, i-1), $
  其中 $k < 0$ 或 $k > m$ 時 $binom(m, k) = 0$。
] <lem-binomial>

#fig("/figures/curves/basis.pdf", width: auto, caption: [
  三次 Bernstein 多項式。
]) <fig-basis>

#proposition(name: [單位分割])[
  對每個 $t in [0, 1]$，所有 $b_(i,n)(t) >= 0$，且 $sum_(i=0)^n b_(i,n)(t) = 1$。
] <prop-unity>

#proposition(name: [端點])[
  $b_(i,n)(0)$ 在 $i = 0$ 時為 1，其餘為 0；$b_(i,n)(1)$ 在 $i = n$ 時為 1，其餘為 0。因此 $B(0) = P_0$、$B(1) = P_n$。
] <prop-endpoints>

#corollary(name: [凸包])[
  每個 $B(t)$（$t in [0, 1]$）都位於控制點 $P_0, dots, P_n$ 的凸包內。
] <cor-hull>

#proposition(name: [仿射不變性])[
  對每個仿射映射 $A(x) = M x + v$，$A(B(t)) = sum_i b_(i,n)(t) A(P_i)$：變換曲線等同於變換其控制點。
] <prop-affine>

#ref(<cor-hull>)讓曲線不超出控制多邊形所張的區域；#ref(<prop-affine>)則是匯出器與 Matplotlib 轉接器只需移動控制點，就能平移、縮放或旋轉曲線的原因。

#api(("BernsteinBasis",), syntax: [
  #raw("BernsteinBasis(")#meta("int")#raw(")(")#meta("float")#raw(")") \
  #raw("BernsteinBasis(")#meta("int")#raw(").matrix(")#meta("values")#raw(")")
])[
  某一次數的基底，位於 `bezierkit.bezier.basis`。在 $t$ 呼叫時，以陣列回傳 $i = 0, dots, n$ 的 $b_(i,n)(t)$；`matrix()` 對每個參數值回傳一列。
]

== 曲線

#api(("BezierCurve",), syntax: [
  #raw("BezierCurve(")#meta("points")#raw(", *, evaluator=None)") \
  #raw("BezierCurve.linear(p0, p1)") \
  #raw("BezierCurve.quadratic(p0, p1, p2)") \
  #raw("BezierCurve.cubic(p0, p1, p2, p3)")
])[
  不可變的 Bézier 曲線，次數 $n >= 0$、維度 $d >= 1$ 均不限，參數範圍為 $[0, 1]$。`points` 可為 `Point` 序列、`PointSet`、$(n + 1) times d$ 陣列或 `ControlPolygon`；所有控制點必須同一維度。
]

#param("degree, dimension")[$n$ 與 $d$。]
#param("control_points")[以 `PointSet` 表示的控制點。]
#param("at(t), at_many(values)")[以 `Point` 回傳 $B(t)$，或以 `PointSet` 回傳多個參數下的值；曲線物件也可直接呼叫，`curve(t)`。]
#param("evaluator")[求值策略（見下文）。]

曲線的運算 `derivative()`、`split()`、`segment()` 與 `reversed()` 詳見#ref(<sec-operations>)。

== 求值

*de Casteljau 演算法*以反覆的線性插值計算 $B(t)$。

#definition(name: [de Casteljau 點])[
  對參數 $t$，令 $P_i^((0)) = P_i$，以及
  $ P_i^((r)) = (1 - t) P_i^((r-1)) + t P_(i+1)^((r-1)), quad r = 1, dots, n, quad i = 0, dots, n - r. $
] <def-casteljau>

每一輪對相鄰點取平均，多邊形少一個點；$n$ 輪後只剩一點（參見#ref(<fig-casteljau>)）。

#theorem(name: [de Casteljau])[
  對 $0 <= r <= n$ 與 $0 <= i <= n - r$，$P_i^((r)) = sum_(j=0)^r b_(j,r)(t) P_(i+j)$。特別地，$P_0^((n)) = B(t)$。
] <thm-casteljau>

#fig("/figures/curves/casteljau.pdf", width: auto, caption: [
  $t = 0.4$ 的 de Casteljau 演算法。
]) <fig-casteljau>

每個中間點都是控制點的凸組合，演算法不會產生互相抵消的大數，因此在高次數時數值穩定。每個參數的計算量為 $O(n^2)$。

#api(("DeCasteljauEvaluator", "BernsteinEvaluator"))[
  兩種求值策略，位於 `bezierkit.bezier.evaluation`，都以 NumPy 一次計算整批參數。預設的 `DeCasteljauEvaluator` 執行上述演算法；`BernsteinEvaluator` 以 Bernstein 矩陣乘上控制點，次數低、批次大時較快，但高次數時會加總可能互相抵消的項。依#ref(<thm-casteljau>)，兩者計算的是同一個多項式。
]

```python
from bezierkit import BezierCurve
from bezierkit.bezier.evaluation import BernsteinEvaluator

fast = BezierCurve(curve.control_points, evaluator=BernsteinEvaluator())
print(fast.at(0.5))   # Point(coords=(2.0, 1.5)), as with the default
```

儲存庫的 `benchmarks/` 目錄比較兩者在 400、10,000 與 100,000 個參數值下的效能。

#import "/template/manual.typ": *

= Bézier 曲線 <sec-curves>

== Bernstein 基底

#definition(name: [Bernstein 多項式])[
  $n >= 0$ 次 Bernstein 多項式為
  $ b_(i,n)(t) = binom(n, i) t^i (1-t)^(n-i), quad i = 0, dots, n. $
  其他整數 $i$ 令 $b_(i,n) = 0$。
] <def-bernstein>

這組多項式出自 #citet(<bernstein1912>)；#citet(<farouki2012>)回顧其歷史與性質，三次的情形如#ref(<fig-basis>)。以下證明用到兩個二項式係數恆等式。

#lemma(name: [二項式恆等式])[
  令 $n >= 1$，$i$、$j$ 為整數，並約定 $k < 0$ 或 $k > m$ 時 $binom(m, k) = 0$。則
  $ binom(n-1, j) + binom(n-1, j-1) = binom(n, j) $
  且
  $ i binom(n, i) = n binom(n-1, i-1). $
] <lem-binomial>

#fig("/figures/curves/basis.pdf", width: auto, caption: [
  三次 Bernstein 多項式。
]) <fig-basis>

#proposition(name: [Bernstein 基底])[
  對 $n >= 0$，多項式 $b_(0,n), dots, b_(n,n)$ 是次數不超過 $n$ 的實係數多項式向量空間的一組基底。
] <prop-basis>

這是 #citet(<floater2025>) 的定理 1.1；#ref(<app-proofs>)從頭證明。

#proposition(name: [單位分割])[
  對每個 $t in [0, 1]$，所有 $b_(i,n)(t) >= 0$，且
  $ sum_(i=0)^n b_(i,n)(t) = 1. $
] <prop-unity>

#definition(name: [Bézier 曲線])[
  設 $P_0, dots, P_n in RR^d$。以 $P_0, dots, P_n$ 為控制點的 $n$ 次 Bézier 曲線為
  $ B(t) = sum_(i=0)^n b_(i,n)(t) P_i, quad t in [0, 1], $
  其控制多邊形為折線 $P_0 P_1 dots P_n$。
] <def-curve>

此定義依循 #citet(<bezier1966>)，形式如 #citet(<farin2002>) 與 #citet(<prautzsch2002>)。

#proposition(name: [端點])[
  $b_(i,n)(0)$ 在 $i = 0$ 時為 1，其餘為 0；$b_(i,n)(1)$ 在 $i = n$ 時為 1，其餘為 0。因此 $B(0) = P_0$、$B(1) = P_n$。
] <prop-endpoints>

#corollary(name: [凸包])[
  每個 $B(t)$（$t in [0, 1]$）都位於控制點 $P_0, dots, P_n$ 的凸包內。
] <cor-hull>

#proposition(name: [仿射不變性])[
  對每個仿射映射 $A(x) = M x + v$ 與每個 $t in [0, 1]$，
  $ A(B(t)) = sum_(i=0)^n b_(i,n)(t) A(P_i). $
  變換曲線等同於變換其控制點。
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

#param("degree")[次數 $n$。]
#param("dimension")[維度 $d$。]
#param("control_points")[以 `PointSet` 表示的控制點。]
#param("at()")[以 `Point` 回傳 $B(t)$；曲線物件也可直接呼叫，`curve(t)`。]
#param("at_many()")[以 `PointSet` 回傳多個參數下的值。]
#param("evaluator")[求值策略（見下文）。]

曲線的運算 `derivative()`、`split()`、`segment()` 與 `reversed()` 詳見#ref(<sec-operations>)。

== 求值

*de Casteljau 演算法*以反覆的線性插值計算 $B(t)$。

#definition(name: [de Casteljau 點])[
  對參數 $t$，令 $P_i^((0)) = P_i$，並對 $r = 1, dots, n$ 令
  $ P_i^((r)) = (1 - t) P_i^((r-1)) + t P_(i+1)^((r-1)), quad i = 0, dots, n - r. $
] <def-casteljau>

每一輪對相鄰點取平均，多邊形少一個點；$n$ 輪後只剩一點（參見#ref(<fig-casteljau>)）。此演算法源自 Paul de Casteljau 約 1959 年在 Citroën 的工作 #citep(<mueller2024>)。

#theorem(name: [de Casteljau])[
  對 $0 <= r <= n$ 與 $0 <= i <= n - r$，
  $ P_i^((r)) = sum_(j=0)^r b_(j,r)(t) P_(i+j). $
  特別地，$P_0^((n)) = B(t)$。
] <thm-casteljau>

此敘述見 #citet(<floater2025>) 的定理 1.6 與 1.7。

#fig("/figures/curves/casteljau.pdf", width: auto, caption: [
  $t = 0.4$ 的 de Casteljau 演算法。
]) <fig-casteljau>

每個中間點都是控制點的凸組合，演算法不會產生互相抵消的大數，因此在高次數時數值穩定。每個參數的計算量為 $O(n^2)$。

#api(("DeCasteljauEvaluator",))[
  預設的求值策略，位於 `bezierkit.bezier.evaluation`：以 NumPy 一次對整批參數執行上述演算法。
]

#api(("BernsteinEvaluator",))[
  以 Bernstein 矩陣乘上控制點。次數低、批次大時較快，但高次數時會加總可能互相抵消的項。依#ref(<thm-casteljau>)，兩種策略計算的是同一個多項式。
]

```python
from bezierkit import BezierCurve
from bezierkit.bezier.evaluation import BernsteinEvaluator

fast = BezierCurve(curve.control_points, evaluator=BernsteinEvaluator())
print(fast.at(0.5))   # Point(coords=(2.0, 1.5)), as with the default
```

儲存庫的 `benchmarks/` 目錄比較兩者在 400、10,000 與 100,000 個參數值下的效能。

== 升階

$n$ 次曲線也是 $n + 1$ 次曲線；新的控制點是舊控制點中相鄰兩點的凸組合。

#lemma(name: [升階恆等式])[
  對 $n >= 0$、$0 <= i <= n$ 與每個 $t$，
  $ b_(i,n)(t) = (n + 1 - i) / (n + 1) b_(i,n+1)(t) + (i + 1) / (n + 1) b_(i+1,n+1)(t). $
] <lem-raise-identity>

#proposition(name: [升階])[
  設 $B$ 的控制點為 $P_0, dots, P_n$。對 $k = 0, dots, n + 1$ 令
  $ Q_k = k / (n + 1) P_(k-1) + (1 - k / (n + 1)) P_k, $
  其中 $P_(-1)$ 與 $P_(n+1)$ 可任意選取，因為它們的係數為零。則
  $ B(t) = sum_(k=0)^(n+1) b_(k,n+1)(t) Q_k quad "對所有" t. $
  曲線及其參數化都不變。
] <prop-raise-degree>

此公式是標準結果 #citep(<farin2002>)#citep(<prautzsch2002>)；#ref(<app-proofs>)的證明不依賴它們。#ref(<prop-elevation>)把它用在直線與二次曲線，也就是本套件需要的情形。

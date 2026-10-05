#import "/template/manual.typ": *

= 導數、反轉與分割 <sec-operations>

每項運算只作用於控制點，並回傳沿用原曲線求值策略的新曲線。

== 導數

Bézier 曲線的導數 $B'(t)$ 是其座標函數（$t$ 的多項式）的導數，為 $RR^d$ 中的向量。

#lemma(name: [Bernstein 多項式的導數])[
  對 $n >= 1$ 與每個整數 $i$，
  $ b'_(i,n)(t) = n [b_(i-1,n-1)(t) - b_(i,n-1)(t)]. $
] <lem-bernstein-derivative>

此為 #citet(<floater2025>) 的引理 1.4。

#theorem(name: [速端曲線])[
  $n$ 次 Bézier 曲線（$n >= 1$）的導數是 $n - 1$ 次 Bézier 曲線
  $ B'(t) = sum_(i=0)^(n-1) b_(i,n-1)(t) dot n (P_(i+1) - P_i). $
] <thm-hodograph>

控制點為 $n(P_(i+1) - P_i)$ 的曲線稱為 $B$ 的速端曲線（#citet(<floater2025>) 的定理 1.8；另見 #citet(<farin2002>)）。

#corollary(name: [端點切線])[
  $B'(0) = n(P_1 - P_0)$，$B'(1) = n(P_n - P_(n-1))$。
] <cor-end-tangents>

這說明了曲線為何朝 $P_1$ 的方向離開 $P_0$，並從 $P_(n-1)$ 的方向抵達 $P_n$。

#api(("BezierCurve.derivative",), syntax: [
  #raw("derivative(order=1)")
])[
  以 `BezierCurve` 回傳 `order` 階導數，即套用#ref(<thm-hodograph>) `order` 次。常數（0 次）的導數是 0 次的零曲線；`order=0` 回傳曲線本身。
]

```python
d = curve.derivative()
print(list(d.control_points))
# [Point(coords=(3.0, 6.0)), Point(coords=(6.0, 0.0)), Point(coords=(3.0, -6.0))]
print(d.at(0.5))   # Point(coords=(4.5, 0.0)): the tangent at the top is horizontal
```

== 反轉

#lemma(name: [對稱性])[
  對所有 $i$ 與 $t$，$b_(i,n)(1 - t) = b_(n-i,n)(t)$。
] <lem-symmetry>

#proposition(name: [反轉])[
  控制點為 $P_n, dots, P_0$ 的曲線就是 $t |-> B(1 - t)$。
] <prop-reversal>

#api(("BezierCurve.reversed",))[
  依#ref(<prop-reversal>)，回傳反向走訪的曲線。
]

== 分割

在 $t = c$ 執行 de Casteljau 演算法不只得到曲線值：每一輪的第一個點構成 $c$ 之前那段曲線的控制多邊形，最後一個點構成 $c$ 之後那段的控制多邊形（參見#ref(<fig-split>)）。

#theorem(name: [分割])[
  令 $c in [0, 1]$，並在 $t = c$ 計算#ref(<def-casteljau>)的各點。令 $L_j = P_0^((j))$、$R_j = P_j^((n-j))$，$j = 0, dots, n$。則對每個 $s in [0, 1]$
  $ B(c s) = sum_(j=0)^n b_(j,n)(s) L_j $
  且
  $ B(c + (1 - c) s) = sum_(j=0)^n b_(j,n)(s) R_j. $
] <thm-subdivision>

這是經典結果，見 #citet(<floater2025>)（第 8.4 節，由 blossom 導出）與 #citet(<farin2002>)。

#fig("/figures/curves/split.pdf", width: auto, caption: [
  在 $t = 0.4$ 分割三次曲線。
]) <fig-split>

#api(("BezierCurve.split", "BezierCurve.segment"), syntax: [
  #raw("split(")#meta("float")#raw(")") \
  #raw("segment(t0, t1)")
])[
  `split(c)` 回傳#ref(<thm-subdivision>)的兩條曲線，次數不變，參數範圍都是 $[0, 1]$。`segment(t0, t1)` 回傳曲線在 $t_0$ 與 $t_1$ 之間的部分，重新參數化到 $[0, 1]$；$t_0 = t_1$ 時回傳單點 $B(t_0)$，即 0 次曲線。參數超出 $[0, 1]$ 或 $t_0 > t_1$ 時拋出例外。
]

`segment()` 分割兩次：先在 $t_1$ 分割並保留左段，再在 $t_0 slash t_1$ 分割該段並保留右段。

#corollary(name: [截取])[
  對 $0 <= t_0 < t_1 <= 1$，`segment(t0, t1)` 回傳的曲線為 $s |-> B(t_0 + (t_1 - t_0) s)$。
] <cor-segment>

```python
left, right = curve.split(0.4)
print(left.at(1.0), right.at(0.0))         # both B(0.4) = (1.552, 1.44)
print(curve.segment(0.25, 0.75).at(0.5))   # B(0.5) = (2.0, 1.5)
```


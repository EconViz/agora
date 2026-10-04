#import "/template/manual.typ": *

= 導數、分割與反轉 <sec-operations>

每項運算只作用於控制點，並回傳沿用原曲線求值策略的新曲線。

== 導數

#theorem(name: [速端曲線])[
  $n$ 次 Bézier 曲線（$n >= 1$）的導數是 $n - 1$ 次 Bézier 曲線
  $ B'(t) = sum_(i=0)^(n-1) b_(i,n-1)(t) dot n (P_(i+1) - P_i). $
  特別地，$B'(0) = n(P_1 - P_0)$、$B'(1) = n(P_n - P_(n-1))$。
] <thm-hodograph>

最後一句說明了曲線為何朝 $P_1$ 的方向離開 $P_0$，並從 $P_(n-1)$ 的方向抵達 $P_n$。

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

== 分割

在 $t = c$ 執行 de Casteljau 演算法不只得到曲線值：每一輪的第一個點構成 $c$ 之前那段曲線的控制多邊形，最後一個點構成 $c$ 之後那段的控制多邊形（參見#ref(<fig-split>)）。

#theorem(name: [分割])[
  令 $c in [0, 1]$，並在 $t = c$ 計算 de Casteljau 的各點。令 $L_j = P_0^((j))$、$R_j = P_j^((n-j))$，$j = 0, dots, n$。則對每個 $s in [0, 1]$
  $ B(c s) = sum_(j=0)^n b_(j,n)(s) L_j, quad
    B(c + (1 - c) s) = sum_(j=0)^n b_(j,n)(s) R_j. $
] <thm-subdivision>

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

#theorem(name: [截取])[
  對 $0 <= t_0 < t_1 <= 1$，`segment(t0, t1)` 回傳的曲線為 $s |-> B(t_0 + (t_1 - t_0) s)$。
] <thm-segment>

```python
left, right = curve.split(0.4)
print(left.at(1.0), right.at(0.0))         # both B(0.4) = (1.552, 1.44)
print(curve.segment(0.25, 0.75).at(0.5))   # B(0.5) = (2.0, 1.5)
```

== 反轉

#theorem(name: [反轉])[
  控制點為 $P_n, dots, P_0$ 的曲線就是 $t |-> B(1 - t)$。
] <thm-reversal>

#api(("BezierCurve.reversed",))[
  依#ref(<thm-reversal>)，回傳反向走訪的曲線。
]

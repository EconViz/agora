#import "/template/manual.typ": *

= 导数、分割与反转 <sec-operations>

每项运算只作用于控制点，并返回沿用原曲线求值策略的新曲线。

== 导数

#theorem(name: [速端曲线])[
  $n$ 次 Bézier 曲线（$n >= 1$）的导数是 $n - 1$ 次 Bézier 曲线
  $ B'(t) = sum_(i=0)^(n-1) b_(i,n-1)(t) dot n (P_(i+1) - P_i). $
  特别地，$B'(0) = n(P_1 - P_0)$、$B'(1) = n(P_n - P_(n-1))$。
] <thm-hodograph>

最后一句说明了曲线为何朝 $P_1$ 的方向离开 $P_0$，并从 $P_(n-1)$ 的方向抵达 $P_n$。

#api(("BezierCurve.derivative",), syntax: [
  #raw("derivative(order=1)")
])[
  以 `BezierCurve` 返回 `order` 阶导数，即套用#ref(<thm-hodograph>) `order` 次。常数（0 次）的导数是 0 次的零曲线；`order=0` 返回曲线本身。
]

```python
d = curve.derivative()
print(list(d.control_points))
# [Point(coords=(3.0, 6.0)), Point(coords=(6.0, 0.0)), Point(coords=(3.0, -6.0))]
print(d.at(0.5))   # Point(coords=(4.5, 0.0)): the tangent at the top is horizontal
```

== 分割

在 $t = c$ 运行 de Casteljau 算法不只得到曲线值：每一轮的第一个点构成 $c$ 之前那段曲线的控制多边形，最后一个点构成 $c$ 之后那段的控制多边形（参见#ref(<fig-split>)）。

#theorem(name: [分割])[
  令 $c in [0, 1]$，并在 $t = c$ 计算 de Casteljau 的各点。令 $L_j = P_0^((j))$、$R_j = P_j^((n-j))$，$j = 0, dots, n$。则对每个 $s in [0, 1]$
  $ B(c s) = sum_(j=0)^n b_(j,n)(s) L_j, quad
    B(c + (1 - c) s) = sum_(j=0)^n b_(j,n)(s) R_j. $
] <thm-subdivision>

#fig("/figures/curves/split.pdf", width: auto, caption: [
  在 $t = 0.4$ 分割三次曲线。
]) <fig-split>

#api(("BezierCurve.split", "BezierCurve.segment"), syntax: [
  #raw("split(")#meta("float")#raw(")") \
  #raw("segment(t0, t1)")
])[
  `split(c)` 返回#ref(<thm-subdivision>)的两条曲线，次数不变，参数范围都是 $[0, 1]$。`segment(t0, t1)` 返回曲线在 $t_0$ 与 $t_1$ 之间的部分，重新参数化到 $[0, 1]$；$t_0 = t_1$ 时返回单点 $B(t_0)$，即 0 次曲线。参数超出 $[0, 1]$ 或 $t_0 > t_1$ 时抛出异常。
]

`segment()` 分割两次：先在 $t_1$ 分割并保留左段，再在 $t_0 slash t_1$ 分割该段并保留右段。

#theorem(name: [截取])[
  对 $0 <= t_0 < t_1 <= 1$，`segment(t0, t1)` 返回的曲线为 $s |-> B(t_0 + (t_1 - t_0) s)$。
] <thm-segment>

```python
left, right = curve.split(0.4)
print(left.at(1.0), right.at(0.0))         # both B(0.4) = (1.552, 1.44)
print(curve.segment(0.25, 0.75).at(0.5))   # B(0.5) = (2.0, 1.5)
```

== 反转

#theorem(name: [反转])[
  控制点为 $P_n, dots, P_0$ 的曲线就是 $t |-> B(1 - t)$。
] <thm-reversal>

#api(("BezierCurve.reversed",))[
  根据#ref(<thm-reversal>)，返回反向遍历的曲线。
]

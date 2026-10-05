#import "/template/manual.typ": *

= Bézier 曲线 <sec-curves>

== Bernstein 基底

#definition(name: [Bernstein 多项式])[
  $n >= 0$ 次 Bernstein 多项式为
  $ b_(i,n)(t) = binom(n, i) t^i (1-t)^(n-i), quad i = 0, dots, n. $
  其他整数 $i$ 令 $b_(i,n) = 0$。
] <def-bernstein>

这组多项式出自 #citet(<bernstein1912>)；#citet(<farouki2012>)回顾其历史与性质，三次的情形如#ref(<fig-basis>)。以下证明用到两个二项式系数恒等式。

#lemma(name: [二项式恒等式])[
  令 $n >= 1$，$i$、$j$ 为整数，并约定 $k < 0$ 或 $k > m$ 时 $binom(m, k) = 0$。则
  $ binom(n-1, j) + binom(n-1, j-1) = binom(n, j) $
  且
  $ i binom(n, i) = n binom(n-1, i-1). $
] <lem-binomial>

#fig("/figures/curves/basis.pdf", width: auto, caption: [
  三次 Bernstein 多项式。
]) <fig-basis>

#proposition(name: [Bernstein 基底])[
  对 $n >= 0$，多项式 $b_(0,n), dots, b_(n,n)$ 是次数不超过 $n$ 的实系数多项式向量空间的一组基底。
] <prop-basis>

这是 #citet(<floater2025>) 的定理 1.1；#ref(<app-proofs>)从头证明。

#proposition(name: [单位分解])[
  对每个 $t in [0, 1]$，所有 $b_(i,n)(t) >= 0$，且
  $ sum_(i=0)^n b_(i,n)(t) = 1. $
] <prop-unity>

#definition(name: [Bézier 曲线])[
  设 $P_0, dots, P_n in RR^d$。以 $P_0, dots, P_n$ 为控制点的 $n$ 次 Bézier 曲线为
  $ B(t) = sum_(i=0)^n b_(i,n)(t) P_i, quad t in [0, 1], $
  其控制多边形为折线 $P_0 P_1 dots P_n$。
] <def-curve>

此定义依循 #citet(<bezier1966>)，形式如 #citet(<farin2002>) 与 #citet(<prautzsch2002>)。

#proposition(name: [端点])[
  $b_(i,n)(0)$ 在 $i = 0$ 时为 1，其余为 0；$b_(i,n)(1)$ 在 $i = n$ 时为 1，其余为 0。因此 $B(0) = P_0$、$B(1) = P_n$。
] <prop-endpoints>

#corollary(name: [凸包])[
  每个 $B(t)$（$t in [0, 1]$）都位于控制点 $P_0, dots, P_n$ 的凸包内。
] <cor-hull>

#proposition(name: [仿射不变性])[
  对每个仿射映射 $A(x) = M x + v$ 与每个 $t in [0, 1]$，
  $ A(B(t)) = sum_(i=0)^n b_(i,n)(t) A(P_i). $
  变换曲线等同于变换其控制点。
] <prop-affine>

#ref(<cor-hull>)让曲线不超出控制多边形所张的区域；#ref(<prop-affine>)则是导出器与 Matplotlib 适配器只需移动控制点，就能平移、缩放或旋转曲线的原因。

#api(("BernsteinBasis",), syntax: [
  #raw("BernsteinBasis(")#meta("int")#raw(")(")#meta("float")#raw(")") \
  #raw("BernsteinBasis(")#meta("int")#raw(").matrix(")#meta("values")#raw(")")
])[
  某一次数的基底，位于 `bezierkit.bezier.basis`。在 $t$ 调用时，以数组返回 $i = 0, dots, n$ 的 $b_(i,n)(t)$；`matrix()` 对每个参数值返回一列。
]

== 曲线

#api(("BezierCurve",), syntax: [
  #raw("BezierCurve(")#meta("points")#raw(", *, evaluator=None)") \
  #raw("BezierCurve.linear(p0, p1)") \
  #raw("BezierCurve.quadratic(p0, p1, p2)") \
  #raw("BezierCurve.cubic(p0, p1, p2, p3)")
])[
  不可变的 Bézier 曲线，次数 $n >= 0$、维度 $d >= 1$ 均不限，参数范围为 $[0, 1]$。`points` 可为 `Point` 序列、`PointSet`、$(n + 1) times d$ 数组或 `ControlPolygon`；所有控制点必须同一维度。
]

#param("degree")[次数 $n$。]
#param("dimension")[维度 $d$。]
#param("control_points")[以 `PointSet` 表示的控制点。]
#param("at()")[以 `Point` 返回 $B(t)$；曲线对象也可直接调用，`curve(t)`。]
#param("at_many()")[以 `PointSet` 返回多个参数下的值。]
#param("evaluator")[求值策略（见下文）。]

曲线的运算 `derivative()`、`split()`、`segment()` 与 `reversed()` 详见#ref(<sec-operations>)。

== 求值

*de Casteljau 算法*以反复的线性插值计算 $B(t)$。

#definition(name: [de Casteljau 点])[
  对参数 $t$，令 $P_i^((0)) = P_i$，并对 $r = 1, dots, n$ 令
  $ P_i^((r)) = (1 - t) P_i^((r-1)) + t P_(i+1)^((r-1)), quad i = 0, dots, n - r. $
] <def-casteljau>

每一轮对相邻点取平均，多边形少一个点；$n$ 轮后只剩一点（参见#ref(<fig-casteljau>)）。此算法源自 Paul de Casteljau 约 1959 年在 Citroën 的工作 #citep(<mueller2024>)。

#theorem(name: [de Casteljau])[
  对 $0 <= r <= n$ 与 $0 <= i <= n - r$，
  $ P_i^((r)) = sum_(j=0)^r b_(j,r)(t) P_(i+j). $
  特别地，$P_0^((n)) = B(t)$。
] <thm-casteljau>

此叙述见 #citet(<floater2025>) 的定理 1.6 与 1.7。

#fig("/figures/curves/casteljau.pdf", width: auto, caption: [
  $t = 0.4$ 的 de Casteljau 算法。
]) <fig-casteljau>

每个中间点都是控制点的凸组合，算法不会产生互相抵消的大数，因此在高次数时数值稳定。每个参数的计算量为 $O(n^2)$。

#api(("DeCasteljauEvaluator",))[
  默认的求值策略，位于 `bezierkit.bezier.evaluation`：以 NumPy 一次对整批参数运行上述算法。
]

#api(("BernsteinEvaluator",))[
  以 Bernstein 矩阵乘上控制点。次数低、批量大时较快，但高次数时会求和可能互相抵消的项。根据#ref(<thm-casteljau>)，两种策略计算的是同一个多项式。
]

```python
from bezierkit import BezierCurve
from bezierkit.bezier.evaluation import BernsteinEvaluator

fast = BezierCurve(curve.control_points, evaluator=BernsteinEvaluator())
print(fast.at(0.5))   # Point(coords=(2.0, 1.5)), as with the default
```

仓库的 `benchmarks/` 目录比较两者在 400、10,000 与 100,000 个参数值下的效能。

== 升阶

$n$ 次曲线也是 $n + 1$ 次曲线；新的控制点是旧控制点中相邻两点的凸组合。

#lemma(name: [升阶恒等式])[
  对 $n >= 0$、$0 <= i <= n$ 与每个 $t$，
  $ b_(i,n)(t) = (n + 1 - i) / (n + 1) b_(i,n+1)(t) + (i + 1) / (n + 1) b_(i+1,n+1)(t). $
] <lem-raise-identity>

#proposition(name: [升阶])[
  设 $B$ 的控制点为 $P_0, dots, P_n$。对 $k = 0, dots, n + 1$ 令
  $ Q_k = k / (n + 1) P_(k-1) + (1 - k / (n + 1)) P_k, $
  其中 $P_(-1)$ 与 $P_(n+1)$ 可任意选取，因为它们的系数为零。则
  $ B(t) = sum_(k=0)^(n+1) b_(k,n+1)(t) Q_k quad "对所有" t. $
  曲线及其参数化都不变。
] <prop-raise-degree>

此公式是标准结果 #citep(<farin2002>)#citep(<prautzsch2002>)；#ref(<app-proofs>)的证明不依赖它们。#ref(<prop-elevation>)把它用在直线与二次曲线，也就是本软件包需要的情形。

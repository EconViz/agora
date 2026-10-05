#import "/template/manual.typ": *

= Bézier curves <sec-curves>

== The Bernstein basis

#definition(name: [Bernstein polynomials])[
  The Bernstein polynomials of degree $n >= 0$ are
  $ b_(i,n)(t) = binom(n, i) t^i (1-t)^(n-i), quad i = 0, dots, n. $
  For all other integers $i$ we put $b_(i,n) = 0$.
] <def-bernstein>

The polynomials are due to #citet(<bernstein1912>)\; #citet(<farouki2012>)
surveys their history and properties, and @fig-basis shows the cubic ones.
The proofs below use two identities of binomial coefficients.

#lemma(name: [Binomial identities])[
  Let $n >= 1$ and let $i, j$ be integers, with $binom(m, k) = 0$ for
  $k < 0$ or $k > m$. Then
  $ binom(n-1, j) + binom(n-1, j-1) = binom(n, j) $
  and
  $ i binom(n, i) = n binom(n-1, i-1). $
] <lem-binomial>

#fig("/figures/curves/basis.pdf", width: auto, caption: [
  The cubic Bernstein polynomials.
]) <fig-basis>

#proposition(name: [Bernstein basis])[
  For $n >= 0$, the polynomials $b_(0,n), dots, b_(n,n)$ are a basis of the
  vector space of real polynomials of degree at most $n$.
] <prop-basis>

This is Theorem 1.1 of #citet(<floater2025>)\; @app-proofs proves it from
scratch.

#proposition(name: [Partition of unity])[
  For every $t in [0, 1]$, $b_(i,n)(t) >= 0$ for all $i$, and
  $ sum_(i=0)^n b_(i,n)(t) = 1. $
] <prop-unity>

#definition(name: [Bézier curve])[
  Let $P_0, dots, P_n in RR^d$. The Bézier curve of degree $n$ with control
  points $P_0, dots, P_n$ is
  $ B(t) = sum_(i=0)^n b_(i,n)(t) P_i, quad t in [0, 1], $
  and its control polygon is the polyline $P_0 P_1 dots P_n$.
] <def-curve>

The definition follows #citet(<bezier1966>) in the form of
#citet(<farin2002>) and #citet(<prautzsch2002>).

#proposition(name: [Endpoints])[
  $b_(i,n)(0) = 1$ if $i = 0$ and $0$ otherwise; $b_(i,n)(1) = 1$ if
  $i = n$ and $0$ otherwise. Hence $B(0) = P_0$ and $B(1) = P_n$.
] <prop-endpoints>

#corollary(name: [Convex hull])[
  Every point $B(t)$, $t in [0, 1]$, lies in the convex hull of the control
  points $P_0, dots, P_n$.
] <cor-hull>

#proposition(name: [Affine invariance])[
  For every affine map $A(x) = M x + v$ and every $t in [0, 1]$,
  $ A(B(t)) = sum_(i=0)^n b_(i,n)(t) A(P_i). $
  Transforming the curve is the same as transforming its control points.
] <prop-affine>

@cor-hull keeps a curve inside the region its control polygon spans, and
@prop-affine is why the exporters and the Matplotlib adapter can move,
scale or rotate a curve by moving its control points alone.

#api(("BernsteinBasis",), syntax: [
  #raw("BernsteinBasis(")#meta("int")#raw(")(")#meta("float")#raw(")") \
  #raw("BernsteinBasis(")#meta("int")#raw(").matrix(")#meta("values")#raw(")")
])[
  The basis of one degree, in `bezierkit.bezier.basis`. Calling it at $t$
  returns the values $b_(i,n)(t)$ for $i = 0, dots, n$ as an array;
  `matrix()` returns one such row per parameter value.
]

== Curves

#api(("BezierCurve",), syntax: [
  #raw("BezierCurve(")#meta("points")#raw(", *, evaluator=None)") \
  #raw("BezierCurve.linear(p0, p1)") \
  #raw("BezierCurve.quadratic(p0, p1, p2)") \
  #raw("BezierCurve.cubic(p0, p1, p2, p3)")
])[
  An immutable Bézier curve of any degree $n >= 0$ and dimension $d >= 1$,
  over $[0, 1]$. `points` is a sequence of `Point`s, a `PointSet`, a
  $(n + 1) times d$ array or a `ControlPolygon`; the control points must
  share one dimension.
]

#param("degree")[The degree $n$.]
#param("dimension")[The dimension $d$.]
#param("control_points")[The control points as a `PointSet`.]
#param("at()")[$B(t)$ as a `Point`; a curve object is also callable, `curve(t)`.]
#param("at_many()")[$B$ at many parameters, as a `PointSet`.]
#param("evaluator")[The evaluation strategy (see below).]

The operations on a curve, `derivative()`, `split()`, `segment()` and
`reversed()`, are the subject of @sec-operations.

== Evaluation

*de Casteljau's algorithm* evaluates $B(t)$ by repeated linear
interpolation.

#definition(name: [de Casteljau points])[
  For a parameter $t$ put $P_i^((0)) = P_i$ and, for $r = 1, dots, n$,
  $ P_i^((r)) = (1 - t) P_i^((r-1)) + t P_(i+1)^((r-1)), quad i = 0, dots, n - r. $
] <def-casteljau>

Each round averages neighbouring points, so the polygon shrinks by one
point; after $n$ rounds one point is left (@fig-casteljau). The algorithm
goes back to Paul de Casteljau's work at Citroën around 1959
#citep(<mueller2024>).

#theorem(name: [de Casteljau])[
  For $0 <= r <= n$ and $0 <= i <= n - r$,
  $ P_i^((r)) = sum_(j=0)^r b_(j,r)(t) P_(i+j). $
  In particular $P_0^((n)) = B(t)$.
] <thm-casteljau>

The statement is Theorems 1.6 and 1.7 of #citet(<floater2025>).

#fig("/figures/curves/casteljau.pdf", width: auto, caption: [
  de Casteljau's algorithm at $t = 0.4$.
]) <fig-casteljau>

Every intermediate point is a convex combination of the control points, so
the algorithm never forms large cancelling terms; it is the numerically
stable choice for high degrees. Its cost is $O(n^2)$ per parameter.

#api(("DeCasteljauEvaluator",))[
  The default evaluation strategy, in `bezierkit.bezier.evaluation`: the
  algorithm above, applied to a whole batch of parameters at once with
  NumPy.
]

#api(("BernsteinEvaluator",))[
  Multiplies the Bernstein matrix by the control points. It is faster for
  low degrees and large batches but sums terms that can cancel at high
  degree. By @thm-casteljau both strategies compute the same polynomial.
]

```python
from bezierkit import BezierCurve
from bezierkit.bezier.evaluation import BernsteinEvaluator

fast = BezierCurve(curve.control_points, evaluator=BernsteinEvaluator())
print(fast.at(0.5))   # Point(coords=(2.0, 1.5)), as with the default
```

The repository's `benchmarks/` directory compares the two on batches of 400,
10,000 and 100,000 parameter values.

== Degree elevation

A curve of degree $n$ is also a curve of degree $n + 1$; the new control
points are convex combinations of neighbouring old ones.

#lemma(name: [Degree elevation identity])[
  For $n >= 0$, $0 <= i <= n$ and every $t$,
  $ b_(i,n)(t) = (n + 1 - i) / (n + 1) b_(i,n+1)(t) + (i + 1) / (n + 1) b_(i+1,n+1)(t). $
] <lem-raise-identity>

#proposition(name: [Degree elevation])[
  Let $B$ have control points $P_0, dots, P_n$. For $k = 0, dots, n + 1$ put
  $ Q_k = k / (n + 1) P_(k-1) + (1 - k / (n + 1)) P_k, $
  where $P_(-1)$ and $P_(n+1)$ may be chosen arbitrarily, since their
  coefficients are zero. Then
  $ B(t) = sum_(k=0)^(n+1) b_(k,n+1)(t) Q_k quad "for all" t. $
  The curve and its parameterization are unchanged.
] <prop-raise-degree>

The formula is standard #citep(<farin2002>)#citep(<prautzsch2002>)\; the
proof in @app-proofs is self-contained. @prop-elevation applies it to lines
and quadratics, the cases the package needs.

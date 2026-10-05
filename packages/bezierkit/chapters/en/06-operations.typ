#import "/template/manual.typ": *

= Derivatives, reversal and subdivision <sec-operations>

Each operation acts on the control points alone and returns a new curve
that keeps the evaluator of the original.

== Derivatives

The derivative $B'(t)$ of a Bézier curve is the derivative of its coordinate
functions, which are polynomials in $t$; it is a vector in $RR^d$.

#lemma(name: [Derivative of the Bernstein polynomials])[
  For $n >= 1$ and every integer $i$,
  $ b'_(i,n)(t) = n [b_(i-1,n-1)(t) - b_(i,n-1)(t)]. $
] <lem-bernstein-derivative>

This is Lemma 1.4 of #citet(<floater2025>).

#theorem(name: [Hodograph])[
  The derivative of a degree-$n$ Bézier curve ($n >= 1$) is the degree
  $n - 1$ Bézier curve
  $ B'(t) = sum_(i=0)^(n-1) b_(i,n-1)(t) dot n (P_(i+1) - P_i). $
] <thm-hodograph>

The curve of control points $n(P_(i+1) - P_i)$ is the hodograph of $B$
(Theorem 1.8 of #citet(<floater2025>)\; see also #citet(<farin2002>)).

#corollary(name: [End tangents])[
  $B'(0) = n(P_1 - P_0)$ and $B'(1) = n(P_n - P_(n-1))$.
] <cor-end-tangents>

This is why a curve leaves $P_0$ in the direction of $P_1$ and arrives at
$P_n$ from $P_(n-1)$.

#api(("BezierCurve.derivative",), syntax: [
  #raw("derivative(order=1)")
])[
  The `order`-th derivative as a `BezierCurve`, by applying @thm-hodograph
  `order` times. The derivative of a constant (degree 0) is the zero curve
  of degree 0; `order=0` returns the curve itself.
]

```python
d = curve.derivative()
print(list(d.control_points))
# [Point(coords=(3.0, 6.0)), Point(coords=(6.0, 0.0)), Point(coords=(3.0, -6.0))]
print(d.at(0.5))   # Point(coords=(4.5, 0.0)): the tangent at the top is horizontal
```

== Reversal

#lemma(name: [Symmetry])[
  $b_(i,n)(1 - t) = b_(n-i,n)(t)$ for all $i$ and $t$.
] <lem-symmetry>

#proposition(name: [Reversal])[
  The curve with control points $P_n, dots, P_0$ is $t |-> B(1 - t)$.
] <prop-reversal>

#api(("BezierCurve.reversed",))[
  The curve traced in the opposite direction, by @prop-reversal.
]

== Subdivision

Running de Casteljau's algorithm at $t = c$ does more than evaluate: the
first points of each round form the control polygon of the part of the curve
before $c$, and the last points that of the part after it (@fig-split).

#theorem(name: [Subdivision])[
  Let $c in [0, 1]$, and compute the de Casteljau points of
  @def-casteljau at $t = c$. Put $L_j = P_0^((j))$ and $R_j = P_j^((n-j))$
  for $j = 0, dots, n$. Then for every $s in [0, 1]$
  $ B(c s) = sum_(j=0)^n b_(j,n)(s) L_j $
  and
  $ B(c + (1 - c) s) = sum_(j=0)^n b_(j,n)(s) R_j. $
] <thm-subdivision>

The result is classical; see #citet(<floater2025>) (Section 8.4, where it
is derived from the blossom) and #citet(<farin2002>).

#fig("/figures/curves/split.pdf", width: auto, caption: [
  Splitting the cubic at $t = 0.4$.
]) <fig-split>

#api(("BezierCurve.split", "BezierCurve.segment"), syntax: [
  #raw("split(")#meta("float")#raw(")") \
  #raw("segment(t0, t1)")
])[
  `split(c)` returns the two curves of @thm-subdivision, each of the same
  degree and parameterized over $[0, 1]$. `segment(t0, t1)` returns the part
  of the curve between $t_0$ and $t_1$, reparameterized over $[0, 1]$; when
  $t_0 = t_1$ it is the single point $B(t_0)$, a curve of degree 0.
  Parameters outside $[0, 1]$, or $t_0 > t_1$, raise.
]

`segment()` splits twice: first at $t_1$, keeping the left part, then that
part at $t_0 slash t_1$, keeping the right part.

#corollary(name: [Segment extraction])[
  For $0 <= t_0 < t_1 <= 1$ the curve returned by `segment(t0, t1)` is
  $s |-> B(t_0 + (t_1 - t_0) s)$.
] <cor-segment>

```python
left, right = curve.split(0.4)
print(left.at(1.0), right.at(0.0))         # both B(0.4) = (1.552, 1.44)
print(curve.segment(0.25, 0.75).at(0.5))   # B(0.5) = (2.0, 1.5)
```


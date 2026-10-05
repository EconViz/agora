#import "/template/manual.typ": *

= Constructions and Hermite interpolation <sec-construction>

A cubic is fixed by its endpoints and the derivatives there. The
constructions in this chapter turn such endpoint conditions into control
points, which is how economic curves known by a few values and slopes become
Bézier curves.

== Endpoint constructions

Each construction is a frozen dataclass with a `build()` method, in
`bezierkit.construction`.

#api(("EndpointDerivatives",), syntax: [
  #raw("EndpointDerivatives(start, end, start_derivative, end_derivative).build()")
])[
  The cubic with $B(0) = $ `start`, $B(1) = $ `end`,
  $B'(0) = $ `start_derivative` and $B'(1) = $ `end_derivative`, in any
  dimension.
]

#proposition(name: [Endpoint conditions])[
  Let $P_0, P_3, D_0, D_1 in RR^d$. The cubic Bézier curve with controls
  $ P_0, quad P_0 + D_0 slash 3, quad P_3 - D_1 slash 3, quad P_3 $
  satisfies $B(0) = P_0$, $B(1) = P_3$, $B'(0) = D_0$ and $B'(1) = D_1$, and
  it is the only polynomial curve of degree at most 3 that does.
] <prop-endpoint>

#api(("TangentDirections",), syntax: [
  #raw("TangentDirections(start, end, start_direction, end_direction, start_handle=1.0, end_handle=1.0).build()")
])[
  Endpoint tangents given as directions, with the handle lengths
  $|P_1 - P_0| = $ `start_handle` and $|P_3 - P_2| = $ `end_handle`. The
  directions are normalized, so only their orientation matters; handles must
  be finite and non-negative. By @prop-endpoint, $B'(0) = 3 dot$
  `start_handle` times the unit start direction.
]

#api(("PlanarSlopes",), syntax: [
  #raw("PlanarSlopes(start, end, start_slope, end_slope, start_handle=1.0, end_handle=1.0).build()")
])[
  A planar cubic whose ends have the slopes $dif y slash dif x$ given, built
  as `TangentDirections` with directions $(1, m)$. Slopes must be finite; a
  vertical tangent needs `TangentDirections`.
]

```python
from bezierkit.construction import PlanarSlopes

demand = PlanarSlopes(
    start=Point(0, 5), end=Point(5, 0), start_slope=-2, end_slope=-0.3,
).build()
print(demand.control_points[1])   # (0.447, 4.106): one unit from (0, 5) along slope -2
```

== Hermite interpolation

Cubic Hermite interpolation matches a function and its derivative at both
ends of an interval.

#definition(name: [Cubic Hermite interpolant])[
  Let $f$ be differentiable on $[x_0, x_1]$ with $x_0 != x_1$. A cubic
  Hermite interpolant of $f$ is a polynomial $H$ of degree at most 3 with
  $ H(x_i) = f(x_i), quad H'(x_i) = f'(x_i), quad i = 0, 1. $
  For a curve, interpolate each coordinate.
] <def-hermite>

This is the case of two nodes of the Hermite polynomial in Section 3.4 of
#citet(<burden2011>), where it is Definition 3.8. Such a polynomial exists
and is unique:

#proposition(name: [Existence and uniqueness])[
  The cubic Hermite interpolant of @def-hermite exists and is unique. With
  $h = x_1 - x_0$, $f_i = f(x_i)$ and $m_i = f'(x_i)$ it is
  $ H(x) = sum_(i=0)^3 b_(i,3)((x - x_0) slash h) c_i, $
  where the coefficients are
  $ c_0 = f_0, quad c_1 = f_0 + h m_0 slash 3, quad c_2 = f_1 - h m_1 slash 3, quad c_3 = f_1. $
] <prop-hermite-unique>

The same statement, for any number of nodes, is Theorem (2.1.5.2) of
#citet(<stoer2002>). Over a parameter interval $[t_0, t_1]$ of width
$h = t_1 - t_0$, the Bézier segment is evaluated at $s = (t - t_0) slash h$,
which rescales derivatives by $h$.

#api(("parametric_hermite",), syntax: [
  #raw("parametric_hermite(p0, p3, derivative0, derivative1, *, t0=0.0, t1=1.0)")
])[
  The cubic segment with controls $P_0$, $P_0 + h D_0 slash 3$,
  $P_3 - h D_1 slash 3$, $P_3$, in `bezierkit.interpolation`. $h = 0$ raises
  `ValueError`; a negative $h$ reverses the interval.
]

#proposition(name: [Hermite interpolation])[
  Let $H(t) = B((t - t_0) slash h)$ for the segment returned by
  `parametric_hermite`. Then $H(t_0) = P_0$, $H(t_1) = P_3$,
  $H'(t_0) = D_0$ and $H'(t_1) = D_1$.
] <prop-hermite>

#api(("graph_hermite",), syntax: [
  #raw("graph_hermite(*, x0, x1, y0, y1, m0, m1)")
])[
  The interpolant of a graph $y = f(x)$ from the values $y_0 = f(x_0)$,
  $y_1 = f(x_1)$ and slopes $m_0 = f'(x_0)$, $m_1 = f'(x_1)$: the
  parametric form with $P = (x, f(x))$, $D = (1, f'(x))$ and $t = x$. Its
  controls are
  $ (x_0, y_0), quad (x_0 + h/3, y_0 + h m_0 slash 3), quad (x_1 - h/3, y_1 - h m_1 slash 3), quad (x_1, y_1), $
  with $h = x_1 - x_0$ (@fig-hermite).
]

#proposition(name: [Graph form])[
  The segment of `graph_hermite` is the graph of the cubic Hermite
  interpolant $H$ of $f$ on $[x_0, x_1]$: it is
  $s |-> (x_0 + h s, H(x_0 + h s))$, $s in [0, 1]$.
] <prop-graph-hermite>

```python
from bezierkit.interpolation import graph_hermite

# f(x) = 4 / x^2 on [1, 1.5]
segment = graph_hermite(x0=1, x1=1.5, y0=4, y1=16 / 9, m0=-8, m1=-64 / 27)
```

#fig("/figures/construction/hermite.pdf", width: auto, caption: [
  Hermite interpolant of $4 slash x^2$ on $[1, 1.5]$.
]) <fig-hermite>

== Interpolation error

#theorem(name: [Hermite error bound])[
  Let $f$ be four times continuously differentiable on $[x_0, x_1]$ with
  $x_0 < x_1$, let $H$ be its cubic Hermite interpolant (@def-hermite), and
  put $h = x_1 - x_0$ and $M = max |f^((4))|$ on the interval. For every
  $x in [x_0, x_1]$ there is a $xi in [x_0, x_1]$ with
  $ f(x) - H(x) = (f^((4)) (xi)) / 24 (x - x_0)^2 (x - x_1)^2, $
  and therefore
  $ max_(x in [x_0, x_1]) |f(x) - H(x)| <= (M h^4) / 384. $
] <thm-hermite-error>

The error formula is Theorem 3.9 of #citet(<burden2011>), whose proof is
left to Exercise 3.4.11 there, and Theorem (2.1.5.9) of
#citet(<stoer2002>). The bound is sharp: for $f(x) = x^4$ on $[0, 1]$ the
error is $x^2 (x - 1)^2$, whose maximum $1 slash 16$ at $x = 1 slash 2$
equals $M h^4 slash 384$ with $M = 24$.

Halving the interval divides the bound by 16, which is what adaptive fitting
exploits (@sec-fitting). For $f(x) = 4 slash x^2$ on $[1, 1.5]$,
$f^((4))(x) = 480 slash x^6$, so $M = 480$ and the bound is
$480 dot 0.5^4 slash 384 approx 0.078$.

#api(("hermite_error_bound",), syntax: [
  #raw("hermite_error_bound(max_fourth_derivative, t0, t1)")
])[
  The bound $M |t_1 - t_0|^4 slash 384$ of @thm-hermite-error, in
  `bezierkit.fitting`. $M$ must be finite and non-negative.
]

The bound is for a scalar function. For a curve $t |-> (x(t), y(t))$, apply
it to each coordinate. In $RR^d$ the Euclidean error is at most $sqrt(d)$
times the largest coordinate bound, because $norm(v)_2 <= sqrt(d) norm(v)_oo$
for $v in RR^d$ (Section 2.2 of #citet(<golub2013>)).

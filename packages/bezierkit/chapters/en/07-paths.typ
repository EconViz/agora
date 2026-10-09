#import "/template/manual.typ": *

= Cubic segments and paths <sec-paths>

Renderers draw cubics: TikZ's `.. controls ..`, SVG's `C` and Matplotlib's
`CURVE4` all take four control points. `CubicBezierSegment` is that cubic as
a value object, and `PiecewiseBezier` joins cubics into paths.

== Cubic segments

#api(("CubicBezierSegment",), syntax: [
  #raw("CubicBezierSegment(p0, p1, p2, p3, *, fit_error=None)")
])[
  An immutable cubic with its four control points as the fields `p0`, `p1`,
  `p2`, `p3` (also `control_points`, and iteration). It evaluates,
  differentiates, splits, restricts and reverses like a `BezierCurve`, but
  `split()`, `segment()` and `reversed()` return cubic segments again.
  `segment(t, t)` returns the degenerate cubic whose four controls are all
  $B(t)$.
]

#param("fit_error", type: "float | None", default: "None")[The measured error of a fitted segment (@sec-fitting); kept through split, segment and reversal, and ignored by equality.]
#param("as_curve()")[Convert to a degree-3 `BezierCurve` without changing a control point.]
#param("from_curve(curve)")[Convert a degree-3 `BezierCurve` without changing a control point.]
#param("from_line()")[The exact cubic of a line (@prop-elevation).]
#param("from_quadratic()")[The exact cubic of a quadratic (@prop-elevation).]

== Tight bounding boxes

#definition(name: [Axis-aligned bounding box])[
  The axis-aligned bounding box of a non-empty bounded set $K subset RR^d$ is
  the smallest box
  $ [alpha_1, beta_1] times dots times [alpha_d, beta_d] $
  that contains $K$, where $alpha_k = inf {x_k : x in K}$ and
  $beta_k = sup {x_k : x in K}$.
] <def-bbox>

The convex hull of the control points contains a curve (@cor-hull) but can be
far larger than it. `bounding_box` returns the box of @def-bbox for the
curve itself (@fig-bbox). Its candidates come from the roots of the
derivative of each coordinate.

#proposition(name: [Bounding box of a cubic])[
  Let $B$ be the cubic with control points $P_0, dots, P_3 in RR^d$, and put
  $ a = -P_0 + 3P_1 - 3P_2 + P_3, quad b = 3P_0 - 6P_1 + 3P_2, quad c = 3(P_1 - P_0). $
  Then $B(t) = a t^3 + b t^2 + c t + P_0$. For each coordinate $k$ let $T_k$
  consist of $0$, $1$ and the roots in $(0, 1)$ of
  $ B'_k (t) = 3a_k t^2 + 2 b_k t + c_k $
  when this polynomial is not identically zero; when it is, $T_k = {0, 1}$.
  Then the coordinates of the bounding box of $B([0, 1])$ are
  $ alpha_k = min_(t in T_k) B_k (t), quad beta_k = max_(t in T_k) B_k (t). $
] <prop-bbox>

#api(("CubicBezierSegment.bounding_box",))[
  `(low, high)`: two points holding the per-axis minimum and maximum of the
  curve, found by evaluating it at the candidate parameters of @prop-bbox.
]

#fig("/figures/paths/bbox.pdf", width: auto, caption: [
  The tight bounding box of a cubic.
]) <fig-bbox>

== Degree elevation

Degree elevation (@prop-raise-degree) writes a curve of degree $n$ as a curve
of degree $n + 1$ with the same parameterization. The package needs it to
write lines and quadratics as cubics, so that every renderer receives four
control points. Applying @prop-raise-degree once or twice gives the controls
below.

#proposition(name: [Lines and quadratics as cubics])[
  The line from $P_0$ to $P_3$, parameterized by $(1 - t) P_0 + t P_3$, is the
  cubic with controls
  $ P_0, quad P_0 + 1/3 (P_3 - P_0), quad P_0 + 2/3 (P_3 - P_0), quad P_3. $
  The quadratic with controls $P_0, C, P_3$ is the cubic with controls
  $ P_0, quad P_0 + 2/3 (C - P_0), quad P_3 + 2/3 (C - P_3), quad P_3. $
  In both cases the curve and its parameterization are unchanged.
] <prop-elevation>

#api(("to_cubic",), syntax: [
  #raw("to_cubic(")#meta("curve")#raw(")")
])[
  In `bezierkit.bezier`. Turns a linear, quadratic or cubic `BezierCurve`
  into a `CubicBezierSegment` by @prop-elevation (a segment is returned as
  is); higher degrees raise `DegreeError`.
]

#api(("line_to_cubic",), syntax: [
  #raw("line_to_cubic(p0, p3)")
])[
  The cubic of the line from `p0` to `p3`.
]

#api(("quadratic_to_cubic",), syntax: [
  #raw("quadratic_to_cubic(p0, control, p3)")
])[
  The cubic of the quadratic with the given controls.
]

```python
from bezierkit.bezier import to_cubic

q = BezierCurve.quadratic(Point(0, 0), Point(3, 6), Point(9, 0))
print(to_cubic(q).control_points)
# (Point(coords=(0.0, 0.0)), Point(coords=(2.0, 4.0)),
#  Point(coords=(5.0, 4.0)), Point(coords=(9.0, 0.0)))
```

== Piecewise paths

#api(("PiecewiseBezier",), syntax: [
  #raw("PiecewiseBezier(")#meta("segments")#raw(", *, closed=False, continuity_tolerance=1e-9)") \
  #raw("PiecewiseBezier.compound(")#meta("paths")#raw(")")
])[
  A path of cubic segments. Consecutive segments must meet: each segment's
  `p3` must lie within `continuity_tolerance` of the next one's `p0`, and a
  closed path's last `p3` within it of the first `p0`; otherwise
  `ValueError` is raised. `closed` is metadata for exporters (SVG `Z`, TikZ
  `cycle`): it never adds a closing segment.
]

The package parameterizes a path uniformly. This is a convention of
the package, not a standard notion: a path of $m$ segments
$S_0, dots, S_(m-1)$ is the map
$ P(t) = S_k (m t - k), quad k = min(floor(m t), m - 1), quad t in [0, 1]. $
Each segment takes an equal share $1 slash m$ of $[0, 1]$, regardless of its
length.

#param("segments")[The segments in order.]
#param("control_points")[Their control points.]
#param("subpaths")[The `BezierSubpath`s.]
#param("at(t)")[Evaluate under the uniform parameterization.]
#param("at_many(values)")[Evaluate at many parameters.]
#param("split(t)")[Divide the path at `t`; a parameter inside a segment splits that segment (@thm-subdivision).]
#param("segment(t0, t1)")[Keep the part between two parameters.]
#param("reversed()")[Reverse the order of the segments and each segment.]
#param("closed")[Closure flag.]
#param("is_compound")[Whether there are several subpaths.]
#param("dimension")[The dimension $d$.]

#changed("1.0.0", label: "PiecewiseBezier.segment")[Returns the requested interval when `t0` falls inside a segment; previously the end point was wrong, because the path was split at `t0` and the suffix re-parameterized]

```python
from bezierkit import CubicBezierSegment, PiecewiseBezier

path = PiecewiseBezier([
    CubicBezierSegment.from_line(Point(0, 0), Point(2, 0)),
    CubicBezierSegment.from_line(Point(2, 0), Point(2, 4)),
])
print(path.at(0.75))                     # Point(coords=(2.0, 2.0))
print(path.segment(0.25, 0.75).at(1.0))  # Point(coords=(2.0, 2.0))
```

`compound()` gathers several paths into one, keeping their subpaths
separate, as for a shape with a hole. A compound path has no single
parameterization: evaluating, splitting or restricting it raises
`ValueError`; reversal and export work. Splitting or restricting a closed
path also raises, except for the whole path or a single point, since a
closed path has no first and last point to keep.

== Continuity

Two curves meet at a join. Let $h_S, h_T > 0$, let
$S : [u_0 - h_S, u_0] -> RR^d$ and $T : [u_0, u_0 + h_T] -> RR^d$ be
continuously differentiable as often as needed (with one-sided derivatives
at the ends of their intervals), and let $C$ be the curve that equals $S$ on
the first interval and $T$ on the second.

#definition(name: [Parametric continuity])[
  For $k >= 0$, the curve $C$ is $C^k$ at $u_0$ if
  $S^((j))(u_0) = T^((j))(u_0)$ for $j = 0, dots, k$.
] <def-continuity>

#definition(name: [Geometric continuity $G^1$])[
  The curve $C$ is $G^1$ at $u_0$ if $S(u_0) = T(u_0)$, the tangent vectors
  $S'(u_0)$ and $T'(u_0)$ are non-zero, and $T'(u_0) = lambda S'(u_0)$ for
  some $lambda > 0$; that is, the two unit tangents agree.
] <def-geometric-continuity>

Parametric and geometric continuity are the standard notions for joined
curves #citep(<farin2002>)#citep(<prautzsch2002>)\; the geometric notion of
every order $k$ is treated by #citet(<barsky1989>). This manual uses $C^0$,
$C^1$ and $G^1$ only. A $C^1$ join with non-zero tangents is $G^1$.

#proposition(name: [Continuity of cubic joins])[
  Let $S$ and $T$ be the cubics with controls $P_0, dots, P_3$ and
  $Q_0, dots, Q_3$, evaluated at $(u - u_0 + h_S) slash h_S$ and
  $(u - u_0) slash h_T$ respectively.
  + $C$ is $C^0$ at $u_0$ if and only if $P_3 = Q_0$.
  + If $P_3 = Q_0$, then $C$ is $C^1$ at $u_0$ if and only if
    $ (P_3 - P_2) / h_S = (Q_1 - Q_0) / h_T. $
  + If $P_3 = Q_0$, $P_3 != P_2$ and $Q_1 != Q_0$, then $C$ is $G^1$ at $u_0$
    if and only if $Q_1 - Q_0 = mu (P_3 - P_2)$ for some $mu > 0$.
  + Under the uniform parameterization of `PiecewiseBezier`, $h_S = h_T$, so
    the condition in 2 reads $P_3 - P_2 = Q_1 - Q_0$.
] <prop-continuity>

`PiecewiseBezier` enforces only $C^0$, a shared endpoint. Whether a join
should also be smooth is the caller's decision: a kink in an indifference
curve or a corner in a polyline is meant to stay.

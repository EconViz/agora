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
#param("as_curve(), from_curve(curve)")[Convert to and from a degree-3 `BezierCurve` without changing a control point.]
#param("from_line(p0, p3), from_quadratic(p0, c, p3)")[Exact cubics for a line or a quadratic (@prop-elevation).]

== Tight bounding boxes

The convex hull of the control points contains a curve (@cor-hull) but can be
far larger than it. `bounding_box` returns the smallest axis-aligned box
(@fig-bbox).

#proposition(name: [Bounding box])[
  Write the cubic as $B(t) = a t^3 + b t^2 + c t + P_0$ with
  $a = -P_0 + 3P_1 - 3P_2 + P_3$, $b = 3P_0 - 6P_1 + 3P_2$ and
  $c = 3(P_1 - P_0)$. On each axis $k$, the minimum and maximum of
  $B_k(t)$ over $[0, 1]$ are attained at $t = 0$, $t = 1$, or a root in
  $(0, 1)$ of $3a_k t^2 + 2 b_k t + c_k$.
] <prop-bbox>

#api(("CubicBezierSegment.bounding_box",))[
  `(low, high)`: two points holding the per-axis minimum and maximum of the
  curve, found by evaluating it at the candidate parameters of @prop-bbox.
]

#fig("/figures/paths/bbox.pdf", width: auto, caption: [
  The tight bounding box of a cubic.
]) <fig-bbox>

== Degree elevation

#lemma(name: [Basis identities])[
  For $n >= 0$ and every $t$,
  + $sum_(i=0)^n i b_(i,n)(t) = n t$;
  + $b_(i,n)(t) = (n + 1 - i) / (n + 1) b_(i,n+1)(t) + (i + 1) / (n + 1) b_(i+1,n+1)(t)$.
] <lem-basis-elevation>

#proposition(name: [Degree elevation])[
  The line from $P_0$ to $P_3$ is the cubic with controls
  $P_0$, $P_0 + 1/3 (P_3 - P_0)$, $P_0 + 2/3 (P_3 - P_0)$, $P_3$. The
  quadratic with controls $P_0, C, P_3$ is the cubic with controls
  $P_0$, $P_0 + 2/3 (C - P_0)$, $P_3 + 2/3 (C - P_3)$, $P_3$. Both are the
  same curve with the same parameterization.
] <prop-elevation>

#api(("to_cubic", "line_to_cubic", "quadratic_to_cubic"), syntax: [
  #raw("to_cubic(")#meta("curve")#raw(")")
])[
  In `bezierkit.bezier`. `to_cubic()` turns a linear, quadratic or cubic
  `BezierCurve` into a `CubicBezierSegment` by @prop-elevation (a segment is
  returned as is); higher degrees raise `DegreeError`.
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

#definition(name: [Uniform parameterization])[
  A path of $m$ segments $S_0, dots, S_(m-1)$ is the map
  $ P(t) = S_k (m t - k), quad k = min(floor(m t), m - 1), quad t in [0, 1]. $
] <def-uniform>

Each segment takes an equal share $1 slash m$ of $[0, 1]$, regardless of its
length.

#param("segments, control_points, subpaths")[The segments in order, their control points, and the `BezierSubpath`s.]
#param("at(t), at_many(values)")[Evaluate under the uniform parameterization.]
#param("split(t), segment(t0, t1)")[Divide the path, or keep the part between two parameters; a parameter inside a segment splits that segment (@thm-subdivision).]
#param("reversed()")[Reverse the order of the segments and each segment.]
#param("closed, is_compound, dimension")[Closure flag, whether there are several subpaths, and $d$.]

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

#definition(name: [Continuity at a join])[
  A curve $C$ defined on an interval is $C^0$ at an interior parameter $u_0$
  if it is continuous there, and $C^1$ if moreover its one-sided derivatives
  at $u_0$ exist and are equal.
] <def-continuity>

#proposition(name: [Continuity of cubic joins])[
  Let cubics $S$ and $T$ with controls $P_0, dots, P_3$ and
  $Q_0, dots, Q_3$ occupy consecutive parameter spans of lengths $h_S$ and
  $h_T$, and let $P_3 = Q_0$. The joined curve is $C^1$ at the join if and
  only if $(P_3 - P_2) slash h_S = (Q_1 - Q_0) slash h_T$. Under the uniform
  parameterization of `PiecewiseBezier`, $h_S = h_T$, so the condition is
  $P_3 - P_2 = Q_1 - Q_0$.
] <prop-continuity>

`PiecewiseBezier` enforces only $C^0$, a shared endpoint. Whether a join
should also be smooth is the caller's decision: a kink in an indifference
curve or a corner in a polyline is meant to stay.

#import "/template/manual.typ": *

= Fitting <sec-fitting>

Fitting turns a smooth function or a list of sampled points into a
`PiecewiseBezier` whose error is measured and reported, segment by segment,
in the coordinate units of the curve. The functions live in
`bezierkit.fitting`.

== Adaptive Hermite fitting

#api(("fit_parametric",), syntax: [
  #raw("fit_parametric(")#meta("function")#raw(", ")#meta("derivative")#raw(", *, t0, t1, tolerance, max_depth=20, max_segments=4096, error_samples=9)")
])[
  Fit a parametric curve $C(t)$, given as a function returning `Point`s and
  its derivative returning `Vector`s, over $[t_0, t_1]$. The algorithm is a
  recursive bisection:

  + Build the Hermite segment on the current interval from $C$ and $C'$ at its
    ends (@prop-hermite).
  + Measure its error: the largest Euclidean distance between $C(t_j)$ and
    the segment at `error_samples` equally spaced parameters, ends included.
  + If the error is at most `tolerance`, keep the segment, recording the
    error as its `fit_error`. Otherwise halve the interval and fit each half.

  Every accepted segment therefore meets the tolerance at its probe
  parameters. If an interval still fails at depth `max_depth`, or keeping
  it would exceed `max_segments`, `ToleranceNotMet` is raised rather than a
  worse path returned.
]

#param("tolerance", type: "float")[Allowed error, in coordinate units; must be positive.]
#param("max_depth", type: "int", default: "20")[Largest number of halvings of the starting interval.]
#param("max_segments", type: "int", default: "4096")[Largest number of segments in the result.]
#param("error_samples", type: "int", default: "9")[Probe parameters per segment, at least 3.]

#api(("fit_graph",), syntax: [
  #raw("fit_graph(")#meta("function")#raw(", ")#meta("derivative")#raw(", *, x0, x1, tolerance, ...)")
])[
  Fit the graph $y = f(x)$ for $x in [x_0, x_1]$: `fit_parametric` with
  $C(x) = (x, f(x))$ and $C'(x) = (1, f'(x))$, the same options, and the
  error measured as a Euclidean distance in the $(x, y)$ plane.
]

```python
from bezierkit.fitting import fit_graph

path = fit_graph(lambda x: 4 / x**2, lambda x: -8 / x**3,
                 x0=0.8, x1=3, tolerance=1e-3)
print(len(path.segments))                    # 10
print(max(s.fit_error for s in path))        # 0.000676
```

#fig("/figures/fitting/adaptive.pdf", width: auto, caption: [
  Adaptive fit of $4 slash x^2$; segments alternate colour.
]) <fig-adaptive>

Segments are short where the curve bends sharply and long where it is
nearly straight (@fig-adaptive). The Hermite error bound predicts how deep
the bisection has to go:

#corollary(name: [Depth of adaptive fitting])[
  Let each coordinate of $C$ be four times continuously differentiable on
  $[t_0, t_1]$ with $|C_k^((4))| <= M$, let $H = |t_1 - t_0|$, and let
  $d$ be the dimension. Every interval at depth
  $ k >= 1/4 log_2 (sqrt(d) M H^4 / (384 epsilon)) $
  passes the error test with tolerance $epsilon$, so unless `max_depth` or
  `max_segments` is reached first, the bisection stops at that depth at the
  latest.
] <cor-depth>

The measured error is a lower bound for the true maximum error of a
segment: it is checked only at the probe parameters. Increase
`error_samples` when the curve could wiggle between them.

== Polyline simplification

#api(("fit_polyline",), syntax: [
  #raw("fit_polyline(")#meta("points")#raw(", *, tolerance, closed=False, duplicate_tolerance=1e-12, preserve_corners=True, corner_angle=pi/4)")
])[
  Simplify sampled points into a path of straight chords, each written as
  an exact cubic (@prop-elevation). The steps are:

  + Drop each point within `duplicate_tolerance` of the one before it. A
    closed polyline also drops a final copy of its first point, and is
    rotated so that it starts at its lexicographically smallest point, which
    makes the output independent of where the samples began.
  + Keep the end points and, with `preserve_corners`, every vertex where the
    direction turns by at least `corner_angle` radians.
  + Between consecutive kept vertices, apply the Ramer--Douglas--Peucker
    algorithm #citep(<ramer1972>)#citep(<douglas1973>): if the vertex
    farthest from the chord is within `tolerance` of it, the chord replaces
    the whole run; otherwise keep that vertex and recurse on both sides.

  Each chord's `fit_error` is the largest distance from the vertices it
  replaced to the chord (@fig-polyline).
]

#proposition(name: [Polyline tolerance])[
  Every input vertex that survives step 1 lies within `tolerance` of the
  chord of the output segment that replaced it.
] <prop-rdp>

#fig("/figures/fitting/polyline.pdf", width: auto, caption: [
  41 noisy samples simplified with tolerance $0.08$.
]) <fig-polyline>

#api(("maximum_polyline_deviation",), syntax: [
  #raw("maximum_polyline_deviation(")#meta("points")#raw(", ")#meta("path")#raw(")")
])[
  The largest distance from any of the points to the nearest chord
  $P_0 P_3$ of the path's segments: a check of @prop-rdp that also covers the
  points step 1 dropped.
]

Like any method that sees only samples, `fit_polyline` bounds the
deviation from the samples, not from an unknown continuous curve between
them; sample more densely for a closer match.

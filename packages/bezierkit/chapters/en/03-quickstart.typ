#import "/template/manual.typ": *

= Quick start <sec-quickstart>

== A cubic curve

The curve used throughout this manual is the cubic with control points
$(0, 0)$, $(1, 2)$, $(3, 2)$ and $(4, 0)$ (@fig-quickstart).

#example(```python
from bezierkit import BezierCurve, PiecewiseBezier, Point
from bezierkit.bezier import to_cubic
from bezierkit.export.tikz import to_tikz

curve = BezierCurve.cubic(Point(0, 0), Point(1, 2), Point(3, 2), Point(4, 0))
print(curve.at(0.5))                 # Point(coords=(2.0, 1.5))
print(curve.derivative().at(0.5))    # Point(coords=(4.5, 0.0))
left, right = curve.split(0.4)       # two cubics that together trace curve

path = PiecewiseBezier([to_cubic(curve)])
print(to_tikz(path, precision=2, options="thick"))
# \draw[thick] (0.00,0.00) .. controls (1.00,2.00) and (3.00,2.00) .. (4.00,0.00);
```)

#fig("/figures/curves/cubic.pdf", width: auto, caption: [
  The cubic of @sec-quickstart, its control polygon and convex hull.
]) <fig-quickstart>

The curve starts at $P_0$ and ends at $P_3$, leaves $P_0$ towards $P_1$ and
arrives at $P_3$ from $P_2$, and never leaves the shaded hull of its control
points (@thm-hull). The last line is the curve as a TikZ path, ready to paste
into a #LaTeX document.

== The pieces

- *Values.* `Point`, `Vector` and `PointSet` are immutable and
  dimension-checked (@sec-geometry).
- *Curves.* `BezierCurve` has any degree and dimension;
  `CubicBezierSegment` is the cubic that renderers consume; a
  `PiecewiseBezier` joins cubics into a path (@sec-curves, @sec-paths).
- *Constructions.* Endpoint conditions, slopes, derivatives or Hermite data
  become control points (@sec-construction).
- *Approximation.* Smooth functions, sampled points and level sets
  $F(x, y) = c$ become cubic paths with a stated error (@sec-fitting,
  @sec-implicit).
- *Output.* Samples, JSON, SVG path data and TikZ, and Matplotlib paths
  (@sec-export).

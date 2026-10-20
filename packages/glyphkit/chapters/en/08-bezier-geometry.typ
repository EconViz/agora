#import "/template/manual.typ": *

= Bézier outline geometry <sec-glyph-bezier>

== Exact command model

`GlyphOutline` preserves moves, lines, quadratic curves, cubic curves, and closes. It does not silently turn a curve into sampled points. The selected control polygons in @fig-glyph-outline come from those exact commands.

== Quadratic and cubic segments

For $0 <= t <= 1$, a quadratic segment is
$ Q(t) = (1-t)^2 P_0 + 2(1-t)t P_1 + t^2 P_2, $
and a cubic segment is
$ C(t) = (1-t)^3 P_0 + 3(1-t)^2t P_1 + 3(1-t) t^2 P_2 + t^3 P_3. $
Both reproduce their endpoints exactly. Their endpoint tangents are parallel to $P_1-P_0$ and $P_n-P_(n-1)$.

#api(("GlyphOutline",))[Stores exact, renderer-neutral contours in font coordinates; compound glyphs are decomposed during extraction.]
#api(("MoveTo",))[Moves to the first point of a new contour without drawing a segment.]
#api(("LineTo",))[Draws a straight segment to the specified endpoint.]
#api(("QuadraticTo",))[Draws a quadratic Bézier segment using one control point.]
#api(("CubicTo",))[Draws a cubic Bézier segment using two control points.]
#api(("ClosePath",))[Closes the active contour and makes its final edge explicit.]

== Adaptive flattening

#api(("flatten",))[
  Recursively subdivides a curve until every control point lies within the requested tolerance of its chord. The result is a tuple of open or closed `Polyline` values.
]

== Tolerance and subdivision

Let $d(P, A B)$ be the distance from control point $P$ to chord $A B$. A quadratic is accepted when $d(P_1,P_0 P_2) <= epsilon$; a cubic requires both interior controls to satisfy the bound. Otherwise de Casteljau subdivision at $t=1/2$ creates two smaller curves. The tolerance is in font units, so consumers should convert a layout-space or pixel tolerance before flattening.

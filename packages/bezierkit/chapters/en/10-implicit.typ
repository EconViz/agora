#import "/template/manual.typ": *

= Level sets <sec-implicit>

Indifference curves, isoquants and contour lines are level sets
$F(x, y) = c$ of a function of two variables. `trace_implicit` turns them
into cubic paths without solving for $y$, so it handles curves that turn
back, close up or break into several pieces.

#api(("trace_implicit",), syntax: [
  #raw("trace_implicit(")#meta("function")#raw(", *, levels, viewport, resolution=(101, 101), tolerance=1e-2, gradient=None)")
])[
  Trace $F(x, y) = c$ for each level $c$ inside the rectangle `viewport`
  $= (x_min, x_max, y_min, y_max)$, in `bezierkit.implicit`.
]

#param("function")[$F$, called with two floats; it must be finite at every grid point, or `ValueError` is raised.]
#param("levels")[One level or an iterable of finite levels.]
#param("resolution", type: "(int, int)", default: "(101, 101)")[Grid points along $x$ and $y$, at least 2 each.]
#param("tolerance", type: "float", default: "1e-2")[Allowed deviation, in coordinate units, of the simplified and curved segments.]
#param("gradient", type: "callable | None", default: "None")[$nabla F = (F_x, F_y)$, as a pair or a `Vector`. When given, straight pieces are bent into cubics that follow the curve's tangent.]

== Algorithm

+ *Sample.* Evaluate $F$ on a regular grid of the viewport.
+ *March.* In each grid cell, mark the corners where $F >= c$. An edge whose
  ends are marked differently is crossed by the level set; the crossing point
  is placed by linear interpolation of $F$ along the edge
  #citep(<lorensen1987>). A cell with two crossings contributes one line
  piece. A cell with four crossings is a saddle: the average of the four
  corner values decides which crossings to join (@fig-saddle).
+ *Stitch.* Join pieces that share an end point into chains. A chain that
  returns to its start is closed; one that reaches the viewport's edge or a
  branch point is open. Disconnected components stay separate paths.
+ *Simplify.* Reduce each chain with `fit_polyline` at `tolerance`
  (@sec-fitting), without corner preservation.
+ *Bend* (with `gradient`). Replace each straight piece by a cubic whose end
  tangents follow the level set (@thm-gradient), with handles one third of
  the chord long. The cubic is kept only if it stays within `tolerance` of
  the chord; where $nabla F = 0$ at either end, the piece stays straight.

#fig("/figures/implicit/saddle.pdf", width: auto, caption: [
  Saddle cell, centre (a) high, (b) low; filled corners have $F >= c$.
]) <fig-saddle>

#theorem(name: [Tangent of a level set])[
  Let $F$ be continuously differentiable near a point $p$ with $F(p) = c$
  and $nabla F(p) != 0$. Near $p$ the level set $F = c$ is a $C^1$ curve,
  and its tangent at $p$ is parallel to $(F_y(p), -F_x(p))$.
] <thm-gradient>

The tangent $(F_y, -F_x)$ needs no division, so a vertical tangent
($F_y = 0$) is as easy as any other, although the slope
$dif y slash dif x = -F_x slash F_y$ of the graph form is infinite there.

```python
from bezierkit.implicit import trace_implicit

contours = trace_implicit(
    lambda x, y: x**2 * y,
    levels=[1, 2, 4],
    viewport=(0.5, 4, 0, 6),
    resolution=(121, 121),
    tolerance=0.01,
    gradient=lambda x, y: (2 * x * y, x**2),
)
print(contours.level_values)                     # (1.0, 2.0, 4.0)
print(len(contours.for_level(4)[0].segments))    # 15
```

#fig("/figures/implicit/contours.pdf", width: auto, caption: [
  $x^2 y = c$ for $c = 1, 2, 4$, inner to outer.
]) <fig-contours>

== Results

#api(("ContourSet", "LevelContours"))[
  `trace_implicit` returns a `ContourSet` whose `contours` hold one
  `LevelContours` per level, in the order given: its `level` and its
  `paths`, one `PiecewiseBezier` per connected component. `level_values`
  lists the levels, `paths` all paths together, and `for_level(c)` the
  paths of one level (`KeyError` if it was not traced).
]

== Limitations

The traced curve is exact only at the grid crossings; between them it is the
piecewise-linear marching-squares curve, simplified and bent within
`tolerance`. Raise `resolution` and lower `tolerance` for a closer match.
Features smaller than a grid cell can be missed, and the saddle rule picks
one of the two possible connections. Kinks such as the corner of a Leontief
indifference curve are rounded to within the grid spacing, since the grid
sees no exact corner.

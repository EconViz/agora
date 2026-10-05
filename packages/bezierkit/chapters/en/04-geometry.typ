#import "/template/manual.typ": *

= Geometry values <sec-geometry>

All values are immutable: operations return new objects. Coordinates must be
finite; NaN and infinities raise `ValueError` when a value is created.

== Points and vectors

#api(("Point", "Vector"), syntax: [
  #raw("Point(")#meta("float")#raw(", ...)") \
  #raw("Vector(")#meta("float")#raw(", ...)")
])[
  A point or a vector in $RR^d$, given by its $d >= 1$ coordinates. Points
  and vectors combine as in affine geometry (@tab-point-arithmetic).
]

#tbl(caption: [Arithmetic of points and vectors])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Expression], [Result]),
    [`point - point`], [A `Vector`],
    [`point + vector`, `point - vector`], [A `Point`],
    [`vector + vector`, `vector * scalar`], [A `Vector`; `scalar * vector` works too],
  )
] <tab-point-arithmetic>

#param("coords")[The coordinate tuple.]
#param("dimension")[The dimension $d$.]
#param("x")[The first coordinate, when it exists.]
#param("y")[The second coordinate, when it exists.]
#param("z")[The third coordinate, when it exists.]
#param("dot()")[The inner product of two vectors.]
#param("norm()")[The Euclidean length of a vector.]
#param("normalized()")[The unit vector in the direction of a vector; a zero vector cannot be normalized.]

Mixing dimensions raises `DimensionMismatch`. `point + point` is not
rejected: it adds the coordinates and returns a `Point`, which is meaningful
only in combinations whose weights sum to one, such as the averages inside
de Casteljau's algorithm.

```python
from bezierkit import Point, Vector

p = Point(1, 2)
q = p + Vector(3, -1) * 2      # Point(coords=(7.0, 0.0))
v = q - p                      # Vector(coords=(6.0, -2.0))
print(v.norm())                # 6.324555320336759
```

== Point sets

#api(("PointSet",), syntax: [#raw("PointSet(")#meta("points")#raw(")")])[
  An immutable batch of points backed by a read-only $("count", d)$ NumPy
  array, as returned by batch evaluation and sampling. It offers `count`,
  `dimension`, `array` (a read-only copy), the columns `x`, `y`, `z`,
  iteration over `Point`s and indexing.
]

== Parameters

#api(("Interval",))[
  `Interval(start, end)` is a closed interval with `contains()`, `clamp()`
  and `linspace()`.
]

#api(("ParameterValues",))[
  Validates a scalar or a one-dimensional array of parameters against a
  domain. Every curve uses it, so `at(1.2)` on a curve over $[0, 1]$ raises
  `ParameterOutOfDomain`.
]

== Errors

#tbl(caption: [Exceptions])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Exception], [Raised when]),
    [`BezierKitError`], [Base class of the exceptions below],
    [`DimensionMismatch`], [Points, vectors or segments of different dimensions are combined],
    [`DegreeError`], [A curve has the wrong degree for an operation, or no control points],
    [`ParameterOutOfDomain`], [A parameter lies outside the curve's domain $[0, 1]$],
    [`ToleranceNotMet`], [Adaptive fitting cannot reach its tolerance within its limits (@sec-fitting)],
  )
]

Invalid arguments that are not geometry, such as a negative tolerance, raise
`ValueError`.

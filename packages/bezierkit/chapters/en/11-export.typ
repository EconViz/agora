#import "/template/manual.typ": *

= Sampling and export <sec-export>

The exporters write geometry only. They choose no colour, line width, theme,
axis, label or canvas, and they never flatten a cubic into line pieces: TikZ
gets native `.. controls ..` curves and SVG native `C` commands.

== Sampling

#api(("UniformSampler", "Sample"), syntax: [
  #raw("UniformSampler(")#meta("int")#raw(").sample(")#meta("curve")#raw(")")
])[
  Evaluate any curve or path at `count` equally spaced parameters over its
  domain, both ends included (`count` $>= 2$), in `bezierkit.sampling`. The
  `Sample` holds the read-only parameters `t` and the `points`, with the
  coordinate arrays `x` and `y` and iteration over `(t, point)` pairs.
]

```python
from bezierkit.sampling import UniformSampler

sample = UniformSampler(5).sample(curve)
print(sample.x)   # [0.      0.90625 2.      3.09375 4.     ]
```

== Rounding and transforms

The text exporters write each coordinate with a fixed number of decimal
places `precision`, and accept a `transform` that maps each control point
(a `Point`) to a two-dimensional `Point` before it is written, for example
from data to page coordinates.

#proposition(name: [Rounding error])[
  If every coordinate of every control point is changed by at most
  $epsilon$, then every coordinate of $B(t)$ changes by at most $epsilon$
  for every $t in [0, 1]$, and $B(t)$ moves by at most $epsilon sqrt(d)$.
  Rounding to $p$ decimal places gives $epsilon = 1/2 dot 10^(-p)$.
] <prop-rounding>

So with the default `precision=6`, an exported planar curve stays within
$0.71 times 10^(-6)$ of the original everywhere, not only at its control
points. An affine `transform` is exact by @prop-affine; a non-affine one
moves the control points correctly but not, in general, the points between
them.

== JSON

#api(("dumps", "loads", "PathDocument"), syntax: [
  #raw("dumps(")#meta("path")#raw(", *, metadata=None, indent=None)") \
  #raw("loads(")#meta("str")#raw(")")
])[
  In `bezierkit.export.json`. `dumps()` writes a path in the versioned
  schema of @tab-json, with sorted keys and no NaN or infinity; `loads()`
  validates a document and returns a `PathDocument` holding the `path` and
  its `metadata`. An unknown schema or version, a segment without exactly
  four points, a point of the wrong dimension, or a non-finite number raises
  `ValueError`.
]

#tbl(caption: [JSON path schema, version 1])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Key], [Value]),
    [`schema`], [The string `"bezierkit.path"`],
    [`version`], [The integer `1`; readers reject other versions],
    [`dimension`], [The dimension $d$ of every point],
    [`subpaths`], [A non-empty array of `{"closed": bool, "segments": [...]}`, each segment four points of $d$ numbers],
    [`metadata`], [A JSON object, passed through uninterpreted],
  )
] <tab-json>

```python
from bezierkit.export.json import dumps, loads

text = dumps(path, metadata={"name": "arch"})
# {"dimension":2,"metadata":{"name":"arch"},"schema":"bezierkit.path",
#  "subpaths":[{"closed":false,"segments":[[[0.0,0.0],[1.0,2.0],...]]}],"version":1}
assert loads(text).path.segments == path.segments
```

Version 1 is frozen: a new required key, a change in closure semantics or in
the control-point layout requires version 2.

== SVG

#api(("to_svg_path_data", "from_svg_path_data"), syntax: [
  #raw("to_svg_path_data(")#meta("path")#raw(", *, precision=6, transform=None)") \
  #raw("from_svg_path_data(")#meta("str")#raw(")")
])[
  In `bezierkit.export.svg`. The path data string (the `d` attribute) of a
  planar path, using only absolute `M`, `C` and `Z` commands, one `M` per
  subpath; no SVG document or styling. `from_svg_path_data()` parses that
  same subset back; relative commands, lines and arcs raise `ValueError`.
]

```python
from bezierkit.export.svg import to_svg_path_data

print(to_svg_path_data(path, precision=2))   # M 0.00 0.00 C 1.00 2.00 3.00 2.00 4.00 0.00
```

== TikZ

#api(("to_tikz", "segment_to_tikz"), syntax: [
  #raw("to_tikz(")#meta("path")#raw(", *, precision=6, transform=None, options=None)") \
  #raw("segment_to_tikz(")#meta("segment")#raw(", *, precision=6, transform=None, include_start=True)")
])[
  In `bezierkit.export.tikz`. One `\draw` command per subpath, each segment
  written as `.. controls (P1) and (P2) .. (P3)`, closed subpaths ending in
  `-- cycle`. `options` is inserted verbatim as `\draw[options]`; nothing is
  chosen by default. `segment_to_tikz()` writes one segment, without the
  `\draw`, for callers assembling their own commands.
]

```python
from bezierkit.export.tikz import to_tikz

print(to_tikz(path, precision=2, options="thick"))
# \draw[thick] (0.00,0.00) .. controls (1.00,2.00) and (3.00,2.00) .. (4.00,0.00);
```

Every figure in this manual was made this way: a script builds the curves
with #pkg("bezierkit"), writes them with `to_tikz()` into a `standalone`
#LaTeX document beside the axes and labels, and compiles it to PDF. The
`.tex` source of each figure ships with the manual.

== Matplotlib <sec-matplotlib>

#api(("from_path", "to_path", "approximate_path"), syntax: [
  #raw("from_path(")#meta("path")#raw(", *, transform=None)") \
  #raw("to_path(")#meta("path")#raw(")") \
  #raw("approximate_path(")#meta("path")#raw(", ")#meta("transform")#raw(", *, tolerance, max_depth=20)")
])[
  In `bezierkit.adapters.matplotlib`, with the `matplotlib` extra.
  `from_path()` converts a Matplotlib `Path` exactly: `MOVETO`, `LINETO`,
  `CURVE3`, `CURVE4` and `CLOSEPOLY` become cubics, lines and quadratics by
  @prop-elevation. An affine `transform` is applied to the control points,
  which is exact (@prop-affine); a non-affine one raises `ValueError`.
  `to_path()` converts back, one `CURVE4` per segment.
]

A non-affine transform, such as a logarithmic axis, does not map cubics to
cubics. `approximate_path()` is the explicit opt-in: it subdivides each
transformed segment until its midpoints lie within `tolerance / 2` of the
chords, then simplifies the points with `fit_polyline` at `tolerance / 2`.
It does not claim to be exact.

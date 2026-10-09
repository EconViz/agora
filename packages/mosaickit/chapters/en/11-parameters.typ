#import "/template/manual.typ": *

= Parameters, grids and animation <sec-parameters>

== Parameters and expressions

A layer coordinate may be an expression in named parameters instead of a
number. The scene then describes a family of diagrams, one for each value of
the parameters; binding picks one.

#api(("Parameter",), syntax: [#raw("Parameter(name, value_type=None)")])[
  A named placeholder. With `value_type` set, a bound value must be an
  instance of it; every bound value must be hashable. `values(seq)` returns
  `ParameterValues`, checking each value at once.
]

#api(("Expression", "Constant"), syntax: [#raw("Constant(value)")])[
  Immutable expression trees. Parameters and constants combine with `+`,
  `-`, `*`, `/`, `**`, unary `-` and the comparisons `<`, `<=`, `>`, `>=`,
  and `equals()`; plain numbers are wrapped as constants. Equality of
  expressions is structural (`==` compares trees, so `equals()` builds the
  comparison instead), and using an expression as a truth value raises
  `BindingError`: evaluate it first. `evaluate(bindings)` computes the value
  from a mapping of parameters to values; `free_parameters()` is the set of
  parameters the tree contains.
]

#definition(name: [Expressions and binding])[
  An _expression_ is a constant, a parameter, or $e_1 circle.small e_2$ for
  expressions $e_1, e_2$ and an operation $circle.small$. Its free parameters
  are $"free"(c) = emptyset$, $"free"(p) = {p}$ and
  $"free"(e_1 circle.small e_2) = "free"(e_1) union "free"(e_2)$. A
  _binding_ $beta$ is a finite map from parameters to values, and
  $"bind"(e, beta)$ is: the value $e(beta)$ if
  $"free"(e) subset.eq "dom" beta$; otherwise $e$ itself if $e$ is a
  parameter; otherwise $"bind"(e_1, beta) circle.small "bind"(e_2, beta)$.
  A plain value $v$ has no free parameters and evaluates to itself.
] <def-binding>

#theorem(name: [Partial binding])[
  For every expression $e$ and binding $beta$,
  (i) $"free"("bind"(e, beta)) = "free"(e) without "dom" beta$, and
  (ii) for every binding $gamma$ with $"dom" gamma inter "dom" beta = emptyset$
  and $"dom" gamma supset.eq "free"(e) without "dom" beta$,
  $"bind"(e, beta)(gamma) = e(beta union gamma)$.
] <thm-binding>

#corollary(name: [Binding in stages])[
  For bindings $beta_1, beta_2$ with disjoint domains, $"bind"("bind"(e,
  beta_1), beta_2)$ and $"bind"(e, beta_1 union beta_2)$ have the same free
  parameters and the same value under every binding of them. In particular
  `canvas.bind(p, 1).bind(q, 2)` draws the same diagram as
  `canvas.bind({p: 1, q: 2})`.
] <cor-stages>

`bind` walks through tuples, mappings and every `mosaickit` dataclass, so a
whole scene is bound at once; a layer's `model` is left alone. Rendering a
scene that still has free parameters raises `BindingError` naming them.

```python
from mosaickit import Canvas, Parameter, TextLayer

x = Parameter("x", value_type=float)
template = Canvas().add(TextLayer((x, 2 * x + 1), "moving"))
frame = template.bind(x, 3.0)
print(frame.snapshot().layers[0].position)    # (3.0, 7.0)
```

== Grids

#api(("CanvasGrid", "Span"), syntax: [
  #raw("CanvasGrid(cells, rows=None, cols=None, shape=None, links=())") \
  #raw("Span(canvas, rows=1, cols=1)")
])[
  Several canvases in one figure. `cells` is either a flat list of canvases,
  `Span`s and `None`s (empty cells), filled row by row, or a list of rows,
  where row spans are allowed and every row must account for every column.
  `shape=(rows, cols)` is the same as passing both. Each canvas is copied,
  so changing it afterwards does not change the grid. Overlapping spans,
  spans past the edge, too many cells or mixed flat and nested cells raise
  `ConfigurationError`. `render()` and `save()` work as on a canvas.
]

#proposition(name: [Inferred grid shape])[
  For a flat list of $n >= 1$ plain cells with neither `rows` nor `cols`
  given, the grid has $c = ceil(sqrt(n))$ columns and $r = ceil(n slash c)$
  rows. Then $r c >= n$, $r <= c$, and fewer than $c$ cells are left empty,
  all in the last row.
] <prop-grid-shape>

With only `cols` given, $r = ceil(n slash c)$; with only `rows`,
$c = ceil(n slash r)$.

#api(("Layout", "CanvasGrid.from_layout"), syntax: [#raw("CanvasGrid.from_layout(canvases, layout)")])[
  Common arrangements: `SINGLE`, `STACKED` (two rows), `SIDE_BY_SIDE`,
  `GRID_2X2`, `GRID_3X3`, and the three-canvas `TOP_TWO_BOTTOM_ONE` and
  `TOP_ONE_BOTTOM_TWO`, whose single canvas spans both columns.
]

#api(("CanvasGrid.sweep",), syntax: [#raw("CanvasGrid.sweep(template, values, *, cols=None)")])[
  One cell per value of a `ParameterValues`, each the template bound to it.
]

#api(("GridLink",), added: "0.5.0", syntax: [#raw("GridLink(start_cell, start, end_cell, end, role=\"link\", stroke=None)")])[
  A straight line from `start` in one cell to `end` in another, each in its
  own cell's data coordinates, drawn over the figure across the gaps between
  cells. Cells are numbered in placement order. Its style is `role`
  resolved in the start cell's theme, with `stroke` on top. A cell index out
  of range raises `ConfigurationError` when the grid is built.
  #changed("0.5.0", label: "CanvasGrid")[`links` added]
]

```python
from mosaickit import Canvas, CanvasGrid, GridLink, MarkerLayer, Parameter, Stroke

shift = Parameter("shift", value_type=float)
template = Canvas().add(MarkerLayer([(5, 2.5 + shift)]))
cells = [template.bind(shift, v) for v in (0.0, 2.0, 4.0)]
link = GridLink(0, (5, 2.5), 2, (5, 6.5), stroke=Stroke(dash="dashed"))
CanvasGrid(cells, cols=3, links=[link]).save("sweep.pdf")
```

#fig("/figures/grids/sweep.pdf", width: auto, caption: [
  A three-value sweep with a link from the first cell to the last.
]) <fig-sweep>

== Animation

#api(("Animation",), syntax: [
  #raw("Animation(template, parameter, values, fps=30)") \
  #raw("Animation.sweep(canvas, values, *, fps=30)")
])[
  One frame per value: the template bound to the parameter. `frames()`
  yields the frames as renderer-neutral scenes; `save(path)` writes a GIF
  (through Pillow) or an MP4 (through `ffmpeg`). The values are checked
  against the parameter when the animation is created; an empty list or a
  non-positive `fps` raises `ConfigurationError`.
]

```python
from mosaickit import Animation

values = shift.values([0.0, 1.0, 2.0, 3.0])
Animation.sweep(template, values, fps=4).save("sweep.gif")
```

#import "/template/manual.typ": *

= Layers and axes <sec-layers>

== Common fields

#api(("Layer",), syntax: [#raw("Layer(*, id=")#meta("uuid")#raw(", role=\"primary\", z_index=0, visible=True, legend=None, model=None)")])[
  The immutable base of every layer. All layers take these keyword-only
  fields after their own positional ones.
]

#param("id")[A non-empty string, unique within the scene; a random hex string by default. Legends, region labels and `remove()` refer to layers by id.]
#param("role")[A dotted role name such as `"primary"` or `"mypkg.boundary"`; it selects the layer's style from the theme (@sec-themes). Each layer type has its own default and a fallback category consulted last.]
#param("z_index")[A finite drawing order; higher is drawn later, on top. A group adds its own `z_index` to its children's.]
#param("visible")[`False` leaves the layer out of the render.]
#param("legend")[The legend label of the layer; layers without one are not in legends.]
#param("model")[Any domain object the layer was built from. It takes part in render caching (@sec-rendering) but not in equality or binding.]

Coordinates are pairs of finite real numbers in data units, or parameter
expressions (@sec-parameters). Invalid geometry raises `ConfigurationError`
when the layer is created, not when it is drawn.

== Primitive layers

#tbl(caption: [Primitive layers])[
  #booktabs(
    columns: (auto, auto, 1fr),
    header: ([Layer], [Default role], [Draws]),
    [`PathLayer(path, stroke)`], [`primary`], [The polyline through at least two points],
    [`FillLayer(boundary, fill, stroke)`], [`region`], [The polygon on at least three points, filled and outlined],
    [`MarkerLayer(points, marker)`], [`point`], [A marker at each of at least one point],
    [`TextLayer(position, text)`], [`text`], [Text at a point],
    [`ArrowLayer(start, end, stroke)`], [`annotation`], [A straight arrow, optionally labelled],
    [`LegendLayer(entries, style)`], [`legend`], [A legend of labelled layers],
    [`GroupLayer(children)`], [`primary`], [Nothing of its own; groups layers],
  )
] <tab-layers>

#api(("PathLayer",), syntax: [#raw("PathLayer(path, stroke=None, arrow_placement=ArrowPlacement.END, clip=True, *, ...)")])[
  Joins its points with straight segments. When the resolved stroke has an
  `arrow` style, arrowheads are drawn at the `START`, `END` or `BOTH` ends,
  aligned with the end segments. `clip=False` lets the line run past the
  plot edge at full width, which is what the axis presets use.
  #changed("0.2.0")[`clip` added (default `True`); arrowheads no longer redraw a solid shaft over the end of the path, so dashed arrows stay dashed]
]

#api(("FillLayer",), syntax: [#raw("FillLayer(boundary, fill=None, stroke=None, *, ...)")])[
  A closed polygon filled with `fill` and outlined with `stroke`. Its id is
  what a `RegionLabelLayer` names.
]

#api(("MarkerLayer",), syntax: [#raw("MarkerLayer(points, marker=None, *, ...)")])[
  One marker per point. Markers are drawn whole. A marker centred on the plot
  edge, such as a point on an axis, is not cut in half; one centred outside
  the plot is omitted.
  #changed("0.5.1")[Markers are drawn whole on the plot edge; markers centred outside the plot are left out]
]

#api(("TextLayer",), syntax: [#raw("TextLayer(position, text, style=None, offset=(0, 0), anchor=\"center\", math=False, *, ...)")])[
  Text at `position`, moved by `offset` points. `anchor` names the point of
  the text box placed there: `center`, `left`, `right`, `top`, `bottom`,
  `top-left`, `top-right`, `bottom-left` or `bottom-right`. With
  `math=True` the text is set as mathematics (`"a_1"` gives $a_1$).
  #changed("0.2.0")[`anchor` accepts the four corners `top-left`, `top-right`, `bottom-left`, `bottom-right`]
]

#api(("ArrowLayer",), syntax: [#raw("ArrowLayer(start, end, stroke=None, label=None, arrow_placement=ArrowPlacement.END, *, ...)")])[
  A straight arrow from `start` to `end`, with an open head unless the
  stroke names another `ArrowStyle`; `label` is written at its midpoint.
  A dashed, dotted or dash-dot stroke dashes the shaft and leaves the heads
  solid. Arrowheads are not clipped to the plot.
  #changed("0.2.0")[Arrowheads are no longer clipped to the axes]
  #changed("0.5.0")[A dashed, dotted or dash-dot stroke dashes the shaft; the heads stay solid]
]

#api(("LegendLayer",), syntax: [#raw("LegendLayer(entries=(), style=None, *, ...)")])[
  A legend listing the layers whose ids are in `entries`, or every layer
  that has a `legend` label when `entries` is empty. An id that is missing or
  has no label raises `RenderError`. `LegendStyle(visible=False)` hides it.
]

#api(("GroupLayer",), syntax: [#raw("GroupLayer(children, *, ...)")])[
  A layer made of layers. Children are drawn as if they were in the scene,
  with the group's `z_index` added to theirs; an invisible group hides them
  all.
]

== Axes

#api(("AxisSpec", "build_axes"), syntax: [
  #raw("AxisSpec(extent, arrow=None, label=None)") \
  #raw("build_axes(x, y) -> list[Layer]")
])[
  `build_axes` turns two axis specifications into ordinary layers with the
  role `axes`. When neither has an `arrow`, the result is a closed frame
  around the extents; otherwise each axis is a line along $y = 0$ or
  $x = 0$, with filled triangle heads at the `ArrowPlacement` given. Titles
  sit past the arrow tips: the x title to the right, the y title above, 6 pt
  away.
  #changed("0.2.0")[Axis presets draw filled triangle arrowheads; axis lines are not clipped, so they keep their full width on the plot edge]
  #changed("0.3.0")[Axis titles are placed past the arrow tips instead of centred on them]
]

#api(("quadrant_axes", "crosshair_axes", "box_frame"), syntax: [
  #raw("quadrant_axes(x_max, y_max)") \
  #raw("crosshair_axes(x_range, y_range)") \
  #raw("box_frame(total_x, total_y)")
])[
  Three presets, respectively: two axes from the origin with heads at the far
  ends; two axes through the origin with heads at both ends; and a frame
  without heads.
]

Every axis is made of `PathLayer` and `TextLayer`, so it can be restyled
through the `axes` role, removed by id (`axes.x`, `axes.y`, `axes.frame`,
`axes.x.label`, `axes.y.label`) or replaced by hand-made layers.

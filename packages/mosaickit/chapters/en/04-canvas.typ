#import "/template/manual.typ": *

= Canvases and scenes <sec-canvas>

== Canvas specifications

#api(("CanvasSpec",), syntax: [
  #raw("CanvasSpec(x_range=(0, 10), y_range=(0, 10), width=6.0, height=6.0,") \
  #raw("           dpi=300, x_label=\"X\", y_label=\"Y\", title=None)")
])[
  The physical and coordinate dimensions of a diagram. `x_range` and
  `y_range` are the data ranges shown; `width` and `height` are the figure
  size in inches; `dpi` is an integer in $[1, 1200]$. The properties
  `x_min`, `x_max`, `y_min`, `y_max` read the ranges, and `replace(**changes)`
  returns a copy with some fields changed. Ranges must be finite with
  `lo < hi`, sizes positive and finite; anything else raises
  `ConfigurationError`.
]

#api(("Interval",), syntax: [#raw("Interval(")#meta("lo")#raw(", ")#meta("hi")#raw(")")])[
  A finite increasing interval, `lo < hi`, shared by specifications and
  axes.
]

== Canvas

#api(("Canvas",), syntax: [
  #raw("Canvas(spec=None, theme=None, config=None, renderer=None, *,") \
  #raw("       role_overrides=None)")
])[
  A fluent builder around an immutable scene. Arguments left `None` come
  from the configuration active when the canvas is created (@sec-config):
  its `canvas_spec`, `theme` and `renderer`. `role_overrides` maps role names
  to `StyleBundle`s applied on top of the theme and the configuration
  (@thm-resolution).
]

#param("add(layer), extend(layers)")[Append one layer or several; return the canvas.]
#param("remove(layer_id), clear()")[Remove the layer with that id (searching inside groups) or every layer; return the canvas. An unknown id raises `ConfigurationError`.]
#param("snapshot()")[The current `Scene`. Later calls to `add()` do not change it.]
#param("copy()")[A new canvas with the same specification, theme, configuration, renderer, overrides, scene and bindings.]
#param("bind(parameter, value), bind(mapping)")[A new canvas whose scene has those parameters replaced by values (@sec-parameters); the original keeps its parameters.]
#param("render(*, renderer=None, cache=None)")[Render the scene and return the renderer's result (@sec-rendering).]
#param("save(target, *, renderer=None, cache=None, **options)")[Render, write `.png`, `.pdf` or `.svg`, close the result and return the written paths. The options are those of `SaveOptions`.]

The builder methods change the canvas but never a scene: each call replaces
the canvas's scene with a new one, so a snapshot, a copy or a bound canvas
taken earlier keeps exactly what it had.

```python
from mosaickit import Canvas, PathLayer

canvas = Canvas()
before = canvas.snapshot()
canvas.add(PathLayer([(0, 0), (1, 1)], id="line"))
assert before.layers == ()             # the old snapshot is unchanged
assert canvas.snapshot().layers[0].id == "line"
```

== Scenes

#api(("Scene",), syntax: [#raw("Scene(layers=(), metadata={})")])[
  A persistent, ordered collection of layers. `add()`, `extend()`,
  `remove()` and `clear()` return new scenes; `Scene.empty()` is the empty
  one. Layer ids must be unique across the whole scene, groups included;
  a duplicate raises `ConfigurationError`. `ordered_layers` sorts the
  top-level layers by `z_index`, keeping insertion order among equals, which
  is the order in which they are drawn.
]

== Errors and warnings

#tbl(caption: [Exceptions and warnings])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Class], [Raised or emitted when]),
    [`MosaicKitError`], [Base class of the three errors below],
    [`ConfigurationError`], [A model, style, theme, specification or configuration value is invalid],
    [`BindingError`], [A parameter is missing, has the wrong type, or an expression cannot be evaluated],
    [`RenderError`], [A renderer cannot do what was asked: an unknown format or renderer, a missing legend entry],
    [`LayoutWarning`], [Automatic placement could not avoid every obstacle (@sec-labels)],
    [`CacheBypassWarning`], [A layer's model is not hashable, so it is rendered without caching],
  )
]

#changed("0.2.0", label: "LayoutWarning")[Added, emitted when no callout position avoids every obstacle]

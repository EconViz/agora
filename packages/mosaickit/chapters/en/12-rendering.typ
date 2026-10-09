#import "/template/manual.typ": *

= Rendering <sec-rendering>

== Renderers

#api(("Renderer",), syntax: [
  #raw("name: str") \
  #raw("render(scene, context) -> Any") \
  #raw("save(result, target, options) -> list[Path]")
])[
  The protocol implemented by every backend. A renderer receives an
  immutable scene and a private render context (specification, theme, overrides,
  palette, cache and bindings), and returns a result that `save` writes.
  Grids and animations also require `render_grid` and `save_animation`; a
  renderer without them raises `RenderError`. Render plans and contexts
  remain private while the built-in backend evolves.
]

#api(("RendererRegistry",), syntax: [#raw("RendererRegistry()")])[
  `register(renderer)` adds a backend under its `name`. An object missing
  `name`, `render` or `save`, or one whose name is already registered, raises
  `RenderError`. `get(name)` returns a registered renderer or loads a built-in
  one. The only built-in is `"matplotlib"`, imported on first use
  #citep(<hunter2007>).
]

== The Matplotlib renderer

Rendering a canvas builds a render plan: it binds the scene (a free parameter
raises `BindingError`), flattens groups, sorts layers by `z_index`, resolves
each layer's style (@thm-resolution) and replaces palette names by colors.
The figure gets the canvas size and DPI, the `canvas` role's fill as its
background, and axes set to the specification's ranges with Matplotlib's own
axis lines turned off; axes in #pkg("mosaickit") are layers.

Builders, one per layer type, then draw the layers in order. Deferred passes
handle layer types whose work depends on everything else: legends, point
labels, region labels, gutter text and span braces. These passes run in
registration order, and each receives all layers of its type at once.

#api(("register_builder", "register_pass"), added: "0.2.0", syntax: [
  #raw("register_builder(layer_type, builder)") \
  #raw("register_pass(layer_type, run)")
])[
  These functions in `mosaickit.rendering.matplotlib` teach the renderer a
  new layer type without changing #pkg("mosaickit"). A builder is called as
  `builder(ax, resolved)` and returns the Matplotlib artist; a pass is called
  as `run(ax, layers, context)` with a `PassContext` whose `handles` map
  layer ids to legend artists. `resolved.layer` is the layer and
  `resolved.style` its resolved `StyleBundle`. Lookups follow the method
  resolution order, so a subclass inherits its parent's registration. A
  layer declares which of its fields holds its explicit style for each slot
  through the class variable `style_slots`, and its last-resort role
  through `fallback_category`.
  #changed("0.2.0", label: "Layer")[Layers declare `style_slots`; Matplotlib drawing is driven by a per-type registry]
]

Region-label callouts avoid everything on the axes, including what
registered third-party builders drew.

== Results and saving

#api(("SaveOptions",), syntax: [#raw("SaveOptions(transparent=False, expand=True)")])[
  Controls how a result is written; `canvas.save(path, **options)` passes its
  keyword arguments here. `transparent` drops the background. With
  `expand=True`,
  saving grows the canvas just enough, plus a 4 pt margin, to include
  anything drawn past its edges, such as gutter text; it never crops, so a
  diagram that fits keeps exactly the size of its `CanvasSpec`.
  `expand=False` keeps the specified size.
  #changed("0.3.0")[`expand` added (default `True`)]
]

```python
result = canvas.render()
try:
    result.show()          # an interactive window
finally:
    result.close()
```

`render()` returns a `MatplotlibResult` with `figure`, `axes`, `show()`,
`save(target, **options)` and `close()`. `canvas.save()` closes its
temporary result itself. The file format follows the extension: `.png`,
`.pdf` or `.svg` (anything else raises `RenderError`); animations take `.gif`
or `.mp4`. A grid gives every cell one size: the largest canvas width
divided by the columns it spans, by the largest canvas height divided by
the rows it spans; it uses the highest DPI among its canvases.

== Caching

#api(("RenderCache", "CacheKey"), syntax: [#raw("RenderCache(max_entries=256)")])[
  A bounded, thread-safe least-recently-used cache for resolved layers, keyed
  by layer id, bindings, model, specification and style. Each render, grid
  or animation creates its own cache unless one is passed with `cache=`, so
  jobs never share state by accident; pass the same cache to reuse work
  across jobs. A model that cannot be hashed is rendered without caching,
  with one `CacheBypassWarning` per model type and cache; use frozen
  dataclasses for models. `clear()` empties the cache.
]

#import "/template/manual.typ": *

= Introduction <sec-intro>

#changed("0.1.0")[First release: immutable scenes and layers, sparse styles, namespaced themes, canvases, spanning grids, parameter expressions, animation, Matplotlib rendering with job-scoped caches, and strict TOML configuration]
#changed("0.1.1")[Package metadata on PyPI links the homepage, repository, issue tracker, changelog and release notes]
#changed("1.0.0rc1")[Removed the deprecated `Animation` and `TextStyle.family` (see the chapters on parameters and styles)]
#changed("1.0.0rc2")[Faster drawing with identical output: label placement, point validation and Matplotlib's mathtext parsing use arrays and caches scoped to one draw or save]
#changed("1.0.0rc3")[Titles and text that mixes words with `$...$` math are set in the configured text fonts, so Chinese no longer comes out as boxes]
#changed("1.0.0rc4")[Parsed fonts are shared across symbolic links; a configured title keeps the baseline Matplotlib gives it]
#changed("1.0.0rc5")[New `mosaickit.econ_toml` reads the sections of `econ-viz.toml` that every EconViz package shares]
#changed("1.0.0rc6")[Packages declare an `econ_toml.Schema` and mosaickit parses `econ-viz.toml` for them; shared themes (`mosaickit.themes`) and label nudges (`Nudge`) added]

The #pkg("mosaickit") package assembles two-dimensional diagrams from small,
immutable pieces. A scene is an ordered list of layers (paths, filled regions,
markers, text, arrows, labels, braces). Each layer names a semantic role, a
theme maps roles to styles, and a renderer produces PNG, SVG or PDF.
The package is domain-neutral. Domain packages such as #pkg("principle-viz")
and #pkg("utility-viz") define their own models and role names, then pass
#pkg("mosaickit") the layers to draw. Curve construction and TikZ export
belong to geometry packages such as #pkg("bezierkit").

== Design

Four ideas run through the package.

/ Immutable values: Layers, scenes, styles, themes and specifications
  are frozen dataclasses. A `Canvas` is a fluent builder around an immutable
  `Scene`; `snapshot()`, `copy()` and `bind()` never change a scene another
  object holds.
/ Sparse styles: Every style field may be `None`, meaning inherit.
  A layer's explicit style sits on top of canvas overrides, configuration
  overrides, the theme and the primitive defaults (@sec-themes).
/ Roles, not colors: Layers name what they are (`"primary"`,
  `"axes.note"`, `"mypkg.boundary"`); themes decide how that looks, and
  colors are palette names resolved when a canvas renders (@sec-styles).
/ Placement that covers nothing: Region labels, point labels, braces
  and axis annotations are placed after everything else is drawn, by pure
  geometry in display pixels, so that text touches no line, marker, region
  or other text (@sec-geometry, @sec-labels).

== Mathematics and proofs

Automatic placement uses computational geometry: orientation tests, the
even-odd rule, distances to a polygon's boundary, a best-first search for the
point deepest inside a region, and the least-squares packing that keeps axis
text apart. The chapters state what each routine guarantees as numbered
definitions, lemmas, propositions and theorems; the proofs are collected in
@app-proofs, so the chapters can be read for the API alone. The same
treatment covers the algebra of styles and themes (sparse merging, role
resolution) and parameter binding. The standard references are
#citet(<deberg2008>) for the geometry and #citet(<barlow1972>) for the
order-restricted least squares behind @thm-spread.

== Reading guide

#tbl(caption: [Chapter guide])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([Topic], [Contents], [Section]),
    table.cell(rowspan: 3)[Building],
    [Canvases, specifications, scenes], [#ref(<sec-canvas>)],
    [Paths, fills, markers, text, axes], [#ref(<sec-layers>)],
    [Axis marks, notes and braces], [#ref(<sec-annotations>)],
    table.cell(rowspan: 2)[Placement],
    [Layout geometry], [#ref(<sec-geometry>)],
    [Region and point labels], [#ref(<sec-labels>)],
    table.cell(rowspan: 2)[Appearance],
    [Styles, colors, palettes], [#ref(<sec-styles>)],
    [Themes, roles, configuration], [#ref(<sec-themes>)],
    table.cell(rowspan: 2)[Output],
    [Parameters and grids], [#ref(<sec-parameters>)],
    [Renderers, caches, saving], [#ref(<sec-rendering>)],
  )
] <tab-guide>

Start with @sec-quickstart, @sec-canvas and @sec-layers. Every
figure in this manual is #pkg("mosaickit") output, drawn by the canvas or
grid it illustrates and saved as PDF at the printed size.

The scripts that draw the figures of this manual come as one zip, sorted by topic: #link("https://econ-viz.org/assets/mosaickit/agora/mosaickit-examples.zip")[mosaickit-examples.zip].

#import "/template/manual.typ": *

= Settings <sec-settings>

#changed("0.2.0.dev0", label: "Config")[Settings are read from the shared `econ-viz.toml`; #pkg("micro-viz") declares its own tables under `[micro]`]
#changed("0.2.0.dev0", label: "Config")[`[micro.region]` shades the marginal-return regions or not, to the top of the plot or only under the curve]

#pkg("micro-viz") reads the shared `econ-viz.toml`. #pkg("mosaickit") parses and checks the file; #pkg("micro-viz") only declares what it takes, under `[micro]`.

#api(("Config",), syntax: [
  ```python
  Config.load(path=None)
  Config.discover()
  Config.from_dict(data)
  config.use()
  ```
])[
  The theme read from an `econ-viz.toml`. `load()` reads `path`, or `econ-viz.toml` in the working directory. `use()` makes it the default, so every figure made without an explicit `theme` uses it, and returns the config. Relative paths in the file are resolved against the file's directory.
]

```python
from micro_viz import Config

Config.load("econ-viz.toml").use()
```

A key left out keeps the built-in default, and without any file the output is the same as before settings existed.

```toml
base = "manual"            # shared look: black and white on white

[font]
text = "serif"
math = "texgyrepagella-math.otf"

[fonts]
serif = ["texgyrepagella-regular.otf", "texgyrepagella-italic.otf"]

[micro]
language = "en"            # en, zh-TW or zh-CN

[micro.stroke]
curve = 3.5                # points

[micro.region]
fill = true
extent = "top"
```

The manual builds each edition's figures from the files `config/econ-viz.toml`, `config/econ-viz.zh-TW.toml` and `config/econ-viz.zh-CN.toml`, which differ in the fonts and the language only.

== Shared keys

`base`, `[font]`, `[fonts]`, `background`, `axis` and `label` are shared by all EconViz packages and are documented with #pkg("mosaickit"). There is no dark theme: the background is always white.

== The `[micro]` tables <sec-micro-tables>

#tbl(caption: [Keys of the `[micro]` tables])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([Key], [Meaning], [Default]),
    [`language`], [Language of built-in figure text], [`en`],
    [`color.<element>`], [Colour of one element (see below)], [the theme's],
    [`stroke.curve`], [Width of a main curve, in points], [3.5],
    [`stroke.dashed`], [Width of a dashed curve], [2.0],
    [`stroke.guide`], [Width of axes and guide lines], [1.0],
    [`stroke.after`], [Width of a curve after a change (thin, solid)], [1.5],
    [`stroke.arrow`], [Width of a movement arrow (solid)], [1.2],
    [`marker.diameter`], [Diameter of a marked point], [6.5],
    [`brace.gap`], [Gap between a shaded region and its brace], [4.0],
    [`opacity.region`], [Opacity of shaded regions, above 0 and at most 1], [0.2],
    [`region.fill`], [Shade the regions of a figure (`false` keeps only braces and names)], [`true`],
    [`region.extent`], [`top` shades up to the top of the plot, `curve` only under the curve], [`top`],
    [`label.<group>.<side>`], [Move a label group (@sec-nudges)], [none],
  )
] <tab-micro>

The colour elements are `axis`, `label`, `guide`, `marker`, `total`, `average`, `marginal`, `variable`, `fixed`, `price`, `region_light`, `region_mid` and `region_dark`. Each takes a theme role, so `manual` gives black and white and `default` gives colour.

A curve after a change is always thin and solid, a parallel shift is a straight arrow, and a curved arrow means rotation only; settings change widths, never these conventions.

== Themes in code

#api(("PlotTheme", "shared_theme", "default_theme"), syntax: [
  ```python
  shared_theme(name)
  default_theme(palette=None)
  ```
])[
  `PlotTheme` holds the look of one figure: colours, line widths, marker size, region shading, fonts and the language. `shared_theme(name)` builds one from a shared #pkg("mosaickit") theme name such as `"manual"`; `default_theme()` returns the theme a figure uses without an explicit one, that of the active `Config`.
]

== Region fill <sec-region-fill>

The marginal-return regions of the production figures can be shaded or not, shaded to the top of the plot or only under the curve, and each region can take its own colour.

```python
from dataclasses import replace

from micro_viz import shared_theme, total_product_canvas

theme = replace(shared_theme("manual"), region_extent="curve")
total_product_canvas(
    result,
    theme=theme,
    region_colors={"increasing": "#bbbbbb", "diminishing": "#dddddd"},
)
```

`region_colors` maps a region kind (`increasing`, `diminishing`, `negative`) to a colour; a kind left out keeps its theme shade.

#fig("/figures/production/total_product.svg", width: 46%, caption: [
  Shade to the top
]) <fig-region-top>

#fig("/figures/production/total_product_under_curve.svg", width: 46%, caption: [
  Shade under the curve
]) <fig-region-curve>

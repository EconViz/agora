#import "/template/manual.typ": *

= Themes and configuration <sec-themes>

A `Theme` defines the default look of a diagram; a `Config` loads theme
overrides and font settings from a TOML file. `Canvas`, `Figure`,
`DemandDiagram`, price-effect decompositions and `EdgeworthBox` share these
style objects.

== Built-in themes

#changed("1.6.0", label: "themes.default")[Colour-blind-friendly default palette, with `COLORBLIND_CYCLE_RGB` and `COLORBLIND_CYCLE_HEX`]
#changed("1.11.0", label: "Theme")[Complete theme system: background colour, label scale and defaults for every economic layer]
#changed("1.11.0", label: "themes")[New `paper`, `monochrome`, `presentation` and `dark` themes]
#changed("1.12.0", label: "Theme")[Colour, width and opacity of secondary indifference curves]

#api(("themes",), updated: "v1.11.0", syntax: [
  ```python
  from utility_viz import Canvas, themes

  cvs = Canvas(theme=themes.paper)
  ```
])[
  The Python API provides the themes below. Theme objects are immutable; to
  change a field, create a new `Theme` or override the field with a
  `Config`.

  #tbl(caption: [Built-in themes])[
    #booktabs(
      columns: (auto, 1fr),
      header: ([Name], [Character]),
      [`default`], [Colour-blind-friendly default palette],
      [`colorblind`], [Alias with the same palette as `default`],
      [`nord`], [Cool theme on the Nord palette],
      [`paper`], [Transparent background and fine lines for print],
      [`monochrome`], [Black and white; layers told apart by line style and marker],
      [`presentation`], [Larger labels, lines and markers for projection],
      [`dark`], [Dark background with matching foreground colours],
    )
  ] <tab-themes>

  The Python API and the `base` key of a configuration file accept all seven
  names#footnote[Passed directly to `--theme` on the command line, only the six themes other than the `colorblind` alias are accepted.].

  The default theme takes its colours from a colour-blind-friendly palette
  #citep(<thriveth2014>).

  `themes.COLORBLIND_CYCLE_HEX` and `themes.COLORBLIND_CYCLE_RGB` give the
  palette as hexadecimal and RGB values. Economics teaching leans heavily on
  diagrams, so meaning should never rest on colour alone, or visually
  impaired students cannot follow it #citep(<kugler1996>).
]

The figures below show the same Cobb-Douglas diagram in each built-in theme except `dark`, with the manual's line weights on a white page.

#example([```python
from dataclasses import replace

from utility_viz import Canvas, levels, solve, themes
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

# The theme's own colours and the manual's line weights on a white page
theme = replace(
    themes.default,
    background_color="#ffffff",
    ic_linewidth=2.6,
    budget_linewidth=2.6,
    eq_markersize=5.0,
)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$", theme=theme)
cvs.add_utility(model, levels=levels.around(eq.utility, n=3))
cvs.add_budget(2.0, 3.0, 30.0, fill=True)
cvs.add_equilibrium(eq)
cvs.save("theme_default.png")
```])

#fig("/figures/themes/default.svg", width: 56%, caption: [
  The `default` theme.
])

#example([```python
from dataclasses import replace

from utility_viz import Canvas, levels, solve, themes
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

# The theme's own colours and the manual's line weights on a white page
theme = replace(
    themes.nord,
    background_color="#ffffff",
    ic_linewidth=2.6,
    budget_linewidth=2.6,
    eq_markersize=5.0,
)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$", theme=theme)
cvs.add_utility(model, levels=levels.around(eq.utility, n=3))
cvs.add_budget(2.0, 3.0, 30.0, fill=True)
cvs.add_equilibrium(eq)
cvs.save("theme_nord.png")
```])

#fig("/figures/themes/nord.svg", width: 56%, caption: [
  The `nord` theme.
])

#example([```python
from dataclasses import replace

from utility_viz import Canvas, levels, solve, themes
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

# The theme's own colours and the manual's line weights on a white page
theme = replace(
    themes.paper,
    background_color="#ffffff",
    ic_linewidth=2.6,
    budget_linewidth=2.6,
    eq_markersize=5.0,
)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$", theme=theme)
cvs.add_utility(model, levels=levels.around(eq.utility, n=3))
cvs.add_budget(2.0, 3.0, 30.0, fill=True)
cvs.add_equilibrium(eq)
cvs.save("theme_paper.png")
```])

#fig("/figures/themes/paper.svg", width: 56%, caption: [
  The `paper` theme.
])

#example([```python
from dataclasses import replace

from utility_viz import Canvas, levels, solve, themes
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

# The theme's own colours and the manual's line weights on a white page
theme = replace(
    themes.monochrome,
    background_color="#ffffff",
    ic_linewidth=2.6,
    budget_linewidth=2.6,
    eq_markersize=5.0,
)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$", theme=theme)
cvs.add_utility(model, levels=levels.around(eq.utility, n=3))
cvs.add_budget(2.0, 3.0, 30.0, fill=True)
cvs.add_equilibrium(eq)
cvs.save("theme_monochrome.png")
```])

#fig("/figures/themes/monochrome.svg", width: 56%, caption: [
  The `monochrome` theme.
])

#example([```python
from dataclasses import replace

from utility_viz import Canvas, levels, solve, themes
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

# The theme's own colours and the manual's line weights on a white page
theme = replace(
    themes.presentation,
    background_color="#ffffff",
    ic_linewidth=2.6,
    budget_linewidth=2.6,
    eq_markersize=5.0,
)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$", theme=theme)
cvs.add_utility(model, levels=levels.around(eq.utility, n=3))
cvs.add_budget(2.0, 3.0, 30.0, fill=True)
cvs.add_equilibrium(eq)
cvs.save("theme_presentation.png")
```])

#fig("/figures/themes/presentation.svg", width: 56%, caption: [
  The `presentation` theme.
])

== Custom themes

#api(("Theme",), updated: "v1.12.0", syntax: [
  ```python
  from utility_viz import Theme

  my_theme = Theme(
      name="custom",
      background_color="white",
      label_scale=1.0,
      axis_color="#333333",
      label_color="#333333",
      ic_color="#2563eb",
      secondary_ic_color="#93c5fd",
      secondary_ic_opacity=0.45,
      budget_color="#dc2626",
      eq_color="#16a34a",
  )
  ```
])[
  A `Theme` holds default colours, widths and styles for diagram elements.
  Fields not given keep the class defaults; style arguments passed
  explicitly to a drawing method take precedence over the theme.
]

#param("name", type: "str")[Theme identifier.]
#param("background_color", type: "str | None", default: "None")[Background of the figure and axes; `None` keeps it transparent.]
#param("label_scale", type: "float", default: "1.0")[Multiplier for ordinary label sizes.]
#param("axis_color", type: "str", default: "\"#222222\"")[Axis colour.]
#param("label_color", type: "str", default: "\"#222222\"")[Colour of axis labels and origin text.]
#param("ic_color", type: "str", default: "\"#377EB8\"")[Indifference-curve colour.]
#param("ic_linewidth", type: "float", default: "1.8")[Indifference-curve width.]
#param("secondary_ic_color", type: "str | None", default: "None")[Colour of non-focal indifference curves; `None` uses `ic_color`.]
#param("secondary_ic_linewidth", type: "float", default: "1.0")[Width of non-focal indifference curves.]
#param("secondary_ic_opacity", type: "float", default: "0.45")[Opacity of non-focal indifference curves.]
#param("path_color", type: "str", default: "\"#4DAF4A\"")[Colour of PCC and ICC paths.]
#param("budget_color", type: "str", default: "\"#984EA3\"")[Budget-line colour.]
#param("budget_fill_alpha", type: "float", default: "0.08")[Opacity of the budget-set shading.]
#param("eq_color", type: "str", default: "\"#E41A1C\"")[Colour of the equilibrium and its drop lines.]
#param("eq_markersize", type: "float", default: "4.0")[Equilibrium marker size.]

`Theme` also holds colours and widths for rays, kinks, compensated budget
lines and price-effect arrows. `axis_stroke`, `drop_stroke`,
`projection_stroke`, `guide_stroke` and `box_stroke` hold the defaults of
other lines; markers, labels, fills and legends come from `Marker`, `Label`,
`Fill` and `Legend` properties (@sec-styles).

== Configuration files

#changed("1.10.0", label: "Config")[`Config`, `econ-viz.toml`, `econ-viz init` and `plot --config`]
#changed("1.11.0", label: "Config")[Configuration files accept every built-in theme and keep the same visual meaning across diagram types]
#changed("2.0.0b1", label: "Config")[Default file renamed `utility-viz.toml`; legacy `econ-viz.toml` still read with a warning]
#changed("2.0.0b1", label: "Config.discover")[New `Config.discover()`, falling back to the built-in defaults when no file exists]

#api(("Config.load", "Config.use", "Config.reset"), added: "v1.10.0", syntax: [
  ```python
  from utility_viz import Config

  Config.load("utility-viz.toml").use()
  # diagrams created from here on use these settings

  Config.reset()
  # back to the built-in defaults
  ```
])[
  `Config.load()` reads a TOML file and returns a `Config`; `use()` makes it
  the default for later diagrams, and `reset()` restores the built-in
  defaults.
]

=== Tutorial: one shared style

Figures in one set of lecture notes or one paper usually share their
colours and line styles. Rather than repeating the same arguments on every
`Canvas`, write the style once in an `utility-viz.toml` at the project root,
where both Python and the command line read it.

+ *Create a template.* Run the following in the project root. It writes a
  commented `utility-viz.toml` listing the names and fields each section
  accepts:

  ```bash
  utility-viz init
  ```

  Every setting in the template starts commented out; keep only what you
  change and delete the rest.

+ *Pick a base theme.* `base` names the built-in theme to start from
  (@tab-themes); everything else overrides it:

  ```toml
  base = "paper"
  ```

+ *Override colours and styles.* Write only the fields you change:

  ```toml
  [color]
  ic = "#1B4F72"
  eq = "#C0392B"

  [stroke.budget]
  width = 1.6
  style = "dashed"

  [marker.eq]
  size = 5

  [label.point]
  fontsize = 11
  position = "right"
  ```

  Section names map to theme properties: `ic` under `[color]` sets
  `ic_color`, and `[stroke.budget]` sets `theme.budget_stroke`. The fields
  inside a section are the arguments of `Stroke`, `Marker`, `Label`, `Fill`
  or `Legend` (@sec-styles). Fonts go under `[font]` as `text` and `math`.
  Fields you leave out keep the base theme's values.

+ *Use it from Python.* Load it once, before creating any diagram:

  ```python
  from utility_viz import Config

  Config.load().use()   # reads ./utility-viz.toml by default
  ```

  Every `Canvas`, `Figure`, `DemandDiagram` and `EdgeworthBox` created
  afterwards uses these settings; `Config.reset()` restores the defaults.

+ *Use it from the command line.* `utility-viz plot` reads
  `utility-viz.toml` from the current directory on its own; pass another
  file with `--config`:

  ```bash
  utility-viz plot --config utility-viz.toml --model cobb-douglas \
    --px 2 --py 3 --income 30 --output figure.png
  ```

Settings apply in this order, highest first: arguments passed to `Canvas`
or a drawing method, then the configuration file, then the base theme. For
example, `Canvas(theme=themes.default)` ignores the file's theme.

A mistake in the file makes `Config.load()` raise `InvalidParameterError`
with the valid names. For instance, writing `[stroke.budgt]` for
`[stroke.budget]` gives:

```text
utility-viz.toml: [stroke.budgt]: no such setting (choose: axis, box, budget, ...)
```


=== This manual's settings <sec-manual-toml>

Every example in this manual loads `manual.toml` first. It sets the look of the figures: grey curves, black axes and guides, black points and a white page. It leaves the font out so that it runs anywhere; the figures use TeX Gyre Pagella, and without that font you get the default typeface.

```toml
# Settings for every figure in this manual
# Grey curves and black axes and guides and black points on a white background
# Load them before drawing
#
#     Config.load("manual.toml").use()
#
# Each section maps to a Theme property as described in the Themes chapter

base = "default"

# The font is TeX Gyre Pagella and it is not set here so the file runs on any machine
# Add [font] text = "TeX Gyre Pagella" if the font is installed

[color]
background = "#ffffff"
axis = "#1a1a1a"
label = "#1a1a1a"
ic = "#8c8c8c"              # indifference curves
secondary_ic = "#b8b8b8"    # the curves beside a highlighted one
path = "#1a1a1a"            # price- and income-consumption paths
budget = "#222222"
eq = "#1a1a1a"              # equilibrium and other points
ray = "#8c8c8c"
kink = "#8c8c8c"
sub_effect = "#8c8c8c"
inc_effect = "#8c8c8c"
compensated_budget = "#1a1a1a"
subsistence = "#8c8c8c"
contract = "#8c8c8c"
core = "#1a1a1a"
price = "#8c8c8c"
walrasian = "#1a1a1a"

[stroke.axis]
width = 1.0
style = "solid"
arrow = "-|>"

[stroke.ic]
width = 2.6

[stroke.secondary_ic]
width = 1.8
opacity = 1.0

[stroke.path]
width = 1.4

[stroke.budget]
width = 2.6

[stroke.ray]
width = 0.9

[stroke.substitution]
width = 1.8

[stroke.income]
width = 1.8

[stroke.compensated_budget]
width = 1.0

[stroke.contract]
width = 2.6

[stroke.price]
width = 2.6

[stroke.drop]               # guides from a point to the axes
width = 0.8
style = "dashed"
color = "#1a1a1a"

[stroke.projection]
width = 0.8
style = "dashed"
color = "#1a1a1a"

[stroke.guide]
width = 0.8
style = "dashed"
color = "#1a1a1a"

[marker.eq]
size = 5

[marker.point]
size = 5

[label.point]               # the text beside a point such as x* at the optimum
fontsize = 14
position = "right"
offset = 10

[fill.budget]
opacity = 0.08
```

=== File lookup <sec-config-lookup>

#api(("Config.discover",), added: "v2.0.0b1", syntax: [
  #raw("Config.discover(")#oarg("path")#raw(", directory=None)")
])[
  Find and read a configuration file without failing when there is none.
]

`Config.load()`, `Config.discover()` and `utility-viz plot` resolve the
file in this order:

+ the path given explicitly (`Config.load("file.toml")` or `--config`),
  which must exist and is the only file read;
+ `utility-viz.toml` in the current directory (or `directory=`);
+ the legacy `econ-viz.toml`, with a deprecation warning;
+ the built-in defaults.

When both files exist, `utility-viz.toml` wins and the legacy one is ignored
with a warning. The two functions differ only when no file is found:
`Config.load()` raises `InvalidParameterError` ("config file not found"),
as in 1.x, while `Config.discover()` returns the built-in defaults.
`utility-viz init --migrate` turns a legacy file into `utility-viz.toml`
(@sec-cli-init).


#import "/template/manual.typ": *

= Canvas <sec-canvas>

`Canvas` builds on a #pkg("matplotlib") `Figure` and `Axes` and provides
layers for indifference curves, budget lines, equilibria and more.

== Constructor

#changed("1.7.0", label: "Canvas")[Per-figure text and math fonts without changing #pkg("matplotlib")'s global configuration]
#changed("1.8.0", label: "Canvas")[`Axis`, `Marker`, `Label` and `Fill` style objects]
#changed("1.9.0", label: "Canvas")[Axes, origin, titles and other text elements accept a `Label`]
#changed("1.11.0", label: "Canvas")[Backgrounds, labels, lines and markers all take their defaults from the theme]
#changed("1.12.0", label: "Canvas.add_utility")[Focal utility level, secondary curve style and ordinal labels]

#api(("Canvas",), updated: "v1.7.0", syntax: [
  ```python
  from utility_viz import ArrowStyle, Canvas, Stroke, themes

  cvs = Canvas(
      x_max=20,
      y_max=15,
      x_label="x",
      y_label="y",
      title=r"Cobb-Douglas $x^{0.5} y^{0.5}$",
      dpi=300,
      x_label_pos="right",   # "top", "right" or "bottom"
      y_label_pos="top",     # "left", "top" or "right"
      font="DejaVu Sans",
      math_font="stix",
      axis_stroke=Stroke(width=1.0, arrow=ArrowStyle.TRIANGLE),
      theme=themes.default,
  )
  ```
])[
  Create a canvas and set its axis ranges, axis labels, fonts, line styles and
  theme. Visual settings not passed explicitly come from the active `Config`
  and `Theme`.
]

#param("x_max", type: "float", default: "10")[Upper bound of the horizontal axis.]
#param("y_max", type: "float", default: "10")[Upper bound of the vertical axis.]
#param("x_label", type: "str", default: "\"X\"")[Label at the tip of the horizontal axis.]
#param("y_label", type: "str", default: "\"Y\"")[Label at the tip of the vertical axis.]
#param("title", type: "str | None", default: "None")[Figure title.]
#param("dpi", type: "int", default: "300")[Raster export resolution, clamped to 1--1200.]
#param("x_label_pos", type: "str", default: "\"right\"")[
  Position of the horizontal label relative to the arrow; a `LabelPosition`
  is also accepted (@tab-x-label-pos).
]
#tbl(caption: [`x_label_pos` values])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Value], [Position]),
    [`"top"`], [Above the arrow],
    [`"right"`], [Right of the arrow],
    [`"bottom"`], [Below the arrow],
  )
] <tab-x-label-pos>
#param("y_label_pos", type: "str", default: "\"top\"")[
  Position of the vertical label relative to the arrow (@tab-y-label-pos).
]
#tbl(caption: [`y_label_pos` values])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Value], [Position]),
    [`"left"`], [Left of the arrow],
    [`"top"`], [Above the arrow],
    [`"right"`], [Right of the arrow],
  )
] <tab-y-label-pos>
#param("font", type: "str | list", default: "None")[
  Font for all text, or a list of candidate fonts. It applies to this canvas
  only and leaves #pkg("matplotlib")'s global configuration alone.
]
#param("math_font", type: "str", default: "None")[
  #pkg("matplotlib") math font set: `dejavusans`, `dejavuserif`, `cm`,
  `stix`, `stixsans` and so on.
]
#param("axis_stroke", type: "Stroke", default: "theme")[
  Width, style, colour and arrowhead of both axes (@sec-styles).
]
#param("x_axis_stroke", type: "Stroke", default: "None")[Override for the horizontal axis.]
#param("y_axis_stroke", type: "Stroke", default: "None")[Override for the vertical axis.]
#param("theme", type: "Theme", default: "themes.default")[Colour and style theme (@sec-themes).]

== Drawing methods

The `add_*` methods add a layer to the canvas and return the same `Canvas`,
so calls can be chained (@sec-chaining).

#api(("add_utility",), syntax: [
  ```python
  cvs.add_utility(
      func,
      levels=3,          # count or list of levels
      color=None,        # default: theme.ic_color
      linewidth=None,    # default: theme.ic_linewidth
      show_rays=False,
      show_kinks=False,
      kink_radius=1.0,
      show_bliss=True,   # star at the bliss point (Satiation)
      show_ic_labels=False,
      stroke=None,
      ray_stroke=None,
      ic_label=None,
      highlight_level=None,
      secondary_stroke=None,
      label_style="numeric",
  )
  ```
])[
  Draw indifference curves for a utility model.
]

#param("levels", type: "int | list", default: "3")[A number of curves, or a list of utility values such as `levels.around(eq.utility, n=5)` to place them around the optimum.]
#param("highlight_level", type: "float | None", default: "None")[Focal utility level. The closest curve is drawn in the main style.]
#param("secondary_stroke", type: "Stroke | None", default: "None")[Style of the other curves; defaults to `theme.secondary_ic_stroke`.]
#param("show_ic_labels", type: "bool", default: "False")[Label the curves. Labels follow the curve's tangent and stay inside the plotting area (@fig-ic-hierarchy).]
#param("label_style", type: "str", default: "\"numeric\"")[`"numeric"` shows utility values; `"ordinal"` numbers the curves $u_1, u_2, dots$ in increasing utility.]

```python
lvls = levels.around(eq.utility, n=5)
cvs.add_utility(
    model,
    levels=lvls,
    highlight_level=eq.utility,
    show_ic_labels=True,
    label_style="ordinal",
)
```

#fig("/figures/canvas/add_utility.svg", width: 42%, caption: [
  Three indifference curves.
]) <fig-add-utility>

#fig("/figures/canvas/ic_hierarchy.svg", width: 82%, caption: [
  Focal and secondary curves.
]) <fig-ic-hierarchy>

#api(("add_budget",), syntax: [
  ```python
  cvs.add_budget(
      px, py, income,
      color=None,
      linewidth=None,
      linestyle="-",
      label=None,        # legend label (LaTeX)
      fill=False,        # shade feasible set
      fill_alpha=None,   # default: theme.budget_fill_alpha
      stroke=None,
  )
  ```
])[
  Draw the budget line $p_x x + p_y y = I$.
]

#param("fill", type: "bool | Fill", default: "False")[`True` shades the feasible set with the theme's fill; pass a `Fill` to set its colour and opacity.]
#param("stroke", type: "Stroke | None", default: "None")[Colour, width, style and opacity of the line in one object; takes precedence over `color`, `linewidth` and `linestyle` (@sec-styles).]
#param("label", type: "str | None", default: "None")[Legend text, shown once `show_legend()` is called.]

#fig("/figures/canvas/add_budget.svg", width: 42%, caption: [
  Budget line and shading.
])

#api(("add_equilibrium",), syntax: [
  ```python
  cvs.add_equilibrium(
      eq,                # result of solve()
      color=None,
      markersize=None,
      label="x^*",
      drop_dashes=True,  # dashed lines to axes
      show_ray=False,    # expansion path
      drop_stroke=None,
      ray_stroke=None,
      marker=None,
  )
  ```
])[
  Mark the optimal bundle returned by `solve()`.
]

#param("drop_dashes", type: "bool", default: "True")[Drop lines to both axes.]
#param("show_ray", type: "bool", default: "False")[Draw the expansion path through the origin and the optimum.]
#param("marker", type: "Marker | None", default: "None")[Style of the equilibrium marker (@sec-styles).]

#fig("/figures/canvas/add_equilibrium.svg", width: 42%, caption: [
  Equilibrium and drop lines.
])

#api(("add_ray",), syntax: [
  ```python
  cvs.add_ray(
      slope,             # dy/dx
      color=None,
      linewidth=None,
      stroke=None,
  )
  ```
])[
  Draw a ray from the origin with slope `slope` ($dif y slash dif x$), for an
  expansion path or a fixed consumption ratio.
]

#fig("/figures/canvas/add_ray.svg", width: 42%, caption: [
  Expansion-path ray.
])

#api(("add_point",), syntax: [
  ```python
  cvs.add_point(
      x, y,
      label=None,
      color=None,
      markersize=None,
      offset=None,       # label offset (pt)
      marker=None,
  )
  ```
])[
  Mark any point, such as a bundle to compare with the optimum.
]

#param("label", type: "str | Label | None", default: "None")[Marker text, as a string or a `Label`.]
#param("offset", type: "tuple | None", default: "None")[Offset of the text from the point, in points.]
#param("marker", type: "Marker | None", default: "None")[Style of the point marker.]

#fig("/figures/canvas/add_point.svg", width: 42%, caption: [
  A labelled point $A$.
])

#api(("show", "save"), syntax: [
  ```python
  cvs.show()               # interactive window
  cvs.save("figure.png")   # .png / .pdf / .svg / .tex
  ```
])[
  `show()` opens an interactive window. `save()` writes the file in the
  format given by its extension (@sec-export) and releases the
  #pkg("matplotlib") figure, so call it last.
]

#fig("/figures/canvas/show_save.svg", width: 42%, caption: [
  The complete canvas.
]) <fig-show-save>

== Styles <sec-styles>

#changed("1.7.0", label: "Canvas")[Independent axis-label positions, line styles and arrowhead styles for `Canvas` and `Figure`]
#changed("1.7.0", label: "Stroke")[One `Stroke` controls line width, style, colour and arrowheads across canvases, figures, demand diagrams and Edgeworth boxes]
#changed("1.8.0", label: "Stroke")[Every line style is a `Stroke`; the individual style arguments remain as shorthands]
#changed("1.9.0", label: "Stroke")[New `opacity` field]
#changed("1.6.0", label: "Canvas")[Default indifference-curve line width reduced from `2.0` to `1.8`]
#changed("1.0.2", label: "Canvas")[Math axis labels are no longer double-wrapped]
#changed("1.3.1", label: "Canvas")[Canvas rendering split into `canvas.renderers` and `canvas.primitives`]

`LineStyle` defines line patterns, `ArrowStyle` arrowheads, and `Stroke`
bundles width, pattern, colour and arrowhead for axes, budget lines, paths
and drop lines.

=== Line styles

#api(("LineStyle",), added: "v1.7.0", syntax: [
  `LineStyle.SOLID`, `DASHED`, `DOTTED`, `DASHDOT`
])[
  Solid, dashed, dotted and dash-dot lines (@fig-line-styles). Axes accept
  the enum or the matching string; other lines use `Stroke(style=...)`.
]

```python
import matplotlib.pyplot as plt

from utility_viz import Canvas, LineStyle

styles = [
    LineStyle.SOLID,
    LineStyle.DASHED,
    LineStyle.DOTTED,
    LineStyle.DASHDOT,
]

fig, axes = plt.subplots(1, 4, figsize=(8.5, 2.2))
for ax, style in zip(axes, styles):
    Canvas(
        title=style.value,
        x_line_style=style,
        y_line_style=style,
        fig=fig,
        ax=ax,
    )

# Axis labels sit outside the arrowheads; give four panels more room.
fig.subplots_adjust(wspace=0.62)
fig.savefig("line_styles.png", dpi=160, transparent=True)
```

#fig("/figures/canvas/line_styles.svg", width: 94%, caption: [
  The four line styles.
]) <fig-line-styles>

=== Arrow styles

#api(("ArrowStyle",), added: "v1.7.0", syntax: [
  `ArrowStyle.SIMPLE`, `TRIANGLE`, `FANCY`, `WEDGE`
])[
  Four arrowhead styles (@fig-arrow-styles). Axes use `x_arrow_style` and
  `y_arrow_style`; other lines use `Stroke(arrow=...)`.
]

#fig("/figures/canvas/arrow_styles.svg", width: 94%, caption: [
  The four arrow styles.
]) <fig-arrow-styles>

=== Stroke

#api(("Stroke",), added: "v1.7.0", updated: "v1.9.0", syntax: [
  #raw("Stroke(width=")#meta("float")#raw(", style=")#meta("LineStyle")#raw(", color=")#meta("str")#raw(
    ", arrow=",
  )#meta("ArrowStyle")#raw(", opacity=")#meta("float")#raw(")")
])[
  Width, pattern, colour, arrowhead and opacity of one line. Fields left
  unset inherit from the active theme. `opacity` ranges from 0 to 1.
]

=== Axis

#api(("Axis",), added: "v1.8.0", syntax: [
  `Axis(label=None, label_position=None, stroke=None)`
])[
  Label, label position and line of one axis in one object. `Canvas`,
  `Figure`, `DemandDiagram` and `EdgeworthBox` all accept `x_axis` and
  `y_axis`. When shorthand arguments are passed as well, fields set in the
  `Axis` win.

  ```python
  from utility_viz import Axis, Canvas, Label, Stroke

  cvs = Canvas(
      x_axis=Axis(
          label=Label(text="x_1", fontsize=16),
          label_position="bottom",
          stroke=Stroke(width=1.2),
      ),
      y_axis=Axis(label="x_2"),
  )
  ```
]

=== Marker and Label

#api(("Marker",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Marker(color=None, size=None, shape=None, opacity=None)`
])[
  Colour, size, shape and opacity of a point marker. `shape` takes a
  #pkg("matplotlib") marker string such as `"o"`, `"s"`, `"^"`, `"D"` or
  `"*"`.
]

#api(("Label",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Label(text=None, position=None, offset=None, color=None, fontsize=None, visible=None, opacity=None)`
])[
  Text, position, offset, colour, size, visibility and opacity of a label.
  The position is a side or a corner; `Label(visible=False)` hides the text.

  ```python
  from utility_viz import Label, Marker

  cvs.add_equilibrium(
      eq,
      marker=Marker(shape="s", size=8),
      label=Label(position="bottom-left", offset=8),
  )
  cvs.add_point(
      12, 2,
      marker=Marker(color="black", shape="D"),
      label=Label(text="A", position="left", fontsize=14),
  )
  ```
]

=== Fill

#api(("Fill",), added: "v1.8.0", updated: "v1.9.0", syntax: [
  `Fill(color=None, opacity=None)`
])[
  Colour and opacity of a shaded area. `alpha` is a compatible shorthand for
  `opacity`; one call must not pass different values for both.

  ```python
  from utility_viz import Fill

  cvs.add_budget(
      2, 3, 30,
      fill=Fill(color="lightgrey", opacity=0.4),
  )
  ```
]

== Method chaining <sec-chaining>

The `add_*` methods can be chained, ending with `save()`:

```python
Canvas(x_max=20, y_max=15) \
    .add_utility(model, levels=lvls) \
    .add_budget(2.0, 3.0, 30.0, fill=True) \
    .add_equilibrium(eq, show_ray=True) \
    .save("figure.png")
```

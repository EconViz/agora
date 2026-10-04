#import "/template/manual.typ": *

= Figures <sec-figures>

#changed("0.10.0", label: "MarketFigure")[Figures are square (6 × 6 in at 150 dpi) on an opaque white background; straight curves stop at 92% of the price axis]
#changed("0.10.0", label: "MarketFigure")[Curves are named beside their visible end instead of in a legend]
#changed("0.10.0", label: "MarketFigure")[Axis titles default to $p$ and $Q$, set in italic math past the arrow tips; titles use normal weight]
#changed("0.10.0", label: "MarketFigure")[Equilibrium and policy labels are placed by #pkg("mosaickit") beside their point; crowded quantities are marked on the quantity axis]
#changed("0.10.0", label: "MarketFigure.finalize")[No legend by default; `finalize(legend=True)` adds one]

Every figure in this manual is a `MarketFigure`, or a #pkg("mosaickit")
canvas built by a function such as `ppf_canvas()`. Both follow one visual
language: a square plot, arrowed axes with no ticks or grid, curves named at
their ends, areas named inside them, values marked on the axes, and labels
placed so they cover no line, point, area or other text.

== MarketFigure

#api(("MarketFigure",), syntax: [
  ```python
  from principle_viz import MarketFigure

  fig = MarketFigure(
      x_max=20.0,
      y_max=20.0,
      x_label="Q",
      y_label="p",
      title="Market Diagram",
      theme=None,       # PlotTheme
      palette=None,     # "default", "colorblind", "nord", "monochrome"
      labels=None,      # {layer id: Label}
      visibility=None,  # {layer id: bool}
  )
  ```
])[
  A market diagram on a #pkg("mosaickit") canvas, with axes from 0 to
  `x_max` and `y_max`. Axis titles are LaTeX math unless they are words; an
  empty `title` draws none.
]

#param("theme, palette")[Colours and line widths (@sec-palettes). `palette` is a shorthand for `PlotTheme.from_palette(palette)`; `theme` wins when both are given.]
#param("labels, visibility")[Overrides for built-in labels and layers, by layer id (@sec-labels).]

#api(("MarketFigure.add_curves", "MarketFigure.add_equilibrium"), syntax: [
  #raw("add_curves(")#meta("demand")#raw(", ")#meta("supply")#raw(", q_max, demand_label=\"$D$\", supply_label=\"$S$\")") \
  #raw("add_equilibrium(")#meta("result")#raw(", label=\"$e^*$\", color=None)")
])[
  Draw demand and supply from $Q = 0$ to `q_max`, each named at its end, and
  mark an equilibrium with a filled point and its label.
]

Each topic adds its own methods, described in its chapter (@tab-figure-methods).

#tbl(caption: [Topic methods of `MarketFigure`])[
  #booktabs(
    columns: (auto, auto),
    header: ([Method], [Section]),
    [`add_comparative_statics`], [#ref(<sec-shifts>)],
    [`add_discrete_curves`, `add_discrete_equilibrium`], [#ref(<sec-discrete>)],
    [`add_welfare`, `add_welfare_transition`], [#ref(<sec-welfare>)],
    [`add_tax_transform`, `add_tax_comparison`, `add_subsidy_comparison`], [#ref(<sec-taxes>)],
    [`add_price_control`], [#ref(<sec-controls>)],
    [`add_trade`], [#ref(<sec-trade>)],
    [`add_externality`, `add_common_resource`], [#ref(<sec-failures>)],
    [`add_minimum_wage`, `add_loanable_funds`], [#ref(<sec-factor>)],
  )
] <tab-figure-methods>

#api(("MarketFigure.finalize", "MarketFigure.save"), syntax: [
  #raw("finalize(legend=False)") \
  #raw("save(")#meta("path")#raw(", dpi=150)")
])[
  `finalize()` hides guide lines that would cut a shaded welfare region in
  two (the value stays marked on its axis) and, only with `legend=True`,
  adds a legend. `save()` writes PNG, SVG or PDF according to the extension
  and creates missing directories. `close()` is a no-op kept for
  compatibility.
]

#api(("MarketFigure.add_layer", "MarketFigure.add_layers"), syntax: [
  #raw("add_layer(")#meta("layer")#raw(")") \
  #raw("add_layers(")#meta("layers")#raw(")")
])[
  Add any #pkg("mosaickit") layer, for annotations the topic methods do not
  provide. An axis mark replaces an earlier mark at the same value. The
  finished scene is available as `fig.scene`.
]

#api(("MarketFigure.add_metrics",), syntax: [
  #raw("add_metrics(")#meta("values")#raw(", *, title=None, location=\"upper right\")")
])[
  A text box of name--value pairs, for notebooks and debugging. Teaching
  figures leave it out: the numbers belong in the text.
]

== Labels and layers <sec-labels>

#changed("0.10.1", label: "Label")[Every built-in label can be renamed, hidden or moved: `Label`, `labels=`, `configure_label()` and `label_ids`]
#changed("0.10.1", label: "MarketFigure.configure_layer")[Every layer can be hidden or shown: `visibility=`, `configure_layer()`, `hide()`, `show()` and `layer_ids`]

Every line, point, area and piece of text in a figure is a layer with a
stable id, such as `market.demand`, `market.demand.label` or
`market.welfare.dwl`. The ids follow the structure of the figure:
`axes.*` for the axes, `market.<part>` for each element, and a `.label`
suffix for the text that names it. `fig.layer_ids` lists every layer;
`fig.label_ids` lists the configurable text (labels, axis marks and
braces).

#api(("Label",), added: "v0.10.1", syntax: [
  #raw("Label(text=None, visible=None, offset=None)")
])[
  An override for one built-in label. Fields left as `None` keep the
  package's default. An `offset` in points opts the label out of automatic
  placement and moves it by exactly that much.
]

#api(("MarketFigure.configure_label", "MarketFigure.configure_layer"), added: "v0.10.1", syntax: [
  #raw("configure_label(")#meta("layer id")#raw(", label=None, *, text=None, visible=None, offset=None)") \
  #raw("configure_layer(")#meta("layer id")#raw(", *, visible)")
])[
  Rename, hide or move one label (the id may omit its final `.label`), or
  show or hide any layer. `hide(*ids)` and `show(*ids)` toggle several at
  once. Each returns the figure.
]

The same overrides can be passed when the figure is created, as `labels=`
and `visibility=` mappings; they then apply to layers added later as well.
Aggregation figures and the canvas functions (`ppf_canvas()`,
`public_good_canvas()`, ...) accept the same two arguments.

```python
from principle_viz import Label, MarketFigure

fig = MarketFigure(
    x_max=12, y_max=12,
    labels={
        "market.demand.label": Label(text="Demand"),
        "market.supply.label": Label(text="Supply"),
    },
)
fig.add_curves(demand, supply, q_max=10)
fig.add_equilibrium(eq)
fig.configure_label("market.equilibrium", text="$E$")
fig.hide("axes.origin.label")
fig.finalize()
```

#fig("/figures/figures/labels.svg", width: 46%, caption: [
  Renamed curves and equilibrium; origin label hidden.
])

== Palettes and themes <sec-palettes>

#changed("0.1.0", label: "ColorModel")[`default`, `colorblind`, `nord` and `monochrome` colour models]
#changed("0.10.0", label: "ColorModel")[The `default` palette takes its hues from #pkg("mosaickit"): demand blue, supply red, deadweight loss teal]
#changed("0.10.0", label: "PlotTheme")[Supply and demand curves are 3.5 pt wide, axes 1.0 pt, equilibrium points 6.5 pt across]

A `ColorModel` assigns a colour to each economic role; a `PlotTheme` adds line
widths and axis options and compiles both into a #pkg("mosaickit") theme.

#api(("ColorModel",), syntax: [
  #raw("ColorModel(name, axis_color, label_color, demand_color, supply_color, ...)")
])[
  Named colour roles: `axis_color`, `label_color`, `demand_color`,
  `supply_color`, `baseline_color`, `shifted_color`, `tax_color`,
  `control_color`, `cs_color`, `ps_color`, `tax_revenue_color`, `dwl_color`
  and `arrow_color`. Each is `"#hex"` or a #pkg("mosaickit") palette name
  such as `"blue"`.
]

#tbl(caption: [Built-in colour models])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Name], [Character]),
    [`default`], [#pkg("mosaickit") hues: demand blue, supply red, deadweight loss teal; surpluses in the curve hues at 15% opacity],
    [`colorblind`], [A colour-blind-friendly qualitative palette],
    [`nord`], [The Nord palette],
    [`monochrome`], [Black, white and greys, for print],
  )
] <tab-palettes>

`list_color_models()` returns the names and `get_color_model(name)` the
model; the four are also exported as `DEFAULT_COLOR_MODEL`,
`COLORBLIND_COLOR_MODEL`, `NORD_COLOR_MODEL` and `MONOCHROME_COLOR_MODEL`.

#api(("PlotTheme",), syntax: [
  #raw("PlotTheme(color_model=..., demand_linewidth=3.5, supply_linewidth=3.5, ...)") \
  #raw("PlotTheme.from_palette(")#meta("name")#raw(", **options)")
])[
  A colour model with line widths (`demand_linewidth`,
  `supply_linewidth`, `shifted_linewidth`, `tax_linewidth`,
  `arrow_linewidth`, `dashed_linewidth`), `equilibrium_marker_size`, and
  the switches `show_grid`, `show_ticks`, `show_axis_arrows` and
  `show_origin_label`. `from_palette()` starts from a built-in colour model
  and sets any of these fields.
]

```python
fig = MarketFigure(x_max=12, y_max=12, palette="monochrome")
```

#fig("/figures/figures/monochrome.svg", width: 46%, caption: [
  The `monochrome` palette.
])

== Canvases

#api(("Canvas",))[
  The #pkg("mosaickit") `Canvas` with the same `labels=`, `visibility=`,
  `configure_label()`, `configure_layer()`, `hide()`, `show()`,
  `layer_ids` and `label_ids` as `MarketFigure`. The canvas functions of
  the PPF, public-good and revenue chapters return it; save it with
  `save()`, or combine several with `mosaickit.CanvasGrid`.
]

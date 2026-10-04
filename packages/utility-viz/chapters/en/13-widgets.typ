#import "/template/manual.typ": *

= Interactive widgets <sec-widgets>

#changed("1.4.0", label: "WidgetViewer")[`WidgetViewer` provides slider controls in Jupyter notebooks]
#changed("1.4.0", label: "WidgetViewer")[Numeric input boxes for notebook widgets]
#changed("2.0.0b1", label: "WidgetViewer")[#modify[Moved to `utility_viz.core.interactive`]]

`WidgetViewer` provides sliders and numeric input boxes in Jupyter and
redraws the figure when a parameter changes. It needs the `interactive`
extra (@sec-extras). #modify[Import it from `utility_viz.core.interactive`;
it was `econ_viz.interactive` in 1.x.]

#api(("WidgetViewer",), added: "v1.4.0", syntax: [
  #raw("WidgetViewer(")#meta("draw")#raw(", ")#meta("name")#raw("=(")#meta("min")#raw(", ")#meta("max")#raw(", ")#meta("step")#raw("), ...).show()")
])[
  Pass a drawing function `draw` and give each parameter's range as
  `(min, max, step)`. Each parameter gets a linked `FloatSlider` and
  `FloatText`; when a value changes, `draw` is called again and its figure
  replaces the old one in the cell.
]

`draw` follows the same contract as for `Animator` (@sec-animation), but may
take several parameters. Starting from the price-sweep example there, let
`draw()` also take `alpha`:

#example(modify[```python
from utility_viz.core.interactive import WidgetViewer

def draw(alpha: float, px: float) -> Canvas:
    model = CobbDouglas(alpha=alpha, beta=1.0 - alpha)
    ...  # rest as in the animation example

WidgetViewer(
    draw,
    alpha=(0.2, 0.8, 0.05),
    px=(1.0, 6.0, 0.25),
).show()
```])

== Notebook setup

In a fresh Jupyter or Colab runtime, run the steps in this order#footnote[The Playground notebook in the #modify[#pkg("utility-viz")] repository, `notebook/econ-viz Playground.ipynb`#modify[ (which keeps its historical name)], follows this flow; open it in Jupyter, VS Code or Colab. It does not reinstall when #modify[#pkg("utility-viz")] is already present.]:

+ Run the install cell.
+ If the install upgraded #pkg("ipywidgets"), #pkg("traitlets") or
  #pkg("IPython"), restart the runtime.
+ After the restart, continue from the import cell without reinstalling.

== Widgets or GIFs

Use `WidgetViewer` when users should adjust the parameters themselves; use
`Animator` to export a GIF when a fixed sweep should play in slides or on a
web page (@sec-animation).

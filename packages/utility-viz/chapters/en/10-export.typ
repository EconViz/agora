#import "/template/manual.typ": *

= Export <sec-export>

== Output formats

#changed("1.5.0", label: "Canvas.save")[Pure TikZ export backend; `Canvas.save()` and `Figure.save()` accept `.tex`]
#changed("1.6.0", label: "Canvas.save")[TikZ axis regression tests no longer depend on colour indices]
#changed("1.3.1", label: "Canvas.save")[`Canvas`, `Figure` and `EdgeworthBox` share one figure exporter (`io.exporter`)]

#api(("Canvas.save",), syntax: [#raw("cvs.save(")#meta("path")#raw(")")])[
  Write the figure to `path`; the format follows the extension. `Figure`,
  `DemandDiagram` and `EdgeworthBox` have the same method.
]

- PNG: raster, at the canvas `dpi` (default 300).
- PDF, SVG: vector output that stays sharp when printed or scaled.
- TeX: TikZ code (`.tex`) for inclusion in #LaTeX documents; adjust it with
  the keyword arguments `tikz_scale` and `tikz_standalone`.

```python
cvs.save("figure.png")   # PNG, canvas DPI (default 300)
cvs.save("figure.pdf")   # PDF (vector)
cvs.save("figure.svg")   # SVG (vector)
cvs.save("figure.tex")   # TikZ
```

The `dpi` parameter of `Canvas` only affects raster output; lower it for
faster previews:

```python
cvs = Canvas(x_max=20, y_max=15, dpi=150)   # lower DPI, faster preview
```

== Animated GIFs

#changed("1.4.0", label: "Animator.save")[Frames are composited onto an opaque background before export, for more reliable GIFs]

Export a GIF with `Animator.save()`; @sec-animation has complete examples.

#modify[```python
from utility_viz.core.animation import Animator

Animator(draw_frame, frames=frames).save("animation.gif", fps=12, dpi=120)
```]

== Interactive window

`cvs.show()` opens a live #pkg("matplotlib") window instead of saving. In
the CLI, omitting `--output` has the same effect (@sec-cli-plot):

#modify[```bash
utility-viz plot --model cobb-douglas --px 2 --py 3 --income 30
```]

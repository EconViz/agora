from mosaickit import CanvasGrid

from utility_viz import ArrowStyle, Canvas, Config

Config.load("econ-viz.toml").use()  # figure settings

styles = [ArrowStyle.SIMPLE, ArrowStyle.TRIANGLE, ArrowStyle.FANCY, ArrowStyle.WEDGE]
panels = [
    Canvas(title=style.value, x_label="$x$", y_label="$y$", x_label_pos="bottom", x_arrow_style=style, y_arrow_style=style)
    for style in styles
]
for panel in panels:
    panel.spec = panel.spec.replace(width=2.2, height=2.0)  # small panels
CanvasGrid([panels]).save("arrow_styles.png")

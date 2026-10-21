from mosaickit import CanvasGrid

from utility_viz import Canvas, Config, LineStyle

Config.load("manual.toml").use()  # figure settings

styles = [LineStyle.SOLID, LineStyle.DASHED, LineStyle.DOTTED, LineStyle.DASHDOT]
panels = [
    Canvas(title=style.value, x_label="$x$", y_label="$y$", x_label_pos="bottom", x_line_style=style, y_line_style=style)
    for style in styles
]
for panel in panels:
    panel.spec = panel.spec.replace(width=2.2, height=2.0)  # small panels
CanvasGrid([panels]).save("line_styles.png")

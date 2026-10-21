from mosaickit import CanvasGrid

from utility_viz import Canvas, Config, LineStyle

Config.load("manual.toml").use()  # 图形设置

styles = [LineStyle.SOLID, LineStyle.DASHED, LineStyle.DOTTED, LineStyle.DASHDOT]
titles = ["实线", "虚线", "点线", "点划线"]
panels = [
    Canvas(title=title, x_label="$x$", y_label="$y$", x_label_pos="bottom", x_line_style=style, y_line_style=style)
    for style, title in zip(styles, titles)
]
for panel in panels:
    panel.spec = panel.spec.replace(width=2.2, height=2.0)  # 小画布
CanvasGrid([panels]).save("line_styles.png")

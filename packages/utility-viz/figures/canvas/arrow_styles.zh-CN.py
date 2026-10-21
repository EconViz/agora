from mosaickit import CanvasGrid

from utility_viz import ArrowStyle, Canvas, Config

Config.load("manual.toml").use()  # 图形设置

styles = [ArrowStyle.SIMPLE, ArrowStyle.TRIANGLE, ArrowStyle.FANCY, ArrowStyle.WEDGE]
titles = ["简单", "三角形", "花式", "楔形"]
panels = [
    Canvas(title=title, x_label="$x$", y_label="$y$", x_label_pos="bottom", x_arrow_style=style, y_arrow_style=style)
    for style, title in zip(styles, titles)
]
for panel in panels:
    panel.spec = panel.spec.replace(width=2.2, height=2.0)  # 小画布
CanvasGrid([panels]).save("arrow_styles.png")

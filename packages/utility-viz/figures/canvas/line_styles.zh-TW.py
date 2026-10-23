from mosaickit import CanvasGrid

from utility_viz import Canvas, Config, LineStyle

Config.load("econ-viz.toml").use()  # 載入圖形設定

styles = [LineStyle.SOLID, LineStyle.DASHED, LineStyle.DOTTED, LineStyle.DASHDOT]
titles = ["實線", "虛線", "點線", "點劃線"]
panels = [
    Canvas(title=title, x_label="$x$", y_label="$y$", x_label_pos="bottom", x_line_style=style, y_line_style=style)
    for style, title in zip(styles, titles)
]
for panel in panels:
    panel.spec = panel.spec.replace(width=2.2, height=2.0)  # 小畫布
CanvasGrid([panels]).save("line_styles.png")

import matplotlib.pyplot as plt

from utility_viz import Canvas, Config, LineStyle

Config.load("manual.toml").use()  # 圖形設定

styles = [LineStyle.SOLID, LineStyle.DASHED, LineStyle.DOTTED, LineStyle.DASHDOT]
titles = ["實線", "虛線", "點線", "點劃線"]

fig, axes = plt.subplots(1, 4, figsize=(7.6, 2.0))
for ax, style, title in zip(axes, styles, titles):
    Canvas(
        title=title,
        x_label="$x$",
        y_label="$y$",
        x_line_style=style,
        y_line_style=style,
        font="PingFang TC",  # 使用有中文字形的字體
        fig=fig,
        ax=ax,
    )

# 預留軸標籤的空間
fig.subplots_adjust(wspace=0.62)
fig.savefig("line_styles.png", dpi=160)

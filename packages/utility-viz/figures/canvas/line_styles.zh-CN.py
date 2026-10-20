import matplotlib.pyplot as plt

from utility_viz import Canvas, Config, LineStyle

Config.load("manual.toml").use()  # 图形设置

styles = [LineStyle.SOLID, LineStyle.DASHED, LineStyle.DOTTED, LineStyle.DASHDOT]
titles = ["实线", "虚线", "点线", "点划线"]

fig, axes = plt.subplots(1, 4, figsize=(7.6, 2.0))
for ax, style, title in zip(axes, styles, titles):
    Canvas(
        title=title,
        x_label="$x$",
        y_label="$y$",
        x_line_style=style,
        y_line_style=style,
        font="Noto Serif SC",  # 使用有中文字形的字体
        fig=fig,
        ax=ax,
    )

# 预留轴标签的空间
fig.subplots_adjust(wspace=0.62)
fig.savefig("line_styles.png", dpi=160)

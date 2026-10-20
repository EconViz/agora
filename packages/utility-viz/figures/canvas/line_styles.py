import matplotlib.pyplot as plt

from utility_viz import Canvas, Config, LineStyle

Config.load("manual.toml").use()  # figure settings

styles = [LineStyle.SOLID, LineStyle.DASHED, LineStyle.DOTTED, LineStyle.DASHDOT]

fig, axes = plt.subplots(1, 4, figsize=(7.6, 2.0))
for ax, style in zip(axes, styles):
    Canvas(
        title=style.value,
        x_label="$x$",
        y_label="$y$",
        x_line_style=style,
        y_line_style=style,
        fig=fig,
        ax=ax,
    )

# leave room for axis labels
fig.subplots_adjust(wspace=0.62)
fig.savefig("line_styles.png", dpi=160)

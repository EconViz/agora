import matplotlib.pyplot as plt

from utility_viz import ArrowStyle, Canvas, Config

Config.load("manual.toml").use()  # the settings behind this manual's figures

styles = [ArrowStyle.SIMPLE, ArrowStyle.TRIANGLE, ArrowStyle.FANCY, ArrowStyle.WEDGE]

fig, axes = plt.subplots(1, 4, figsize=(7.6, 2.0))
for ax, style in zip(axes, styles):
    Canvas(
        title=style.name,
        x_label="$x$",
        y_label="$y$",
        x_arrow_style=style,
        y_arrow_style=style,
        fig=fig,
        ax=ax,
    )

# leave room for axis labels
fig.subplots_adjust(wspace=0.62)
fig.savefig("arrow_styles.png", dpi=160)

import matplotlib.pyplot as plt

from utility_viz import ArrowStyle, Canvas, Config

Config.load("manual.toml").use()  # 圖形設定

styles = [ArrowStyle.SIMPLE, ArrowStyle.TRIANGLE, ArrowStyle.FANCY, ArrowStyle.WEDGE]
titles = ["簡單", "三角形", "花式", "楔形"]

fig, axes = plt.subplots(1, 4, figsize=(7.6, 2.0))
for ax, style, title in zip(axes, styles, titles):
    Canvas(
        title=title,
        x_label="$x$",
        y_label="$y$",
        x_arrow_style=style,
        y_arrow_style=style,
        font="PingFang TC",  # 使用有中文字形的字體
        fig=fig,
        ax=ax,
    )

# 預留軸標籤的空間
fig.subplots_adjust(wspace=0.62)
fig.savefig("arrow_styles.png", dpi=160)

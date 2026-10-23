from mosaickit import (
    AxisSpec,
    Canvas,
    CanvasGrid,
    CanvasSpec,
    Config as MosaicConfig,
    DashStyle,
    Fill,
    Marker,
    MarkerLayer,
    PathLayer,
    Stroke,
    StyleBundle,
    TextLayer,
    TextStyle,
    build_axes,
)
import numpy as np

from utility_viz import Config, solve
from utility_viz.core.scenes import UTILITY_THEME, budget_layers, indifference_layers
from utility_viz.models import CobbDouglas

INK, DARK, GREY = "#1a1a1a", "#222222", "#8c8c8c"  # 手册主题的颜色
settings = Config.load("econ-viz.toml")
text = TextStyle(color=INK, size=14, font="serif")

# Cobb-Douglas 的 x 需求
model = CobbDouglas(alpha=0.5, beta=0.5)
py, income, px_a, px_b = 2.0, 40.0, 1.5, 4.0
points = {"A": px_a, "B": px_b}
optimum = {name: solve(model, px=px, py=py, income=income) for name, px in points.items()}
X = 29.0  # x 都从 0 画到 29


def panel(y_min, y_max, height, y_label):
    """白底、细轴的面板；从点通往坐标轴的辅助线是虚线。"""
    spec = CanvasSpec(
        x_range=(0, X), y_range=(y_min, y_max), width=4.6, height=height, x_label="", y_label=""
    )
    roles = {
        "canvas": StyleBundle(fill=Fill(color="#ffffff", opacity=1.0)),
        "axes": StyleBundle(stroke=Stroke(color=INK, width=1.0), text=text),
        "guide": StyleBundle(stroke=Stroke(color=INK, width=0.8, dash=DashStyle.DASHED)),
    }
    cv = Canvas(spec, theme=UTILITY_THEME, config=MosaicConfig(fonts=settings.fonts, math_font=settings.math_font), role_overrides=roles)
    cv.extend(
        build_axes(
            AxisSpec((0, X), arrow="end", label="$x$"),
            AxisSpec((0, y_max), arrow="end", label=y_label),
        )
    )
    cv.add(TextLayer((0, 0), "0", offset=(-6, -8), anchor="top-right", style=text, id="origin"))
    return cv


def mark(cv, name, x, y):
    """黑点与斜体字母，以及通往两轴的虚线辅助线。"""
    cv.add(PathLayer([(0, y), (x, y)], id=f"{name}.h", role="guide"))
    cv.add(PathLayer([(x, 0), (x, y)], id=f"{name}.v", role="guide"))
    cv.add(
        MarkerLayer(
            [(x, y)], marker=Marker(color=INK, size=26, edge_width=0), id=f"{name}.dot", z_index=5
        )
    )
    cv.add(
        TextLayer(
            (x, y),
            name,
            math=True,
            offset=(8, 6),
            anchor="bottom-left",
            style=text,
            id=f"{name}.label",
        )
    )


# 上图是商品空间
top = panel(-3.5, 24, 3.9, "$y$")
top.extend(budget_layers(px_a, py, income, layer_id="ba", stroke=Stroke(color=DARK, width=2.6)))
top.extend(
    budget_layers(
        px_b, py, income, layer_id="bb", stroke=Stroke(color=DARK, width=2.2, dash=DashStyle.DASHED)
    )
)
for name, eq in optimum.items():
    curve, _ = indifference_layers(
        model, [eq.utility], X, 24, layer_id=f"u.{name}", stroke=Stroke(color=GREY, width=2.6)
    )
    top.extend(curve)
    mark(top, name, eq.x, eq.y)

# 下图是需求曲线
bottom = panel(-1.2, 7, 3.6, "$p_x$")
prices = np.linspace(0.8, 6.0, 80)
demand = tuple(zip(0.5 * income / prices, prices))
bottom.add(PathLayer(demand, stroke=Stroke(color=GREY, width=2.6), id="demand"))
for name, eq in optimum.items():
    mark(bottom, name, eq.x, points[name])

CanvasGrid([[top], [bottom]]).save("demand.png")

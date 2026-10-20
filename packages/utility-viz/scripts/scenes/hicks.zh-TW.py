from mosaickit import (
    ArrowLayer,
    ArrowStyle,
    AxisSpec,
    Canvas,
    CanvasSpec,
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

from utility_viz import DecompositionMethod
from utility_viz.core.scenes import UTILITY_THEME, budget_layers, indifference_layers
from utility_viz.models import CobbDouglas, decompose_price_effect

INK, DARK, GREY = "#1a1a1a", "#222222", "#8c8c8c"  # 同 manual.toml 的顏色
text = TextStyle(color=INK, size=14)
effect_name = TextStyle(
    color=INK, size=13, family="PingFang TC"
)  # 選用中日韓字體

# x 的價格由 2 漲到 4
# A 舊 C 新 B 為補償點
model = CobbDouglas(alpha=0.5, beta=0.5)
px0, px1, py, income = 2.0, 4.0, 3.0, 60.0
result = decompose_price_effect(
    model, px=(px0, px1), py=py, income=income, method=DecompositionMethod.HICKS
)
bundles = {"A": result.A, "B": result.B, "C": result.C}
X, Y = 26.0, 24.0

# 白底細軸的畫布
spec = CanvasSpec(x_range=(0, X), y_range=(-7.5, Y), width=4.6, height=4.2, x_label="", y_label="")
roles = {
    "canvas": StyleBundle(fill=Fill(color="#ffffff", opacity=1.0)),
    "axes": StyleBundle(stroke=Stroke(color=INK, width=1.0), text=text),
    "guide": StyleBundle(stroke=Stroke(color=INK, width=0.8, dash=DashStyle.DASHED)),
}
cv = Canvas(spec, theme=UTILITY_THEME, role_overrides=roles)
cv.extend(
    build_axes(
        AxisSpec((0, X), arrow="end", label="$x$"), AxisSpec((0, Y), arrow="end", label="$y$")
    )
)
cv.add(TextLayer((0, 0), "0", offset=(-6, -8), anchor="top-right", style=text, id="origin"))

# 三條預算線與兩條曲線
cv.extend(budget_layers(px0, py, income, layer_id="b0", stroke=Stroke(color=DARK, width=2.6)))
cv.extend(budget_layers(px1, py, income, layer_id="b1", stroke=Stroke(color=DARK, width=2.6)))
compensated = [(0, result.compensated_income / py), (X, (result.compensated_income - px1 * X) / py)]
cv.add(
    PathLayer(
        compensated, stroke=Stroke(color=INK, width=1.0, dash=DashStyle.DASHED), id="compensated"
    )
)
for name in ("A", "C"):
    curve, _ = indifference_layers(
        model,
        [bundles[name].utility],
        X,
        Y,
        layer_id=f"u.{name}",
        stroke=Stroke(color=GREY, width=2.6),
    )
    cv.extend(curve)

# 三個組合與虛線輔助線
for name, bundle in bundles.items():
    cv.add(PathLayer([(bundle.x, 0), (bundle.x, bundle.y)], id=f"{name}.guide", role="guide"))
    cv.add(
        MarkerLayer(
            [(bundle.x, bundle.y)],
            marker=Marker(color=INK, size=26, edge_width=0),
            id=f"{name}.dot",
            z_index=5,
        )
    )
    cv.add(
        TextLayer(
            (bundle.x, bundle.y),
            name,
            math=True,
            offset=(8, 6),
            anchor="bottom-left",
            style=text,
            id=f"{name}.label",
        )
    )

# x 方向效果畫成箭頭
# 名稱展開到同一水平
gap, row, depth, spread = 0.2, 1.6, -4.4, 3.8
effects = [("A", "B", "替代效果", 1), ("B", "C", "所得效果", -1)]
for i, (start, end, name, direction) in enumerate(effects):
    x0, x1 = bundles[start].x, bundles[end].x
    sign = 1 if x1 > x0 else -1
    arrow = Stroke(color=GREY, width=1.8, arrow=ArrowStyle.TRIANGLE)
    cv.add(
        ArrowLayer((x0 + gap * sign, row), (x1 - gap * sign, row), stroke=arrow, id=f"effect.{i}")
    )
    foot = (x0 + x1) / 2 + direction * spread
    cv.add(
        PathLayer(
            [((x0 + x1) / 2, row - 0.6), (foot, depth + 0.4)],
            stroke=Stroke(color=INK, width=0.8),
            id=f"leader.{i}",
            clip=False,
        )
    )
    cv.add(TextLayer((foot, depth), name, anchor="top", style=effect_name, id=f"effect.label.{i}"))

cv.save("hicks.png")

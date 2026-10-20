import numpy as np
from mosaickit import (
    ArrowLayer,
    ArrowStyle,
    AxisSpec,
    Canvas,
    CanvasSpec,
    Fill,
    FillLayer,
    Marker,
    MarkerLayer,
    PathLayer,
    Stroke,
    StyleBundle,
    TextLayer,
    TextStyle,
)
from scipy.interpolate import CubicSpline

from utility_viz.core.scenes import UTILITY_THEME

INK, GREY, LENS = "#1a1a1a", "#8c8c8c", "#ececec"  # the colours of manual.toml
text = TextStyle(color=INK, size=12)

# after a textbook figure
# J from O_J and K from O_K
# curves are splines through control points
J = {  # J's control points low to high
    1: (
        [3.80, 3.91, 4.18, 4.59, 5.12, 5.75, 6.46, 7.16, 8.07],
        [5.15, 4.29, 3.49, 2.74, 2.08, 1.52, 1.07, 0.79, 0.58],
    ),
    2: (
        [4.26, 4.37, 4.60, 4.94, 5.25, 5.90, 6.30, 7.15, 7.84],
        [5.28, 4.55, 3.86, 3.22, 2.79, 2.13, 1.83, 1.38, 1.17],
    ),
    3: (
        [5.12, 5.20, 5.38, 5.64, 5.95, 6.35, 6.81, 7.29, 7.80],
        [5.40, 4.88, 4.39, 3.93, 3.50, 3.18, 2.91, 2.73, 2.63],
    ),
}
K = {  # K's from outer to inner
    1: (
        [3.38, 4.17, 4.91, 5.57, 5.95, 6.60, 6.93, 7.16, 7.19],
        [4.86, 4.65, 4.30, 3.83, 3.50, 2.57, 1.83, 0.79, 0.24],
    ),
    2: (
        [3.62, 4.22, 4.77, 5.27, 5.68, 6.03, 6.30, 6.47, 6.54],
        [4.35, 4.14, 3.83, 3.43, 2.97, 2.44, 1.83, 1.26, 0.64],
    ),
    3: (
        [3.64, 4.12, 4.55, 4.93, 5.25, 5.53, 5.73, 5.86, 5.92],
        [3.80, 3.65, 3.41, 3.11, 2.79, 2.33, 1.88, 1.41, 0.92],
    ),
}
# four allocations A to D
allocations = {"A": (7.16, 0.79), "B": (6.30, 1.83), "C": (5.25, 2.79), "D": (5.95, 3.50)}
# positions of the labels
letters = {"A": (7.41, 0.93), "B": (6.55, 1.90), "C": (5.48, 2.93), "D": (6.14, 3.67)}
curve_labels = {
    "U_J^1": (8.35, 0.48),
    "U_J^2": (8.12, 1.09),
    "U_J^3": (8.05, 2.58),
    "U_K^1": (7.46, 0.25),
    "U_K^2": (6.58, 0.36),
    "U_K^3": (5.95, 0.66),
}


def spline(points, n=240):
    """A smooth curve through the control points, as n sampled points."""
    points = np.column_stack(points)  # turn xs and ys into points
    chord = np.r_[0, np.cumsum(np.hypot(*np.diff(points, axis=0).T))]
    return CubicSpline(chord, points)(np.linspace(0, chord[-1], n))


curves_j = {k: spline(v) for k, v in J.items()}
curves_k = {k: spline(v) for k, v in K.items()}

# box plus margin for the arrows
# 0.6 inch per unit
x_range, y_range, unit = (-1.0, 11.15), (-0.8, 6.8), 0.6
spec = CanvasSpec(
    x_range=x_range,
    y_range=y_range,
    x_label="",
    y_label="",
    width=(x_range[1] - x_range[0]) * unit / 0.775,
    height=(y_range[1] - y_range[0]) * unit / 0.77,
)
roles = {"canvas": StyleBundle(fill=Fill(color="#ffffff", opacity=1.0))}
cv = Canvas(spec, theme=UTILITY_THEME, role_overrides=roles)
cv.add(
    PathLayer(
        [(0, 0), (10, 0), (10, 6), (0, 6), (0, 0)],
        stroke=Stroke(color=INK, width=0.6),
        id="box",
        clip=False,
    )
)

# lens up to allocation A
j1, k1 = curves_j[1], curves_k[1]
near = lambda curve, point: int(np.argmin(np.hypot(*(curve - point).T)))
gaps = [
    (np.hypot(*(j1[a] - k1[b])), a, b)
    for a in range(0, 240, 2)
    for b in range(0, 240, 2)
    if j1[a][1] > 4 and k1[b][0] < 4.2
]
_, a_top, b_top = min(gaps)
a_end, b_end = near(j1, allocations["A"]), near(k1, allocations["A"])
lens = [tuple(p) for p in k1[b_top : b_end + 1]] + [tuple(p) for p in j1[a_top : a_end + 1][::-1]]
cv.add(FillLayer(lens, fill=Fill(color=LENS, opacity=1.0), id="lens", z_index=0))

# curve width and dot size
for k, points in curves_j.items():
    cv.add(
        PathLayer(
            [tuple(p) for p in points], stroke=Stroke(color=INK, width=2.66), id=f"j{k}", z_index=2
        )
    )
for k, points in curves_k.items():
    cv.add(
        PathLayer(
            [tuple(p) for p in points], stroke=Stroke(color=GREY, width=2.66), id=f"k{k}", z_index=2
        )
    )
for name, point in allocations.items():
    cv.add(
        MarkerLayer(
            [point], marker=Marker(color=INK, size=41.6, edge_width=0), id=f"dot.{name}", z_index=4
        )
    )
    cv.add(
        TextLayer(
            letters[name],
            name,
            math=True,
            anchor="center",
            style=text,
            id=f"letter.{name}",
            z_index=4,
        )
    )
for label, point in curve_labels.items():
    cv.add(TextLayer(point, label, math=True, anchor="center", style=text, id=f"label.{label}"))
cv.add(TextLayer((-0.14, -0.20), "O_J", math=True, anchor="center", style=text, id="origin.j"))
cv.add(TextLayer((10.30, 6.18), "O_K", math=True, anchor="center", style=text, id="origin.k"))

# arrows along each person's axes
arrow, plain = Stroke(color=GREY, width=1.0, arrow=ArrowStyle.TRIANGLE), Stroke(
    color=GREY, width=1.0
)
cv.add(ArrowLayer((3.91, -0.34), (5.96, -0.34), stroke=arrow, id="side.bottom"))
cv.add(TextLayer((3.78, -0.35), "x_J", math=True, anchor="right", style=text, id="name.bottom"))
cv.add(ArrowLayer((5.93, 6.35), (3.98, 6.35), stroke=arrow, id="side.top"))
cv.add(TextLayer((6.07, 6.36), "x_K", math=True, anchor="left", style=text, id="name.top"))
cv.add(PathLayer([(-0.67, 1.91), (-0.67, 2.47)], stroke=plain, id="side.left.line", clip=False))
cv.add(ArrowLayer((-0.67, 3.47), (-0.67, 4.18), stroke=arrow, id="side.left"))
cv.add(TextLayer((-0.67, 2.99), "y_J", math=True, anchor="center", style=text, id="name.left"))
cv.add(PathLayer([(10.67, 3.47), (10.67, 4.04)], stroke=plain, id="side.right.line", clip=False))
cv.add(ArrowLayer((10.67, 2.47), (10.67, 1.78), stroke=arrow, id="side.right"))
cv.add(TextLayer((10.67, 3.01), "y_K", math=True, anchor="center", style=text, id="name.right"))

cv.save("edgeworth.png")

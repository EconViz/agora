from utility_viz import Config, Figure, Layout, levels, solve
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # figure settings

fig = Figure(Layout.SIDE_BY_SIDE, x_max=20, y_max=15, x_label="$x$", y_label="$y$", shared_y=True)

# before and after x doubles
cases = [
    (CobbDouglas(alpha=0.5, beta=0.5), 2.0, 3.0, 30.0),
    (CobbDouglas(alpha=0.3, beta=0.7), 4.0, 3.0, 30.0),
]
for idx, (model, px, py, income) in enumerate(cases):
    eq = solve(model, px=px, py=py, income=income)
    panel = fig[idx]  # each panel is a Canvas
    panel.add_utility(model, levels=levels.around(eq.utility, n=5))
    panel.add_budget(px, py, income, fill=True)
    panel.add_equilibrium(eq, show_ray=True)
fig.save("side_by_side.png")

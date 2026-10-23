from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import CobbDouglas

Config.load("econ-viz.toml").use()  # figure settings

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # italic x and y
cvs.add_utility(model, levels=levels.around(eq.utility, n=3))  # three curves around the optimum
cvs.save("add_utility.png")

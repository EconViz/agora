from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # figure settings

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # italic x and y
lvls = levels.around(eq.utility, n=5)  # five curves and one through the optimum
cvs.add_utility(model, levels=lvls)
cvs.add_budget(2.0, 3.0, 30.0, fill=True)  # the line and its feasible set
cvs.add_equilibrium(eq, show_ray=True)  # with the expansion path
cvs.save("cobb_douglas.png")

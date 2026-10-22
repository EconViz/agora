from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # 图形设置

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # 斜体的 x 与 y
lvls = levels.around(eq.utility, n=5)  # 含过最优点的五条曲线
cvs.add_utility(model, levels=lvls)
cvs.add_budget(2.0, 3.0, 30.0, fill=True)  # 预算线与可行集合
cvs.add_equilibrium(eq, show_ray=True)  # 附扩张路径
cvs.save("cobb_douglas.png")

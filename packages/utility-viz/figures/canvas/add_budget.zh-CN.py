from utility_viz import Canvas, Config

Config.load("econ-viz.toml").use()  # 载入图形设置

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # 斜体的 x 与 y
cvs.add_budget(2.0, 3.0, 30.0, fill=True)  # 预算线与可行集合
cvs.save("add_budget.png")

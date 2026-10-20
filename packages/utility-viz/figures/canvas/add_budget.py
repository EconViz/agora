from utility_viz import Canvas, Config

Config.load("manual.toml").use()  # the settings behind this manual's figures

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # italic x and y
cvs.add_budget(2.0, 3.0, 30.0, fill=True)  # the line and its feasible set
cvs.save("add_budget.png")

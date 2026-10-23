from utility_viz import Canvas, Config

Config.load("econ-viz.toml").use()  # 載入圖形設定

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # 斜體的 x 與 y
cvs.add_budget(2.0, 3.0, 30.0, fill=True)  # 預算線與可行集合
cvs.save("add_budget.png")

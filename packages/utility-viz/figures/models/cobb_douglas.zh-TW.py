from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # 圖形設定

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")  # 斜體的 x 與 y
lvls = levels.around(eq.utility, n=5)  # 含過最適點的五條曲線
cvs.add_utility(model, levels=lvls)
cvs.add_budget(2.0, 3.0, 30.0, fill=True)  # 預算線與可行集合
cvs.add_equilibrium(eq, show_ray=True)  # 附擴張路徑
cvs.save("cobb_douglas.png")

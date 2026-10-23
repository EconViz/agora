from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import Leontief

Config.load("manual.toml").use()  # 載入圖形設定

model = Leontief(a=1.0, b=1.0)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")
cvs.add_utility(
    model,
    levels=levels.around(eq.utility, n=5),
    show_rays=True,
    show_kinks=True,  # 每個折點畫射線與標記
)
cvs.add_budget(2.0, 3.0, 30.0)
cvs.add_equilibrium(eq)
cvs.save("leontief.png")

import numpy as np

from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import CustomUtility

Config.load("manual.toml").use()  # 图形设置

# 任何数组函数都可作效用
model = CustomUtility(func=lambda x, y: np.log(x) + np.log(y), name="log+log")
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=5))
cvs.add_budget(2.0, 3.0, 30.0)
cvs.add_equilibrium(eq)
cvs.save("custom.png")

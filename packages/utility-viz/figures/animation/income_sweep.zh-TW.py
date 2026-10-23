import numpy as np

from utility_viz import Canvas, Config, levels, solve
from utility_viz.core.animation import Animator
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # 載入圖形設定

model = CobbDouglas(alpha=0.5, beta=0.5)
# 每格用同一組曲線
fixed = levels.around(solve(model, px=2.0, py=2.0, income=20.0).utility, n=5)


def draw(income: float) -> Canvas:
    """一格影格：所得是 income。"""
    eq = solve(model, px=2.0, py=2.0, income=income)
    cvs = Canvas(x_max=14, y_max=12, x_label="$x_1$", y_label="$x_2$")
    cvs.add_utility(model, levels=fixed)
    cvs.add_budget(2.0, 2.0, income, fill=True)
    cvs.add_equilibrium(eq, show_ray=True)
    return cvs


Animator(draw, frames=np.linspace(8.0, 36.0, 45)).save("income_sweep.gif", fps=12, dpi=120)

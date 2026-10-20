import numpy as np

from utility_viz import Canvas, Config, levels
from utility_viz.models import Satiation

Config.load("manual.toml").use()  # 圖形設定

model = Satiation(bliss_x=6.0, bliss_y=4.0)

# 曲線取自效用值網格
X, Y = np.meshgrid(np.linspace(0.1, 12.0, 300), np.linspace(0.1, 10.0, 300))

cvs = Canvas(x_max=12, y_max=10, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.percentile(model(X, Y), n=5))  # u 的五個百分位數
cvs.save("satiation.png")

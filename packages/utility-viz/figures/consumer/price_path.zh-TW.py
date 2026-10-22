from utility_viz import Canvas, Config, LinearBudget, PricePath, levels
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # 圖形設定

model = CobbDouglas(alpha=0.5, beta=0.5)
budget = LinearBudget(px=2.0, py=2.0, income=40.0)
path = PricePath(model, budget=budget, price="px", price_range=(0.8, 6.0), n=40)

# 圍繞中段最適點的曲線
eq = path.equilibria[len(path.equilibria) // 2]

cvs = Canvas(x_max=25, y_max=20, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=5))
cvs.add_path(path)  # 價格消費曲線
cvs.save("price_path.png")

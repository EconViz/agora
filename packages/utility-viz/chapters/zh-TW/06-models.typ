#import "/template/manual.typ": *

= 核心模型 <sec-models>

#changed("1.3.1", label: "models.registry")[新增模型註冊表（`models.registry`），供命令列工具建立模型]

內建模型位於 `utility_viz.models`，可傳入 `solve()` 與 `Canvas.add_utility()`。本章依偏好特性分組，列出各模型的效用函數、參數、特有行為與圖形。

== 平滑偏好

#changed("1.7.0", label: "CobbDouglas")[修正效用模型的定義域、非對稱 CES 的擴張路徑、Cobb-Douglas 的極限情況，以及所得未花完時的飽和最適解]
#changed("1.7.0", label: "CobbDouglas")[修正效用值接近零或為負時的等高線水準計算]
#changed("1.3.1", label: "CobbDouglas")[等高線水準的規則集中在 `contours.level_policies`]
#changed("1.1.0", label: "Translog")[`Translog` 模型，以及圖例與無異曲線標籤]

Cobb-Douglas、CES 與 Translog 的無異曲線為平滑曲線；最適解取決於模型參數、價格與所得。

=== Cobb-Douglas

#api(("CobbDouglas",), syntax: [`CobbDouglas(alpha=0.5, beta=0.5)`])[
  Cobb-Douglas 效用函數 #citep(<cobb1928>)：
  $
    u(x, y) = x^alpha y^beta
  $
  正指數決定兩種商品的相對權重，無異曲線以座標軸為漸近線。
]

#param("alpha", default: "0.5")[商品 $x$ 的權重。]
#param("beta", default: "0.5")[商品 $y$ 的權重。]

=== CES

#api(("CES",), syntax: [`CES(alpha=0.5, beta=0.5, rho=0.5)`])[
  CES #citep(<arrow1961>) 透過 `rho` 調整商品間的替代彈性：
  $ u(x, y) = (alpha x^rho + beta y^rho)^(1 / rho). $
  替代彈性為 $sigma = 1 slash (1 - rho)$。極限形式分別為 Cobb-Douglas（$rho -> 0$）、完全互補（$rho -> -infinity$）與完全替代（$rho -> 1$）。
]

#param("alpha", default: "0.5")[商品 $x$ 的權重。]
#param("beta", default: "0.5")[商品 $y$ 的權重。]
#param("rho", default: "0.5")[替代參數，且 $rho != 1$。]

#example([```python
from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import CES

Config.load("econ-viz.toml").use()  # 載入圖形設定

model = CES(alpha=0.5, beta=0.5, rho=-0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=5))
cvs.add_budget(2.0, 3.0, 30.0)
cvs.add_equilibrium(eq)
cvs.save("ces.png")
```])

#fig("/figures/models/ces.svg", width: 56%, caption: [CES 曲線])

=== Translog

#api(("Translog",), added: "v1.1.0", syntax: [
  `Translog(alpha_0=0.0, alpha_x=0.5, alpha_y=0.5, beta_xx=0.0, beta_yy=0.0, beta_xy=0.0)`
])[
  Translog #citep(<christensen1975>) 以對數的一次項、二次項與交叉項表示效用：
  $
    ln u(x, y) = & alpha_0 + alpha_x ln x + alpha_y ln y \
                 & + 1/2 beta_(x x) (ln x)^2 + 1/2 beta_(y y) (ln y)^2 + beta_(x y) ln x ln y.
  $
  二次項與交叉項控制曲率。所有 $beta$ 係數為零時，退化為 Cobb-Douglas 型的對數線性形式。
]

#param("alpha_0", default: "0.0")[對數效用截距。]
#param("alpha_x", default: "0.5")[$ln x$ 的一次項權重。]
#param("alpha_y", default: "0.5")[$ln y$ 的一次項權重。]
#param("beta_xx", default: "0.0")[$x$ 方向的曲率。]
#param("beta_yy", default: "0.0")[$y$ 方向的曲率。]
#param("beta_xy", default: "0.0")[$x$ 與 $y$ 的交叉效果。]

#example([```python
from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import Translog

Config.load("econ-viz.toml").use()  # 載入圖形設定

model = Translog(alpha_x=0.6, alpha_y=0.4, beta_xy=0.12)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=18, y_max=12, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=4))
cvs.add_budget(2.0, 3.0, 30.0)
cvs.add_equilibrium(eq)
cvs.save("translog.png")
```])

#fig("/figures/models/translog.svg", width: 56%, caption: [Translog 範例])

== 拗折點與角解

無異曲線有拗折或為直線時，最適解可能位於拗折點或座標軸，不能僅以相切條件判定。

=== 完全互補

#api(("Leontief",), syntax: [`Leontief(a=1.0, b=1.0)`])[
  完全互補效用函數：
  $
    u(x, y) = min{a x, b y}
  $
  無異曲線呈 L 型。權重與價格為正時，最適點滿足固定比例 $a x = b y$。

  #changed("2.0.0b1", label: "Leontief")[折角效用函數的無異曲線在 Matplotlib 與 TikZ 輸出中保留精確直角]
  轉角在圖片與 TikZ 輸出中都畫成精確的直角；以 `CustomUtility` 建立的分段 `min`/`max` 函數亦同。
]

#param("a", default: "1.0")[商品 $x$ 的權重。]
#param("b", default: "1.0")[商品 $y$ 的權重。]

#example([```python
from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import Leontief

Config.load("econ-viz.toml").use()  # 載入圖形設定

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
```])

#fig("/figures/models/leontief.svg", width: 56%, caption: [
  完全互補射線
])

=== 完全替代

#api(("PerfectSubstitutes",), syntax: [`PerfectSubstitutes(a=1.0, b=1.0)`])[
  完全替代效用函數：
  $ u(x, y) = a x + b y. $
  無異曲線為直線。每元邊際效用不同時，最適解為僅購買較高者的角解；兩者相等時，預算線上的消費組合皆為最適解。
]

#param("a", default: "1.0")[商品 $x$ 的邊際效用。]
#param("b", default: "1.0")[商品 $y$ 的邊際效用。]

#example([```python
from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import PerfectSubstitutes

Config.load("econ-viz.toml").use()  # 載入圖形設定

model = PerfectSubstitutes(a=1.0, b=2.0)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=5))
cvs.add_budget(2.0, 3.0, 30.0)
cvs.add_equilibrium(eq)
cvs.save("perfect_substitutes.png")
```])

#fig("/figures/models/perfect_substitutes.svg", width: 56%, caption: [
  完全替代角解
])

=== 最大值效用

#api(("maximum",), syntax: [`CustomUtility(func=lambda x, y: np.maximum(a * x, b * y))`])[
  以兩個加權數量的最大值定義效用：
  $
    u(x, y) = max{a x, b y}
  $
  此偏好不具凸性。在正權重與正價格下，最適解位於效用較高的預算線軸截距。此模型以 `CustomUtility` 建立（詳見#ref(<sec-advanced>)）。
]

#param("a", default: "1.0")[商品 $x$ 的權重。]
#param("b", default: "1.0")[商品 $y$ 的權重。]

#example([```python
import numpy as np

from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import CustomUtility

Config.load("econ-viz.toml").use()  # 載入圖形設定

model = CustomUtility(func=lambda x, y: np.maximum(x, y), name="maximum")
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=25, y_max=20, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=5))
cvs.add_budget(2.0, 3.0, 30.0)
cvs.add_equilibrium(eq)
cvs.save("maximum.png")
```])

#fig("/figures/models/maximum.svg", width: 56%, caption: [最大值效用])

== 所得與參考點

以下模型分別描述準線性偏好、最低消費需求與具有極樂點的飽和偏好。

=== 準線性

#api(("QuasiLinear",), syntax: [`QuasiLinear(v_func=numpy.log, linear_in="y")`])[
  準線性效用中，一種商品以線性項表示：
  $ u(x, y) = f(x) + y. $
  在內部解範圍內，非線性商品的需求不受所得影響。`linear_in` 指定線性項對應的商品。
]

#param("v_func", default: "numpy.log")[遞增且凹的函數 $f$。]
#param("linear_in", default: "\"y\"")[以線性方式進入的商品。]

#example([```python
import numpy as np

from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import QuasiLinear

Config.load("econ-viz.toml").use()  # 載入圖形設定

model = QuasiLinear(v_func=np.log, linear_in="y")
eq = solve(model, px=1.0, py=2.0, income=20.0)

cvs = Canvas(x_max=15, y_max=15, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=5))
cvs.add_budget(1.0, 2.0, 20.0)
cvs.add_equilibrium(eq)
cvs.save("quasi_linear.png")
```])

#fig("/figures/models/quasi_linear.svg", width: 56%, caption: [
  準線性偏好
])

#changed("1.9.0", label: "Haagsma")[新增具有閉式解的 Haagsma 效用模型，用於劣等財與季芬財分析]

=== Haagsma

#api(("Haagsma",), added: "v1.9.0", syntax: [
  `Haagsma(alpha_x=1.0, alpha_y=2.0, gamma_x=2.0, gamma_y=27.0)`
])[
  #citet(<haagsma2012>) 效用函數為
  $
    u(x, y) = alpha_x ln(x - gamma_x) - alpha_y ln(gamma_y - y).
  $
  定義域為 $x > gamma_x$ 且 $0 <= y < gamma_y$，並要求 $0 < alpha_x < alpha_y$。商品 $x$ 的 Marshall 需求隨所得下降；當 $gamma_y p_y < I < gamma_y p_y + gamma_x p_x$ 時，商品 $x$ 為季芬財。

  所得達到 $gamma_y p_y + gamma_x p_x$ 時，效用在預算線上沒有有限最大值，模型會拋出 `InvalidParameterError`。
]

#param("alpha_x", default: "1.0")[商品 $x$ 的權重，必須小於 `alpha_y`。]
#param("alpha_y", default: "2.0")[商品 $y$ 的權重。]
#param("gamma_x", default: "2.0")[商品 $x$ 的數量下界。]
#param("gamma_y", default: "27.0")[商品 $y$ 的數量上界。]
#param("demand(px, py, income)")[回傳閉式內部解。]
#param("is_giffen(px, py, income)")[檢查指定預算下商品 $x$ 是否為季芬財。]

#example([```python
from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import Haagsma

Config.load("econ-viz.toml").use()  # 載入圖形設定

model = Haagsma(gamma_y=10.0)
eq = solve(model, px=1.0, py=1.0, income=11.0)

cvs = Canvas(x_max=9, y_max=12, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=4))
cvs.add_budget(1.0, 1.0, 11.0)
cvs.add_equilibrium(eq)
cvs.save("haagsma.png")
```])

#fig("/figures/models/haagsma.svg", width: 56%, caption: [$gamma_y = 10$ 的 Haagsma])

=== Stone-Geary

#api(("StoneGeary",), syntax: [`StoneGeary(alpha=0.5, beta=0.5, bar_x=1.0, bar_y=1.0)`])[
  Stone-Geary #citep(<stone1954>)#citep(<geary1950>) 在 Cobb-Douglas 中加入最低消費量：
  $ u(x, y) = (x - overline(x))^alpha (y - overline(y))^beta. $
  滿足基本需求量 $overline(x)$ 與 $overline(y)$ 後，剩餘所得依權重分配。
]

#param("alpha", default: "0.5")[超額 $x$ 的權重。]
#param("beta", default: "0.5")[超額 $y$ 的權重。]
#param("bar_x", default: "1.0")[基本需求量 $overline(x)$。]
#param("bar_y", default: "1.0")[基本需求量 $overline(y)$。]

#example([```python
from utility_viz import Canvas, Config, levels, solve
from utility_viz.models import StoneGeary

Config.load("econ-viz.toml").use()  # 載入圖形設定

model = StoneGeary(alpha=0.5, beta=0.5, bar_x=2.0, bar_y=2.0)
eq = solve(model, px=2.0, py=3.0, income=30.0)

cvs = Canvas(x_max=20, y_max=15, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.around(eq.utility, n=5))
cvs.add_budget(2.0, 3.0, 30.0, fill=True)
cvs.add_equilibrium(eq)
cvs.save("stone_geary.png")
```])

#fig("/figures/models/stone_geary.svg", width: 56%, caption: [
  Stone-Geary
])

=== 飽和偏好

#api(("Satiation",), syntax: [`Satiation(bliss_x=5.0, bliss_y=5.0, a=1.0, b=1.0)`])[
  飽和偏好以 $(x^*, y^*)$ 為效用最高的極樂點：
  $ u(x, y) = -a (x - x^*)^2 - b (y - y^*)^2. $
  當 $a, b > 0$，偏離極樂點會使效用下降，無異曲線為封閉橢圓，偏好不具單調性。
]

#param("bliss_x", default: "5.0")[極樂點座標 $x^*$。]
#param("bliss_y", default: "5.0")[極樂點座標 $y^*$。]
#param("a", default: "1.0")[$x$ 軸方向的曲率。]
#param("b", default: "1.0")[$y$ 軸方向的曲率。]

#example([```python
import numpy as np

from utility_viz import Canvas, Config, levels
from utility_viz.models import Satiation

Config.load("econ-viz.toml").use()  # 載入圖形設定

model = Satiation(bliss_x=6.0, bliss_y=4.0)

# 曲線取自效用值網格
X, Y = np.meshgrid(np.linspace(0.1, 12.0, 300), np.linspace(0.1, 10.0, 300))

cvs = Canvas(x_max=12, y_max=10, x_label="$x$", y_label="$y$")
cvs.add_utility(model, levels=levels.percentile(model(X, Y), n=5))  # u 的五個百分位數
cvs.save("satiation.png")
```])

#fig("/figures/models/satiation.svg", width: 56%, caption: [
  極樂點飽和偏好
])

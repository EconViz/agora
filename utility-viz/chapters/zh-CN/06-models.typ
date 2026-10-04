#import "/template/manual.typ": *

= 核心模型 <sec-models>

#changed("1.3.1", label: "models.registry")[添加模型注册表（`models.registry`），供命令行工具创建模型]

内置模型位于 #modify[`utility_viz.models`]，可传入 `solve()` 与 `Canvas.add_utility()`。本章按偏好特性分组，列出各模型的效用函数、参数、特有行为与图形。

== 平滑偏好

#changed("1.7.0", label: "CobbDouglas")[修正效用模型的定义域、非对称 CES 的扩张路径、Cobb-Douglas 的极限情况，以及收入未花完时的饱和最优解]
#changed("1.7.0", label: "CobbDouglas")[修正效用值接近零或为负时的等高线水平计算]
#changed("1.3.1", label: "CobbDouglas")[等高线水平的规则集中在 `contours.level_policies`]
#changed("1.1.0", label: "Translog")[`Translog` 模型，以及图例与无差异曲线标签]

Cobb-Douglas、CES 与 Translog 的无差异曲线为平滑曲线；最优解取决于模型参数、价格与收入。

=== Cobb-Douglas

#api(("CobbDouglas",), syntax: [`CobbDouglas(alpha=0.5, beta=0.5)`])[
  Cobb-Douglas 效用函数 #citep(<cobb1928>)：
  $
    u(x, y) = x^alpha y^beta
  $
  正指数决定两种商品的相对权重，无差异曲线以坐标轴为渐近线。
]

#param("alpha", default: "0.5")[商品 $x$ 的权重。]
#param("beta", default: "0.5")[商品 $y$ 的权重。]

=== CES

#api(("CES",), syntax: [`CES(alpha=0.5, beta=0.5, rho=0.5)`])[
  CES #citep(<arrow1961>) 通过 `rho` 调整商品间的替代弹性：
  $ u(x, y) = (alpha x^rho + beta y^rho)^(1 / rho). $
  替代弹性为 $sigma = 1 slash (1 - rho)$。极限形式分别为 Cobb-Douglas（$rho -> 0$）、完全互补（$rho -> -infinity$）与完全替代（$rho -> 1$）。
]

#param("alpha", default: "0.5")[商品 $x$ 的权重。]
#param("beta", default: "0.5")[商品 $y$ 的权重。]
#param("rho", default: "0.5")[替代参数，且 $rho != 1$。]

#fig("/figures/models/ces.svg", width: 42%, caption: [CES 曲线。])

=== Translog

#api(("Translog",), added: "v1.1.0", syntax: [
  `Translog(alpha_0=0.0, alpha_x=0.5, alpha_y=0.5, beta_xx=0.0, beta_yy=0.0, beta_xy=0.0)`
])[
  Translog #citep(<christensen1975>) 以对数的一次项、二次项与交叉项表示效用：
  $
    ln u(x, y) = & alpha_0 + alpha_x ln x + alpha_y ln y \
                 & + 1/2 beta_(x x) (ln x)^2 + 1/2 beta_(y y) (ln y)^2 + beta_(x y) ln x ln y.
  $
  二次项与交叉项控制曲率。所有 $beta$ 系数为零时，退化为 Cobb-Douglas 型的对数线性形式。
]

#param("alpha_0", default: "0.0")[对数效用截距。]
#param("alpha_x", default: "0.5")[$ln x$ 的一次项权重。]
#param("alpha_y", default: "0.5")[$ln y$ 的一次项权重。]
#param("beta_xx", default: "0.0")[$x$ 方向的曲率。]
#param("beta_yy", default: "0.0")[$y$ 方向的曲率。]
#param("beta_xy", default: "0.0")[$x$ 与 $y$ 的交叉效应。]

#fig("/figures/models/translog.svg", width: 42%, caption: [Translog 示例。])

== 折点与角解

无差异曲线有折点或为直线时，最优解可能位于折点或坐标轴，不能仅以相切条件判定。

=== 完全互补

#api(("Leontief",), syntax: [`Leontief(a=1.0, b=1.0)`])[
  完全互补效用函数：
  $
    u(x, y) = min{a x, b y}
  $
  无差异曲线呈 L 型。权重与价格为正时，最优点满足固定比例 $a x = b y$。

  #changed("2.0.0b1", label: "Leontief")[#modify[折角效用函数的无差异曲线在 Matplotlib 与 TikZ 输出中保留精确直角]]
  #modify[转角在图片与 TikZ 输出中都画成精确的直角；以 `CustomUtility` 创建的分段 `min`/`max` 函数亦同。]
]

#param("a", default: "1.0")[商品 $x$ 的权重。]
#param("b", default: "1.0")[商品 $y$ 的权重。]

#fig("/figures/models/leontief.svg", width: 42%, caption: [
  完全互补射线。
])

=== 完全替代

#api(("PerfectSubstitutes",), syntax: [`PerfectSubstitutes(a=1.0, b=1.0)`])[
  完全替代效用函数：
  $ u(x, y) = a x + b y. $
  无差异曲线为直线。每元边际效用不同时，最优解为仅购买较高者的角解；两者相等时，预算线上的消费组合皆为最优解。
]

#param("a", default: "1.0")[商品 $x$ 的边际效用。]
#param("b", default: "1.0")[商品 $y$ 的边际效用。]

#fig("/figures/models/perfect_substitutes.svg", width: 42%, caption: [
  完全替代角解。
])

=== 最大值效用

#api(("maximum",), syntax: [`CustomUtility(func=lambda x, y: np.maximum(a * x, b * y))`])[
  以两个加权数量的最大值定义效用：
  $
    u(x, y) = max{a x, b y}
  $
  此偏好不具凸性。在正权重与正价格下，最优解位于效用更高的预算线轴截距。此模型以 `CustomUtility` 创建（详见#ref(<sec-advanced>)）。
]

#param("a", default: "1.0")[商品 $x$ 的权重。]
#param("b", default: "1.0")[商品 $y$ 的权重。]

#fig("/figures/models/maximum.svg", width: 42%, caption: [最大值效用。])

== 收入与参考点

以下模型分别描述准线性偏好、最低消费需求与具有饱和点的饱和偏好。

=== 准线性

#api(("QuasiLinear",), syntax: [`QuasiLinear(v_func=numpy.log, linear_in="y")`])[
  准线性效用中，一种商品以线性项表示：
  $ u(x, y) = f(x) + y. $
  在内部解范围内，非线性商品的需求不受收入影响。`linear_in` 指定线性项对应的商品。
]

#param("v_func", default: "numpy.log")[递增且凹的函数 $f$。]
#param("linear_in", default: "\"y\"")[以线性方式进入的商品。]

#fig("/figures/models/quasi_linear.svg", width: 42%, caption: [
  准线性偏好。
])

#changed("1.9.0", label: "Haagsma")[添加具有闭式解的 Haagsma 效用模型，用于劣等财与季芬财分析]

=== Haagsma

#api(("Haagsma",), added: "v1.9.0", syntax: [
  `Haagsma(alpha_x=1.0, alpha_y=2.0, gamma_x=2.0, gamma_y=27.0)`
])[
  #citet(<haagsma2012>) 效用函数为
  $
    u(x, y) = alpha_x ln(x - gamma_x) - alpha_y ln(gamma_y - y).
  $
  定义域为 $x > gamma_x$ 且 $0 <= y < gamma_y$，并要求 $0 < alpha_x < alpha_y$。商品 $x$ 的 Marshall 需求随收入下降；当 $gamma_y p_y < I < gamma_y p_y + gamma_x p_x$ 时，商品 $x$ 为季芬财。

  收入达到 $gamma_y p_y + gamma_x p_x$ 时，效用在预算线上没有有限最大值，模型会抛出 `InvalidParameterError`。
]

#param("alpha_x", default: "1.0")[商品 $x$ 的权重，必须小于 `alpha_y`。]
#param("alpha_y", default: "2.0")[商品 $y$ 的权重。]
#param("gamma_x", default: "2.0")[商品 $x$ 的数量下界。]
#param("gamma_y", default: "27.0")[商品 $y$ 的数量上界。]
#param("demand(px, py, income)")[返回闭式内部解。]
#param("is_giffen(px, py, income)")[检查指定预算下商品 $x$ 是否为季芬财。]

#fig("/figures/models/haagsma.svg", width: 42%, caption: [$gamma_y = 10$ 的 Haagsma。])

=== Stone-Geary

#api(("StoneGeary",), syntax: [`StoneGeary(alpha=0.5, beta=0.5, bar_x=1.0, bar_y=1.0)`])[
  Stone-Geary #citep(<stone1954>)#citep(<geary1950>) 在 Cobb-Douglas 中添加最低消费量：
  $ u(x, y) = (x - overline(x))^alpha (y - overline(y))^beta. $
  满足基本需求量 $overline(x)$ 与 $overline(y)$ 后，剩余收入依权重分配。
]

#param("alpha", default: "0.5")[超额 $x$ 的权重。]
#param("beta", default: "0.5")[超额 $y$ 的权重。]
#param("bar_x", default: "1.0")[基本需求量 $overline(x)$。]
#param("bar_y", default: "1.0")[基本需求量 $overline(y)$。]

#fig("/figures/models/stone_geary.svg", width: 42%, caption: [
  Stone-Geary。
])

=== 饱和偏好

#api(("Satiation",), syntax: [`Satiation(bliss_x=5.0, bliss_y=5.0, a=1.0, b=1.0)`])[
  饱和偏好以 $(x^*, y^*)$ 为效用最高的饱和点：
  $ u(x, y) = -a (x - x^*)^2 - b (y - y^*)^2. $
  当 $a, b > 0$，偏离饱和点会使效用下降，无差异曲线为封闭椭圆，偏好不具单调性。
]

#param("bliss_x", default: "5.0")[饱和点坐标 $x^*$。]
#param("bliss_y", default: "5.0")[饱和点坐标 $y^*$。]
#param("a", default: "1.0")[$x$ 轴方向的曲率。]
#param("b", default: "1.0")[$y$ 轴方向的曲率。]

#fig("/figures/models/satiation.svg", width: 42%, caption: [
  饱和偏好。
])

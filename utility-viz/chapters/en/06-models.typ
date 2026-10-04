#import "/template/manual.typ": *

= Core models <sec-models>

#changed("1.3.1", label: "models.registry")[Model registry (`models.registry`) used by the command-line tool to build models]

The core models cover smooth, kinked, linear, income-dependent, and
reference-point preferences. They all live in #modify[`utility_viz.models`]. This chapter
gives each model's function, parameters, distinct behaviour, and figure.

== Smooth preferences

#changed("1.7.0", label: "CobbDouglas")[Fixed utility domains, asymmetric CES expansion paths, Cobb-Douglas limit cases, and satiation optima that leave income unspent]
#changed("1.7.0", label: "CobbDouglas")[Fixed contour levels when utility is near zero or negative]
#changed("1.3.1", label: "CobbDouglas")[Contour-level rules gathered in `contours.level_policies`]
#changed("1.1.0", label: "Translog")[`Translog` model, with legends and indifference-curve labels]

These models produce smooth indifference curves and normally have an
interior optimum when prices and income are positive.

=== Cobb-Douglas

#api(("CobbDouglas",), syntax: [`CobbDouglas(alpha=0.5, beta=0.5)`])[
  The standard model for smooth, strictly convex preferences
  #citep(<cobb1928>):
  $ u(x, y) = x^alpha y^beta. $
  The exponents control the relative weight placed on each good. The
  indifference curves approach both axes without touching them.
]

#param("alpha", default: "0.5")[Weight on good $x$.]
#param("beta", default: "0.5")[Weight on good $y$.]

=== CES

#api(("CES",), syntax: [`CES(alpha=0.5, beta=0.5, rho=0.5)`])[
  Constant elasticity of substitution #citep(<arrow1961>): the ease of substitution varies
  while preferences stay smooth,
  $ u(x, y) = (alpha x^rho + beta y^rho)^(1 slash rho). $
  The elasticity of substitution is $sigma = 1 slash (1 - rho)$. As $rho$
  changes, CES approaches Cobb-Douglas ($rho -> 0$), Leontief
  ($rho -> -infinity$) or perfect substitutes ($rho -> 1$).
]

#param("alpha", default: "0.5")[Weight on good $x$.]
#param("beta", default: "0.5")[Weight on good $y$.]
#param("rho", default: "0.5")[Substitution parameter, $rho != 1$.]

#fig("/figures/models/ces.svg", width: 42%, caption: [CES with $rho = -0.5$.])

=== Translog

#api(("Translog",), added: "v1.1.0", syntax: [
  `Translog(alpha_0=0.0, alpha_x=0.5, alpha_y=0.5, beta_xx=0.0, beta_yy=0.0, beta_xy=0.0)`
])[
  A flexible log-quadratic model for smooth preferences
  #citep(<christensen1975>):
  $
    ln u(x, y) = & alpha_0 + alpha_x ln x + alpha_y ln y \
                 & + 1/2 beta_(x x) (ln x)^2 + 1/2 beta_(y y) (ln y)^2 + beta_(x y) ln x ln y.
  $
  The quadratic and interaction terms let the curvature vary across the
  consumption space. With all $beta$ coefficients zero it reduces to a
  Cobb-Douglas-style log-linear form.
]

#param("alpha_0", default: "0.0")[Log-utility intercept.]
#param("alpha_x", default: "0.5")[First-order weight on $ln x$.]
#param("alpha_y", default: "0.5")[First-order weight on $ln y$.]
#param("beta_xx", default: "0.0")[Curvature in $x$.]
#param("beta_yy", default: "0.0")[Curvature in $y$.]
#param("beta_xy", default: "0.0")[Interaction between $x$ and $y$.]

#fig("/figures/models/translog.svg", width: 42%, caption: [Translog with $beta_(x y) = 0.12$.])

== Kinks and corners

These models show how non-smooth or linear preferences move the optimum
to a kink or a corner.

=== Perfect complements

#api(("Leontief",), syntax: [`Leontief(a=1.0, b=1.0)`])[
  Goods consumed in fixed proportions:
  $ u(x, y) = min(a x, b y). $
  The indifference curves are L-shaped, and the optimum lies at the kink
  where the two weighted quantities are equal.

  #changed("2.0.0b1", label: "Leontief")[#modify[Indifference curves of kinked utilities keep exact right-angle corners in Matplotlib and TikZ output]]
  #modify[The corners are drawn as exact right angles, in image and TikZ
  output alike; this also holds for piecewise `min`/`max` functions built
  with `CustomUtility`.]
]

#param("a", default: "1.0")[Weight on good $x$.]
#param("b", default: "1.0")[Weight on good $y$.]

#fig("/figures/models/leontief.svg", width: 42%, caption: [
  Leontief, with the ray through the kinks.
])

=== Perfect substitutes

#api(("PerfectSubstitutes",), syntax: [`PerfectSubstitutes(a=1.0, b=1.0)`])[
  A constant rate of trade-off between the goods:
  $ u(x, y) = a x + b y. $
  The indifference curves are straight lines. The consumer normally buys
  only the good with the greater marginal utility per dollar, a corner
  solution.
]

#param("a", default: "1.0")[Marginal utility of good $x$.]
#param("b", default: "1.0")[Marginal utility of good $y$.]

#fig("/figures/models/perfect_substitutes.svg", width: 42%, caption: [
  Perfect substitutes: a corner solution on the $y$-axis.
])

=== Maximum utility

#api(("maximum",), syntax: [`CustomUtility(func=lambda x, y: np.maximum(a * x, b * y))`])[
  Maximum utility keeps only the larger weighted quantity in each bundle:
  $ u(x, y) = max(a x, b y). $
  Each indifference curve has two arms that extend towards the axes. The
  preferences are non-convex, so on a linear budget the optimum normally
  lies at the intercept with the greater weighted utility. There is no
  dedicated class; the model is built with `CustomUtility`
  (@sec-advanced).
]

#param("a", default: "1.0")[Weight on good $x$.]
#param("b", default: "1.0")[Weight on good $y$.]

#fig("/figures/models/maximum.svg", width: 42%, caption: [Maximum utility.])

== Income and reference points

These models add special income effects, subsistence requirements or a
preferred consumption point.

=== Quasi-linear

#api(("QuasiLinear",), syntax: [`QuasiLinear(v_func=numpy.log, linear_in="y")`])[
  One good enters utility linearly:
  $ u(x, y) = f(x) + y. $
  Once the solution is interior, the non-linear good has no income effect.
  `linear_in` reverses the roles of $x$ and $y$.
]

#param("v_func", default: "numpy.log")[Increasing, concave function $f$.]
#param("linear_in", default: "\"y\"")[Good that enters linearly.]

#fig("/figures/models/quasi_linear.svg", width: 42%, caption: [
  Quasi-linear preferences: vertically parallel indifference curves.
])

#changed("1.9.0", label: "Haagsma")[Haagsma utility model with a closed-form solution, for inferior- and Giffen-good analysis]

=== Haagsma

#api(("Haagsma",), added: "v1.9.0", syntax: [
  `Haagsma(alpha_x=1.0, alpha_y=2.0, gamma_x=2.0, gamma_y=27.0)`
])[
  The #citet(<haagsma2012>) utility function,
  $
    u(x, y) = alpha_x ln(x - gamma_x) - alpha_y ln(gamma_y - y).
  $
  It is defined for $x > gamma_x$ and $0 <= y < gamma_y$, and requires
  $0 < alpha_x < alpha_y$. Marshallian demand for $x$ falls with income, and
  $x$ is a Giffen good when $gamma_y p_y < I < gamma_y p_y + gamma_x p_x$.

  Once income reaches $gamma_y p_y + gamma_x p_x$, utility has no finite
  maximum on the budget line and the model raises `InvalidParameterError`.
]

#param("alpha_x", default: "1.0")[Weight on good $x$; must be less than `alpha_y`.]
#param("alpha_y", default: "2.0")[Weight on good $y$.]
#param("gamma_x", default: "2.0")[Lower bound on the quantity of $x$.]
#param("gamma_y", default: "27.0")[Upper bound on the quantity of $y$.]
#param("demand(px, py, income)")[Closed-form interior solution.]
#param("is_giffen(px, py, income)")[Whether $x$ is a Giffen good at the given budget.]

#fig("/figures/models/haagsma.svg", width: 42%, caption: [Haagsma with $gamma_y = 10$.])

=== Stone-Geary

#api(("StoneGeary",), syntax: [`StoneGeary(alpha=0.5, beta=0.5, bar_x=1.0, bar_y=1.0)`])[
  Cobb-Douglas with minimum consumption requirements
  #citep(<stone1954>)#citep(<geary1950>):
  $ u(x, y) = (x - overline(x))^alpha (y - overline(y))^beta. $
  The consumer first covers the subsistence quantities $overline(x)$ and
  $overline(y)$, then allocates the remaining income like a Cobb-Douglas
  consumer.
]

#param("alpha", default: "0.5")[Weight on supernumerary $x$.]
#param("beta", default: "0.5")[Weight on supernumerary $y$.]
#param("bar_x", default: "1.0")[Subsistence quantity $overline(x)$.]
#param("bar_y", default: "1.0")[Subsistence quantity $overline(y)$.]

#fig("/figures/models/stone_geary.svg", width: 42%, caption: [
  Stone-Geary with $overline(x) = overline(y) = 2$.
])

=== Satiation

#api(("Satiation",), syntax: [`Satiation(bliss_x=5.0, bliss_y=5.0, a=1.0, b=1.0)`])[
  A bliss point that maximises utility:
  $ u(x, y) = -a (x - x^*)^2 - b (y - y^*)^2. $
  Utility falls in every direction away from $(x^*, y^*)$, so the
  indifference curves are closed ellipses and monotonicity does not hold.
]

#param("bliss_x", default: "5.0")[Bliss-point coordinate $x^*$.]
#param("bliss_y", default: "5.0")[Bliss-point coordinate $y^*$.]
#param("a", default: "1.0")[Curvature along the $x$-axis.]
#param("b", default: "1.0")[Curvature along the $y$-axis.]

#fig("/figures/models/satiation.svg", width: 42%, caption: [
  Satiation around the bliss point $(6, 4)$.
])

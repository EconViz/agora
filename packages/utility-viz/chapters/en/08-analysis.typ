#import "/template/manual.typ": *

= Analysis <sec-analysis>

The analysis API provides comparative statics of Marshallian demand, the
Slutsky matrix, and checks for homogeneity and homotheticity of utility
functions.

== Comparative statics

#changed("1.7.0", label: "comparative_statics")[Comparative statics no longer step outside the domain near zero prices or income, or near subsistence constraints]
#changed("1.1.0", label: "comparative_statics")[`comparative_statics` helper]

#api(("comparative_statics",), added: "v1.1.0", syntax: [
  #raw("comparative_statics(")#meta("model")#raw(", px=")#meta("float")#raw(", py=")#meta("float")#raw(
    ", income=",
  )#meta("float")#raw(")")
])[
  Estimate the six partial derivatives of two-good Marshallian demand with
  respect to $p_x$, $p_y$ and income by finite differences, returned as a
  `ComparativeStatics`.

  - Central finite differences around `solve(...)`, with a default
    relative step of `1e-3`.
  - Warns when the own-price derivative is positive or the income
    derivative negative, the signatures of Giffen and inferior goods.
]

#param("dx_dpx", type: "float")[$partial x^* slash partial p_x$.]
#param("dx_dpy", type: "float")[$partial x^* slash partial p_y$.]
#param("dx_dI", type: "float")[$partial x^* slash partial I$.]
#param("dy_dpx", type: "float")[$partial y^* slash partial p_x$.]
#param("dy_dpy", type: "float")[$partial y^* slash partial p_y$.]
#param("dy_dI", type: "float")[$partial y^* slash partial I$.]

#modify[```python
from utility_viz import comparative_statics
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.4, beta=0.6)
cs = comparative_statics(model, px=2.0, py=3.0, income=60.0)

print(round(cs.dx_dpx, 1), round(cs.dx_dpy, 1), round(cs.dx_dI, 1))
print(round(cs.dy_dpx, 1), round(cs.dy_dpy, 1), round(cs.dy_dI, 1))

# -6.0 0.0 0.2
# 0.0 -4.0 0.2
```]

== Slutsky matrix

#changed("1.2.3", label: "slutsky_matrix")[`SlutskyMatrix` checks symmetry, negative semidefiniteness and homogeneity, and warns when a condition fails]

#api(("slutsky_matrix",), updated: "v1.2.3", syntax: [
  #raw("slutsky_matrix(")#meta("model")#raw(", px=")#meta("float")#raw(", py=")#meta("float")#raw(", income=")#meta(
    "float",
  )#raw(")")
])[
  The two-good Slutsky substitution matrix, computed from Marshallian
  demand derivatives and income effects. The result checks
  symmetry, negative semidefiniteness and homogeneity, and warns when a
  condition fails. `as_array()` returns it as a #pkg("NumPy") array.
]

#modify[```python
from utility_viz import slutsky_matrix
from utility_viz.models import CobbDouglas

S = slutsky_matrix(
    CobbDouglas(alpha=0.4, beta=0.6),
    px=2.0, py=3.0, income=60.0,
)

print(round(S.s_xx, 1), round(S.s_xy, 1))
print(round(S.s_yx, 1), round(S.s_yy, 1))
print(S.as_array().round(1))

# -3.6 2.4
# 2.4 -1.6
# [[-3.6  2.4]
#  [ 2.4 -1.6]]
```]

== Homogeneity

#changed("1.1.0", label: "HomogeneityAnalyzer")[`HomogeneityAnalyzer` and `ReturnsToScale` in the analysis module]

#api(("HomogeneityAnalyzer",), added: "v1.1.0", syntax: [
  #raw("HomogeneityAnalyzer(")#meta("model")#raw(")")
])[
  Check homogeneity and homotheticity of a utility function, and
  degree-zero homogeneity of demand.
]

#param("degree()")[Estimate the degree of homogeneity; see @sec-rts.]
#param("euler_check(x, y)")[Euler-theorem residual at a bundle.]
#param("is_homothetic()")[Whether the MRS is invariant to proportional scaling.]
#param("demand_degree_zero(px, py, income)")[
  Whether Marshallian demand is homogeneous of degree zero.
]

#modify[```python
from utility_viz.models import CobbDouglas, HomogeneityAnalyzer

analyzer = HomogeneityAnalyzer(CobbDouglas(alpha=0.4, beta=0.6))
result = analyzer.degree()

print(round(result.degree, 6))
print(result.returns_to_scale)
print(round(analyzer.euler_check(3.0, 4.0), 6))
print(analyzer.is_homothetic())
print(analyzer.demand_degree_zero(px=2.0, py=3.0, income=60.0))

# 1.0
# ReturnsToScale.CONSTANT
# 0.0
# True
# True
```]

== Returns to scale <sec-rts>

`degree()` returns a `HomogeneityResult` with these fields:

#param("degree", type: "float")[Estimated degree of homogeneity.]
#param("is_homogeneous", type: "bool")[Whether the function is homogeneous.]
#param("returns_to_scale", type: "ReturnsToScale")[Returns-to-scale class, one of the values below.]

For Cobb-Douglas utility the degree is $alpha + beta$:
$ u(lambda x, lambda y) = lambda^(alpha + beta) u(x, y). $

#param("INCREASING")[$alpha + beta > 1$, increasing returns.]
#param("CONSTANT")[$alpha + beta = 1$, constant returns.]
#param("DECREASING")[$alpha + beta < 1$, decreasing returns.]
#param("NOT_HOMOGENEOUS")[No consistent degree of homogeneity.]

```python
def shifted_utility(x, y):
    return x**0.4 * y**0.6 + 1.0


models = [
    CobbDouglas(alpha=0.7, beta=0.6),
    CobbDouglas(alpha=0.4, beta=0.6),
    CobbDouglas(alpha=0.2, beta=0.5),
    shifted_utility,
]

for model in models:
    result = HomogeneityAnalyzer(model).degree()
    degree = None if result.degree is None else round(result.degree, 1)
    print(degree, result.returns_to_scale.name)

# 1.3 INCREASING
# 1.0 CONSTANT
# 0.7 DECREASING
# None NOT_HOMOGENEOUS
```

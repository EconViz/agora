#import "/template/manual.typ": *

= 分析 <sec-analysis>

分析 API 提供 Marshall 需求的比较静态、Slutsky 矩阵，以及效用函数的齐次性与位似性检查。

== 比较静态

#changed("1.7.0", label: "comparative_statics")[修正价格、收入接近零或基本需求限制时，比较静态计算超出定义域的问题]
#changed("1.1.0", label: "comparative_statics")[`comparative_statics` 辅助函数]

#api(("comparative_statics",), added: "v1.1.0", syntax: [
  #raw("comparative_statics(")#meta("model")#raw(", px=")#meta("float")#raw(", py=")#meta("float")#raw(
    ", income=",
  )#meta("float")#raw(")")
])[
  以有限差分估计两商品 Marshall 需求对 $p_x$、$p_y$ 与收入的六个偏导数，返回 `ComparativeStatics`。

  - 在 `solve(...)` 的结果附近使用中央有限差分，默认的相对步长是 `1e-3`。
  - 检测到自身价格导数为正或收入导数为负时会发出警告，分别对应季芬财与劣等财的需求特性。
]

#param("dx_dpx", type: "float")[$partial x^* slash partial p_x$。]
#param("dx_dpy", type: "float")[$partial x^* slash partial p_y$。]
#param("dx_dI", type: "float")[$partial x^* slash partial I$。]
#param("dy_dpx", type: "float")[$partial y^* slash partial p_x$。]
#param("dy_dpy", type: "float")[$partial y^* slash partial p_y$。]
#param("dy_dI", type: "float")[$partial y^* slash partial I$。]

```python
from utility_viz import comparative_statics
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.4, beta=0.6)
cs = comparative_statics(model, px=2.0, py=3.0, income=60.0)

print(round(cs.dx_dpx, 1), round(cs.dx_dpy, 1), round(cs.dx_dI, 1))
print(round(cs.dy_dpx, 1), round(cs.dy_dpy, 1), round(cs.dy_dI, 1))

# -6.0 0.0 0.2
# 0.0 -4.0 0.2
```

== Slutsky 矩阵

#changed("1.2.3", label: "slutsky_matrix")[`SlutskyMatrix` 会检查对称性、负半定性与齐次性，条件不成立时发出警告]

#api(("slutsky_matrix",), updated: "v1.2.3", syntax: [
  #raw("slutsky_matrix(")#meta("model")#raw(", px=")#meta("float")#raw(", py=")#meta("float")#raw(", income=")#meta(
    "float",
  )#raw(")")
])[
  以 Marshall 需求导数与收入效应计算两商品的 Slutsky 替代矩阵，并检查对称性、负半定性与齐次性；检查未通过时发出警告。使用 `as_array()` 可转为 #pkg("NumPy") 数组。
]

```python
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
```

== 齐次性

#changed("1.1.0", label: "HomogeneityAnalyzer")[分析模块中的 `HomogeneityAnalyzer` 与 `ReturnsToScale`]

#api(("HomogeneityAnalyzer",), added: "v1.1.0", syntax: [
  #raw("HomogeneityAnalyzer(")#meta("model")#raw(")")
])[
  检查效用函数的齐次性、位似性与需求的零次齐次性。
]

#param("degree()")[估计齐次次数，详见#ref(<sec-rts>)。]
#param("euler_check(x, y)")[计算指定消费组合的 Euler 定理残差。]
#param("is_homothetic()")[边际替代率（MRS）在等比例缩放下是否不变。]
#param("demand_degree_zero(px, py, income)")[
  Marshall 需求是否为零次齐次。
]

```python
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
```

== 规模报酬 <sec-rts>

`degree()` 返回 `HomogeneityResult`，包含下列字段：

#param("degree", type: "float")[估计的齐次次数。]
#param("is_homogeneous", type: "bool")[是否为齐次函数。]
#param("returns_to_scale", type: "ReturnsToScale")[规模报酬的分类，取值如下。]

Cobb-Douglas 的齐次次数为 $alpha + beta$：
$ u(lambda x, lambda y) = lambda^(alpha + beta) u(x, y). $

#param("INCREASING")[$alpha + beta > 1$，规模报酬递增。]
#param("CONSTANT")[$alpha + beta = 1$，规模报酬不变。]
#param("DECREASING")[$alpha + beta < 1$，规模报酬递减。]
#param("NOT_HOMOGENEOUS")[没有一致的齐次次数。]

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

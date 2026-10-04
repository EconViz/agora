#import "/template/manual.typ": *

= 构造与 Hermite 插值 <sec-construction>

三次曲线由两个端点及其导数决定。本章的构造方法把这类端点条件转为控制点，经济学中只知道几个数值与斜率的曲线，就是这样变成 Bézier 曲线。

== 端点构造

每种构造都是带有 `build()` 方法的不可变 dataclass，位于 `bezierkit.construction`。

#api(("EndpointDerivatives",), syntax: [
  #raw("EndpointDerivatives(start, end, start_derivative, end_derivative).build()")
])[
  满足 $B(0) = $ `start`、$B(1) = $ `end`、$B'(0) = $ `start_derivative`、$B'(1) = $ `end_derivative` 的三次曲线，维度不限。
]

#theorem(name: [端点条件])[
  控制点为 $P_0$、$P_0 + D_0 slash 3$、$P_3 - D_1 slash 3$、$P_3$ 的三次曲线，是唯一满足 $B(0) = P_0$、$B(1) = P_3$、$B'(0) = D_0$、$B'(1) = D_1$ 的三次曲线。
] <thm-endpoint>

#api(("TangentDirections",), syntax: [
  #raw("TangentDirections(start, end, start_direction, end_direction, start_handle=1.0, end_handle=1.0).build()")
])[
  以方向给定端点切线，控制柄长度为 $|P_1 - P_0| = $ `start_handle`、$|P_3 - P_2| = $ `end_handle`。方向会先归一化，因此只有方向有影响；控制柄长度必须为有限的非负值。根据#ref(<thm-endpoint>)，$B'(0)$ 等于 3 倍 `start_handle` 乘以起点的单位方向。
]

#api(("PlanarSlopes",), syntax: [
  #raw("PlanarSlopes(start, end, start_slope, end_slope, start_handle=1.0, end_handle=1.0).build()")
])[
  两端斜率 $dif y slash dif x$ 为给定值的平面三次曲线，以方向 $(1, m)$ 的 `TangentDirections` 构造。斜率必须为有限值；垂直切线请改用 `TangentDirections`。
]

```python
from bezierkit.construction import PlanarSlopes

demand = PlanarSlopes(
    start=Point(0, 5), end=Point(5, 0), start_slope=-2, end_slope=-0.3,
).build()
print(demand.control_points[1])   # (0.447, 4.106): one unit from (0, 5) along slope -2
```

== Hermite 插值

三次 Hermite 插值在区间两端同时吻合函数值与导数。在宽度为 $h = t_1 - t_0$ 的参数区间 $[t_0, t_1]$ 上，Bézier 线段在 $s = (t - t_0) slash h$ 处求值，导数因此乘上 $h$。

#api(("parametric_hermite",), syntax: [
  #raw("parametric_hermite(p0, p3, derivative0, derivative1, *, t0=0.0, t1=1.0)")
])[
  控制点为 $P_0$、$P_0 + h D_0 slash 3$、$P_3 - h D_1 slash 3$、$P_3$ 的三次线段，位于 `bezierkit.interpolation`。$h = 0$ 时抛出 `ValueError`；$h$ 为负表示反向的区间。
]

#theorem(name: [Hermite 插值])[
  对 `parametric_hermite` 返回的线段，令 $H(t) = B((t - t_0) slash h)$。则 $H(t_0) = P_0$、$H(t_1) = P_3$、$H'(t_0) = D_0$、$H'(t_1) = D_1$。
] <thm-hermite>

#api(("graph_hermite",), syntax: [
  #raw("graph_hermite(*, x0, x1, y0, y1, m0, m1)")
])[
  由函数值 $y_0 = f(x_0)$、$y_1 = f(x_1)$ 与斜率 $m_0 = f'(x_0)$、$m_1 = f'(x_1)$ 得到图形 $y = f(x)$ 的插值曲线，即取 $P = (x, f(x))$、$D = (1, f'(x))$、$t = x$ 的参数形式。控制点为
  $ (x_0, y_0), quad (x_0 + h/3, y_0 + h m_0 slash 3), quad (x_1 - h/3, y_1 - h m_1 slash 3), quad (x_1, y_1), $
  其中 $h = x_1 - x_0$；它们的 $x$ 坐标等距，因此线段仍是某个函数的图形（参见#ref(<fig-hermite>)）。
]

```python
from bezierkit.interpolation import graph_hermite

# f(x) = 4 / x^2 on [1, 1.5]
segment = graph_hermite(x0=1, x1=1.5, y0=4, y1=16 / 9, m0=-8, m1=-64 / 27)
```

#fig("/figures/construction/hermite.pdf", width: auto, caption: [
  $4 slash x^2$ 在 $[1, 1.5]$ 的 Hermite 插值。
]) <fig-hermite>

== 插值误差

#theorem(name: [Hermite 误差界限])[
  设 $f$ 在 $[x_0, x_1]$ 上四阶连续可微，$H$ 为其三次 Hermite 插值，$h = x_1 - x_0$，$M = max |f^((4))|$。则
  $ max_(x in [x_0, x_1]) |f(x) - H(x)| <= M h^4 / 384. $
] <thm-hermite-error>

区间减半时界限变为 1/16，自适应拟合正是利用这一点（详见#ref(<sec-fitting>)）。以 $f(x) = 4 slash x^2$ 在 $[1, 1.5]$ 为例，$f^((4))(x) = 480 slash x^6$，故 $M = 480$，界限为 $480 dot 0.5^4 slash 384 approx 0.078$。

#api(("hermite_error_bound",), syntax: [
  #raw("hermite_error_bound(max_fourth_derivative, t0, t1)")
])[
  #ref(<thm-hermite-error>)的界限 $M |t_1 - t_0|^4 slash 384$，位于 `bezierkit.fitting`。$M$ 必须为有限的非负值。
]

此界限适用于纯量函数。对曲线 $t |-> (x(t), y(t))$，分别套用到每个坐标；欧氏误差最多为两者中较大界限的 $sqrt(2)$ 倍。

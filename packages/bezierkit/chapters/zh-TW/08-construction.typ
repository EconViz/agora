#import "/template/manual.typ": *

= 建構與 Hermite 插值 <sec-construction>

三次曲線由兩個端點及其導數決定。本章的建構方法把這類端點條件轉為控制點，經濟學中只知道幾個數值與斜率的曲線，就是這樣變成 Bézier 曲線。

== 端點建構

每種建構都是帶有 `build()` 方法的不可變 dataclass，位於 `bezierkit.construction`。

#api(("EndpointDerivatives",), syntax: [
  #raw("EndpointDerivatives(start, end, start_derivative, end_derivative).build()")
])[
  滿足 $B(0) = $ `start`、$B(1) = $ `end`、$B'(0) = $ `start_derivative`、$B'(1) = $ `end_derivative` 的三次曲線，維度不限。
]

#proposition(name: [端點條件])[
  控制點為 $P_0$、$P_0 + D_0 slash 3$、$P_3 - D_1 slash 3$、$P_3$ 的三次曲線，是唯一滿足 $B(0) = P_0$、$B(1) = P_3$、$B'(0) = D_0$、$B'(1) = D_1$ 的三次曲線。
] <prop-endpoint>

#api(("TangentDirections",), syntax: [
  #raw("TangentDirections(start, end, start_direction, end_direction, start_handle=1.0, end_handle=1.0).build()")
])[
  以方向給定端點切線，控制柄長度為 $|P_1 - P_0| = $ `start_handle`、$|P_3 - P_2| = $ `end_handle`。方向會先正規化，因此只有方向有影響；控制柄長度必須為有限的非負值。依#ref(<prop-endpoint>)，$B'(0)$ 等於 3 倍 `start_handle` 乘以起點的單位方向。
]

#api(("PlanarSlopes",), syntax: [
  #raw("PlanarSlopes(start, end, start_slope, end_slope, start_handle=1.0, end_handle=1.0).build()")
])[
  兩端斜率 $dif y slash dif x$ 為給定值的平面三次曲線，以方向 $(1, m)$ 的 `TangentDirections` 建構。斜率必須為有限值；垂直切線請改用 `TangentDirections`。
]

```python
from bezierkit.construction import PlanarSlopes

demand = PlanarSlopes(
    start=Point(0, 5), end=Point(5, 0), start_slope=-2, end_slope=-0.3,
).build()
print(demand.control_points[1])   # (0.447, 4.106): one unit from (0, 5) along slope -2
```

== Hermite 插值

三次 Hermite 插值在區間兩端同時吻合函數值與導數。

#definition(name: [三次 Hermite 插值多項式])[
  設 $f$ 在 $[x_0, x_1]$ 上可微，$x_0 != x_1$。其三次 Hermite 插值多項式是次數不超過 3、滿足 $H(x_i) = f(x_i)$ 與 $H'(x_i) = f'(x_i)$（$i = 0, 1$）的多項式 $H$。對曲線則逐一插值每個座標。
] <def-hermite>

將區間重新縮放到 $[0, 1]$ 後，就單一座標套用#ref(<prop-endpoint>)，可知它存在且唯一。在寬度為 $h = t_1 - t_0$ 的參數區間 $[t_0, t_1]$ 上，Bézier 線段在 $s = (t - t_0) slash h$ 處求值，導數因此乘上 $h$。

#api(("parametric_hermite",), syntax: [
  #raw("parametric_hermite(p0, p3, derivative0, derivative1, *, t0=0.0, t1=1.0)")
])[
  控制點為 $P_0$、$P_0 + h D_0 slash 3$、$P_3 - h D_1 slash 3$、$P_3$ 的三次線段，位於 `bezierkit.interpolation`。$h = 0$ 時拋出 `ValueError`；$h$ 為負表示反向的區間。
]

#proposition(name: [Hermite 插值])[
  對 `parametric_hermite` 回傳的線段，令 $H(t) = B((t - t_0) slash h)$。則 $H(t_0) = P_0$、$H(t_1) = P_3$、$H'(t_0) = D_0$、$H'(t_1) = D_1$。
] <prop-hermite>

#api(("graph_hermite",), syntax: [
  #raw("graph_hermite(*, x0, x1, y0, y1, m0, m1)")
])[
  由函數值 $y_0 = f(x_0)$、$y_1 = f(x_1)$ 與斜率 $m_0 = f'(x_0)$、$m_1 = f'(x_1)$ 得到圖形 $y = f(x)$ 的插值曲線，即取 $P = (x, f(x))$、$D = (1, f'(x))$、$t = x$ 的參數形式。控制點為
  $ (x_0, y_0), quad (x_0 + h/3, y_0 + h m_0 slash 3), quad (x_1 - h/3, y_1 - h m_1 slash 3), quad (x_1, y_1), $
  其中 $h = x_1 - x_0$；它們的 $x$ 座標等距，因此線段仍是某個函數的圖形（參見#ref(<fig-hermite>)）。
]

```python
from bezierkit.interpolation import graph_hermite

# f(x) = 4 / x^2 on [1, 1.5]
segment = graph_hermite(x0=1, x1=1.5, y0=4, y1=16 / 9, m0=-8, m1=-64 / 27)
```

#fig("/figures/construction/hermite.pdf", width: auto, caption: [
  $4 slash x^2$ 在 $[1, 1.5]$ 的 Hermite 插值。
]) <fig-hermite>

== 插值誤差

#theorem(name: [Hermite 誤差界限])[
  設 $f$ 在 $[x_0, x_1]$ 上四階連續可微，$H$ 為其三次 Hermite 插值多項式（詳見#ref(<def-hermite>)），$h = x_1 - x_0$，$M = max |f^((4))|$。則
  $ max_(x in [x_0, x_1]) |f(x) - H(x)| <= M h^4 / 384. $
] <thm-hermite-error>

區間減半時界限變為 1/16，自適應擬合正是利用這一點（詳見#ref(<sec-fitting>)）。以 $f(x) = 4 slash x^2$ 在 $[1, 1.5]$ 為例，$f^((4))(x) = 480 slash x^6$，故 $M = 480$，界限為 $480 dot 0.5^4 slash 384 approx 0.078$。

#api(("hermite_error_bound",), syntax: [
  #raw("hermite_error_bound(max_fourth_derivative, t0, t1)")
])[
  #ref(<thm-hermite-error>)的界限 $M |t_1 - t_0|^4 slash 384$，位於 `bezierkit.fitting`。$M$ 必須為有限的非負值。
]

此界限適用於純量函數。對曲線 $t |-> (x(t), y(t))$，分別套用到每個座標；歐氏誤差至多為兩者中較大界限的 $sqrt(2)$ 倍。

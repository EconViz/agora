#import "/template/manual.typ": *

== 三次线段与路径

#proof(of: <prop-bbox>)[
  展开三次 Bernstein 形式并依 $t$ 的次方合并，
  $ B(t) &= (1-t)^3 P_0 + 3t(1-t)^2 P_1 + 3t^2(1-t) P_2 + t^3 P_3 \
         &= (1 - 3t + 3t^2 - t^3) P_0 + (3t - 6t^2 + 3t^3) P_1 + (3t^2 - 3t^3) P_2 + t^3 P_3 \
         &= a t^3 + b t^2 + c t + P_0, $
  其中 $a$、$b$、$c$ 如命题所述。

  固定坐标 $k$。$B_k$ 是多项式，在紧致区间 $[0, 1]$ 上连续，因此在其上取得最小值与最大值。设 $t^*$ 是取得其中一个的点。若 $t^* in (0, 1)$，则 $B_k$ 在内点有极值且可微，故 $B'_k (t^*) = 0$（Fermat 定理）。分两种情形。
  - $B'_k$ 不恒为零。它是次数至多为 2 的多项式，至多有两个根；若 $t^*$ 在 $(0, 1)$ 内，它就是其中之一。每种情形都有 $t^* in T_k$。
  - $B'_k$ 恒为零。则 $B_k$ 为常数，其极值在 $t = 0$ 也取得，且 $0 in T_k$。
  因此 $B_k$ 在 $[0, 1]$ 上的最小值与最大值，等于它在有限集 $T_k subset [0, 1]$ 上的最小值与最大值，也就是命题中的 $alpha_k$ 与 $beta_k$，因为它们就是 $B_k$ 在曲线上的下确界与上确界。由#ref(<def-bbox>)，边界框是各区间 $[alpha_k, beta_k]$ 的乘积：包含曲线的方框必包含每个值 $B_k (t)$，因而包含 $alpha_k$ 与 $beta_k$；而这些区间的乘积本身就包含曲线。
]

#proof(of: <prop-elevation>)[
  _直线。_直线 $t |-> (1 - t) P_0 + t P_3$ 是控制点为 $R_0 = P_0$、$R_1 = P_3$ 的一次 Bézier 曲线。由#ref(<prop-raise-degree>)取 $n = 1$，它是控制点为
  $ Q_0 = P_0, quad Q_1 = 1/2 P_0 + 1/2 P_3, quad Q_2 = P_3 $
  的二次曲线。再套用#ref(<prop-raise-degree>)取 $n = 2$，得到控制点为
  $ S_0 &= Q_0 = P_0, \
    S_1 &= 1/3 Q_0 + 2/3 Q_1 = 2/3 P_0 + 1/3 P_3, \
    S_2 &= 2/3 Q_1 + 1/3 Q_2 = 1/3 P_0 + 2/3 P_3, \
    S_3 &= Q_2 = P_3 $
  的三次曲线，亦即对 $i = 0, dots, 3$ 有 $S_i = P_0 + i/3 (P_3 - P_0)$。

  _二次曲线。_由#ref(<prop-raise-degree>)取 $n = 2$ 与控制点 $P_0, C, P_3$，三次控制点为
  $ Q_0 = P_0, quad Q_1 = 1/3 P_0 + 2/3 C, quad Q_2 = 2/3 C + 1/3 P_3, quad Q_3 = P_3, $
  即 $Q_1 = P_0 + 2/3 (C - P_0)$、$Q_2 = P_3 + 2/3 (C - P_3)$。

  每一步都是关于 $t$ 的恒等式，因此曲线与其参数化不变。
]

#proof(of: <prop-continuity>)[
  令 $B_S$、$B_T$ 为控制点分别是 $P_i$ 与 $Q_i$ 的三次 Bézier 曲线，使 $S(u) = B_S ((u - u_0 + h_S) slash h_S)$、$T(u) = B_T ((u - u_0) slash h_T)$。在 $u = u_0$ 处，两个参数分别为 $1$ 与 $0$。由#ref(<prop-endpoints>)，$S(u_0) = P_3$、$T(u_0) = Q_0$。由连锁律与#ref(<cor-end-tangents>)，
  $ S'(u_0) = (B'_S (1)) / h_S = (3(P_3 - P_2)) / h_S, quad T'(u_0) = (B'_T (0)) / h_T = (3(Q_1 - Q_0)) / h_T. $
  + 由#ref(<def-continuity>)取 $k = 0$，$C$ 在 $u_0$ 为 $C^0$ 若且唯若 $S(u_0) = T(u_0)$，即 $P_3 = Q_0$。
  + 当 $P_3 = Q_0$，#ref(<def-continuity>)取 $k = 1$ 多出 $S'(u_0) = T'(u_0)$ 的条件，两边除以 3 即所述等式。
  + 当 $P_3 = Q_0$，由#ref(<def-geometric-continuity>)，接点为 $G^1$ 若且唯若 $S'(u_0) != 0$、$T'(u_0) != 0$，且存在 $lambda > 0$ 使 $T'(u_0) = lambda S'(u_0)$。两个切矢量皆非零，若且唯若 $P_3 != P_2$ 且 $Q_1 != Q_0$，此时
    $ Q_1 - Q_0 = (lambda h_T / h_S) (P_3 - P_2). $
    反之，若 $Q_1 - Q_0 = mu (P_3 - P_2)$ 且 $mu > 0$，取 $lambda = mu h_S slash h_T > 0$，即得 $T'(u_0) = lambda S'(u_0)$。
  + 均匀参数化下，$m$ 段路径的每段占 $1 slash m$，故 $h_S = h_T$，第 2 项的等式化为 $P_3 - P_2 = Q_1 - Q_0$。
]

== 建构与插值

#proof(of: <prop-endpoint>)[
  对具所述控制点的曲线 $B$，由#ref(<prop-endpoints>)得 $B(0) = P_0$、$B(1) = P_3$，由#ref(<cor-end-tangents>)得
  $ B'(0) = 3(P_1 - P_0) = D_0, quad B'(1) = 3(P_3 - P_2) = D_1. $
  再设 $Gamma$ 是任一次数至多为 3、满足 $Gamma(0) = P_0$、$Gamma(1) = P_3$、$Gamma'(0) = D_0$、$Gamma'(1) = D_1$ 的多项式曲线。对每个坐标套用#ref(<prop-basis>)，存在唯一的 $R_0, dots, R_3$ 使 $Gamma(t) = sum_i b_(i,3)(t) R_i$。对控制点 $R_i$ 作上述计算，得
  $ Gamma(0) = R_0, quad Gamma(1) = R_3, quad Gamma'(0) = 3(R_1 - R_0), quad Gamma'(1) = 3(R_3 - R_2). $
  与四个条件比较，得 $R_0 = P_0$、$R_3 = P_3$、$R_1 = P_0 + D_0 slash 3$、$R_2 = P_3 - D_1 slash 3$。所以 $R_i$ 就是所述的控制点，$Gamma = B$。
]

#proof(of: <prop-hermite-unique>)[
  令 $G(s) = H(x_0 + h s)$。映射 $H |-> G$ 是次数至多为 3 的多项式集合上的双射，反映射为 $G |-> G((x - x_0) slash h)$。由连锁律，$H(x_i) = f_i$ 与 $H'(x_i) = m_i$（$i = 0, 1$）等价于
  $ G(0) = f_0, quad G(1) = f_1, quad G'(0) = h m_0, quad G'(1) = h m_1. $
  由#ref(<prop-endpoint>)取 $d = 1$、$P_0 = f_0$、$P_3 = f_1$、$D_0 = h m_0$、$D_1 = h m_1$，恰有一个次数至多为 3 的多项式 $G$ 满足这四个条件，其 Bernstein 系数为 $c_0, dots, c_3$。因此 $H$ 存在、唯一，且等于 $sum_i b_(i,3)((x - x_0) slash h) c_i$。
]

#proof(of: <prop-hermite>)[
  在 $t = t_0$ 与 $t = t_1$，线段分别于 $s = 0$ 与 $s = 1$ 求值，由#ref(<prop-endpoints>)得 $H(t_0) = P_0$、$H(t_1) = P_3$。由连锁律，$H'(t) = B'(s) slash h$。由#ref(<cor-end-tangents>)，$B'(0) = 3(P_1 - P_0) = h D_0$、$B'(1) = 3(P_3 - P_2) = h D_1$，故 $H'(t_0) = D_0$、$H'(t_1) = D_1$。证明中不需要 $h > 0$。
]

#proof(of: <prop-graph-hermite>)[
  将线段写成 $(X(s), Y(s))$。$X$ 的控制点为
  $ x_0, quad x_0 + h/3, quad x_1 - h/3 = x_0 + 2h/3, quad x_1, $
  由#ref(<prop-elevation>)（由 $x_0$ 到 $x_1$ 的直线），它们正是直线 $s |-> x_0 + h s$ 的控制点，故 $X(s) = x_0 + h s$。$Y$ 的控制点为 $y_0, y_0 + h m_0 slash 3, y_1 - h m_1 slash 3, y_1$，即#ref(<prop-hermite-unique>)中对数据 $y_i = f(x_i)$、$m_i = f'(x_i)$ 的系数 $c_0, dots, c_3$。因此 $Y(s) = H(x_0 + h s)$，线段为 $s |-> (x_0 + h s, H(x_0 + h s))$。
]

#proof(of: <thm-hermite-error>)[
  $x in {x_0, x_1}$ 的情形是平凡的：第一个公式两边皆为零，对任何 $xi$ 都成立。设 $x_0 < x < x_1$，并令
  $ E = f - H, quad w(t) = (t - x_0)^2 (t - x_1)^2, quad K = E(x) / w(x), quad g = E - K w. $
  则 $w(x) > 0$，$g$ 四阶连续可微，且 $g(x_0) = g(x) = g(x_1) = 0$：$E$ 与 $w$ 在 $x_0$、$x_1$ 为零，而 $g(x) = E(x) - K w(x) = 0$。此外 $g'(x_0) = g'(x_1) = 0$：由#ref(<def-hermite>)，$E'(x_i) = f'(x_i) - H'(x_i) = 0$，而 $w$ 在每个 $x_i$ 有二重根，故 $w'(x_i) = 0$。

  由 Rolle 定理（#citet(<burden2011>) 的定理 1.7），$g'$ 在某个 $xi_1 in (x_0, x)$ 与某个 $xi_2 in (x, x_1)$ 为零。因此 $g'$ 有四个相异零点 $x_0 < xi_1 < xi_2 < x_1$。$g'$ 连续且三阶可微，由广义 Rolle 定理（#citet(<burden2011>) 的定理 1.10），存在 $xi in (x_0, x_1)$ 使 $g^((4))(xi) = 0$。由于 $H$ 的次数至多为 3，而 $w$ 是首项系数为 1 的四次多项式，$H^((4)) = 0$、$w^((4)) = 24$，因此
  $ 0 = g^((4))(xi) = f^((4))(xi) - 24 K, quad "即" quad K = (f^((4))(xi)) / 24. $
  故 $f(x) - H(x) = E(x) = K w(x)$，这就是第一个公式。

  关于界限：$(x - x_0)(x_1 - x)$ 是两个和为 $h$ 的非负数之积，至多为 $(h slash 2)^2$。因此 $w(x) <= h^4 slash 16$，
  $ |f(x) - H(x)| <= M / 24 dot h^4 / 16 = (M h^4) / 384. $
]

== 拟合与等值线

#proof(of: <cor-depth>)[
  设 $[a, b]$ 是深度 $k$ 的区间，则 $b - a = L slash 2^k$。在此区间上，Hermite 线段的每个坐标都是 $C$ 同一坐标的三次 Hermite 插值多项式（详见#ref(<prop-hermite>)与#ref(<prop-hermite-unique>)），因此由#ref(<thm-hermite-error>)，其误差不超过 $M (b - a)^4 slash 384$。任一参数处的欧氏误差至多为最大坐标误差的 $sqrt(d)$ 倍，因为对 $v in RR^d$ 有 $norm(v)_2 <= sqrt(d) norm(v)_oo$：事实上 $norm(v)_2^2 = sum_k v_k^2 <= d norm(v)_oo^2$。特别地，在量测参数上取最大值得到的实测误差满足
  $ e <= sqrt(d) M L^4 / (384 dot 2^(4k)). $
  此值不超过 $epsilon$，若且唯若 $2^(4k) >= sqrt(d) M L^4 slash (384 epsilon)$，也就是 $k >= 1/4 log_2 (sqrt(d) M L^4 slash (384 epsilon))$。每个 $k >= k^*$ 都满足此式，所以该深度的每个区间都会被接受。

  再设 `max_depth` $>= k^*$ 且 `max_segments` $>= 2^(k^*)$。区间只有在不合格时才会被分割，而这只发生在深度 $k < k^*$。因此所有区间的深度至多为 $k^*$，不会因深度而抛出 `ToleranceNotMet`。被接受的区间是把 $[t_0, t_1]$ 对半至多 $k^*$ 次得到的互不重叠的片段，所以至多有 $2^(k^*)$ 个。不合格的区间至少会产生两个被接受的线段，因此「目前已接受的线段数加二」不会超过这个最终数目，而它至多为 `max_segments`；所以线段数上限也不会被超过。
]

#proof(of: <prop-rdp>)[
  以 `rdp`$(i, j)$ 表示算法对指针 $i < j$ 运行的递归步骤，它回传由 $i$ 到 $j$ 的递增指针列表。对 $j - i$ 作强归纳，证明对回传列表中任两个相邻指针 $u < v$，每个满足 $u <= l <= v$ 的指针 $l$ 都有 $"dist"(v_l, [v_u, v_v]) <= epsilon$。

  _基底。_若 $j <= i + 1$，列表为 $(i, j)$，且介于 $i$ 与 $j$（含）之间的指针只有 $i$ 与 $j$，其顶点就是弦的端点，距离为零。

  _归纳步骤。_否则令 $delta^*$ 为严格介于 $i$ 与 $j$ 之间的顶点到 $[v_i, v_j]$ 的最大距离。若 $delta^* <= epsilon$，列表为 $(i, j)$，由 $delta^*$ 的选取以及端点距离为零，结论成立。若 $delta^* > epsilon$，步骤选取指针 $m$，$i < m < j$，并回传 $"rdp"(i, m)$ 的列表接上 $"rdp"(m, j)$ 的列表，$m$ 只出现一次。结果中任两个相邻指针，在这两个列表之一中也是相邻的。由于 $m - i$ 与 $j - m$ 都小于 $j - i$，归纳假设适用于两者。

  步骤 2 与 3 对步骤 2 保留的每两个相邻顶点运行 `rdp` 并串接结果。输出恰保留回传的指针 $a_0 < dots < a_m$，其中每两个相邻指针在某个列表中也相邻。这就证明了不等式。输出线段的 `fit_error` 是 $max_(a_j <= i <= a_(j+1)) "dist"(v_i, [v_(a_j), v_(a_(j+1))])$，因此不超过 $epsilon$。
]

#proof(of: <cor-rdp-path>)[
  1. 到凸集的距离是凸函数。对线段 $K = [a, b]$，设 $x_1, x_2$ 满足 $"dist"(x_i, K) <= epsilon$，并在 $y_i in K$ 取得（由紧致性，最小值存在），$lambda in [0, 1]$。则 $lambda y_1 + (1 - lambda) y_2 in K$，由三角不等式，
  $ norm(lambda x_1 + (1 - lambda) x_2 - (lambda y_1 + (1 - lambda) y_2))_2 <= lambda norm(x_1 - y_1)_2 + (1 - lambda) norm(x_2 - y_2)_2 <= epsilon. $
  所以 $"dist"(lambda x_1 + (1 - lambda) x_2, K) <= epsilon$。

  折线上的点 $x$ 位于某条边 $[v_i, v_(i+1)]$ 上，即 $x = lambda v_i + (1 - lambda) v_(i+1)$。选取 $j$ 使 $a_j <= i < a_(j+1)$；因指针为整数，$i + 1 <= a_(j+1)$，由#ref(<prop-rdp>)，$v_i$ 与 $v_(i+1)$ 都在 $[v_(a_j), v_(a_(j+1))]$ 的 $epsilon$ 范围内。由刚证的凸性，$x$ 亦然。

  2. 通过步骤 1 的点就是某个 $v_i$，由#ref(<prop-rdp>)，它离某条弦不超过 $epsilon$。被删除的输入点 $p$ 与其前一个保留的顶点（记为 $v$）相距不超过 $delta$；设弦 $[a, b]$ 与 $v$ 相距不超过 $epsilon$，则
  $ "dist"(p, [a, b]) <= norm(p - v)_2 + "dist"(v, [a, b]) <= delta + epsilon. $
  封闭折线结尾重复的起点在同样条件下被删除，取 $v = v_0$ 即可。
]

#proof(of: <prop-center>)[
  把 $[0, 1]^2$ 的四个角代入 $u$，每个角只有一项不为零且系数为 $1$，所以 $u$ 在角点取角点值。在 $s = t = 1 slash 2$，四个权重乘积都等于 $1/2 dot 1/2 = 1/4$，因此 $u(1/2, 1/2) = 1/4 (f_(00) + f_(10) + f_(11) + f_(01))$。
]

#proof(of: <thm-gradient>)[
  因为 $nabla F(p) != 0$，$F_y (p) != 0$ 或 $F_x (p) != 0$。

  _情形 $F_y (p) != 0$。_套用#ref(<thm-ift>)：存在 $I$、$J$ 与 $C^1$ 函数 $phi : I -> J$，$phi(p_x) = p_y$，且 $L_c inter (I times J) = {(x, phi(x)) : x in I}$。令 $N = I times J$、$gamma(x) = (x, phi(x))$。对 $F(x, phi(x)) = c$ 用连锁律微分，在 $gamma(x)$ 处得 $F_x + F_y phi' = 0$。由 $F_y$ 的连续性，可缩小 $I$ 与 $J$ 使 $F_y != 0$ 在 $N$ 上成立；于是
  $ gamma'(x) = (1, phi'(x)) = (1, -F_x / F_y) = 1 / F_y (F_y, -F_x), $
  它非零，且在 $gamma(x)$ 处平行于 $(F_y, -F_x)$。

  _情形 $F_x (p) != 0$。_交换 $x$ 与 $y$ 的角色：存在 $C^1$ 函数 $psi$ 使 $L_c inter N = {(psi(y), y)}$，曲线 $gamma(y) = (psi(y), y)$，且 $psi' = -F_y slash F_x$，故
  $ gamma'(y) = (-F_y / F_x, 1) = -1 / F_x (F_y, -F_x), $
  同样非零且平行于 $(F_y, -F_x)$。

  最后 $nabla F dot (F_y, -F_x) = F_x F_y - F_y F_x = 0$。
]

== 导出

#proof(of: <prop-rounding>)[
  两条曲线的差为
  $ tilde(B)(t) - B(t) = sum_(i=0)^n b_(i,n)(t) (tilde(P)_i - P_i). $
  由#ref(<prop-unity>)，权重 $b_(i,n)(t)$ 非负且和为 1，因此对每个坐标，
  $ |tilde(B)_k (t) - B_k (t)| <= sum_(i=0)^n b_(i,n)(t) |tilde(P)_(i,k) - P_(i,k)| <= epsilon. $
  由于对 $v in RR^d$ 有 $norm(v)_2 <= sqrt(d) norm(v)_oo$（见 #citet(<golub2013>) 第 2.2 节），得 $norm(tilde(B)(t) - B(t))_2 <= sqrt(d) epsilon$。

  导出器以 Python 的定点格式写出每个坐标的 $p$ 位小数，得到最接近该坐标的 $10^(-p)$ 的整数倍，与原坐标相差至多 $1/2 dot 10^(-p)$。导出器也把绝对值小于 $1/2 dot 10^(-p)$ 的坐标写成 $0$，改变量即该绝对值，同样至多为 $1/2 dot 10^(-p)$。
]

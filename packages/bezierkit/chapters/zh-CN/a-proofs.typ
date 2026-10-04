#import "/template/manual.typ": *

= 证明 <app-proofs>

本附录按各章出现的顺序，证明其中陈述的引理、命题、定理与推论。以下 $b_(i,n)$ 为#ref(<def-bernstein>)的 Bernstein 多项式，$B$ 为#ref(<def-curve>)的 Bézier 曲线，次数为 $n$，控制点为 $P_0, dots, P_n$。

== Bernstein 基底与求值

#proof(of: <lem-binomial>)[
  指标超出所述范围时两边都为零，因此设 $0 <= j <= n$、$1 <= i <= n$。第一式通分为 $j! (n - j)!$：
  $ (n-1)! / (j! (n-1-j)!) + (n-1)! / ((j-1)! (n-j)!)
    = ((n-1)! ((n - j) + j)) / (j! (n-j)!) = binom(n, j). $
  第二式则为 $i binom(n, i) = n! slash ((i-1)! (n-i)!) = n binom(n-1, i-1)$。
]

#proof(of: <prop-unity>)[
  当 $t in [0, 1]$ 时，$t$ 与 $1 - t$ 都非负，因此每个 $b_(i,n)(t)$ 都非负。由二项式定理，
  $ sum_(i=0)^n binom(n, i) t^i (1-t)^(n-i) = (t + (1 - t))^n = 1. $
]

#proof(of: <prop-endpoints>)[
  在 $t = 0$，除非 $i = 0$，否则因子 $t^i$ 为零，且 $b_(0,n)(0) = (1 - 0)^n = 1$。在 $t = 1$，除非 $i = n$，否则因子 $(1-t)^(n-i)$ 为零，且 $b_(n,n)(1) = 1$。因此 $B(0) = sum_i b_(i,n)(0) P_i = P_0$，同理 $B(1) = P_n$。
]

#proof(of: <cor-hull>)[
  由#ref(<prop-unity>)，$B(t) = sum_i lambda_i P_i$，其中 $lambda_i = b_(i,n)(t) >= 0$ 且 $sum_i lambda_i = 1$。由定义，点的凸组合位于这些点的凸包内。
]

#proof(of: <prop-affine>)[
  由 $M$ 的线性与#ref(<prop-unity>)，
  $ A(B(t)) = M sum_i b_(i,n)(t) P_i + (sum_i b_(i,n)(t)) v
            = sum_i b_(i,n)(t) (M P_i + v)
            = sum_i b_(i,n)(t) A(P_i). $
]

#proof(of: <thm-casteljau>)[
  对 $r$ 作归纳。$r = 0$ 时，$P_i^((0)) = P_i = b_(0,0)(t) P_i$。假设 $r - 1$ 时成立，则
  $ P_i^((r)) &= (1 - t) sum_(j=0)^(r-1) b_(j,r-1)(t) P_(i+j)
                + t sum_(j=0)^(r-1) b_(j,r-1)(t) P_(i+1+j) \
              &= sum_(j=0)^r [(1 - t) b_(j,r-1)(t) + t b_(j-1,r-1)(t)] P_(i+j). $
  由#ref(<lem-binomial>)，方括号等于 $[binom(r-1, j) + binom(r-1, j-1)] t^j (1-t)^(r-j) = b_(j,r)(t)$。取 $r = n$、$i = 0$，即得 $P_0^((n)) = B(t)$。
]

== 导数、分割与反转

#proof(of: <lem-bernstein-derivative>)[
  由乘积法则，
  $ b'_(i,n)(t) = binom(n, i) [i t^(i-1) (1-t)^(n-i) - (n - i) t^i (1-t)^(n-i-1)]. $
  由#ref(<lem-binomial>)，$i binom(n, i) = n binom(n-1, i-1)$；以 $n - i$ 代替 $i$ 并利用 $binom(n, i) = binom(n, n-i)$，又得 $(n - i) binom(n, i) = n binom(n-1, i)$。因此两项分别为 $n b_(i-1,n-1)(t)$ 与 $n b_(i,n-1)(t)$；$i = 0$ 与 $i = n$ 时消失的那一项，正符合约定 $b_(-1,n-1) = b_(n,n-1) = 0$。
]

#proof(of: <thm-hodograph>)[
  由#ref(<lem-bernstein-derivative>)，将第一个和式的指标平移后，
  $ B'(t) = n sum_(i=0)^n [b_(i-1,n-1)(t) - b_(i,n-1)(t)] P_i
          = n sum_(i=0)^(n-1) b_(i,n-1)(t) (P_(i+1) - P_i). $
]

#proof(of: <cor-end-tangents>)[
  由#ref(<thm-hodograph>)，$B'$ 是控制点为 $n(P_(i+1) - P_i)$（$i = 0, dots, n - 1$）的 $n - 1$ 次曲线；对它套用#ref(<prop-endpoints>)即得。
]

#proof(of: <lem-symmetry>)[
  $ b_(i,n)(1 - t) = binom(n, i) (1-t)^i t^(n-i) = binom(n, n-i) t^(n-i) (1-t)^i = b_(n-i,n)(t). $
]

#proof(of: <prop-reversal>)[
  令 $j = n - i$ 重新编号，
  $ sum_(i=0)^n b_(i,n)(t) P_(n-i) = sum_(j=0)^n b_(n-j,n)(t) P_j, $
  而由#ref(<lem-symmetry>)，$b_(n-j,n)(t) = b_(j,n)(1 - t)$，故此和为 $B(1 - t)$。
]

#proof(of: <thm-subdivision>)[
  _左段。_将 $1 - c s$ 写成 $(1 - s) + s(1 - c)$，并展开两个幂次：
  $ B(c s) &= sum_(i=0)^n binom(n, i) (c s)^i [(1 - s) + s(1 - c)]^(n-i) P_i \
           &= sum_(i=0)^n sum_(k=0)^(n-i) binom(n, i) binom(n-i, k) c^i (1-c)^k s^(i+k) (1-s)^(n-i-k) P_i. $
  令 $j = i + k$，并利用 $binom(n, i) binom(n-i, j-i) = binom(n, j) binom(j, i)$：
  $ B(c s) = sum_(j=0)^n binom(n, j) s^j (1-s)^(n-j) sum_(i=0)^j binom(j, i) c^i (1-c)^(j-i) P_i
           = sum_(j=0)^n b_(j,n)(s) P_0^((j)), $
  其中内层和由#ref(<thm-casteljau>)即为 $t = c$ 时的 $P_0^((j))$。这就是关于 $L_j$ 的结论。

  _右段。_令 $overline(B)$ 为反转后的曲线，控制点为 $overline(P)_i = P_(n-i)$，由#ref(<prop-reversal>)，$overline(B)(u) = B(1 - u)$。对 $overline(B)$ 在 $overline(c) = 1 - c$ 套用左段的结果，得 $overline(B)(overline(c) s) = sum_j b_(j,n)(s) overline(L)_j$，其中
  $ overline(L)_j = sum_(i=0)^j b_(i,j)(1 - c) P_(n-i)
                  = sum_(l=0)^j b_(l,j)(c) P_(n-j+l) = P_(n-j)^((j)) = R_(n-j), $
  这里用到#ref(<lem-symmetry>)、代换 $l = j - i$ 与#ref(<thm-casteljau>)。因此，再由#ref(<lem-symmetry>)，
  $ B(c + (1 - c) s) = overline(B)((1 - c)(1 - s))
                     = sum_(j=0)^n b_(j,n)(1 - s) R_(n-j)
                     = sum_(j=0)^n b_(n-j,n)(s) R_(n-j)
                     = sum_(k=0)^n b_(k,n)(s) R_k. $
]

#proof(of: <cor-segment>)[
  令 $a = t_0$、$e = t_1$，则 $e > a >= 0$。在 $e$ 分割并保留左段，由#ref(<thm-subdivision>)得到曲线 $u |-> B(e u)$。再于 $a slash e in [0, 1)$ 分割该曲线并保留右段，得到
  $ s |-> B(e (a/e + (1 - a/e) s)) = B(a + (e - a) s). $
]

== 三次线段与路径

#proof(of: <prop-bbox>)[
  展开三次 Bernstein 形式，
  $ B(t) = (1-t)^3 P_0 + 3t(1-t)^2 P_1 + 3t^2(1-t) P_2 + t^3 P_3
         = a t^3 + b t^2 + c t + P_0, $
  其中 $a$、$b$、$c$ 如定理所述。每个坐标 $B_k$ 在紧致区间 $[0, 1]$ 上连续，因此在其上获取最小值与最大值。若极值出现在内点 $t^*$，则它是临界点，$B'_k(t^*) = 3 a_k t^(*2) + 2 b_k t^* + c_k = 0$；否则就在 $0$ 或 $1$。若 $B'_k$ 恒为零，$B_k$ 为常数，任一候选点都给出极值。求得的最小值与最大值都是曲线上的值，因此没有更小的方框能包含曲线。
]

#proof(of: <lem-basis-elevation>)[
  _1._ $n = 0$ 时两边都为零。$n >= 1$ 时，由#ref(<lem-binomial>)得 $i b_(i,n)(t) = n t b_(i-1,n-1)(t)$，故由#ref(<prop-unity>)，$sum_i i b_(i,n)(t) = n t sum_i b_(i-1,n-1)(t) = n t$。

  _2._ 将 $b_(i,n)(t)$ 乘上 $(1 - t) + t = 1$，
  $ b_(i,n)(t) = binom(n, i) t^i (1-t)^(n+1-i) + binom(n, i) t^(i+1) (1-t)^(n-i). $
  因为 $binom(n, i) slash binom(n+1, i) = (n + 1 - i) slash (n + 1)$、$binom(n, i) slash binom(n+1, i+1) = (i + 1) slash (n + 1)$，两项分别是 $b_(i,n+1)(t)$ 与 $b_(i+1,n+1)(t)$ 的所述倍数。
]

#proof(of: <prop-elevation>)[
  _直线。_令 $Q_i = P_0 + i/3 (P_3 - P_0)$，由#ref(<prop-unity>)与#ref(<lem-basis-elevation>)第 1 式，
  $ sum_(i=0)^3 b_(i,3)(t) Q_i = P_0 + (P_3 - P_0) sum_i i/3 b_(i,3)(t) = P_0 + t (P_3 - P_0). $

  _二次曲线。_由#ref(<lem-basis-elevation>)第 2 式取 $n = 2$，
  $ b_(i,2)(t) = (3 - i)/3 b_(i,3)(t) + (i + 1)/3 b_(i+1,3)(t). $
  对二次控制点 $R_0 = P_0$、$R_1 = C$、$R_2 = P_3$，得
  $ sum_(i=0)^2 b_(i,2)(t) R_i = sum_(k=0)^3 b_(k,3)(t) [k/3 R_(k-1) + (3 - k)/3 R_k], $
  其控制点为 $R_0 = P_0$、$1/3 P_0 + 2/3 C$、$2/3 C + 1/3 P_3$、$R_2 = P_3$，与命题所述相同。两个恒等式对每个 $t$ 都成立，因此参数化不变。
]

#proof(of: <prop-continuity>)[
  设接点位于整体参数 $u_0$。在各自的区间上，$S$ 于 $s = (u - u_0 + h_S) slash h_S$ 求值，$T$ 于 $s = (u - u_0) slash h_T$ 求值。由链式法则与#ref(<cor-end-tangents>)，$u_0$ 处的单边导数为 $S'(1) slash h_S = 3(P_3 - P_2) slash h_S$ 与 $T'(0) slash h_T = 3(Q_1 - Q_0) slash h_T$。由于 $P_3 = Q_0$，曲线连续；两个导数相等时，接点处恰为 $C^1$。在均匀参数化下，$m$ 段路径的 $h_S = h_T = 1 slash m$。
]

== 构造与插值

#proof(of: <prop-endpoint>)[
  由#ref(<prop-endpoints>)，$B(0) = P_0$、$B(1) = P_3$；由#ref(<cor-end-tangents>)，$B'(0) = 3(P_1 - P_0) = D_0$、$B'(1) = 3(P_3 - P_2) = D_1$。反之，三次 Bernstein 多项式构成基底，因此三次曲线的控制点唯一，而这四个条件决定了全部控制点：$P_0 = B(0)$、$P_3 = B(1)$、$P_1 = P_0 + B'(0) slash 3$、$P_2 = P_3 - B'(1) slash 3$。
]

#proof(of: <prop-hermite>)[
  在 $t = t_0$ 与 $t = t_1$，线段分别于 $s = 0$ 与 $s = 1$ 求值，由#ref(<prop-endpoints>)得 $H(t_0) = P_0$、$H(t_1) = P_3$。由链式法则，$H'(t) = B'(s) slash h$。由#ref(<cor-end-tangents>)，$B'(0) = 3(P_1 - P_0) = h D_0$、$B'(1) = 3(P_3 - P_2) = h D_1$，故 $H'(t_0) = D_0$、$H'(t_1) = D_1$。证明中不需要 $h > 0$。
]

#proof(of: <thm-hermite-error>)[
  `graph_hermite` 线段的 $x$ 坐标是线性函数 $x$（导数为 1）的插值，由三次 Hermite 插值的唯一性，它对 $x$ 是线性的；因此线段是三次多项式 $H$ 的图形，且 $H(x_i) = f(x_i)$、$H'(x_i) = f'(x_i)$。

  固定 $x in (x_0, x_1)$，令 $w(t) = (t - x_0)^2 (t - x_1)^2$，它在 $x$ 处为正。选取 $K$ 使 $g(t) = f(t) - H(t) - K w(t)$ 在 $t = x$ 处为零。则 $g$ 在 $x_0$、$x$、$x_1$ 为零，且 $g'$ 在 $x_0$、$x_1$ 也为零，因为 $f - H$ 与 $w$ 在这两点都有二重根。由 Rolle 定理，$g'$ 在 $(x_0, x)$ 与 $(x, x_1)$ 各有一个零点，因此在 $[x_0, x_1]$ 上有四个相异零点；据此类推，$g''$ 有三个，$g'''$ 有两个，$g^((4))$ 至少有一个，记为 $xi$。由于 $H$ 是三次多项式而 $w$ 是首项系数为 1 的四次多项式，$0 = g^((4))(xi) = f^((4))(xi) - 24 K$，故
  $ f(x) - H(x) = f^((4))(xi) / 24 (x - x_0)^2 (x - x_1)^2. $
  在区间上 $|(x - x_0)(x - x_1)| <= h^2 slash 4$，于中点取等号，因此 $|f(x) - H(x)| <= M h^4 slash (24 dot 16) = M h^4 slash 384$ #citep(<burden2011>)。
]

== 拟合与等值线

#proof(of: <cor-depth>)[
  深度 $k$ 的区间宽度为 $h = H slash 2^k$。在此区间上，Hermite 线段的每个坐标都在两端吻合 $C$ 对应坐标的值与导数（详见#ref(<prop-hermite>)），因此是该坐标的三次 Hermite 插值，由#ref(<thm-hermite-error>)，其误差不超过 $M h^4 slash 384$。所以欧氏误差处处不超过 $sqrt(d) M h^4 slash 384$，在测量误差的测量参数上当然也成立。当 $2^(4k) >= sqrt(d) M H^4 slash (384 epsilon)$，亦即 $k$ 满足定理中的条件时，此值不超过 $epsilon$。
]

#proof(of: <prop-rdp>)[
  考虑对指标 $i < j$ 的顶点运行的递回步骤。对 $j - i$ 作归纳，证明它返回的任两个相邻指标 $u < v$ 之间的每个顶点，到弦 $P_u P_v$ 的距离都不超过容差。若 $j <= i + 1$，两者之间没有顶点。若离弦 $P_i P_j$ 最远的顶点在容差内，步骤返回 $(i, j)$，结论成立。否则它返回 $(i, m)$ 与 $(m, j)$ 两次调用的结果并在 $m$ 接合，$i < m < j$；每一对相邻指标都来自其中一次调用，可套用归纳假设。外层算法在相邻的保留顶点之间运行此步骤，每个输出线段都连接两个相邻的返回指标。距离是到线段形式的弦的距离，与 `fit_error` 报告的距离相同。
]

#proof(of: <thm-gradient>)[
  由于 $nabla F(p) != 0$，不妨设 $F_y(p) != 0$；$F_x(p) != 0$ 的情形交换 $x$ 与 $y$ 的角色即可。由隐函数定理，存在 $p_x$ 附近的 $C^1$ 函数 $phi$，满足 $phi(p_x) = p_y$，使得在 $p$ 附近等值集即为图形 $gamma(x) = (x, phi(x))$。对 $F(gamma(x)) = c$ 微分得 $F_x + F_y phi' = 0$，故
  $ gamma'(x) = (1, -F_x / F_y) = 1 / F_y (F_y, -F_x), $
  在 $p$ 处平行于 $(F_y, -F_x)$。
]

== 导出

#proof(of: <prop-rounding>)[
  令 $tilde(P)_i = P_i + delta_i$，且每个坐标 $k$ 都有 $|delta_(i,k)| <= epsilon$。扰动后的曲线与 $B$ 相差 $tilde(B)(t) - B(t) = sum_i b_(i,n)(t) delta_i$。由#ref(<prop-unity>)，在每个坐标上
  $ |sum_i b_(i,n)(t) delta_(i,k)| <= sum_i b_(i,n)(t) |delta_(i,k)| <= epsilon, $
  因此欧氏距离最多为 $sqrt(d epsilon^2) = epsilon sqrt(d)$。把数值四舍五入到小数点后 $p$ 位，改变量最多 $1/2 dot 10^(-p)$；导出器把小于此值的数改写为 $0$，也是同样大小的舍入。
]

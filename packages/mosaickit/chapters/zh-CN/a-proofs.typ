#import "/template/manual.typ": *

= 证明 <app-proofs>

本附录按各章出现的顺序，证明其中的引理、命题、定理与推论。以下假设精确算术。代码以浮点数计算相同的量，因此若某个几何构型与退化情形的差异仅在舍入误差范围内（例如点落在边上，或三点几乎共线），代码可能将它判定为任一种结果。平面向量 $u, v$ 的外积记为 $u times v = u_x v_y - u_y v_x$。

== 排列与轨道

#proof(of: <thm-spread>)[
  #emph[变量代换。]令 $o_k = sum_(j < k) (s_j + g) + s_k slash 2$、$y_k = x_k - o_k$、$z_k = c_k - o_k$。由于 $o_(k+1) - o_k = (s_k + s_(k+1)) slash 2 + g$，#ref(<def-packing>)的限制条件即 $y_1 <= dots.c <= y_n$，目标函数为 $sum_k (y_k - z_k)^2$。因此问题是在最小二乘意义下，找出最接近 $z$ 的非递减向量。

  #emph[代码的计算。]考察从第 $i$ 项开始、起点为 $S_B$ 的连续项目组 $B$。对于 $k in B$，代码将它放在
  $ x_k = S_B + sum_(i <= l < k) (s_l + g) + s_k slash 2 = S_B + o_k - O_i $
  其中 $O_i = sum_(l < i) (s_l + g)$。因此 $y_k = S_B - O_i =: Y_B$ 在 $B$ 上为常数。代码取 $S_B$ 为 $c_k - (o_k - O_i)$ 的平均，使 $Y_B$ 成为 $z_k$ 在 $B$ 上的平均；新加入的单一项目则有 $Y = z_k$。组 $A$ 与后续组 $B$ 在 $S_A + "length"(A) + g <= S_B$ 时保持分开。由于 $"length"(A) + g = O_(i_B) - O_(i_A)$，此条件等价于 $Y_A <= Y_B$。因此，代码实现的就是 PAVA：将 $z_k$ 加入为一个块；只要最后两个块的平均递减，就以它们的并集（取其平均）取代。

  #emph[不变式。] (a) 相邻块的平均非递减：最后一对顺序正确时合并即停止，较早的块对不受影响。(b) 在平均为 $mu_B$ 的每个块 $B$ 中，每个起始片段的平均至少为 $mu_B$。单一项目满足 (b)。$A$ 与 $B$ 合并时 $mu_A > mu_B$，合并后的平均 $mu$ 严格介于两者之间。$A$ 内的起始片段平均至少为 $mu_A > mu$。其他起始片段是 $A$ 接上 $B$ 的起始片段 $B'$；若 $B'$ 为整个 $B$，其平均为 $mu$；否则 $B$ 的其余部分 $B''$ 由 $B$ 的 (b) 知平均最多 $mu_B < mu$，而该片段是平均为 $mu$ 的集合中 $B''$ 的补集，平均至少为 $mu$。

  #emph[最佳性。]目标函数严格凸、限制条件 $y_k - y_(k+1) <= 0$ 为线性，因此满足 Karush–Kuhn–Tucker 条件的点即唯一的最小解 #citep(<boyd2004>)。对 $k = 0, dots, n$ 令 $lambda_k = 2 sum_(l <= k) (z_l - y_l)$。平稳条件 $2 (y_k - z_k) + lambda_k - lambda_(k-1) = 0$ 由构造成立。块内的偏差 $z_l - Y_B$ 总和为零，因此 $lambda$ 在每个块末端为零，包括 $lambda_n = 0$。在由第 $i$ 项起的块内，由 (b) 得 $lambda_k = 2 sum_(l=i)^k (z_l - Y_B) >= 0$。最后，$lambda_k > 0$ 只发生在 $k$ 与 $k + 1$ 属于同一块时，此时 $y_k = y_(k+1)$，限制条件取等号。加上 (a) 给出的可行性，所有条件都成立。
]

#proof(of: <cor-spread>)[
  (i) 按排序后的顺序编号，并设 $i < j$。把第 $i$ 到第 $j - 1$ 条限制相加，得
  $ x_j - x_i >= sum_(k=i)^(j-1) ((s_k + s_(k+1)) slash 2 + g) >= (s_i + s_j) slash 2 + g $
  因为每项都非负，且首末两项分别贡献 $s_i slash 2$ 与 $s_j slash 2$。(ii) 若 $c$ 是排列，它使目标函数为 $0$，因此是#ref(<thm-spread>)的唯一最小解。(iii) 沿用该证明的记号，
  $ sum_(k in B) (x_k - c_k) = sum_(k in B) (y_k - z_k) = |B| Y_B - sum_(k in B) z_k = 0 $
]

#proof(of: <thm-lanes>)[
  区间只在与某轨道上所有区间都不冲突时才加入该轨道，之后不再移动，因此结果是轨道分配。任何轨道分配都必须把 $omega$ 个两两冲突的区间放在 $omega$ 条不同轨道，所以至少需要 $omega$ 条轨道。

  反过来，记 $J = [a_J, b_J]$，并设区间按 $a$ 递增的顺序给出。由#ref(<def-conflict>)，$I$ 与 $J$ 冲突恰好等价于半开区间 $[a_I, b_I + g)$ 与 $[a_J, b_J + g)$ 相交。设 $I$ 被放在所用的最高轨道 $k$。$I$ 到来时，每条轨道 $j < k$ 上都有与 $I$ 冲突的区间 $J_j$。每个 $J_j$ 较早到来，故 $a_(J_j) <= a_I$；又与 $I$ 冲突，故 $b_(J_j) + g > a_I$。因此每个 $[a_(J_j), b_(J_j) + g)$ 都含 $a_I$，而 $b_I - a_I + g > 0$ 使 $[a_I, b_I + g)$ 也含 $a_I$。有共同点的半开区间两两相交，所以 $J_0, dots, J_(k-1), I$ 是 $k + 1$ 个两两冲突的区间，$k + 1 <= omega$。
]

== 矩形、线段与多边形

#proof(of: <lem-nearest>)[
  $|q - p|^2 = (q_x - p_x)^2 + (q_y - p_y)^2$，而 $R$ 是 $[x_0, x_1]$ 与 $[y_0, y_1]$ 的乘积，因此两个坐标可分别最小化。在区间上，$t |-> (t - p_x)^2$ 严格凸，无限制的最小值在 $p_x$，所以它在 $[x_0, x_1]$ 上的最小值只在 $min(max(p_x, x_0), x_1)$ 获取；$y$ 亦同。
]

#proof(of: <lem-orient>)[
  将其他行减去第一行，得
  $ "orient"(a, b, c) = det mat(1, a_x, a_y; 1, b_x, b_y; 1, c_x, c_y). $
  列的循环置换为偶置换，交换两行为奇置换，由此得到对称性。又
  $ "orient"(a, b, c) = (b - a) times (c - a) = |b - a| |c - a| sin theta $
  其中 $theta$ 为从 $b - a$ 到 $c - a$ 的有号角；它为正恰好在 $theta in (0, pi)$，即 $c$ 位于有向直线左侧时，位于右侧时为负，而在两向量平行或其一为零，即三点共线时为零。
]

#proof(of: <thm-segments>)[
  先说明：若 $"orient"(c, d, p) = 0$ 且 $p$ 位于 $[c, d]$ 的外接矩形内，则 $p in [c, d]$。事实上，若 $c = d$，外接矩形就是点 $c$；否则由共线性，对某实数 $t$ 有 $p = c + t (d - c)$，而在 $d - c$ 不为零的坐标上，外接矩形条件迫使 $t in [0, 1]$。

  #emph[充分性。]设 $d_1 d_2 < 0$ 且 $d_3 d_4 < 0$。$"orient"(c, d, dot)$ 沿 $[a, b]$ 为仿射函数且变号，因此 $[a, b]$ 与直线 $L_(c d)$ 交于一点；同理 $[c, d]$ 与 $L_(a b)$ 交于一点。由于 $a$、$b$ 位于 $L_(c d)$ 两侧，两直线不平行，恰有一个共同点 $z$；两个交点都等于 $z$，因此 $z$ 同时位于两线段上。另一种情形是某个 $d_i = 0$ 且其端点位于另一线段的外接矩形内，由上述说明，该端点位于另一线段上。

  #emph[必要性。]设 $z$ 为共同点。若 $d_1 d_2 > 0$，则 $a$、$b$ 严格位于 $L_(c d)$ 的同一侧，整个 $[a, b]$ 亦然，与 $z in L_(c d)$ 矛盾；所以 $d_1 d_2 <= 0$，同理 $d_3 d_4 <= 0$。若两者皆为负则得证。否则某个 $d_i$ 为零；不妨设 $d_1 = 0$，其余情形对称。若 $d_2 != 0$，$[a, b]$ 只在 $a$ 与 $L_(c d)$ 相交，故 $z = a$ 且 $a in [c, d]$：$d_1$ 的测试成立。若 $d_2 = 0$，四点共线，两线段是同一直线上重叠的区间，其中一条的端点位于另一条内，因此四个测试之一成立。
]

#proof(of: <lem-rect-segment>)[
  $R$ 的边都在 $R$ 内，因此任一测试成立都给出共同点（参见#ref(<thm-segments>)）。反之，设 $[a, b]$ 与 $R$ 相交但两端点都不在 $R$ 内。线段是连通的，同时含有 $R$ 内与 $R$ 外的点，因此与 $R$ 的边界相交，而边界是四条边的联集；#ref(<thm-segments>)会检测到该边。
]

#proof(of: <lem-segment-distance>)[
  $t |-> |a + t (b - a) - p|^2$ 是凸二次函数，无限制的最小值在 $(p - a) dot (b - a) slash |b - a|^2$；如#ref(<lem-nearest>)的证明，它在 $[0, 1]$ 上的最小值位于该值的截断处。
]

#proof(of: <prop-even-odd>)[
  记 $p = (x, y)$，取 $epsilon > 0$ 小于所有顶点高度与 $y$ 的正差值 $|y_i - y|$，且小到使 $p_epsilon = (x, y + epsilon)$ 与 $p$ 位于 $RR^2 without partial P$ 的同一连通分量（因 $p in.not partial P$ 且各分量为开集，此为可行）。直线 $Y = y + epsilon$ 上没有顶点，且对每个顶点，$y_i > y$ 当且仅当 $y_i > y + epsilon$。因此一条边通过代码的高度测试，恰好等价于它穿过直线 $Y = y + epsilon$，交点横坐标为
  $ X_epsilon = x_0 + (y + epsilon - y_0)(x_1 - x_0) slash (y_1 - y_0) $
  代码比较的是 $x$ 与 $X_0$。若 $x = X_0$，由于高度测试使 $y$ 介于两端点高度之间，点 $(X_0, y)$ 位于该边上，即 $p in partial P$，与假设矛盾；所以 $x != X_0$，由连续性，对够小的 $epsilon$，$x < X_0$ 当且仅当 $x < X_epsilon$。因此代码计算的正是从 $p_epsilon$ 向右、不经过任何顶点的射线所穿过的边。每次穿越都使射线在内部与外部之间切换，而射线在最右方位于外部，所以计数为奇数恰好在 $p_epsilon in "int" P$，即 $p in "int" P$ 时 #citep(<haines1994>)。
]

#proof(of: <thm-rect-inside>)[
  若 $R subset "int" P$，则 $R$ 与 $partial P$ 不相交，因此没有边碰到它（参见#ref(<lem-rect-segment>)），而它的角位于 $"int" P$ 且不在边界上，因此通过奇偶测试（参见#ref(<prop-even-odd>)）。反之，若没有边碰到 $R$，则 $R inter partial P = emptyset$（参见#ref(<lem-rect-segment>)）；特别是各角不在边界上，通过测试即表示它们位于 $"int" P$。$R$ 是连通的且与 $partial P$ 不相交，因此位于 $RR^2 without partial P$ 的一个分量内；它含有一个位于 $"int" P$ 的角，所以 $R subset "int" P$。
]

#proof(of: <cor-rect-overlap>)[
  若有一个角通过测试，它不在边界上时位于 $"int" P$（参见#ref(<prop-even-odd>)），否则位于 $partial P$；无论哪种情形都有 $R inter overline(P) != emptyset$。若有一条边碰到 $R$，则 $R$ 与 $partial P$ 相交。反之，设 $R$ 与 $overline(P)$ 相交。若它与 $partial P$ 相交，就有某条边碰到它。否则 $R$ 与 $partial P$ 不相交而与 $"int" P$ 相交；由连通性得 $R subset "int" P$，其各角通过测试。
]

#proof(of: <prop-ray-exit>)[
  设对某个 $t > T$，$p = o + t r in partial P$，位于边 $e$ 上。若 $e$ 不平行于 $r$，代码对 $e$ 解 $o + t r = a + u (b - a)$，得到这个 $t >= 0$ 与 $u in [0, 1]$，因此 $T >= t$，矛盾。若 $e$ 平行于 $r$，它位于射线所在直线 $ell$ 上。取包含 $e$、位于 $ell$ 上的极大连续边段。它不是整个 $P$（$P$ 的顶点不全共线），所以边段两端都是与某条不在 $ell$ 上、因而不平行于 $r$ 的边共用的顶点。边段中相邻的边不会折返，因为从同一顶点沿 $ell$ 同向出发的两条边会重叠，与 $P$ 为简单多边形矛盾；因此边段是 $ell$ 上的一段，其在 $r$ 方向的远端是端点顶点 $v = o + t_v r$，且 $t_v >= t > T$。相邻的不平行边含有 $v$（$u in {0, 1}$），因此 $T >= t_v$，同样矛盾。所以 ${o + t r : t > T}$ 与 $partial P$ 不相交；它连通且无界，因此位于外部。
]

== 不可及极点

#proof(of: <lem-lipschitz>)[
  对任意集合 $S$，由三角不等式得 $|d(p, S) - d(q, S)| <= |p - q|$，这就处理了 $p$、$q$ 在同一侧的情形。设 $p in overline(P)$、$q in.not overline(P)$，并令 $z$ 为从 $p$ 到 $q$ 的线段上，属于 $overline(P)$ 的最后一点（$overline(P)$ 为闭集，故存在）。紧接在 $z$ 之后的点都在外面，因此 $z in.not "int" P$，即 $z in partial P$。于是
  $ |f(p) - f(q)| = d(p, partial P) + d(q, partial P) <= |p - z| + |z - q| = |p - q| $
]

#proof(of: <thm-polylabel>)[
  代码精确计算 $f$：不在边界上时，由#ref(<prop-even-odd>)符号正确；在边界上时距离为 $0$。记 $b$ 为目前的最佳值；它只会增加，且始终是某个已求值中心的 $f$ 值。

  #emph[结束性。]每次分割使半边长 $h$ 减半。取出 $h sqrt(2) <= epsilon$ 的单元时，更新后 $b >= f(c)$，因此其上界最多比 $b$ 多 $h sqrt(2) <= epsilon$，单元被舍弃而不分割。所以单元构成有限树，每格各推入与取出一次。

  #emph[不变式。]外接矩形的每一点都位于某格的闭正方形内，该格要不在队列中，要不在被舍弃当时满足 $f(c) + h sqrt(2) <= b + epsilon$。初始正方形从左下角起以短边为步长铺设，直到越过远端边缘，覆盖了外接矩形；舍弃按舍弃规则保持不变式；分割把一个正方形换成覆盖它的四个正方形。

  #emph[结论。]结束时队列为空。设 $p^*$ 为极点；它位于 $overline(P)$ 中、外接矩形内，落在某个被舍弃、中心为 $c$、半边长为 $h$ 的单元内。由#ref(<lem-lipschitz>)与 $|p^* - c| <= h sqrt(2)$，
  $ f^* = f(p^*) <= f(c) + h sqrt(2) <= b + epsilon <= f(q) + epsilon, $
  其中 $q$ 为返回的点，$f(q)$ 为最终的 $b$。若 $f^* > epsilon$，则 $f(q) > 0$，故 $q$ 位于 $overline(P)$ 内且与 $partial P$ 距离为正，即 $q in "int" P$。
]

#proof(of: <prop-brace>)[
  记半径为 $r$，拉伸倍率为 $sigma = delta slash 2r >= 1$。拉伸之前，曲线由以下部分组成：圆心 $(0, ell + r)$、从 $-90 degree$ 到 $0 degree$ 的圆弧 $A_1$；从 $v = ell + r$ 到 $v = m - r$ 的线段 $u = r$；圆心 $(2 r, m - r)$、从 $180 degree$ 到 $90 degree$ 的圆弧 $A_2$；圆心 $(2 r, m + r)$、从 $270 degree$ 到 $180 degree$ 的圆弧 $A_3$；从 $m + r$ 到 $h - r$ 的线段 $u = r$；以及圆心 $(0, h - r)$、从 $0 degree$ 到 $90 degree$ 的圆弧 $A_4$。（当 $r = (h - ell) slash 4$ 时两线段长度为零。）曲线起于 $(0, ell)$、终于 $(0, h)$，$A_2$ 与 $A_3$ 交于 $(2 r, m)$，拉伸 $(u, v) |-> (sigma u, v)$ 把它送到 $(delta, m)$。

  (i) 在 $A_1$ 与 $A_4$ 上 $u in [0, r]$；在两线段上 $u = r$；在 $A_2$ 与 $A_3$ 上 $u in [r, 2 r]$。拉伸后 $u in [0, delta]$。

  (ii) 反射 $v |-> ell + h - v$ 交换 $A_1$ 与 $A_4$、$A_2$ 与 $A_3$ 的圆心，并把角度 $theta$ 变为 $-theta$，因此把 $A_1$ 映到 $A_4$、$A_2$ 映到 $A_3$，两线段互换。

  (iii) 沿角度递增方向走圆弧时，运动方向为 $(-sin theta, cos theta)$；沿递减方向时为 $(sin theta, -cos theta)$。在 $A_1$ 终点（$theta = 0$）与 $A_2$ 起点（$theta = 180 degree$）两者都是 $(0, 1)$，即两者间线段的方向；$A_3$ 终点与 $A_4$ 起点亦同。在尖端，$A_2$ 以方向 $(1, 0)$ 抵达（$theta = 90 degree$），$A_3$ 以 $(-1, 0)$ 离开（$theta = 270 degree$）：形成尖点。拉伸与最后的放置都是可逆仿射映射，会带着切线方向且保持其非零，因此连续性与尖点都得以保留。
]

== 标签

#proof(of: <lem-crossing>)[
  共同点满足 $a + t r = c + u s$，其中 $r = b - a$、$s = d - c$。两边与 $s$ 作外积可消去 $u$：$t (r times s) = (c - a) times s$。真正交叉使 $a$、$b$ 严格位于 $L_(c d)$ 两侧，因此两直线不平行，$r times s != 0$，交点唯一。由于 $"orient"(c, d, dot)$ 沿 $[a, b]$ 为仿射函数且两端异号，其零点位于某个 $t in (0, 1)$。
]

#proof(of: <prop-callout>)[
  代码保留一个最佳候选，只在遇到键值严格较小的候选时才替换，因此在枚举的任何前段之后，它保存的是目前为止键值最小的第一个候选。近环结束后，若最小代价为 $0$，最小键值为 $(0, ell_min)$，搜索停止：结果是引线最短的第一个零代价候选。否则以同一个最佳候选继续枚举远环，结果是两环中键值最小的第一个候选。每个步骤都是参数（极点、离开距离、开阔区域、交叉点）的函数，没有随机性，枚举顺序固定。
]

== 样式、主题与绑定

#proof(of: <prop-monoid>)[
  逐栏来看，合并是运算：$x != "None"$ 时 $x circle.small y = x$，否则为 $y$。$(x circle.small y) circle.small z$ 与 $x circle.small (y circle.small z)$ 都等于 $x, y, z$ 中第一个不是 `None` 的值（或 `None`），`None` 是双边单位元，且 $x circle.small x = x$。样式在各栏相等时相等，由此得 (i)–(iii)，再由归纳法得到第一个非 `None` 值的描述。样式组逐槽同理，`None` 槽的行为如同空样式。
]

#proof(of: <prop-hex>)[
  一对十六进制数字 $k in {0, dots, 255}$ 读为 $k slash 255$，写出时取 $"round"(255 dot k slash 255)$ 的两位大写数字。在双精度下，计算出的乘积与 $k$ 相差最多 $255 dot 2^(-52) < 1 slash 2$，因此舍入为 $k$。`include_alpha` 为真，即九个字符的形式时，才写出 alpha 那一对。三位数形式在读取前先把每位数字重复一次。
]

#proof(of: <thm-resolution>)[
  以 $triangle.r$ 表示合并。解析从 $D$ 开始，按 $T$、$G$、$C$ 的顺序，对每个对应依次把 $M[k_n], dots, M[k_1]$（由最一般到最具体）合并到结果之上，不存在的键给出空样式组；最后合并图层自带的样式组 $E$，它由 `style_slots` 指出的字段构成。展开并以结合律（参见#ref(<prop-monoid>)）去掉括号，解析后的样式组为
  $ E triangle.r C[k_1] triangle.r dots.c triangle.r C[k_n] triangle.r
    G[k_1] triangle.r dots.c triangle.r T[k_n] triangle.r D, $
  其各字段为据此顺序第一个不是 `None` 的值。之后绑定调色板只把颜色名称换成颜色，不影响其他字段。
]

#proof(of: <cor-override>)[
  角色为 `axes.note` 的文字图层，其链为（`axes.note`, `axes`, `text`），在#ref(<thm-resolution>)的序列中 $G["text"]$ 位于 $T["axes.note"]$ 之前。由假设，更早的项目都没有设置大小，因此第一个非 `None` 的大小来自 $G["text"]$。
]

#proof(of: <thm-binding>)[
  对 $e$ 作归纳。若 $"free"(e) subset.eq "dom" beta$（特别是常数，以及属于 $"dom" beta$ 的参数），$"bind"(e, beta)$ 是一般值 $e(beta)$：它没有自由参数，符合 (i)，且求值为 $e(beta) = e(beta union gamma)$，因为表达式的值只取决于其自由参数的值。若 $e$ 是参数 $p in.not "dom" beta$，结果为 $p$，$"free" = {p} = "free"(e) without "dom" beta$，值为 $gamma(p) = (beta union gamma)(p)$。否则 $e = e_1 circle.small e_2$，结果为 $"bind"(e_1, beta) circle.small "bind"(e_2, beta)$（一般值包装为常数）。其自由参数为
  $ ("free"(e_1) without "dom" beta) union ("free"(e_2) without "dom" beta) = "free"(e) without "dom" beta $
  而 $gamma$ 绑定了两部分各自的自由参数，由归纳假设其值为
  $ e_1(beta union gamma) circle.small e_2(beta union gamma) = e(beta union gamma) $
]

#proof(of: <cor-stages>)[
  两次应用#ref(<thm-binding>) (i)，两者的自由参数都是 $"free"(e) without "dom" (beta_1 union beta_2)$。对这些参数的绑定 $gamma$（与 $beta_1$、$beta_2$ 不相交），两次应用 (ii) 得
  $ "bind"("bind"(e, beta_1), beta_2)(gamma) = "bind"(e, beta_1)(beta_2 union gamma) = e(beta_1 union beta_2 union gamma) = "bind"(e, beta_1 union beta_2)(gamma) $
  画布以这种方式绑定其场景中的每个表达式。
]

#proof(of: <prop-grid-shape>)[
  由 $r = ceil(n slash c)$ 得 $r c >= n > (r - 1) c$，因此前 $r - 1$ 行是满的，最后一行有 $n - (r - 1) c in [1, c]$ 格，空格数 $r c - n < c$。由 $c = ceil(sqrt(n))$ 得 $n <= c^2$，所以 $n slash c <= c$，$r <= c$。
]

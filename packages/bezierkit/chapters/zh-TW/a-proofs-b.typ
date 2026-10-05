#import "/template/manual.typ": *

== 三次線段與路徑

#proof(of: <prop-bbox>)[
  展開三次 Bernstein 形式並依 $t$ 的次方合併，
  $ B(t) &= (1-t)^3 P_0 + 3t(1-t)^2 P_1 + 3t^2(1-t) P_2 + t^3 P_3 \
         &= (1 - 3t + 3t^2 - t^3) P_0 + (3t - 6t^2 + 3t^3) P_1 + (3t^2 - 3t^3) P_2 + t^3 P_3 \
         &= a t^3 + b t^2 + c t + P_0, $
  其中 $a$、$b$、$c$ 如命題所述。

  固定座標 $k$。$B_k$ 是多項式，在緊緻區間 $[0, 1]$ 上連續，因此在其上取得最小值與最大值。設 $t^*$ 是取得其中一個的點。若 $t^* in (0, 1)$，則 $B_k$ 在內點有極值且可微，故 $B'_k (t^*) = 0$（Fermat 定理）。分兩種情形。
  - $B'_k$ 不恆為零。它是次數至多為 2 的多項式，至多有兩個根；若 $t^*$ 在 $(0, 1)$ 內，它就是其中之一。每種情形都有 $t^* in T_k$。
  - $B'_k$ 恆為零。則 $B_k$ 為常數，其極值在 $t = 0$ 也取得，且 $0 in T_k$。
  因此 $B_k$ 在 $[0, 1]$ 上的最小值與最大值，等於它在有限集 $T_k subset [0, 1]$ 上的最小值與最大值，也就是命題中的 $alpha_k$ 與 $beta_k$，因為它們就是 $B_k$ 在曲線上的下確界與上確界。由#ref(<def-bbox>)，邊界框是各區間 $[alpha_k, beta_k]$ 的乘積：包含曲線的方框必包含每個值 $B_k (t)$，因而包含 $alpha_k$ 與 $beta_k$；而這些區間的乘積本身就包含曲線。
]

#proof(of: <prop-elevation>)[
  _直線。_直線 $t |-> (1 - t) P_0 + t P_3$ 是控制點為 $R_0 = P_0$、$R_1 = P_3$ 的一次 Bézier 曲線。由#ref(<prop-raise-degree>)取 $n = 1$，它是控制點為
  $ Q_0 = P_0, quad Q_1 = 1/2 P_0 + 1/2 P_3, quad Q_2 = P_3 $
  的二次曲線。再套用#ref(<prop-raise-degree>)取 $n = 2$，得到控制點為
  $ S_0 &= Q_0 = P_0, \
    S_1 &= 1/3 Q_0 + 2/3 Q_1 = 2/3 P_0 + 1/3 P_3, \
    S_2 &= 2/3 Q_1 + 1/3 Q_2 = 1/3 P_0 + 2/3 P_3, \
    S_3 &= Q_2 = P_3 $
  的三次曲線，亦即對 $i = 0, dots, 3$ 有 $S_i = P_0 + i/3 (P_3 - P_0)$。

  _二次曲線。_由#ref(<prop-raise-degree>)取 $n = 2$ 與控制點 $P_0, C, P_3$，三次控制點為
  $ Q_0 = P_0, quad Q_1 = 1/3 P_0 + 2/3 C, quad Q_2 = 2/3 C + 1/3 P_3, quad Q_3 = P_3, $
  即 $Q_1 = P_0 + 2/3 (C - P_0)$、$Q_2 = P_3 + 2/3 (C - P_3)$。

  每一步都是關於 $t$ 的恆等式，因此曲線與其參數化不變。
]

#proof(of: <prop-continuity>)[
  令 $B_S$、$B_T$ 為控制點分別是 $P_i$ 與 $Q_i$ 的三次 Bézier 曲線，使 $S(u) = B_S ((u - u_0 + h_S) slash h_S)$、$T(u) = B_T ((u - u_0) slash h_T)$。在 $u = u_0$ 處，兩個引數分別為 $1$ 與 $0$。由#ref(<prop-endpoints>)，$S(u_0) = P_3$、$T(u_0) = Q_0$。由連鎖律與#ref(<cor-end-tangents>)，
  $ S'(u_0) = (B'_S (1)) / h_S = (3(P_3 - P_2)) / h_S, quad T'(u_0) = (B'_T (0)) / h_T = (3(Q_1 - Q_0)) / h_T. $
  + 由#ref(<def-continuity>)取 $k = 0$，$C$ 在 $u_0$ 為 $C^0$ 若且唯若 $S(u_0) = T(u_0)$，即 $P_3 = Q_0$。
  + 當 $P_3 = Q_0$，#ref(<def-continuity>)取 $k = 1$ 多出 $S'(u_0) = T'(u_0)$ 的條件，兩邊除以 3 即所述等式。
  + 當 $P_3 = Q_0$，由#ref(<def-geometric-continuity>)，接點為 $G^1$ 若且唯若 $S'(u_0) != 0$、$T'(u_0) != 0$，且存在 $lambda > 0$ 使 $T'(u_0) = lambda S'(u_0)$。兩個切向量皆非零，若且唯若 $P_3 != P_2$ 且 $Q_1 != Q_0$，此時
    $ Q_1 - Q_0 = (lambda h_T / h_S) (P_3 - P_2). $
    反之，若 $Q_1 - Q_0 = mu (P_3 - P_2)$ 且 $mu > 0$，取 $lambda = mu h_S slash h_T > 0$，即得 $T'(u_0) = lambda S'(u_0)$。
  + 均勻參數化下，$m$ 段路徑的每段占 $1 slash m$，故 $h_S = h_T$，第 2 項的等式化為 $P_3 - P_2 = Q_1 - Q_0$。
]

== 建構與插值

#proof(of: <prop-endpoint>)[
  對具所述控制點的曲線 $B$，由#ref(<prop-endpoints>)得 $B(0) = P_0$、$B(1) = P_3$，由#ref(<cor-end-tangents>)得
  $ B'(0) = 3(P_1 - P_0) = D_0, quad B'(1) = 3(P_3 - P_2) = D_1. $
  再設 $Gamma$ 是任一次數至多為 3、滿足 $Gamma(0) = P_0$、$Gamma(1) = P_3$、$Gamma'(0) = D_0$、$Gamma'(1) = D_1$ 的多項式曲線。對每個座標套用#ref(<prop-basis>)，存在唯一的 $R_0, dots, R_3$ 使 $Gamma(t) = sum_i b_(i,3)(t) R_i$。對控制點 $R_i$ 作上述計算，得
  $ Gamma(0) = R_0, quad Gamma(1) = R_3, quad Gamma'(0) = 3(R_1 - R_0), quad Gamma'(1) = 3(R_3 - R_2). $
  與四個條件比較，得 $R_0 = P_0$、$R_3 = P_3$、$R_1 = P_0 + D_0 slash 3$、$R_2 = P_3 - D_1 slash 3$。所以 $R_i$ 就是所述的控制點，$Gamma = B$。
]

#proof(of: <prop-hermite-unique>)[
  令 $G(s) = H(x_0 + h s)$。映射 $H |-> G$ 是次數至多為 3 的多項式集合上的雙射，反映射為 $G |-> G((x - x_0) slash h)$。由連鎖律，$H(x_i) = f_i$ 與 $H'(x_i) = m_i$（$i = 0, 1$）等價於
  $ G(0) = f_0, quad G(1) = f_1, quad G'(0) = h m_0, quad G'(1) = h m_1. $
  由#ref(<prop-endpoint>)取 $d = 1$、$P_0 = f_0$、$P_3 = f_1$、$D_0 = h m_0$、$D_1 = h m_1$，恰有一個次數至多為 3 的多項式 $G$ 滿足這四個條件，其 Bernstein 係數為 $c_0, dots, c_3$。因此 $H$ 存在、唯一，且等於 $sum_i b_(i,3)((x - x_0) slash h) c_i$。
]

#proof(of: <prop-hermite>)[
  在 $t = t_0$ 與 $t = t_1$，線段分別於 $s = 0$ 與 $s = 1$ 求值，由#ref(<prop-endpoints>)得 $H(t_0) = P_0$、$H(t_1) = P_3$。由連鎖律，$H'(t) = B'(s) slash h$。由#ref(<cor-end-tangents>)，$B'(0) = 3(P_1 - P_0) = h D_0$、$B'(1) = 3(P_3 - P_2) = h D_1$，故 $H'(t_0) = D_0$、$H'(t_1) = D_1$。證明中不需要 $h > 0$。
]

#proof(of: <prop-graph-hermite>)[
  將線段寫成 $(X(s), Y(s))$。$X$ 的控制點為
  $ x_0, quad x_0 + h/3, quad x_1 - h/3 = x_0 + 2h/3, quad x_1, $
  由#ref(<prop-elevation>)（由 $x_0$ 到 $x_1$ 的直線），它們正是直線 $s |-> x_0 + h s$ 的控制點，故 $X(s) = x_0 + h s$。$Y$ 的控制點為 $y_0, y_0 + h m_0 slash 3, y_1 - h m_1 slash 3, y_1$，即#ref(<prop-hermite-unique>)中對資料 $y_i = f(x_i)$、$m_i = f'(x_i)$ 的係數 $c_0, dots, c_3$。因此 $Y(s) = H(x_0 + h s)$，線段為 $s |-> (x_0 + h s, H(x_0 + h s))$。
]

#proof(of: <thm-hermite-error>)[
  $x in {x_0, x_1}$ 的情形是平凡的：第一個公式兩邊皆為零，對任何 $xi$ 都成立。設 $x_0 < x < x_1$，並令
  $ E = f - H, quad w(t) = (t - x_0)^2 (t - x_1)^2, quad K = E(x) / w(x), quad g = E - K w. $
  則 $w(x) > 0$，$g$ 四階連續可微，且 $g(x_0) = g(x) = g(x_1) = 0$：$E$ 與 $w$ 在 $x_0$、$x_1$ 為零，而 $g(x) = E(x) - K w(x) = 0$。此外 $g'(x_0) = g'(x_1) = 0$：由#ref(<def-hermite>)，$E'(x_i) = f'(x_i) - H'(x_i) = 0$，而 $w$ 在每個 $x_i$ 有二重根，故 $w'(x_i) = 0$。

  由 Rolle 定理（#citet(<burden2011>) 的定理 1.7），$g'$ 在某個 $xi_1 in (x_0, x)$ 與某個 $xi_2 in (x, x_1)$ 為零。因此 $g'$ 有四個相異零點 $x_0 < xi_1 < xi_2 < x_1$。$g'$ 連續且三階可微，由廣義 Rolle 定理（#citet(<burden2011>) 的定理 1.10），存在 $xi in (x_0, x_1)$ 使 $g^((4))(xi) = 0$。由於 $H$ 的次數至多為 3，而 $w$ 是首項係數為 1 的四次多項式，$H^((4)) = 0$、$w^((4)) = 24$，因此
  $ 0 = g^((4))(xi) = f^((4))(xi) - 24 K, quad "即" quad K = (f^((4))(xi)) / 24. $
  故 $f(x) - H(x) = E(x) = K w(x)$，這就是第一個公式。

  關於界限：$(x - x_0)(x_1 - x)$ 是兩個和為 $h$ 的非負數之積，至多為 $(h slash 2)^2$。因此 $w(x) <= h^4 slash 16$，
  $ |f(x) - H(x)| <= M / 24 dot h^4 / 16 = (M h^4) / 384. $
]

== 擬合與等值線

#proof(of: <cor-depth>)[
  設 $[a, b]$ 是深度 $k$ 的區間，則 $b - a = L slash 2^k$。在此區間上，Hermite 線段的每個座標都是 $C$ 同一座標的三次 Hermite 插值多項式（詳見#ref(<prop-hermite>)與#ref(<prop-hermite-unique>)），因此由#ref(<thm-hermite-error>)，其誤差不超過 $M (b - a)^4 slash 384$。任一參數處的歐氏誤差至多為最大座標誤差的 $sqrt(d)$ 倍，因為對 $v in RR^d$ 有 $norm(v)_2 <= sqrt(d) norm(v)_oo$：事實上 $norm(v)_2^2 = sum_k v_k^2 <= d norm(v)_oo^2$。特別地，在量測參數上取最大值得到的實測誤差滿足
  $ e <= sqrt(d) M L^4 / (384 dot 2^(4k)). $
  此值不超過 $epsilon$，若且唯若 $2^(4k) >= sqrt(d) M L^4 slash (384 epsilon)$，也就是 $k >= 1/4 log_2 (sqrt(d) M L^4 slash (384 epsilon))$。每個 $k >= k^*$ 都滿足此式，所以該深度的每個區間都會被接受。

  再設 `max_depth` $>= k^*$ 且 `max_segments` $>= 2^(k^*)$。區間只有在不合格時才會被分割，而這只發生在深度 $k < k^*$。因此所有區間的深度至多為 $k^*$，不會因深度而拋出 `ToleranceNotMet`。被接受的區間是把 $[t_0, t_1]$ 對半至多 $k^*$ 次得到的互不重疊的片段，所以至多有 $2^(k^*)$ 個。不合格的區間至少會產生兩個被接受的線段，因此「目前已接受的線段數加二」不會超過這個最終數目，而它至多為 `max_segments`；所以線段數上限也不會被超過。
]

#proof(of: <prop-rdp>)[
  以 `rdp`$(i, j)$ 表示演算法對指標 $i < j$ 執行的遞迴步驟，它回傳由 $i$ 到 $j$ 的遞增指標列表。對 $j - i$ 作強歸納，證明對回傳列表中任兩個相鄰指標 $u < v$，每個滿足 $u <= l <= v$ 的指標 $l$ 都有 $"dist"(v_l, [v_u, v_v]) <= epsilon$。

  _基底。_若 $j <= i + 1$，列表為 $(i, j)$，且介於 $i$ 與 $j$（含）之間的指標只有 $i$ 與 $j$，其頂點就是弦的端點，距離為零。

  _歸納步驟。_否則令 $delta^*$ 為嚴格介於 $i$ 與 $j$ 之間的頂點到 $[v_i, v_j]$ 的最大距離。若 $delta^* <= epsilon$，列表為 $(i, j)$，由 $delta^*$ 的選取以及端點距離為零，結論成立。若 $delta^* > epsilon$，步驟選取指標 $m$，$i < m < j$，並回傳 $"rdp"(i, m)$ 的列表接上 $"rdp"(m, j)$ 的列表，$m$ 只出現一次。結果中任兩個相鄰指標，在這兩個列表之一中也是相鄰的。由於 $m - i$ 與 $j - m$ 都小於 $j - i$，歸納假設適用於兩者。

  步驟 2 與 3 對步驟 2 保留的每兩個相鄰頂點執行 `rdp` 並串接結果。輸出恰保留回傳的指標 $a_0 < dots < a_m$，其中每兩個相鄰指標在某個列表中也相鄰。這就證明了不等式。輸出線段的 `fit_error` 是 $max_(a_j <= i <= a_(j+1)) "dist"(v_i, [v_(a_j), v_(a_(j+1))])$，因此不超過 $epsilon$。
]

#proof(of: <cor-rdp-path>)[
  1. 到凸集的距離是凸函數。對線段 $K = [a, b]$，設 $x_1, x_2$ 滿足 $"dist"(x_i, K) <= epsilon$，並在 $y_i in K$ 取得（由緊緻性，最小值存在），$lambda in [0, 1]$。則 $lambda y_1 + (1 - lambda) y_2 in K$，由三角不等式，
  $ norm(lambda x_1 + (1 - lambda) x_2 - (lambda y_1 + (1 - lambda) y_2))_2 <= lambda norm(x_1 - y_1)_2 + (1 - lambda) norm(x_2 - y_2)_2 <= epsilon. $
  所以 $"dist"(lambda x_1 + (1 - lambda) x_2, K) <= epsilon$。

  折線上的點 $x$ 位於某條邊 $[v_i, v_(i+1)]$ 上，即 $x = lambda v_i + (1 - lambda) v_(i+1)$。選取 $j$ 使 $a_j <= i < a_(j+1)$；因指標為整數，$i + 1 <= a_(j+1)$，由#ref(<prop-rdp>)，$v_i$ 與 $v_(i+1)$ 都在 $[v_(a_j), v_(a_(j+1))]$ 的 $epsilon$ 範圍內。由剛證的凸性，$x$ 亦然。

  2. 通過步驟 1 的點就是某個 $v_i$，由#ref(<prop-rdp>)，它離某條弦不超過 $epsilon$。被刪除的輸入點 $p$ 與其前一個保留的頂點（記為 $v$）相距不超過 $delta$；設弦 $[a, b]$ 與 $v$ 相距不超過 $epsilon$，則
  $ "dist"(p, [a, b]) <= norm(p - v)_2 + "dist"(v, [a, b]) <= delta + epsilon. $
  封閉折線結尾重複的起點在同樣條件下被刪除，取 $v = v_0$ 即可。
]

#proof(of: <prop-center>)[
  把 $[0, 1]^2$ 的四個角代入 $u$，每個角只有一項不為零且係數為 $1$，所以 $u$ 在角點取角點值。在 $s = t = 1 slash 2$，四個權重乘積都等於 $1/2 dot 1/2 = 1/4$，因此 $u(1/2, 1/2) = 1/4 (f_(00) + f_(10) + f_(11) + f_(01))$。
]

#proof(of: <thm-gradient>)[
  因為 $nabla F(p) != 0$，$F_y (p) != 0$ 或 $F_x (p) != 0$。

  _情形 $F_y (p) != 0$。_套用#ref(<thm-ift>)：存在 $I$、$J$ 與 $C^1$ 函數 $phi : I -> J$，$phi(p_x) = p_y$，且 $L_c inter (I times J) = {(x, phi(x)) : x in I}$。令 $N = I times J$、$gamma(x) = (x, phi(x))$。對 $F(x, phi(x)) = c$ 用連鎖律微分，在 $gamma(x)$ 處得 $F_x + F_y phi' = 0$。由 $F_y$ 的連續性，可縮小 $I$ 與 $J$ 使 $F_y != 0$ 在 $N$ 上成立；於是
  $ gamma'(x) = (1, phi'(x)) = (1, -F_x / F_y) = 1 / F_y (F_y, -F_x), $
  它非零，且在 $gamma(x)$ 處平行於 $(F_y, -F_x)$。

  _情形 $F_x (p) != 0$。_交換 $x$ 與 $y$ 的角色：存在 $C^1$ 函數 $psi$ 使 $L_c inter N = {(psi(y), y)}$，曲線 $gamma(y) = (psi(y), y)$，且 $psi' = -F_y slash F_x$，故
  $ gamma'(y) = (-F_y / F_x, 1) = -1 / F_x (F_y, -F_x), $
  同樣非零且平行於 $(F_y, -F_x)$。

  最後 $nabla F dot (F_y, -F_x) = F_x F_y - F_y F_x = 0$。
]

== 匯出

#proof(of: <prop-rounding>)[
  兩條曲線的差為
  $ tilde(B)(t) - B(t) = sum_(i=0)^n b_(i,n)(t) (tilde(P)_i - P_i). $
  由#ref(<prop-unity>)，權重 $b_(i,n)(t)$ 非負且和為 1，因此對每個座標，
  $ |tilde(B)_k (t) - B_k (t)| <= sum_(i=0)^n b_(i,n)(t) |tilde(P)_(i,k) - P_(i,k)| <= epsilon. $
  由於對 $v in RR^d$ 有 $norm(v)_2 <= sqrt(d) norm(v)_oo$（見 #citet(<golub2013>) 第 2.2 節），得 $norm(tilde(B)(t) - B(t))_2 <= sqrt(d) epsilon$。

  匯出器以 Python 的定點格式寫出每個座標的 $p$ 位小數，得到最接近該座標的 $10^(-p)$ 的整數倍，與原座標相差至多 $1/2 dot 10^(-p)$。匯出器也把絕對值小於 $1/2 dot 10^(-p)$ 的座標寫成 $0$，改變量即該絕對值，同樣至多為 $1/2 dot 10^(-p)$。
]

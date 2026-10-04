#import "/template/manual.typ": *

= 證明 <app-proofs>

本附錄依各章出現的順序，證明其中陳述的定理。以下 $b_(i,n)$ 為#ref(<sec-curves>)的 Bernstein 多項式，並約定 $i < 0$ 或 $i > n$ 時 $b_(i,n) = 0$；$B(t) = sum_i b_(i,n)(t) P_i$ 為 $n$ 次曲線。

以下兩個二項式係數恆等式會反覆使用：
$ binom(n-1, j) + binom(n-1, j-1) = binom(n, j), quad
  i binom(n, i) = n binom(n-1, i-1). $

== Bernstein 基底與求值

#proof(of: <thm-unity>)[
  當 $t in [0, 1]$ 時，$t$ 與 $1 - t$ 都非負，因此每個 $b_(i,n)(t)$ 都非負。由二項式定理，
  $ sum_(i=0)^n binom(n, i) t^i (1-t)^(n-i) = (t + (1 - t))^n = 1. $
]

#proof(of: <thm-endpoints>)[
  在 $t = 0$，除非 $i = 0$，否則因子 $t^i$ 為零，且 $b_(0,n)(0) = (1 - 0)^n = 1$。在 $t = 1$，除非 $i = n$，否則因子 $(1-t)^(n-i)$ 為零，且 $b_(n,n)(1) = 1$。因此 $B(0) = sum_i b_(i,n)(0) P_i = P_0$，同理 $B(1) = P_n$。
]

#proof(of: <thm-hull>)[
  由#ref(<thm-unity>)，$B(t) = sum_i lambda_i P_i$，其中 $lambda_i = b_(i,n)(t) >= 0$ 且 $sum_i lambda_i = 1$。依定義，點的凸組合位於這些點的凸包內。
]

#proof(of: <thm-affine>)[
  由 $M$ 的線性與#ref(<thm-unity>)，
  $ A(B(t)) = M sum_i b_(i,n)(t) P_i + (sum_i b_(i,n)(t)) v
            = sum_i b_(i,n)(t) (M P_i + v)
            = sum_i b_(i,n)(t) A(P_i). $
]

#proof(of: <thm-casteljau>)[
  對 $r$ 作歸納。$r = 0$ 時，$P_i^((0)) = P_i = b_(0,0)(t) P_i$。假設 $r - 1$ 時成立，則
  $ P_i^((r)) &= (1 - t) sum_(j=0)^(r-1) b_(j,r-1)(t) P_(i+j)
                + t sum_(j=0)^(r-1) b_(j,r-1)(t) P_(i+1+j) \
              &= sum_(j=0)^r [(1 - t) b_(j,r-1)(t) + t b_(j-1,r-1)(t)] P_(i+j). $
  方括號等於 $[binom(r-1, j) + binom(r-1, j-1)] t^j (1-t)^(r-j) = b_(j,r)(t)$。取 $r = n$、$i = 0$，即得 $P_0^((n)) = B(t)$。
]

== 導數、分割與反轉

#proof(of: <thm-hodograph>)[
  微分並利用 $i binom(n, i) = n binom(n-1, i-1)$ 與 $(n - i) binom(n, i) = n binom(n-1, i)$，得
  $ b'_(i,n)(t) = n [b_(i-1,n-1)(t) - b_(i,n-1)(t)]. $
  因此，將第一個和式的指標平移後，
  $ B'(t) = n sum_(i=0)^n [b_(i-1,n-1)(t) - b_(i,n-1)(t)] P_i
          = n sum_(i=0)^(n-1) b_(i,n-1)(t) (P_(i+1) - P_i). $
  在 $0$ 與 $1$ 的值，由#ref(<thm-endpoints>)套用到這條 $n - 1$ 次曲線即得。
]

#proof(of: <thm-reversal>)[
  令 $j = n - i$ 重新編號，
  $ sum_(i=0)^n b_(i,n)(t) P_(n-i) = sum_(j=0)^n b_(n-j,n)(t) P_j, $
  而 $b_(n-j,n)(t) = binom(n, j) t^(n-j) (1-t)^j = b_(j,n)(1 - t)$，故此和為 $B(1 - t)$。
]

#proof(of: <thm-subdivision>)[
  _左段。_將 $1 - c s$ 寫成 $(1 - s) + s(1 - c)$，並展開兩個冪次：
  $ B(c s) &= sum_(i=0)^n binom(n, i) (c s)^i [(1 - s) + s(1 - c)]^(n-i) P_i \
           &= sum_(i=0)^n sum_(k=0)^(n-i) binom(n, i) binom(n-i, k) c^i (1-c)^k s^(i+k) (1-s)^(n-i-k) P_i. $
  令 $j = i + k$，並利用 $binom(n, i) binom(n-i, j-i) = binom(n, j) binom(j, i)$：
  $ B(c s) = sum_(j=0)^n binom(n, j) s^j (1-s)^(n-j) sum_(i=0)^j binom(j, i) c^i (1-c)^(j-i) P_i
           = sum_(j=0)^n b_(j,n)(s) P_0^((j)), $
  其中內層和由#ref(<thm-casteljau>)即為 $t = c$ 時的 $P_0^((j))$。這就是關於 $L_j$ 的結論。

  _右段。_令 $overline(B)$ 為反轉後的曲線，控制點為 $overline(P)_i = P_(n-i)$，由#ref(<thm-reversal>)，$overline(B)(u) = B(1 - u)$。對 $overline(B)$ 在 $overline(c) = 1 - c$ 套用左段的結果，得 $overline(B)(overline(c) s) = sum_j b_(j,n)(s) overline(L)_j$，其中
  $ overline(L)_j = sum_(i=0)^j b_(i,j)(1 - c) P_(n-i)
                  = sum_(l=0)^j b_(l,j)(c) P_(n-j+l) = P_(n-j)^((j)) = R_(n-j), $
  這裡用到 $b_(i,j)(1 - c) = b_(j-i,j)(c)$、代換 $l = j - i$ 與#ref(<thm-casteljau>)。因此
  $ B(c + (1 - c) s) = overline(B)((1 - c)(1 - s))
                     = sum_(j=0)^n b_(j,n)(1 - s) R_(n-j)
                     = sum_(j=0)^n b_(n-j,n)(s) R_(n-j)
                     = sum_(k=0)^n b_(k,n)(s) R_k. $
]

#proof(of: <thm-segment>)[
  令 $a = t_0$、$e = t_1$，則 $e > a >= 0$。在 $e$ 分割並保留左段，由#ref(<thm-subdivision>)得到曲線 $u |-> B(e u)$。再於 $a slash e in [0, 1)$ 分割該曲線並保留右段，得到
  $ s |-> B(e (a/e + (1 - a/e) s)) = B(a + (e - a) s). $
]

== 三次線段與路徑

#proof(of: <thm-bbox>)[
  展開三次 Bernstein 形式，
  $ B(t) = (1-t)^3 P_0 + 3t(1-t)^2 P_1 + 3t^2(1-t) P_2 + t^3 P_3
         = a t^3 + b t^2 + c t + P_0, $
  其中 $a$、$b$、$c$ 如定理所述。每個座標 $B_k$ 在緊緻區間 $[0, 1]$ 上連續，因此在其上取得最小值與最大值。若極值出現在內點 $t^*$，則它是臨界點，$B'_k(t^*) = 3 a_k t^(*2) + 2 b_k t^* + c_k = 0$；否則就在 $0$ 或 $1$。若 $B'_k$ 恆為零，$B_k$ 為常數，任一候選點都給出極值。求得的最小值與最大值都是曲線上的值，因此沒有更小的方框能包含曲線。
]

#proof(of: <thm-elevation>)[
  _直線。_首先，由 $i binom(n, i) = n binom(n-1, i-1)$ 與#ref(<thm-unity>)，$sum_i i b_(i,n)(t) = n t sum_i b_(i-1,n-1)(t) = n t$。令 $Q_i = P_0 + i/3 (P_3 - P_0)$，
  $ sum_(i=0)^3 b_(i,3)(t) Q_i = P_0 + (P_3 - P_0) sum_i i/3 b_(i,3)(t) = P_0 + t (P_3 - P_0). $

  _二次曲線。_將 $b_(i,2)(t)$ 乘上 $(1 - t) + t$，
  $ b_(i,2)(t) = (3 - i)/3 b_(i,3)(t) + (i + 1)/3 b_(i+1,3)(t), $
  因為 $binom(2, i) slash binom(3, i) = (3 - i) slash 3$、$binom(2, i) slash binom(3, i+1) = (i + 1) slash 3$。對二次控制點 $R_0 = P_0$、$R_1 = C$、$R_2 = P_3$，得
  $ sum_(i=0)^2 b_(i,2)(t) R_i = sum_(k=0)^3 b_(k,3)(t) [k/3 R_(k-1) + (3 - k)/3 R_k], $
  其控制點為 $R_0 = P_0$、$1/3 P_0 + 2/3 C$、$2/3 C + 1/3 P_3$、$R_2 = P_3$，與定理所述相同。兩個恆等式對每個 $t$ 都成立，因此參數化不變。
]

#proof(of: <thm-continuity>)[
  設接點位於整體參數 $u_0$。在各自的區間上，$S$ 於 $s = (u - u_0 + h_S) slash h_S$ 求值，$T$ 於 $s = (u - u_0) slash h_T$ 求值。由連鎖律與#ref(<thm-hodograph>)，$u_0$ 處的單邊導數為 $S'(1) slash h_S = 3(P_3 - P_2) slash h_S$ 與 $T'(0) slash h_T = 3(Q_1 - Q_0) slash h_T$。由於 $P_3 = Q_0$，曲線連續；兩個導數相等時，接點處恰為 $C^1$。在均勻參數化下，$m$ 段路徑的 $h_S = h_T = 1 slash m$。
]

== 建構與插值

#proof(of: <thm-endpoint>)[
  由#ref(<thm-endpoints>)，$B(0) = P_0$、$B(1) = P_3$；由#ref(<thm-hodograph>)，$B'(0) = 3(P_1 - P_0) = D_0$、$B'(1) = 3(P_3 - P_2) = D_1$。反之，三次 Bernstein 多項式構成基底，因此三次曲線的控制點唯一，而這四個條件決定了全部控制點：$P_0 = B(0)$、$P_3 = B(1)$、$P_1 = P_0 + B'(0) slash 3$、$P_2 = P_3 - B'(1) slash 3$。
]

#proof(of: <thm-hermite>)[
  在 $t = t_0$ 與 $t = t_1$，線段分別於 $s = 0$ 與 $s = 1$ 求值，由#ref(<thm-endpoints>)得 $H(t_0) = P_0$、$H(t_1) = P_3$。由連鎖律，$H'(t) = B'(s) slash h$。由#ref(<thm-hodograph>)，$B'(0) = 3(P_1 - P_0) = h D_0$、$B'(1) = 3(P_3 - P_2) = h D_1$，故 $H'(t_0) = D_0$、$H'(t_1) = D_1$。證明中不需要 $h > 0$。
]

#proof(of: <thm-hermite-error>)[
  `graph_hermite` 線段的 $x$ 座標是線性函數 $x$（導數為 1）的插值，由三次 Hermite 插值的唯一性，它對 $x$ 是線性的；因此線段是三次多項式 $H$ 的圖形，且 $H(x_i) = f(x_i)$、$H'(x_i) = f'(x_i)$。

  固定 $x in (x_0, x_1)$，令 $w(t) = (t - x_0)^2 (t - x_1)^2$，它在 $x$ 處為正。選取 $K$ 使 $g(t) = f(t) - H(t) - K w(t)$ 在 $t = x$ 處為零。則 $g$ 在 $x_0$、$x$、$x_1$ 為零，且 $g'$ 在 $x_0$、$x_1$ 也為零，因為 $f - H$ 與 $w$ 在這兩點都有二重根。由 Rolle 定理，$g'$ 在 $(x_0, x)$ 與 $(x, x_1)$ 各有一個零點，因此在 $[x_0, x_1]$ 上有四個相異零點；依此類推，$g''$ 有三個，$g'''$ 有兩個，$g^((4))$ 至少有一個，記為 $xi$。由於 $H$ 是三次多項式而 $w$ 是首項係數為 1 的四次多項式，$0 = g^((4))(xi) = f^((4))(xi) - 24 K$，故
  $ f(x) - H(x) = f^((4))(xi) / 24 (x - x_0)^2 (x - x_1)^2. $
  在區間上 $|(x - x_0)(x - x_1)| <= h^2 slash 4$，於中點取等號，因此 $|f(x) - H(x)| <= M h^4 slash (24 dot 16) = M h^4 slash 384$ #citep(<burden2011>)。
]

== 擬合與等值線

#proof(of: <thm-depth>)[
  深度 $k$ 的區間寬度為 $h = H slash 2^k$。在此區間上，Hermite 線段的每個座標都在兩端吻合 $C$ 對應座標的值與導數（詳見#ref(<thm-hermite>)），因此是該座標的三次 Hermite 插值，由#ref(<thm-hermite-error>)，其誤差不超過 $M h^4 slash 384$。所以歐氏誤差處處不超過 $sqrt(d) M h^4 slash 384$，在量測誤差的量測參數上當然也成立。當 $2^(4k) >= sqrt(d) M H^4 slash (384 epsilon)$，亦即 $k$ 滿足定理中的條件時，此值不超過 $epsilon$。
]

#proof(of: <thm-rdp>)[
  考慮對指標 $i < j$ 的頂點執行的遞迴步驟。對 $j - i$ 作歸納，證明它回傳的任兩個相鄰指標 $u < v$ 之間的每個頂點，到弦 $P_u P_v$ 的距離都不超過容許誤差。若 $j <= i + 1$，兩者之間沒有頂點。若離弦 $P_i P_j$ 最遠的頂點在容許誤差內，步驟回傳 $(i, j)$，結論成立。否則它回傳 $(i, m)$ 與 $(m, j)$ 兩次呼叫的結果並在 $m$ 接合，$i < m < j$；每一對相鄰指標都來自其中一次呼叫，可套用歸納假設。外層演算法在相鄰的保留頂點之間執行此步驟，每個輸出線段都連接兩個相鄰的回傳指標。距離是到線段形式的弦的距離，與 `fit_error` 回報的距離相同。
]

#proof(of: <thm-gradient>)[
  由於 $nabla F(p) != 0$，不妨設 $F_y(p) != 0$；$F_x(p) != 0$ 的情形交換 $x$ 與 $y$ 的角色即可。由隱函數定理，存在 $p_x$ 附近的 $C^1$ 函數 $phi$，滿足 $phi(p_x) = p_y$，使得在 $p$ 附近等值集即為圖形 $gamma(x) = (x, phi(x))$。對 $F(gamma(x)) = c$ 微分得 $F_x + F_y phi' = 0$，故
  $ gamma'(x) = (1, -F_x / F_y) = 1 / F_y (F_y, -F_x), $
  在 $p$ 處平行於 $(F_y, -F_x)$。
]

== 匯出

#proof(of: <thm-rounding>)[
  令 $tilde(P)_i = P_i + delta_i$，且每個座標 $k$ 都有 $|delta_(i,k)| <= epsilon$。擾動後的曲線與 $B$ 相差 $tilde(B)(t) - B(t) = sum_i b_(i,n)(t) delta_i$。由#ref(<thm-unity>)，在每個座標上
  $ |sum_i b_(i,n)(t) delta_(i,k)| <= sum_i b_(i,n)(t) |delta_(i,k)| <= epsilon, $
  因此歐氏距離至多為 $sqrt(d epsilon^2) = epsilon sqrt(d)$。把數值四捨五入到小數點後 $p$ 位，改變量至多 $1/2 dot 10^(-p)$；匯出器把小於此值的數改寫為 $0$，也是同樣大小的捨入。
]

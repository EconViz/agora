#import "/template/manual.typ": *

= 證明 <app-proofs>

本附錄依各章出現的順序，證明其中陳述的引理、命題、定理與推論。以下假設精確算術；程式以浮點數計算相同的量，因此與退化情形只差捨入誤差的配置（例如點在邊上，或三點幾乎共線）可能被判定為任一結果。平面向量 $u, v$ 的外積記為 $u times v = u_x v_y - u_y v_x$。

== 排列與軌道

#proof(of: <thm-spread>)[
  #emph[變數代換。]令 $o_k = sum_(j < k) (s_j + g) + s_k slash 2$、$y_k = x_k - o_k$、$z_k = c_k - o_k$。由於 $o_(k+1) - o_k = (s_k + s_(k+1)) slash 2 + g$，#ref(<def-packing>)的限制條件即 $y_1 <= dots.c <= y_n$，目標函數為 $sum_k (y_k - z_k)^2$。因此問題是在最小平方意義下，找出最接近 $z$ 的非遞減向量。

  #emph[程式所計算的。]由第 $i$ 項起、起點為 $S_B$ 的連續項目群 $B$，把 $k in B$ 放在 $x_k = S_B + sum_(i <= l < k) (s_l + g) + s_k slash 2 = S_B + o_k - O_i$，其中 $O_i = sum_(l < i) (s_l + g)$。因此 $y_k = S_B - O_i =: Y_B$ 在 $B$ 上為常數，而程式取 $S_B$ 為 $c_k - (o_k - O_i)$ 的平均，使 $Y_B$ 成為 $z_k$ 在 $B$ 上的平均；新加入的單一項目則有 $Y = z_k$。群 $A$ 與其後的群 $B$ 在 $S_A + "length"(A) + g <= S_B$ 時保持分開；由於 $"length"(A) + g = O_(i_B) - O_(i_A)$，此條件即 $Y_A <= Y_B$。因此程式就是相鄰違反者合併演算法：把 $z_k$ 加為一個區塊，只要最後兩個區塊的平均遞減，就以它們的聯集（取其平均）取代。

  #emph[不變式。] (a) 相鄰區塊的平均非遞減：最後一對順序正確時合併即停止，較早的區塊對不受影響。(b) 在平均為 $mu_B$ 的每個區塊 $B$ 中，每個起始片段的平均至少為 $mu_B$。單一項目滿足 (b)。$A$ 與 $B$ 合併時 $mu_A > mu_B$，合併後的平均 $mu$ 嚴格介於兩者之間。$A$ 內的起始片段平均至少為 $mu_A > mu$。其他起始片段是 $A$ 接上 $B$ 的起始片段 $B'$；若 $B'$ 為整個 $B$，其平均為 $mu$；否則 $B$ 的其餘部分 $B''$ 由 $B$ 的 (b) 知平均至多 $mu_B < mu$，而該片段是平均為 $mu$ 的集合中 $B''$ 的補集，平均至少為 $mu$。

  #emph[最佳性。]目標函數嚴格凸、限制條件 $y_k - y_(k+1) <= 0$ 為線性，因此滿足 Karush–Kuhn–Tucker 條件的點即唯一的最小解 #citep(<boyd2004>)。對 $k = 0, dots, n$ 令 $lambda_k = 2 sum_(l <= k) (z_l - y_l)$。平穩條件 $2 (y_k - z_k) + lambda_k - lambda_(k-1) = 0$ 依構造成立。區塊內的偏差 $z_l - Y_B$ 總和為零，因此 $lambda$ 在每個區塊末端為零，包括 $lambda_n = 0$。在由第 $i$ 項起的區塊內，由 (b) 得 $lambda_k = 2 sum_(l=i)^k (z_l - Y_B) >= 0$。最後，$lambda_k > 0$ 只發生在 $k$ 與 $k + 1$ 屬於同一區塊時，此時 $y_k = y_(k+1)$，限制條件取等號。加上 (a) 給出的可行性，所有條件都成立。
]

#proof(of: <cor-spread>)[
  (i) 依排序後的順序編號，並設 $i < j$。把第 $i$ 到第 $j - 1$ 條限制相加，得 $x_j - x_i >= sum_(k=i)^(j-1) ((s_k + s_(k+1)) slash 2 + g) >= (s_i + s_j) slash 2 + g$，因為每項都非負，且首末兩項分別貢獻 $s_i slash 2$ 與 $s_j slash 2$。(ii) 若 $c$ 是排列，它使目標函數為 $0$，因此是#ref(<thm-spread>)的唯一最小解。(iii) 沿用該證明的記號，$sum_(k in B) (x_k - c_k) = sum_(k in B) (y_k - z_k) = |B| Y_B - sum_(k in B) z_k = 0$。
]

#proof(of: <thm-lanes>)[
  區間只在與某軌道上所有區間都不衝突時才加入該軌道，之後不再移動，因此結果是軌道指派。任何軌道指派都必須把 $omega$ 個兩兩衝突的區間放在 $omega$ 條不同軌道，所以至少需要 $omega$ 條軌道。

  反過來，記 $J = [a_J, b_J]$，並設區間依 $a$ 遞增的順序給出。由#ref(<def-conflict>)，$I$ 與 $J$ 衝突恰好等價於半開區間 $[a_I, b_I + g)$ 與 $[a_J, b_J + g)$ 相交。設 $I$ 被放在所用的最高軌道 $k$。$I$ 到來時，每條軌道 $j < k$ 上都有與 $I$ 衝突的區間 $J_j$。每個 $J_j$ 較早到來，故 $a_(J_j) <= a_I$；又與 $I$ 衝突，故 $b_(J_j) + g > a_I$。因此每個 $[a_(J_j), b_(J_j) + g)$ 都含 $a_I$，而 $b_I - a_I + g > 0$ 使 $[a_I, b_I + g)$ 也含 $a_I$。有共同點的半開區間兩兩相交，所以 $J_0, dots, J_(k-1), I$ 是 $k + 1$ 個兩兩衝突的區間，$k + 1 <= omega$。
]

== 矩形、線段與多邊形

#proof(of: <lem-nearest>)[
  $|q - p|^2 = (q_x - p_x)^2 + (q_y - p_y)^2$，而 $R$ 是 $[x_0, x_1]$ 與 $[y_0, y_1]$ 的乘積，因此兩個座標可分別最小化。在區間上，$t |-> (t - p_x)^2$ 嚴格凸，無限制的最小值在 $p_x$，所以它在 $[x_0, x_1]$ 上的最小值只在 $min(max(p_x, x_0), x_1)$ 取得；$y$ 亦同。
]

#proof(of: <lem-orient>)[
  將其他列減去第一列，得
  $ "orient"(a, b, c) = det mat(1, a_x, a_y; 1, b_x, b_y; 1, c_x, c_y). $
  列的循環置換為偶置換，交換兩列為奇置換，由此得到對稱性。又 $"orient"(a, b, c) = (b - a) times (c - a) = |b - a| |c - a| sin theta$，其中 $theta$ 為從 $b - a$ 到 $c - a$ 的有號角；它為正恰好在 $theta in (0, pi)$，即 $c$ 位於有向直線左側時，位於右側時為負，而在兩向量平行或其一為零，即三點共線時為零。
]

#proof(of: <thm-segments>)[
  先說明：若 $"orient"(c, d, p) = 0$ 且 $p$ 位於 $[c, d]$ 的外接矩形內，則 $p in [c, d]$。事實上，若 $c = d$，外接矩形就是點 $c$；否則由共線性，對某實數 $t$ 有 $p = c + t (d - c)$，而在 $d - c$ 不為零的座標上，外接矩形條件迫使 $t in [0, 1]$。

  #emph[充分性。]設 $d_1 d_2 < 0$ 且 $d_3 d_4 < 0$。$"orient"(c, d, dot)$ 沿 $[a, b]$ 為仿射函數且變號，因此 $[a, b]$ 與直線 $L_(c d)$ 交於一點；同理 $[c, d]$ 與 $L_(a b)$ 交於一點。由於 $a$、$b$ 位於 $L_(c d)$ 兩側，兩直線不平行，恰有一個共同點 $z$；兩個交點都等於 $z$，因此 $z$ 同時位於兩線段上。另一種情形是某個 $d_i = 0$ 且其端點位於另一線段的外接矩形內，由上述說明，該端點位於另一線段上。

  #emph[必要性。]設 $z$ 為共同點。若 $d_1 d_2 > 0$，則 $a$、$b$ 嚴格位於 $L_(c d)$ 的同一側，整個 $[a, b]$ 亦然，與 $z in L_(c d)$ 矛盾；所以 $d_1 d_2 <= 0$，同理 $d_3 d_4 <= 0$。若兩者皆為負則得證。否則某個 $d_i$ 為零；不妨設 $d_1 = 0$，其餘情形對稱。若 $d_2 != 0$，$[a, b]$ 只在 $a$ 與 $L_(c d)$ 相交，故 $z = a$ 且 $a in [c, d]$：$d_1$ 的測試成立。若 $d_2 = 0$，四點共線，兩線段是同一直線上重疊的區間，其中一條的端點位於另一條內，因此四個測試之一成立。
]

#proof(of: <lem-rect-segment>)[
  $R$ 的邊都在 $R$ 內，因此任一測試成立都給出共同點（參見#ref(<thm-segments>)）。反之，設 $[a, b]$ 與 $R$ 相交但兩端點都不在 $R$ 內。線段是連通的，同時含有 $R$ 內與 $R$ 外的點，因此與 $R$ 的邊界相交，而邊界是四條邊的聯集；#ref(<thm-segments>)會偵測到該邊。
]

#proof(of: <lem-segment-distance>)[
  $t |-> |a + t (b - a) - p|^2$ 是凸二次函數，無限制的最小值在 $(p - a) dot (b - a) slash |b - a|^2$；如#ref(<lem-nearest>)的證明，它在 $[0, 1]$ 上的最小值位於該值的截斷處。
]

#proof(of: <prop-even-odd>)[
  記 $p = (x, y)$，取 $epsilon > 0$ 小於所有頂點高度與 $y$ 的正差值 $|y_i - y|$，且小到使 $p_epsilon = (x, y + epsilon)$ 與 $p$ 位於 $RR^2 without partial P$ 的同一連通分量（因 $p in.not partial P$ 且各分量為開集，此為可行）。直線 $Y = y + epsilon$ 上沒有頂點，且對每個頂點，$y_i > y$ 若且唯若 $y_i > y + epsilon$。因此一條邊通過程式的高度測試，恰好等價於它穿過直線 $Y = y + epsilon$，交點橫座標為 $X_epsilon = x_0 + (y + epsilon - y_0)(x_1 - x_0) slash (y_1 - y_0)$。程式比較的是 $x$ 與 $X_0$。若 $x = X_0$，由於高度測試使 $y$ 介於兩端點高度之間，點 $(X_0, y)$ 位於該邊上，即 $p in partial P$，與假設矛盾；所以 $x != X_0$，由連續性，對夠小的 $epsilon$，$x < X_0$ 若且唯若 $x < X_epsilon$。因此程式計算的正是從 $p_epsilon$ 向右、不經過任何頂點的射線所穿過的邊。每次穿越都使射線在內部與外部之間切換，而射線在最右方位於外部，所以計數為奇數恰好在 $p_epsilon in "int" P$，即 $p in "int" P$ 時 #citep(<haines1994>)。
]

#proof(of: <thm-rect-inside>)[
  若 $R subset "int" P$，則 $R$ 與 $partial P$ 不相交，因此沒有邊碰到它（參見#ref(<lem-rect-segment>)），而它的角位於 $"int" P$ 且不在邊界上，因此通過奇偶測試（參見#ref(<prop-even-odd>)）。反之，若沒有邊碰到 $R$，則 $R inter partial P = emptyset$（參見#ref(<lem-rect-segment>)）；特別是各角不在邊界上，通過測試即表示它們位於 $"int" P$。$R$ 是連通的且與 $partial P$ 不相交，因此位於 $RR^2 without partial P$ 的一個分量內；它含有一個位於 $"int" P$ 的角，所以 $R subset "int" P$。
]

#proof(of: <cor-rect-overlap>)[
  若有一個角通過測試，它不在邊界上時位於 $"int" P$（參見#ref(<prop-even-odd>)），否則位於 $partial P$；無論哪種情形都有 $R inter overline(P) != emptyset$。若有一條邊碰到 $R$，則 $R$ 與 $partial P$ 相交。反之，設 $R$ 與 $overline(P)$ 相交。若它與 $partial P$ 相交，就有某條邊碰到它。否則 $R$ 與 $partial P$ 不相交而與 $"int" P$ 相交；由連通性得 $R subset "int" P$，其各角通過測試。
]

#proof(of: <prop-ray-exit>)[
  設對某個 $t > T$，$p = o + t r in partial P$，位於邊 $e$ 上。若 $e$ 不平行於 $r$，程式對 $e$ 解 $o + t r = a + u (b - a)$，得到這個 $t >= 0$ 與 $u in [0, 1]$，因此 $T >= t$，矛盾。若 $e$ 平行於 $r$，它位於射線所在直線 $ell$ 上。取包含 $e$、位於 $ell$ 上的極大連續邊段。它不是整個 $P$（$P$ 的頂點不全共線），所以邊段兩端都是與某條不在 $ell$ 上、因而不平行於 $r$ 的邊共用的頂點。邊段中相鄰的邊不會折返，因為從同一頂點沿 $ell$ 同向出發的兩條邊會重疊，與 $P$ 為簡單多邊形矛盾；因此邊段是 $ell$ 上的一段，其在 $r$ 方向的遠端是端點頂點 $v = o + t_v r$，且 $t_v >= t > T$。相鄰的不平行邊含有 $v$（$u in {0, 1}$），因此 $T >= t_v$，同樣矛盾。所以 ${o + t r : t > T}$ 與 $partial P$ 不相交；它連通且無界，因此位於外部。
]

== 不可及極點

#proof(of: <lem-lipschitz>)[
  對任意集合 $S$，由三角不等式得 $|d(p, S) - d(q, S)| <= |p - q|$，這處理了 $p$、$q$ 在同一側的情形。設 $p in overline(P)$、$q in.not overline(P)$，並令 $z$ 為從 $p$ 到 $q$ 的線段上屬於 $overline(P)$ 的最後一點（$overline(P)$ 為閉集，故存在）。緊接在 $z$ 之後的點都在外面，因此 $z in.not "int" P$，即 $z in partial P$。於是 $|f(p) - f(q)| = d(p, partial P) + d(q, partial P) <= |p - z| + |z - q| = |p - q|$。
]

#proof(of: <thm-polylabel>)[
  程式精確計算 $f$：不在邊界上時，由#ref(<prop-even-odd>)符號正確；在邊界上時距離為 $0$。記 $b$ 為目前的最佳值；它只會增加，且始終是某個已求值中心的 $f$ 值。

  #emph[結束性。]每次分割使半邊長 $h$ 減半。取出 $h sqrt(2) <= epsilon$ 的格子時，更新後 $b >= f(c)$，因此其上界至多比 $b$ 多 $h sqrt(2) <= epsilon$，格子被捨棄而不分割。所以格子構成有限樹，每格各推入與取出一次。

  #emph[不變式。]外接矩形的每一點都位於某格的閉正方形內，該格要不在佇列中，要不在被捨棄當時滿足 $f(c) + h sqrt(2) <= b + epsilon$。初始正方形從左下角起以短邊為步長鋪設，直到越過遠端邊緣，覆蓋了外接矩形；捨棄依捨棄規則保持不變式；分割把一個正方形換成覆蓋它的四個正方形。

  #emph[結論。]結束時佇列為空。設 $p^*$ 為極點；它位於 $overline(P)$ 中、外接矩形內，落在某個被捨棄、中心為 $c$、半邊長為 $h$ 的格子內。由#ref(<lem-lipschitz>)與 $|p^* - c| <= h sqrt(2)$，
  $ f^* = f(p^*) <= f(c) + h sqrt(2) <= b + epsilon <= f(q) + epsilon, $
  其中 $q$ 為回傳的點，$f(q)$ 為最終的 $b$。若 $f^* > epsilon$，則 $f(q) > 0$，故 $q$ 位於 $overline(P)$ 內且與 $partial P$ 距離為正，即 $q in "int" P$。
]

#proof(of: <prop-brace>)[
  記半徑為 $r$，拉伸倍率為 $sigma = delta slash 2r >= 1$。拉伸之前，曲線由以下部分組成：圓心 $(0, ell + r)$、從 $-90 degree$ 到 $0 degree$ 的圓弧 $A_1$；從 $v = ell + r$ 到 $v = m - r$ 的線段 $u = r$；圓心 $(2 r, m - r)$、從 $180 degree$ 到 $90 degree$ 的圓弧 $A_2$；圓心 $(2 r, m + r)$、從 $270 degree$ 到 $180 degree$ 的圓弧 $A_3$；從 $m + r$ 到 $h - r$ 的線段 $u = r$；以及圓心 $(0, h - r)$、從 $0 degree$ 到 $90 degree$ 的圓弧 $A_4$。（當 $r = (h - ell) slash 4$ 時兩線段長度為零。）曲線起於 $(0, ell)$、終於 $(0, h)$，$A_2$ 與 $A_3$ 交於 $(2 r, m)$，拉伸 $(u, v) |-> (sigma u, v)$ 把它送到 $(delta, m)$。

  (i) 在 $A_1$ 與 $A_4$ 上 $u in [0, r]$；在兩線段上 $u = r$；在 $A_2$ 與 $A_3$ 上 $u in [r, 2 r]$。拉伸後 $u in [0, delta]$。

  (ii) 反射 $v |-> ell + h - v$ 交換 $A_1$ 與 $A_4$、$A_2$ 與 $A_3$ 的圓心，並把角度 $theta$ 變為 $-theta$，因此把 $A_1$ 映到 $A_4$、$A_2$ 映到 $A_3$，兩線段互換。

  (iii) 沿角度遞增方向走圓弧時，運動方向為 $(-sin theta, cos theta)$；沿遞減方向時為 $(sin theta, -cos theta)$。在 $A_1$ 終點（$theta = 0$）與 $A_2$ 起點（$theta = 180 degree$）兩者都是 $(0, 1)$，即兩者間線段的方向；$A_3$ 終點與 $A_4$ 起點亦同。在尖端，$A_2$ 以方向 $(1, 0)$ 抵達（$theta = 90 degree$），$A_3$ 以 $(-1, 0)$ 離開（$theta = 270 degree$）：形成尖點。拉伸與最後的擺放都是可逆仿射映射，會帶著切線方向且保持其非零，因此連續性與尖點都得以保留。
]

== 標籤

#proof(of: <lem-crossing>)[
  共同點滿足 $a + t r = c + u s$，其中 $r = b - a$、$s = d - c$。兩邊與 $s$ 作外積可消去 $u$：$t (r times s) = (c - a) times s$。真正交叉使 $a$、$b$ 嚴格位於 $L_(c d)$ 兩側，因此兩直線不平行，$r times s != 0$，交點唯一。由於 $"orient"(c, d, dot)$ 沿 $[a, b]$ 為仿射函數且兩端異號，其零點位於某個 $t in (0, 1)$。
]

#proof(of: <prop-callout>)[
  程式保留一個最佳候選，只在遇到鍵值嚴格較小的候選時才替換，因此在列舉的任何前段之後，它保存的是目前為止鍵值最小的第一個候選。近環結束後，若最小代價為 $0$，最小鍵值為 $(0, ell_min)$，搜尋停止：結果是引線最短的第一個零代價候選。否則以同一個最佳候選繼續列舉遠環，結果是兩環中鍵值最小的第一個候選。每個步驟都是引數（極點、離開距離、開闊區域、交叉點）的函數，沒有隨機性，列舉順序固定。
]

== 樣式、主題與綁定

#proof(of: <prop-monoid>)[
  逐欄來看，合併是運算：$x != "None"$ 時 $x circle.small y = x$，否則為 $y$。$(x circle.small y) circle.small z$ 與 $x circle.small (y circle.small z)$ 都等於 $x, y, z$ 中第一個不是 `None` 的值（或 `None`），`None` 是雙邊單位元，且 $x circle.small x = x$。樣式在各欄相等時相等，由此得 (i)–(iii)，再由歸納法得到第一個非 `None` 值的描述。樣式組逐槽同理，`None` 槽的行為如同空樣式。
]

#proof(of: <prop-hex>)[
  一對十六進位數字 $k in {0, dots, 255}$ 讀為 $k slash 255$，寫出時取 $"round"(255 dot k slash 255)$ 的兩位大寫數字。在倍精度下，計算出的乘積與 $k$ 相差至多 $255 dot 2^(-52) < 1 slash 2$，因此捨入為 $k$。`include_alpha` 為真，即九個字元的形式時，才寫出 alpha 那一對。三位數形式在讀取前先把每位數字重複一次。
]

#proof(of: <thm-resolution>)[
  以 $triangle.r$ 表示合併。解析從 $D$ 開始，依 $T$、$G$、$C$ 的順序，對每個對應依序把 $M[k_n], dots, M[k_1]$（由最一般到最具體）合併到結果之上，不存在的鍵給出空樣式組；最後合併圖層自帶的樣式組 $E$，它由 `style_slots` 指名的欄位構成。展開並以結合律（參見#ref(<prop-monoid>)）去掉括號，解析後的樣式組為
  $ E triangle.r C[k_1] triangle.r dots.c triangle.r C[k_n] triangle.r
    G[k_1] triangle.r dots.c triangle.r T[k_n] triangle.r D, $
  其各欄位為依此順序第一個不是 `None` 的值。之後綁定色盤只把顏色名稱換成顏色，不影響其他欄位。
]

#proof(of: <cor-override>)[
  角色為 `axes.note` 的文字圖層，其鏈為（`axes.note`, `axes`, `text`），在#ref(<thm-resolution>)的序列中 $G["text"]$ 位於 $T["axes.note"]$ 之前。依假設，更早的項目都沒有設定大小，因此第一個非 `None` 的大小來自 $G["text"]$。
]

#proof(of: <thm-binding>)[
  對 $e$ 作歸納。若 $"free"(e) subset.eq "dom" beta$（特別是常數，以及屬於 $"dom" beta$ 的參數），$"bind"(e, beta)$ 是一般值 $e(beta)$：它沒有自由參數，符合 (i)，且求值為 $e(beta) = e(beta union gamma)$，因為運算式的值只取決於其自由參數的值。若 $e$ 是參數 $p in.not "dom" beta$，結果為 $p$，$"free" = {p} = "free"(e) without "dom" beta$，值為 $gamma(p) = (beta union gamma)(p)$。否則 $e = e_1 circle.small e_2$，結果為 $"bind"(e_1, beta) circle.small "bind"(e_2, beta)$（一般值包裝為常數）。其自由參數為 $("free"(e_1) without "dom" beta) union ("free"(e_2) without "dom" beta) = "free"(e) without "dom" beta$，而 $gamma$ 綁定了兩部分各自的自由參數，由歸納假設其值為 $e_1(beta union gamma) circle.small e_2(beta union gamma) = e(beta union gamma)$。
]

#proof(of: <cor-stages>)[
  兩次應用#ref(<thm-binding>) (i)，兩者的自由參數都是 $"free"(e) without "dom" (beta_1 union beta_2)$。對這些參數的綁定 $gamma$（與 $beta_1$、$beta_2$ 不相交），兩次應用 (ii) 得 $"bind"("bind"(e, beta_1), beta_2)(gamma) = "bind"(e, beta_1)(beta_2 union gamma) = e(beta_1 union beta_2 union gamma) = "bind"(e, beta_1 union beta_2)(gamma)$。畫布以這種方式綁定其場景中的每個運算式。
]

#proof(of: <prop-grid-shape>)[
  由 $r = ceil(n slash c)$ 得 $r c >= n > (r - 1) c$，因此前 $r - 1$ 列是滿的，最後一列有 $n - (r - 1) c in [1, c]$ 格，空格數 $r c - n < c$。由 $c = ceil(sqrt(n))$ 得 $n <= c^2$，所以 $n slash c <= c$，$r <= c$。
]

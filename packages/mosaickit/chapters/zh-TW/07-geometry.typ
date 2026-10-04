#import "/template/manual.typ": *

= 配置幾何 <sec-geometry>

#changed("0.2.0", label: "mosaickit.layout")[新增：標籤配置背後的純幾何模組]

標籤配置在其他內容都畫完後執行，使用顯示座標：以像素為單位，$y$ 向上遞增。`mosaickit.layout` 套件收錄配置所用的幾何；它不匯入任何繪製器，因此可以單獨測試與重複使用。本章的函式位於 `mosaickit.layout.geometry`；`Rect` 與 `polylabel` 也由 `mosaickit.layout` 匯出。點是數對 `(x, y)`，線段是一對點，多邊形是一串點，最後一點與第一點相連。

== 矩形

#api(("Rect",), syntax: [#raw("Rect(x0, y0, x1, y1)")])[
  閉合的軸對齊矩形 $[x_0, x_1] times [y_0, y_1]$。`Rect.centered(center, width, height)` 以某點為中心建立矩形。它提供 `width`、`height`、`center`、`inflate(pad)`、`corners()`（從 $(x_0, y_0)$ 起逆時針）、`edges()`、`contains(point)`（含邊）、`within(other)`、`intersects(other)`（相切也算）與 `nearest_point(point)`。
]

#lemma(name: [矩形上的最近點])[
  對矩形 $R$ 與點 $p$，`nearest_point` 回傳的點 $q = (min(max(p_x, x_0), x_1), min(max(p_y, y_0), y_1))$ 是 $R$ 上離 $p$ 最近的唯一點。
] <lem-nearest>

引線標註的引線終止於這一點，因此在標籤位置給定下，引線已是最短。

== 方向與線段

#definition(name: [方向])[
  對平面上的點 $a, b, c$，
  $ "orient"(a, b, c) = (b_x - a_x)(c_y - a_y) - (b_y - a_y)(c_x - a_x), $
  即 $b - a$ 與 $c - a$ 的外積。
] <def-orient>

#lemma(name: [方向測試])[
  當 $c$ 位於從 $a$ 指向 $b$ 的有向直線左側（$a -> b -> c$ 為逆時針轉向）時，$"orient"(a, b, c)$ 為正；位於右側時為負；$a$、$b$、$c$ 共線時為零。它在循環置換下不變，交換兩個引數時變號。
] <lem-orient>

#api(("segments_intersect",), syntax: [#raw("segments_intersect(a, b, c, d) -> bool")])[
  閉線段 $[a, b]$ 與 $[c, d]$ 是否有共同點。令 $d_1 = "orient"(c, d, a)$、$d_2 = "orient"(c, d, b)$、$d_3 = "orient"(a, b, c)$、$d_4 = "orient"(a, b, d)$；當 $d_1 d_2 < 0$ 且 $d_3 d_4 < 0$，或某個 $d_i$ 為零且其對應點落在另一線段的外接矩形內時，回答是 #citep(<cormen2009>)。
]

#theorem(name: [線段相交])[
  在精確算術下，`segments_intersect(a, b, c, d)` 為真若且唯若 $[a, b] inter [c, d] != emptyset$。
] <thm-segments>

#api(("rect_hits_segment",), syntax: [#raw("rect_hits_segment(rect, a, b) -> bool")])[
  線段是否碰到矩形：有端點在矩形內，或線段與矩形四邊之一相交。
]

#lemma(name: [線段與矩形])[
  `rect_hits_segment(R, a, b)` 為真若且唯若 $[a, b] inter R != emptyset$。
] <lem-rect-segment>

== 多邊形

#definition(name: [簡單多邊形])[
  若多邊形 $P = (p_0, dots, p_(m-1))$（$m >= 3$）的邊 $[p_i, p_(i+1)]$（指標取模 $m$）只在相鄰邊的共同端點相交，且頂點不全共線，則稱 $P$ 為#emph[簡單多邊形]。其邊界 $partial P$ 是各邊的聯集；由 Jordan 曲線定理，$partial P$ 的補集恰有一個有界連通分量，即#emph[內部] $"int" P$，以及一個無界分量，即#emph[外部]。記 $overline(P) = "int" P union partial P$。
] <def-polygon>

#api(("polygon_edges", "distance_to_boundary"), syntax: [
  #raw("polygon_edges(polygon) -> tuple[Segment, ...]") \
  #raw("distance_to_boundary(point, polygon) -> float")
])[
  多邊形的各邊（含最後一點到第一點），以及點到最近邊的歐氏距離。每條邊的距離把點投影到邊所在直線，再把參數限制在 $[0, 1]$。
]

#lemma(name: [到線段的距離])[
  設 $a != b$，令 $t^* = "clamp"((p - a) dot (b - a) slash |b - a|^2, 0, 1)$。則 $a + t^* (b - a)$ 是 $[a, b]$ 上離 $p$ 最近的點。
] <lem-segment-distance>

#api(("point_in_polygon",), syntax: [#raw("point_in_polygon(point, polygon) -> bool")])[
  奇偶規則：從該點向右作水平射線，計算它穿過的邊數。當一條邊恰有一個端點嚴格位於射線所在直線上方，且交點在該點右側時，該邊計入 #citep(<haines1994>)。
]

#proposition(name: [奇偶規則])[
  設 $P$ 為簡單多邊形且 $p in.not partial P$。則 `point_in_polygon(p, P)` 為真若且唯若 $p in "int" P$。
] <prop-even-odd>

#api(("rect_inside_polygon", "rect_overlaps_polygon"), syntax: [
  #raw("rect_inside_polygon(rect, polygon) -> bool") \
  #raw("rect_overlaps_polygon(rect, polygon) -> bool")
])[
  在內部：四個角都通過奇偶測試，且多邊形沒有任何邊碰到矩形。重疊：有一個角通過測試，或有一條邊碰到矩形（這也涵蓋多邊形整個位於矩形內的情形）。
]

#theorem(name: [多邊形內的矩形])[
  設 $P$ 為簡單多邊形、$R$ 為矩形。則 `rect_inside_polygon(R, P)` 為真若且唯若 $R subset "int" P$。
] <thm-rect-inside>

#corollary(name: [與多邊形重疊的矩形])[
  設 $P$ 為簡單多邊形、$R$ 為矩形。則 `rect_overlaps_polygon(R, P)` 為真若且唯若 $R inter overline(P) != emptyset$。
] <cor-rect-overlap>

#api(("ray_exit",), syntax: [#raw("ray_exit(origin, direction, polygon) -> float")])[
  射線 $o + t r$ 與不平行於它的邊相交處的最大 $t >= 0$；沒有這樣的邊時為 $0$。引線標註以它作為搜尋起點，也就是射線離開區域之處。
]

#proposition(name: [永久離開多邊形])[
  設 $P$ 為簡單多邊形、$r != 0$，且 $T = $ `ray_exit(o, r, P)`。則對每個 $t > T$，$o + t r in.not overline(P)$。
] <prop-ray-exit>

== 區域的視覺中心

區域的形心可能落在區域外（參見#ref(<fig-polylabel>)）。標籤應放在最深處，也就是離邊界最遠的點。

#definition(name: [有號距離與不可及極點])[
  對簡單多邊形 $P$，#emph[有號距離]定義為：當 $p in overline(P)$ 時 $f(p) = d(p, partial P)$，否則 $f(p) = -d(p, partial P)$。$P$ 的#emph[不可及極點]是 $f$ 取得最大值 $f^*$ 之處；$f^*$ 即 $P$ 內最大圓盤的半徑。
] <def-pole>

#lemma(name: [有號距離為 1-Lipschitz])[
  對所有點 $p, q$，$|f(p) - f(q)| <= |p - q|$。
] <lem-lipschitz>

#api(("polylabel",), syntax: [#raw("polylabel(polygon, precision=1.0) -> Point")])[
  在正方形格子上的最佳優先搜尋 #citep(<agafonkin2016>)。外接矩形先以邊長等於其短邊的正方形覆蓋。中心為 $c$、半邊長為 $h$ 的格子得到上界 $f(c) + h sqrt(2)$，放入優先佇列，上界最大者先取出。程序記住目前最佳的中心，起始值為外接矩形的中心；取出的格子若上界比最佳值多出 `precision` 以上，就分成四格，否則捨棄。外接矩形寬或高為零的多邊形回傳其第一個頂點。
]

#theorem(name: [不可及極點])[
  設 $P$ 為簡單多邊形，外接矩形的寬與高皆為正，並設精度 $epsilon > 0$。則 `polylabel` 必定結束，且回傳的點 $q$ 滿足 $f(q) >= f^* - epsilon$。特別地，當 $f^* > epsilon$ 時，$q$ 位於 $"int" P$。
] <thm-polylabel>

#fig("/figures/geometry/polylabel.pdf", width: auto, caption: [
  極點、最大圓盤與形心。
]) <fig-polylabel>

三角形的極點就是內心。配置時以預設精度一像素呼叫 `polylabel`，比任何文字的擺放精度都細。

== 大括號外形

#api(("brace_outline", "Brace"), added: "0.3.0", syntax: [
  #raw("brace_outline(start, end, *, base, depth, direction, axis=\"y\", samples=12)")
])[
  覆蓋 `start`..`end` 的大括號，以 `Brace(points, tip)` 表示。兩端位於直線 `base`（固定的橫向座標），尖端位於跨距中點，在 `direction`（$plus.minus 1$）一側距 `base` 為 `depth`。軸為 `"y"` 時各點為（橫向, 縱向）；為 `"x"` 時為（縱向, 橫向）。每段四分之一圓弧以 `samples` 段取樣。空跨距、非正的深度，或其他方向與軸，引發 `ValueError`。
]

外形先在局部座標中建構，$u$ 為橫向、$v$ 為沿軸方向：四段半徑 $r = min("depth"/2, ("end" - "start")/4)$ 的四分之一圓，以兩段直線相連，再沿橫向拉伸 $"depth" slash 2r$ 倍。因此短跨距的圓弧較小，但尖端仍達到完整深度（參見#ref(<fig-brace>)）。

#proposition(name: [大括號的形狀])[
  設 $ell < h$ 為跨距兩端、$m = (ell + h) slash 2$ 為中點、$delta$ 為深度。在局部座標中、取樣之前，外形是從 $(0, ell)$ 經尖端 $(delta, m)$ 到 $(0, h)$ 的曲線，且
  (i) 位於帶狀區 $0 <= u <= delta$ 內；(ii) 在 $v |-> ell + h - v$ 下對稱；(iii) 除尖端外處處切線連續，尖端處曲線折返（尖點）。
] <prop-brace>

#fig("/figures/geometry/brace.pdf", width: auto, caption: [
  大括號外形；右側跨距小於 $2 delta$。
]) <fig-brace>

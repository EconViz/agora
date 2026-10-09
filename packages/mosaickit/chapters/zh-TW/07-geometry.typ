#import "/template/manual.typ": *

= 配置幾何 <sec-geometry>

#changed("0.2.0", label: "mosaickit.layout")[新增：標籤配置背後的純幾何模組]

標籤會等其他內容全都畫完後再配置，並採用以像素為單位、$y$ 向上遞增的顯示座標。`mosaickit.layout` 套件收錄配置所需的幾何功能；它不匯入任何繪製器，因此可單獨測試及重複使用。本章的函式位於 `mosaickit.layout.geometry`；`Rect` 與 `polylabel` 也會從 `mosaickit.layout` 匯出。點是數對 `(x, y)`，線段由一對點組成，多邊形則是一串首尾相連的點。

== 矩形

#api(("Rect",), syntax: [#raw("Rect(x0, y0, x1, y1)")])[
  閉合的軸對齊矩形 $[x_0, x_1] times [y_0, y_1]$。`Rect.centered(center, width, height)` 以指定點為中心建立矩形。它提供 `width`、`height`、`center`、`inflate(pad)`、`corners()`（從 $(x_0, y_0)$ 開始逆時針排列）、`edges()`、`contains(point)`（包含邊界）、`within(other)`、`intersects(other)`（相切也算）與 `nearest_point(point)`。
]

#lemma(name: [矩形上的最近點])[
  對矩形 $R$ 與點 $p$，`nearest_point` 回傳的點
  $ q = (min(max(p_x, x_0), x_1), min(max(p_y, y_0), y_1)) $
  是 $R$ 上離 $p$ 最近的唯一點。
] <lem-nearest>

引線標註的引線會終止於這一點，因此標籤位置一旦確定，引線便是最短的。

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
  判斷閉線段 $[a, b]$ 與 $[c, d]$ 是否有共同點。令 $d_1 = "orient"(c, d, a)$、$d_2 = "orient"(c, d, b)$、$d_3 = "orient"(a, b, c)$、$d_4 = "orient"(a, b, d)$；若 $d_1 d_2 < 0$ 且 $d_3 d_4 < 0$，或某個 $d_i$ 為零且其對應點落在另一線段的外接矩形（包住該線段的最小軸對齊矩形）內，便判定兩者相交 #citep(<cormen2009>)。
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
  若多邊形 $P = (p_0, dots, p_(m-1))$（$m >= 3$）的各邊 $[p_i, p_(i+1)]$（指標取模 $m$）只會在相鄰邊的共同端點相交，且所有頂點不全共線，便稱 $P$ 為#emph[簡單多邊形]。其邊界 $partial P$ 是所有邊的聯集。依 Jordan 曲線定理，$partial P$ 的補集恰有一個有界連通分量，也就是#emph[內部] $"int" P$，以及一個無界分量，也就是#emph[外部]。記 $overline(P) = "int" P union partial P$。
] <def-polygon>

#api(("polygon_edges", "distance_to_boundary"), syntax: [
  #raw("polygon_edges(polygon) -> tuple[Segment, ...]") \
  #raw("distance_to_boundary(point, polygon) -> float")
])[
  前者回傳多邊形的所有邊（包括最後一點到第一點），後者計算指定點到最近邊的歐氏距離。計算每條邊的距離時，會先將點投影到該邊所在的直線，再把參數限制在 $[0, 1]$。
]

#lemma(name: [到線段的距離])[
  設 $a != b$，令
  $ t^* = "clamp"((p - a) dot (b - a) slash |b - a|^2, 0, 1) $
  則 $a + t^* (b - a)$ 是 $[a, b]$ 上離 $p$ 最近的點。
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
  判定在內部時，四個角都必須通過奇偶測試，而且多邊形的任何一條邊都不能碰到矩形。判定重疊時，只要有一個角通過測試，或有一條邊碰到矩形即可（這也涵蓋多邊形完全位於矩形內的情形）。
]

#theorem(name: [多邊形內的矩形])[
  設 $P$ 為簡單多邊形、$R$ 為矩形。則 `rect_inside_polygon(R, P)` 為真若且唯若 $R subset "int" P$。
] <thm-rect-inside>

#corollary(name: [與多邊形重疊的矩形])[
  設 $P$ 為簡單多邊形、$R$ 為矩形。則 `rect_overlaps_polygon(R, P)` 為真若且唯若 $R inter overline(P) != emptyset$。
] <cor-rect-overlap>

#api(("ray_exit",), syntax: [#raw("ray_exit(origin, direction, polygon) -> float")])[
  回傳射線 $o + t r$ 與不平行於它的邊相交時，所有 $t >= 0$ 中的最大值；若沒有這樣的邊，則回傳 $0$。引線標註會將這個位置，也就是射線離開區域之處，當成搜尋起點。
]

#proposition(name: [永久離開多邊形])[
  設 $P$ 為簡單多邊形、$r != 0$，且 $T = $ `ray_exit(o, r, P)`。則對每個 $t > T$，$o + t r in.not overline(P)$。
] <prop-ray-exit>

== 區域的視覺中心

區域的形心，也就是將區域視為均勻薄片時的質心，可能落在區域外（參見#ref(<fig-polylabel>)）。標籤應放在區域最深處，也就是離邊界最遠的點。

#definition(name: [有號距離與不可及極點])[
  對簡單多邊形 $P$，#emph[有號距離]定義為：當 $p in overline(P)$ 時 $f(p) = d(p, partial P)$，否則 $f(p) = -d(p, partial P)$。$P$ 的#emph[不可及極點]是 $f$ 取得最大值 $f^*$ 之處；$f^*$ 即 $P$ 內最大圓盤的半徑。
] <def-pole>

#lemma(name: [有號距離為 1-Lipschitz])[
  對所有點 $p, q$，$|f(p) - f(q)| <= |p - q|$。
] <lem-lipschitz>

#api(("polylabel",), syntax: [#raw("polylabel(polygon, precision=1.0) -> Point")])[
  在正方形格子上執行最佳優先搜尋 #citep(<agafonkin2016>)。首先用邊長等於外接矩形短邊的正方形覆蓋該矩形。中心為 $c$、半邊長為 $h$ 的格子，其上界為 $f(c) + h sqrt(2)$；格子會放入優先佇列，並優先取出上界最大者。程序會記錄目前最佳的中心，初始值為外接矩形的中心。若取出格子的上界比目前最佳值高出 `precision` 以上，便將它分成四格，否則捨棄。若多邊形的外接矩形寬或高為零，則回傳其第一個頂點。
]

#theorem(name: [不可及極點])[
  設 $P$ 為簡單多邊形，外接矩形的寬與高皆為正，並設精度 $epsilon > 0$。則 `polylabel` 必定結束，且回傳的點 $q$ 滿足 $f(q) >= f^* - epsilon$。特別地，當 $f^* > epsilon$ 時，$q$ 位於 $"int" P$。
] <thm-polylabel>

#fig("/figures/geometry/polylabel.pdf", width: auto, caption: [
  極點、最大圓盤與形心。
]) <fig-polylabel>

三角形的極點就是內心，也就是三條角平分線的交點。配置時會以預設的一像素精度呼叫 `polylabel`，這比任何文字的擺放精度都更細。

== 大括號外形

#api(("brace_outline", "Brace"), added: "0.3.0", syntax: [
  #raw("brace_outline(start, end, *, base, depth, direction, axis=\"y\", samples=12)")
])[
  建立覆蓋 `start`..`end` 的大括號，以 `Brace(points, tip)` 表示。兩端位於直線 `base`（固定的橫向座標），尖端位於跨距中點，並在 `direction`（$plus.minus 1$）一側距 `base` 為 `depth`。軸為 `"y"` 時，各點表示為（橫向, 縱向）；軸為 `"x"` 時，則表示為（縱向, 橫向）。每段四分之一圓弧會以 `samples` 段取樣。若跨距為空、深度不是正數，或方向與軸使用其他值，便會引發 `ValueError`。
]

外形會先在局部座標中建構，其中 $u$ 是橫向，$v$ 是沿軸方向。四段半徑為 $r = min("depth"/2, ("end" - "start")/4)$ 的四分之一圓弧以兩段直線相連，再沿橫向拉伸 $"depth" slash 2r$ 倍。因此，跨距較短時圓弧也會較小，但尖端仍能達到完整深度（參見#ref(<fig-brace>)）。

#proposition(name: [大括號的形狀])[
  設 $ell < h$ 為跨距兩端、$m = (ell + h) slash 2$ 為中點、$delta$ 為深度。在局部座標中、取樣之前，外形是從 $(0, ell)$ 經尖端 $(delta, m)$ 到 $(0, h)$ 的曲線，且
  (i) 位於帶狀區 $0 <= u <= delta$ 內；(ii) 在 $v |-> ell + h - v$ 下對稱；(iii) 除尖端外處處切線連續，尖端處曲線折返（尖點）。
] <prop-brace>

#fig("/figures/geometry/brace.pdf", width: auto, caption: [
  大括號外形；右側跨距小於 $2 delta$。
]) <fig-brace>

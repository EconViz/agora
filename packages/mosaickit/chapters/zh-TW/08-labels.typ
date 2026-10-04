#import "/template/manual.typ": *

= 區域標籤與點標籤 <sec-labels>

標籤為已畫出的東西命名：填色區域或點。標籤圖層在延後處理階段繪製，晚於所有其他圖層，因此能看到必須避開的東西。點標籤先於區域標籤配置，每個配置好的標籤都成為後續標籤的障礙物。

#changed("0.3.0", label: "mosaickit")[點標籤先於區域標籤配置，區域的引線標註因此會避開它們；標籤文字依旋轉角度量測]

== 區域標籤

#api(("RegionLabelLayer",), added: "0.2.0", syntax: [
  #raw("RegionLabelLayer(region, text, short_text=None, placement=\"auto\", style=None,") \
  #raw("                 stroke=Stroke(width=0.8), *, role=\"text\", ...)")
])[
  為填色區域命名；區域以 `FillLayer` 的 id 或至少三點的多邊形給出。`stroke` 設定引線標註的引線樣式。
]

#param("placement=\"auto\"")[文字放得下時置於區域內、以極點為中心（參見#ref(<def-pole>)），其次嘗試 `short_text`；都放不下時以 `text` 作引線標註。]
#param("placement=\"inside\"")[與 `"auto"` 相同，但兩段文字都放不下時，仍把 `short_text`（或 `text`）置中於極點。]
#param("placement=\"callout\"")[一律作引線標註：區域外不加框的文字，以及從極點拉到文字的細引線。]

文字放得下是指：每邊加 2 pt 留白、置中於極點的文字矩形位於區域內（參見#ref(<thm-rect-inside>)），且不碰到任何線、標記、文字或其他區域。#ref(<fig-regions>)同時呈現兩種結果。

#fig("/figures/labels/regions.pdf", width: auto, caption: [
  區域內標籤與引線標註。
]) <fig-regions>

== 點標籤

#api(("PointLabelLayer",), added: "0.3.0", syntax: [#raw("PointLabelLayer(point, text, style=None, *, role=\"text\", ...)")])[
  在點的正旁邊寫上文字為它命名，不使用引線。點的#emph[足跡]是該處畫有標記時的標記，否則是點本身。
  #changed("0.3.1")[點標籤可以位於包含其點的填色區域內]
  #changed("0.3.2")[只有點嚴格位於區域內部時，該區域才算是點自己的區域；位於區域邊上的點，標籤仍放在區域外]
]

標籤在足跡周圍嘗試 16 個方向，距足跡邊緣 4、7、11、16 pt，由近而遠。同一距離內依#ref(<def-candidate-order>)的順序嘗試方向（參見#ref(<fig-candidates>)），第一個不遮蓋任何東西的位置勝出；若都不行，選違規數最少者（相同時取較早者），並發出指名該圖層的 `LayoutWarning`。點嚴格位於其內部（距邊緣超過 1.5 px）的區域是標籤應在之處，不算障礙物。

#definition(name: [候選順序])[
  將方向自 $+x$ 起逆時針編號為 $k = 0, dots, 15$，角度為 $2 pi k slash 16$。點標籤依鍵值 $(min(s, 16 - s), [s > 8])$（$s = (k - 2) mod 16$）遞增的順序嘗試：依與右上方向 $k = 2$ 的角距離，角距離相同的兩個方向則逆時針者優先。
] <def-candidate-order>

#fig("/figures/geometry/candidates.pdf", width: auto, caption: [
  方向的嘗試順序。
]) <fig-candidates>

#fig("/figures/labels/points.pdf", width: auto, caption: [
  點旁的點標籤。
]) <fig-points>

== 硬性限制

兩種標籤遵守同一條規則：不遮蓋任何東西。障礙物從座標軸上已畫的內容收集：路徑的線段、標記與文字的矩形，以及填色區域的多邊形。以下的搜尋位於 `mosaickit.layout.placement`，除 `place_beside` 外也由 `mosaickit.layout` 匯出；它們與幾何模組一樣以顯示像素運算，`scale` 把以點為單位的間距換算為像素。

#api(("Obstacles", "Placement"), syntax: [
  #raw("Obstacles(segments=(), rects=(), polygons=())") \
  #raw("Placement(rect, leader, violations)")
])[
  標籤必須避開的東西，以及標籤的去處：其矩形、引線線段（不畫引線的標籤為 `None`），以及違反的限制數。`Obstacles.extended(segments=..., rects=...)` 加入剛配置的標籤。
  #changed("0.3.0")[`Placement.leader` 可以是 `None`]
]

#definition(name: [違規數])[
  對候選矩形 $R$、障礙物 $O$、繪圖區界線 $B$ 與多邊形集合 $cal(P)$，#emph[違規數]為
  $ V(R) = [R subset.eq.not B] + \#{s in O_"seg" : R inter s != emptyset}
    + \#{Q in O_"rect" : R inter Q != emptyset}
    + \#{P in cal(P) : R inter overline(P) != emptyset}, $
  其中 $[dot]$ 在條件成立時為 1，否則為 0。$V(R) = 0$ 時稱候選位置#emph[不遮蓋任何東西]。
] <def-violations>

各項分別由#ref(<lem-rect-segment>)、`Rect.intersects` 與#ref(<cor-rect-overlap>)精確計算。

== 引線標註

#api(("place_callout",), added: "0.2.0", syntax: [#raw("place_callout(polygon, size, obstacles, bounds, *, scale=1.0) -> Placement")])[
  在區域周圍為給定大小的引線標註搜尋位置。從極點 $o$ 沿 16 個方向 $r$，把候選矩形放在距離 `ray_exit(o, r, P)` 再加 12、24 或 40 pt（近環）之處，並以面向極點的邊或角對齊，使矩形朝遠離區域的方向延伸。引線從極點拉到矩形上的最近點（參見#ref(<lem-nearest>)），在 2 pt 前停止。候選位置的代價為 $V(R)$（區域本身也列入多邊形），中心不在開闊空間時加一，引線離開自身區域後每穿過一條線、一段文字或一個其他區域加一，每位於一個交叉點之外（參見#ref(<def-beyond>)）再加一。
]

#definition(name: [開闊空間與交叉點])[
  #emph[開闊空間]是在繪圖區 4 pt 網格上、面積至少占十分之一的連通空白區域的聯集；較小的空白區域稱為#emph[口袋]，例如兩個陰影區域間未填色的窄帶，文字放在那裡看起來像在為口袋命名。區域的#emph[交叉點]是兩條障礙線段真正交叉（各自嚴格穿過對方）之處，且位於區域邊界上或距邊界 1.5 px 以內。從極點 $o$ 看，若 $(p - x) dot (x - o) > 0$，則稱點 $p$ 位於 $x$ #emph[之外]。
] <def-beyond>

越過交叉點後，線條朝遠離區域的方向分開，放在那裡的標籤會貼著線條延伸之處，而不是它所命名的東西。交叉點本身由方向測試求得。

#lemma(name: [交叉點])[
  若 $[a, b]$ 與 $[c, d]$ 真正交叉，則它們恰交於一點 $a + t (b - a)$，其中
  $ t = ((c - a) times (d - c)) / ((b - a) times (d - c)) in (0, 1), $
  而 $u times v = u_x v_y - u_y v_x$。
] <lem-crossing>

#proposition(name: [引線標註的選擇])[
  以鍵值（代價, 引線長度）依字典序排列候選位置，並逐方向、由近到遠的距離列舉。若近環中有代價為 0 的候選，`place_callout` 回傳其中引線最短的第一個；否則再嘗試遠環（60 與 90 pt），回傳兩環中鍵值最小的第一個候選。結果只取決於引數。
] <prop-callout>

回傳的代價不為零時，繪製器仍畫在該處，並發出指名該圖層的 `LayoutWarning`；放大畫布或縮短文字通常就能消除。

#api(("fits_inside", "place_point_label", "place_beside"), syntax: [
  #raw("fits_inside(polygon, size, obstacles, bounds) -> Rect | None") \
  #raw("place_point_label(footprint, size, obstacles, bounds, *, scale=1.0) -> Placement") \
  #raw("place_beside(anchor, size, *, axis, direction, reach, obstacles, bounds, scale=1.0)")
])[
  其他搜尋：置中於極點的矩形，若放得下且除自身區域外不碰到任何東西就回傳它；前述的點標籤搜尋；以及大括號尖端旁的搜尋，在尖端外 3 到 45 pt 嘗試，並沿跨距以 3 pt 為步長最多滑動 `reach`，位移小者優先。`place_beside` 回傳矩形與其違規數。大括號標籤在該處沒有空位時，繪製器改從尖端嘗試引線標註，保留違規較少者。
  #changed("0.3.0")[新增 `place_point_label` 與 `place_beside`]
]

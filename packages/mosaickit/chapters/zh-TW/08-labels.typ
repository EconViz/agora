#import "/template/manual.typ": *

= 區域標籤與點標籤 <sec-labels>

標籤用來命名已繪製的填色區域或點。標籤圖層會在所有其他圖層之後，由延後處理程序繪製，因此能判斷必須避開哪些物件。點標籤先於區域標籤配置；每個已配置的標籤，都會成為後續標籤的障礙物。

#changed("0.3.0", label: "mosaickit")[點標籤先於區域標籤配置，區域的引線標註因此會避開它們；標籤文字依旋轉角度量測]

== 區域標籤

#api(("RegionLabelLayer",), added: "0.2.0", syntax: [
  #raw("RegionLabelLayer(region, text, short_text=None, placement=\"auto\", style=None,") \
  #raw("                 stroke=Stroke(width=0.8), *, role=\"text\", ...)")
])[
  為填色區域命名；區域可以是 `FillLayer` 的 id，也可以是至少由三點組成的多邊形。`stroke` 設定引線標註的引線樣式。
]

#param("placement=\"auto\"")[若文字放得下，就以極點為中心置於區域內（參見#ref(<def-pole>)）；若長文字放不下，再嘗試 `short_text`。兩者都放不下時，以 `text` 作引線標註。]
#param("placement=\"inside\"")[與 `"auto"` 相同，但兩段文字都放不下時，仍會把 `short_text`（或 `text`）置中於極點。]
#param("placement=\"callout\"")[一律作引線標註：區域外不加框的文字，以及從極點拉到文字的細引線。]

「文字放得下」是指：文字矩形置中於極點、每邊留白 2 pt 後，仍位於區域內（參見#ref(<thm-rect-inside>)），且不碰到任何線條、標記、文字或其他區域。#ref(<fig-regions>)同時呈現這兩種結果。

#fig("/figures/labels/regions.pdf", width: auto, caption: [
  區域內標籤與引線標註。
]) <fig-regions>

== 點標籤

#api(("PointLabelLayer",), added: "0.3.0", syntax: [#raw("PointLabelLayer(point, text, style=None, *, role=\"text\", ...)")])[
  在點的旁邊加上文字為它命名，不使用引線。點的#emph[足跡]是該處畫有標記時的標記，否則就是點本身。
  #changed("0.3.1")[點標籤可以位於包含其點的填色區域內]
  #changed("0.3.2")[只有點嚴格位於區域內部時，該區域才算是點自己的區域；位於區域邊上的點，標籤仍放在區域外]
]

標籤會在足跡周圍嘗試 16 個方向，依序與足跡邊緣間隔 4、7、11、16 pt，由近而遠。同一間隔內，依#ref(<def-candidate-order>)的順序嘗試各方向（參見#ref(<fig-candidates>)），採用第一個不遮蓋任何物件的位置。若沒有合適的位置，就選擇違規數最少者；違規數相同時，採用較早嘗試的位置，並發出指名該圖層的 `LayoutWarning`。若點嚴格位於某區域內（距邊緣超過 1.5 px），標籤應位於該區域內，因此不會將它視為障礙物。

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

兩種標籤都遵守同一條規則：不遮蓋任何物件。障礙物包括座標軸上已繪製的內容：路徑的線段、標記與文字的矩形，以及填色區域的多邊形。以下搜尋函式位於 `mosaickit.layout.placement`；除 `place_beside` 外，也都由 `mosaickit.layout` 匯出。它們與幾何模組一樣，以顯示像素為單位運算；`scale` 則將以點為單位的間距換算為像素。

#api(("Obstacles", "Placement"), syntax: [
  #raw("Obstacles(segments=(), rects=(), polygons=())") \
  #raw("Placement(rect, leader, violations)")
])[
  標籤必須避開的障礙物，以及標籤的配置結果：矩形、引線線段（不畫引線的標籤為 `None`），以及違反的限制數。`Obstacles.extended(segments=..., rects=...)` 會加入剛配置的標籤。
  #changed("0.3.0")[`Placement.leader` 可以是 `None`]
]

#definition(name: [違規數])[
  對候選矩形 $R$、障礙物 $O$、繪圖區界線 $B$ 與多邊形集合 $cal(P)$，#emph[違規數]為
  $ V(R) = [R subset.eq.not B] + \#{s in O_"seg" : R inter s != emptyset}
    + \#{Q in O_"rect" : R inter Q != emptyset}
    + \#{P in cal(P) : R inter overline(P) != emptyset}, $
  其中 $[dot]$ 在條件成立時為 1，否則為 0。$V(R) = 0$ 時，稱候選位置#emph[不遮蓋任何物件]。
] <def-violations>

各項分別由#ref(<lem-rect-segment>)、`Rect.intersects` 與#ref(<cor-rect-overlap>)精確計算。

== 引線標註

#api(("place_callout",), added: "0.2.0", syntax: [#raw("place_callout(polygon, size, obstacles, bounds, *, scale=1.0) -> Placement")])[
  在區域周圍搜尋能容納指定大小引線標註的位置。搜尋從極點 $o$ 沿 16 個方向 $r$ 進行：把候選矩形放在 `ray_exit(o, r, P)` 的距離之外，再間隔 12、24 或 40 pt（近環），並將面向極點的邊或角對齊，使矩形向遠離區域的方向延伸。引線從極點拉向矩形上的最近點（參見#ref(<lem-nearest>)），並在距該點 2 pt 處停止。候選位置的代價以 $V(R)$ 為基礎（區域本身也列入多邊形）：若中心不在開闊空間中，加一；引線離開自身區域後，每穿過一條線、一段文字或一個其他區域，加一；每位於一個交叉點之外（參見#ref(<def-beyond>)），再加一。
]

#definition(name: [開闊空間與交叉點])[
  #emph[開闊空間]是在繪圖區 4 pt 網格上、面積至少占十分之一的連通空白區域的聯集；較小的空白區域稱為#emph[口袋]，例如兩個陰影區域間未填色的窄帶，文字放在那裡看起來像在為口袋命名。區域的#emph[交叉點]是兩條障礙線段真正交叉（各自嚴格穿過對方）之處，且位於區域邊界上或距邊界 1.5 px 以內。從極點 $o$ 看，若 $(p - x) dot (x - o) > 0$，則稱點 $p$ 位於 $x$ #emph[之外]。
] <def-beyond>

越過交叉點後，線條會向遠離區域的方向分開。若把標籤放在那裡，看起來會貼近線條的延伸方向，而非所命名的區域。交叉點本身由方向測試求得。

#lemma(name: [交叉點])[
  若 $[a, b]$ 與 $[c, d]$ 真正交叉，則它們恰交於一點 $a + t (b - a)$，其中
  $ t = ((c - a) times (d - c)) / ((b - a) times (d - c)) in (0, 1), $
  而 $u times v = u_x v_y - u_y v_x$。
] <lem-crossing>

#proposition(name: [引線標註的選擇])[
  以鍵值（代價, 引線長度）依字典序排列候選位置，並逐方向、由近到遠的距離列舉。若近環中有代價為 0 的候選，`place_callout` 回傳其中引線最短的第一個；否則再嘗試遠環（60 與 90 pt），回傳兩環中鍵值最小的第一個候選。結果只取決於引數。
] <prop-callout>

回傳的代價不為零時，繪製器仍會在該處畫出引線標註，並發出指名該圖層的 `LayoutWarning`；放大畫布或縮短文字，通常就能消除警告。

#api(("fits_inside", "place_point_label", "place_beside"), syntax: [
  #raw("fits_inside(polygon, size, obstacles, bounds) -> Rect | None") \
  #raw("place_point_label(footprint, size, obstacles, bounds, *, scale=1.0) -> Placement") \
  #raw("place_beside(anchor, size, *, axis, direction, reach, obstacles, bounds, scale=1.0)")
])[
  其他搜尋包括：置中於極點的矩形，若放得下且除自身區域外不碰到任何物件，就回傳該矩形；前述的點標籤搜尋；以及大括號尖端旁的搜尋。最後一種搜尋會嘗試尖端外 3 到 45 pt 的間隔，並沿跨距以 3 pt 為步長滑動，最多滑動 `reach`，且位移較小者優先。`place_beside` 回傳矩形與其違規數。若該處沒有空間容納大括號標籤，繪製器會改從尖端嘗試引線標註，並保留違規較少的結果。
  #changed("0.3.0")[新增 `place_point_label` 與 `place_beside`]
]

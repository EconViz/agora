#import "/template/manual.typ": *

= 三次線段與路徑 <sec-paths>

繪圖端畫的是三次曲線：TikZ 的 `.. controls ..`、SVG 的 `C` 與 Matplotlib 的 `CURVE4` 都接收四個控制點。`CubicBezierSegment` 就是以數值物件表示的三次曲線，`PiecewiseBezier` 則把三次曲線連接成路徑。

== 三次線段

#api(("CubicBezierSegment",), syntax: [
  #raw("CubicBezierSegment(p0, p1, p2, p3, *, fit_error=None)")
])[
  不可變的三次曲線，四個控制點即欄位 `p0`、`p1`、`p2`、`p3`（亦可用 `control_points` 或逐一取出）。求值、微分、分割、截取與反轉的方式與 `BezierCurve` 相同，但 `split()`、`segment()` 與 `reversed()` 仍回傳三次線段。`segment(t, t)` 回傳四個控制點都是 $B(t)$ 的退化三次曲線。
]

#param("fit_error", type: "float | None", default: "None")[擬合線段的實測誤差（詳見#ref(<sec-fitting>)）；分割、截取與反轉後保留，判斷相等時忽略。]
#param("as_curve(), from_curve(curve)")[與 3 次 `BezierCurve` 互相轉換，不改變任何控制點。]
#param("from_line(p0, p3), from_quadratic(p0, c, p3)")[直線或二次曲線的精確三次表示（詳見#ref(<thm-elevation>)）。]

== 緊密邊界框

控制點凸包包含曲線（詳見#ref(<thm-hull>)），但可能比曲線大得多。`bounding_box` 回傳最小的軸對齊方框（參見#ref(<fig-bbox>)）。

#theorem(name: [邊界框])[
  將三次曲線寫成 $B(t) = a t^3 + b t^2 + c t + P_0$，其中 $a = -P_0 + 3P_1 - 3P_2 + P_3$、$b = 3P_0 - 6P_1 + 3P_2$、$c = 3(P_1 - P_0)$。在每個座標軸 $k$ 上，$B_k(t)$ 於 $[0, 1]$ 的最小值與最大值出現在 $t = 0$、$t = 1$，或 $3a_k t^2 + 2 b_k t + c_k$ 在 $(0, 1)$ 內的根。
] <thm-bbox>

#api(("CubicBezierSegment.bounding_box",))[
  回傳 `(low, high)` 兩點，分別為曲線在各軸的最小值與最大值，由#ref(<thm-bbox>)的候選參數求值而得。
]

#fig("/figures/paths/bbox.pdf", width: auto, caption: [
  三次曲線的緊密邊界框。
]) <fig-bbox>

== 升階

#theorem(name: [升階])[
  由 $P_0$ 到 $P_3$ 的直線，等於控制點為 $P_0$、$P_0 + 1/3 (P_3 - P_0)$、$P_0 + 2/3 (P_3 - P_0)$、$P_3$ 的三次曲線。控制點為 $P_0, C, P_3$ 的二次曲線，等於控制點為 $P_0$、$P_0 + 2/3 (C - P_0)$、$P_3 + 2/3 (C - P_3)$、$P_3$ 的三次曲線。兩者都是同一條曲線，參數化也相同。
] <thm-elevation>

#api(("to_cubic", "line_to_cubic", "quadratic_to_cubic"), syntax: [
  #raw("to_cubic(")#meta("curve")#raw(")")
])[
  位於 `bezierkit.bezier`。`to_cubic()` 依#ref(<thm-elevation>)將一次、二次或三次 `BezierCurve` 轉為 `CubicBezierSegment`（傳入線段時原樣回傳）；更高次數拋出 `DegreeError`。
]

```python
from bezierkit.bezier import to_cubic

q = BezierCurve.quadratic(Point(0, 0), Point(3, 6), Point(9, 0))
print(to_cubic(q).control_points)
# (Point(coords=(0.0, 0.0)), Point(coords=(2.0, 4.0)),
#  Point(coords=(5.0, 4.0)), Point(coords=(9.0, 0.0)))
```

== 分段路徑

#api(("PiecewiseBezier",), syntax: [
  #raw("PiecewiseBezier(")#meta("segments")#raw(", *, closed=False, continuity_tolerance=1e-9)") \
  #raw("PiecewiseBezier.compound(")#meta("paths")#raw(")")
])[
  由三次線段組成的路徑。相鄰線段必須相接：每段的 `p3` 與下一段的 `p0` 距離不得超過 `continuity_tolerance`，封閉路徑最後的 `p3` 與第一個 `p0` 亦然，否則拋出 `ValueError`。`closed` 是給匯出器的資訊（SVG 的 `Z`、TikZ 的 `cycle`），不會額外加入封閉線段。
]

由 $m$ 段 $S_0, dots, S_(m-1)$ 組成的路徑採均勻參數化：
$ P(t) = S_k (m t - k), quad k = min(floor(m t), m - 1), $
不論長短，每段都占 $[0, 1]$ 的 $1 slash m$。

#param("segments, control_points, subpaths")[依序排列的線段、其控制點，以及各 `BezierSubpath`。]
#param("at(t), at_many(values)")[依均勻參數化求值。]
#param("split(t), segment(t0, t1)")[分割路徑，或保留兩個參數之間的部分；參數落在某段內時會分割該段（詳見#ref(<thm-subdivision>)）。]
#param("reversed()")[反轉線段順序與每一段。]
#param("closed, is_compound, dimension")[封閉旗標、是否含多條子路徑，以及 $d$。]

#changed("1.0.0", label: "PiecewiseBezier.segment")[`t0` 落在線段內部時回傳正確的區間；先前會先在 `t0` 分割再對後半段重新參數化，導致終點錯誤]

```python
from bezierkit import CubicBezierSegment, PiecewiseBezier

path = PiecewiseBezier([
    CubicBezierSegment.from_line(Point(0, 0), Point(2, 0)),
    CubicBezierSegment.from_line(Point(2, 0), Point(2, 4)),
])
print(path.at(0.75))                     # Point(coords=(2.0, 2.0))
print(path.segment(0.25, 0.75).at(1.0))  # Point(coords=(2.0, 2.0))
```

`compound()` 把多條路徑合為一條，各子路徑保持分開，例如有洞的形狀。複合路徑沒有單一的參數化：求值、分割或截取會拋出 `ValueError`；反轉與匯出則可正常使用。分割或截取封閉路徑也會拋出例外（整條路徑或單點除外），因為封閉路徑沒有可保留的起點與終點。

== 連續性

#theorem(name: [三次曲線接點的連續性])[
  設控制點為 $P_0, dots, P_3$ 與 $Q_0, dots, Q_3$ 的三次曲線 $S$、$T$ 依序占據長度為 $h_S$、$h_T$ 的參數區間，且 $P_3 = Q_0$。接合後的曲線在接點為 $C^1$，若且唯若 $(P_3 - P_2) slash h_S = (Q_1 - Q_0) slash h_T$。在 `PiecewiseBezier` 的均勻參數化下 $h_S = h_T$，條件即為 $P_3 - P_2 = Q_1 - Q_0$。
] <thm-continuity>

`PiecewiseBezier` 只要求 $C^0$，也就是端點相接。接點是否也要平滑由呼叫端決定：無異曲線的折角或折線的轉角本來就該保留。

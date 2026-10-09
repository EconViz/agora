#import "/template/manual.typ": *

= 快速開始 <sec-quickstart>

== 一條三次曲線

本手冊通篇使用的曲線，是控制點為 $(0, 0)$、$(1, 2)$、$(3, 2)$、$(4, 0)$ 的三次曲線（參見#ref(<fig-quickstart>)）。

#example(```python
from bezierkit import BezierCurve, PiecewiseBezier, Point
from bezierkit.bezier import to_cubic
from bezierkit.export.tikz import to_tikz

curve = BezierCurve.cubic(Point(0, 0), Point(1, 2), Point(3, 2), Point(4, 0))
print(curve.at(0.5))                 # Point(coords=(2.0, 1.5))
print(curve.derivative().at(0.5))    # Point(coords=(4.5, 0.0))
left, right = curve.split(0.4)       # two cubics that together trace curve

path = PiecewiseBezier([to_cubic(curve)])
print(to_tikz(path, precision=2, options="thick"))
# \draw[thick] (0.00,0.00) .. controls (1.00,2.00) and (3.00,2.00) .. (4.00,0.00);
```)

#fig("/figures/curves/cubic.pdf", width: auto, caption: [
  三次曲線及其控制凸包。
]) <fig-quickstart>

曲線由 $P_0$ 出發、在 $P_3$ 結束，離開 $P_0$ 時朝向 $P_1$，抵達 $P_3$ 時來自 $P_2$ 的方向，且始終位於控制點的凸包內（詳見#ref(<cor-hull>)）。最後一行是這條曲線的 TikZ 路徑，可直接貼進 #LaTeX 文件。

== 主要元件

- *數值物件。*`Point`、`Vector` 與 `PointSet` 不可變，並檢查維度（詳見#ref(<sec-geometry>)）。
- *曲線。*`BezierCurve` 可為任意次數與維度；`CubicBezierSegment` 是繪圖端使用的三次曲線；`PiecewiseBezier` 將三次曲線連接成路徑（詳見#ref(<sec-curves>)、#ref(<sec-paths>)）。
- *建構。*把端點條件、斜率、導數或 Hermite 資料轉為控制點（詳見#ref(<sec-construction>)）。
- *近似。*把平滑函數、取樣點與等值線 $F(x, y) = c$ 轉為誤差已知的三次路徑（詳見#ref(<sec-fitting>)、#ref(<sec-implicit>)）。
- *輸出。*取樣、JSON、SVG 路徑資料、TikZ，以及 Matplotlib 路徑（詳見#ref(<sec-export>)）。

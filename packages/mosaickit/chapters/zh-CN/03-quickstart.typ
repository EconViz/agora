#import "/template/manual.typ": *

= 快速入门 <sec-quickstart>

一张图由画布、一组图层与一次保存构成：

#example(```python
from mosaickit import (
    Canvas, Fill, FillLayer, MarkerLayer, PathLayer, Stroke, TextLayer,
    quadrant_axes,
)

canvas = Canvas().extend(quadrant_axes(10, 10))
canvas.add(
    FillLayer(
        [(1, 1), (1, 7), (8, 1)],
        fill=Fill(color="#377EB8", opacity=0.12),
        z_index=-1,
    )
)
canvas.add(
    PathLayer(
        [(1, 8), (2, 5), (4, 3), (7, 1.5), (9, 1)],
        stroke=Stroke(color="#984EA3", width=2),
        id="curve",
    )
)
canvas.add(MarkerLayer([(4, 3)], id="point"))
canvas.add(TextLayer((4, 3), "A", offset=(6, 6)))
canvas.save("diagram.pdf")
```)

#fig("/figures/quickstart/diagram.pdf", width: auto, caption: [
  快速入门的图。
]) <fig-quickstart>

`quadrant_axes(10, 10)` 返回一般的图层：两条带箭头的路径与它们的标题。填色以 `z_index=-1` 置于最底层。路径是通过各点的折线；#pkg("mosaickit") 本身不画曲线，平滑曲线须以大量点传入，或由几何软件包构造后采样。文字自该点往右上偏移 6 pt。调用 `save()` 前不会画任何东西；`save()` 以画布的渲染器（未另行设置时为 Matplotlib）绘制场景、写出文件，并返回写出的路径。

同一个画布可以修改后再次保存：`add()`、`extend()`、`remove()` 与 `clear()` 都返回画布本身，因此可以串接，而先前获取的快照维持原状（详见#ref(<sec-canvas>)）。不可遮盖任何东西的标签也是图层：把 `TextLayer` 换成 `PointLabelLayer((4, 3), "A")`，渲染器就会自行选择摆放方向（详见#ref(<sec-labels>)）。

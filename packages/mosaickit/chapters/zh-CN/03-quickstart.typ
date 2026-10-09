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

`quadrant_axes(10, 10)` 返回一般图层：两条带箭头的路径及其标题。填色图层以 `z_index=-1` 放在最底层。路径是通过各点的折线；#pkg("mosaickit") 本身不直接绘制曲线。如果要呈现平滑曲线，必须传入大量采样点，或先用几何软件包构造曲线再采样。文字从该点向右上偏移 6 pt。调用 `save()` 之前不会进行任何绘制；`save()` 会用画布的渲染器（未另行设置时为 Matplotlib）绘制场景、写出文件，并返回输出路径。

同一个画布可在修改后再次保存：`add()`、`extend()`、`remove()` 与 `clear()` 都会返回画布本身，因此可以链式调用；先前获取的快照则维持原状（详见#ref(<sec-canvas>)）。能自动避让其他内容的标签也是图层：将 `TextLayer` 换成 `PointLabelLayer((4, 3), "A")`，渲染器就会自行选择放置方向（详见#ref(<sec-labels>)）。

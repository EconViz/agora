#import "/template/manual.typ": *

= 快速开始 <sec-quickstart>

#example(```python
from kinetickit import Animation, Bounds2D, Point2D, Scene2D, Vec2, ease

dot = Point2D(id="dot", position=Vec2(1, 1), size=8, color="#e4572e")
scene = Scene2D(dot)
scene = scene.bind(
    {scene.camera.ref("view"): Bounds2D(Vec2(0, 0), Vec2(10, 10))}
)

motion = dot.animate.position.to(
    Vec2(9, 9),
    duration=1.5,
    easing=ease.out_cubic,
)
animation = Animation(scene, motion)

animation.save("dot.svg", width=400, height=400)
animation.save("dot.gif", width=400, height=400, fps=30)
animation.save("dot.html", width=400, height=440)
```)

#api(("Animation",), syntax: [#raw("Animation(scene, motion=None, *, interactions=None, accessibility=None)")])[
  连接不可变场景和动作的主要接口。`frames()` 会逐一生成快照；`save()` 根据目标文件扩展名选择导出器，并返回 `ExportManifest`。
]

#api(("Scene2D",))[包含 2D 节点与相机的不可变场景。`bind()` 会返回绑定初始属性的新场景，不会修改原对象。]
#api(("Point2D",))[带有稳定标识符的圆形标记；位置、大小、颜色与不透明度都可以制作动画。]
#api(("Bounds2D",))[轴对齐矩形，用于表示相机可见范围、裁剪区域、布局与几何范围。]
#api(("Vec2",))[不可变的二维向量，用于位置、方向、尺寸与 2D 几何计算。]

GIF 与 HTML 两行需要对应的可选依赖。KineticKit 会在写入目标之前检查能力；不支持的组合会抛出 `CapabilityError`，也不会留下写入一半的文件。

#api(("ease",))[
  顶层的缓动函数命名空间，包含线性、多项式、正弦、指数、圆形、回拉、弹性、弹跳与三次 Bézier 缓动函数。
]

#fig("/figures/motion/easing.svg", width: 92%, caption: [
  三次缓动的完整路径、等时间采样位置与移动点
]) <fig-kinetic-motion>

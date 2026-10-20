#import "/template/manual.typ": *

= 场景与动作 <sec-scenes-motion>

== 2D 与 3D 场景

#api(("Line2D",))[两点之间的线段；端点、颜色、线宽、虚线样式与绘制进度都可以制作动画。]
#api(("PathNode2D",))[开放或闭合的描边 `Path2D`，保留直线与 Bézier 命令，也支持路径变形。]
#api(("Shape2D",))[填充路径，可以另外添加描边；适合表示区域、闭合轮廓与复合形状。]
#api(("Group2D",))[按顺序容纳多个子节点，并为它们应用共同的变换、不透明度与裁剪。]
#api(("Text2D",))[放置在场景中的 `TextAsset`；缩放、变换与不透明度都可以制作动画。]
#api(("Camera2D",))[定义可见的 2D 世界坐标范围，以及它如何映射到输出画布。]

#api(("Scene3D",))[包含几何对象、光源、组与一台相机的不可变 3D 场景。]
#api(("Point3D",))[三维空间中的点标记；位置、大小、颜色与不透明度都可以制作动画。]
#api(("Line3D",))[由当前相机投影到画布上的单条 3D 线段。]
#api(("Polyline3D",))[按顺序连接一组 3D 点形成的折线。]
#api(("Mesh3D",))[由顶点索引与面组成的网格，会验证拓扑，也可以设置各面的颜色与材质。]
#api(("Surface3D",))[根据 $x,y$ 规则网格及其高度值创建的高度场曲面。]
#api(("Group3D",))[按顺序容纳多个 3D 节点，并应用共同的变换与不透明度。]
#api(("Camera3D",))[透视或正交相机，包含位置、观察目标、裁剪平面与投影设置。]

== 组合时间

#api(("Motion",))[不可变的时间变化描述；可以依次、同时、延迟、重复、反转或裁剪多段动作。]
#api(("Timeline",))[动作树编译后的形式，可以直接计算任意有效时间的属性值。]
#api(("Keyframe",))[某个时间点的属性值，也可以指定通往下一个关键帧的缓动规则。]
#api(("Keyframes",))[同一属性的关键帧序列，会检查时间顺序与端点是否合法。]

```python
motion = (
    a.animate.position.to(Vec2(5, 5), duration=1.0)
    .then(b.animate.opacity.to(1.0, duration=0.5))
    .with_(c.animate.size.to(9, duration=0.5), offset=1.0)
    .mark("settled")
)
```

#api(("SceneTransition",))[根据稳定标识符匹配两个场景的节点，并为兼容属性创建插值动作。]
#api(("TransitionPolicy",))[决定没有匹配或结构不兼容的节点如何进入、退出、交叉淡化或报错。]

路径、网格与曲面都有专用变形工具。系统无法自动统一路径结构或判断预期拓扑时，请明确提供对应方式。

#fig("/figures/projection/surface.svg", width: 88%, caption: [
  由 KineticKit 矢量渲染器投影并按深度排序的 3D 曲面
]) <fig-kinetic-surface>

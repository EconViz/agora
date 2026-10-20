#import "/template/manual.typ": *

= Scenes and motion <sec-scenes-motion>

== 2D and 3D scenes

#api(("Line2D",))[A stroked segment between two points. Its endpoints, colour, width, dash pattern, and drawing progress can be animated.]
#api(("PathNode2D",))[An open or closed stroked `Path2D`. It preserves line and Bézier commands and supports path morphing.]
#api(("Shape2D",))[A filled path, optionally with a stroke. Use it for areas, closed outlines, and compound shapes.]
#api(("Group2D",))[A node that applies shared transforms, opacity, and clipping to an ordered collection of child nodes.]
#api(("Text2D",))[A positioned `TextAsset` produced by a typography adapter, with animatable scale, transform, and opacity.]
#api(("Camera2D",))[Defines the visible 2D world rectangle and its mapping to the output viewport.]

#api(("Scene3D",))[An immutable 3D scene containing geometry, lights, groups, and one camera.]
#api(("Point3D",))[A point marker in three-dimensional space with animatable position, size, colour, and opacity.]
#api(("Line3D",))[A single 3D segment projected by the active camera.]
#api(("Polyline3D",))[An ordered chain of 3D points rendered as connected segments.]
#api(("Mesh3D",))[Indexed vertices and faces with validated topology, optional per-face colour, and material settings.]
#api(("Surface3D",))[A regular height-field surface built from an $x,y$ grid and height values.]
#api(("Group3D",))[An ordered group of 3D nodes sharing a transform and opacity.]
#api(("Camera3D",))[A perspective or orthographic camera with position, target, clipping planes, and projection settings.]

== Composing time

#api(("Motion",))[An immutable description of change over time. Motions can be sequenced, overlapped, delayed, repeated, reversed, or trimmed.]
#api(("Timeline",))[The compiled, random-access form of a motion tree. It evaluates property values at any valid time.]
#api(("Keyframe",))[One value at one time, optionally carrying the easing rule for the following interval.]
#api(("Keyframes",))[A validated sequence of keyframes for one property, including endpoint and ordering checks.]

```python
motion = (
    a.animate.position.to(Vec2(5, 5), duration=1.0)
    .then(b.animate.opacity.to(1.0, duration=0.5))
    .with_(c.animate.size.to(9, duration=0.5), offset=1.0)
    .mark("settled")
)
```

#api(("SceneTransition",))[Builds a motion between two scenes by matching nodes with stable ids and interpolating compatible properties.]
#api(("TransitionPolicy",))[Controls how unmatched or structurally incompatible nodes enter, leave, cross-fade, or fail.]

Paths, meshes, and surfaces have dedicated morphing tools. Use explicit correspondence overrides when automatic normalization cannot infer the intended topology.

#fig("/figures/projection/surface.svg", width: 88%, caption: [
  A 3D surface projected and depth-sorted by KineticKit's vector renderer
]) <fig-kinetic-surface>

#import "/template/manual.typ": *

= Bézier 字形轮廓 <sec-glyph-bezier>

== 保留原始路径命令

`GlyphOutline` 保留移动、直线、二次、三次曲线与闭合命令，不会偷偷把曲线取样成折线。@fig-glyph-outline 的控制多边形直接来自这些命令。

== 二次与三次曲线

二次与三次 Bézier 分别为
$ Q(t)=(1-t)^2 P_0+2(1-t)t P_1+t^2 P_2, $
$ C(t)=(1-t)^3 P_0+3(1-t)^2 t P_1+3(1-t) t^2 P_2+t^3 P_3, quad 0<=t<=1. $
两者都精确通过端点，端点切线由相邻控制点决定。

#api(("GlyphOutline",))[以字体坐标保存精确且不绑定渲染器的轮廓；提取时会展开复合字形。]
#api(("MoveTo",))[移动到新轮廓的第一个点，不会绘制线段。]
#api(("LineTo",))[绘制一条直线到指定端点。]
#api(("QuadraticTo",))[使用一个控制点绘制二次 Bézier 曲线。]
#api(("CubicTo",))[使用两个控制点绘制三次 Bézier 曲线。]
#api(("ClosePath",))[闭合当前轮廓，并明确加入最后一条边。]

== 将曲线自动细分为折线

#api(("flatten",))[
  曲线扁平化（curve flattening）会递归细分曲线，直到控制点到弦的距离都不超过允许误差，再返回开放或闭合的 `Polyline`。
]

== 误差与细分

二次曲线以 $d(P_1, overline(P_0 P_2)) <= epsilon$ 为停止条件；三次曲线同时检查两个内部控制点。未达到条件时，以 de Casteljau 法在 $t = 1 / 2$ 细分。误差单位是字体单位；若调用方以像素指定误差，必须先换算回字体单位。

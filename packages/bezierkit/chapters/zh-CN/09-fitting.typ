#import "/template/manual.typ": *

= 拟合 <sec-fitting>

拟合把平滑函数或一串采样点转为 `PiecewiseBezier`，并逐段测量、报告误差，单位与曲线坐标相同。相关函数位于 `bezierkit.fitting`。

== 自适应 Hermite 拟合

#api(("fit_parametric",), syntax: [
  #raw("fit_parametric(")#meta("function")#raw(", ")#meta("derivative")#raw(", *, t0, t1, tolerance, max_depth=20, max_segments=4096, error_samples=9)")
])[
  在 $[t_0, t_1]$ 上拟合参数曲线 $C(t)$；`function` 返回 `Point`，`derivative` 返回 `Vector`。算法为递回二分：

  + 以目前区间两端的 $C$ 与 $C'$ 创建 Hermite 线段（详见#ref(<prop-hermite>)）。
  + 测量误差：在 `error_samples` 个等距参数（含两端）上，$C(t_j)$ 与线段之间的最大欧氏距离。
  + 误差不超过 `tolerance` 时保留此线段，并将误差记为其 `fit_error`；否则将区间对半，两半各自拟合。

  因此每个保留的线段在测量参数上都符合容差。若区间到了 `max_depth` 仍不合格，或保留它会超过 `max_segments`，就抛出 `ToleranceNotMet`，而不返回质量较差的路径。
]

#param("tolerance", type: "float")[容差，单位同坐标；必须为正。]
#param("max_depth", type: "int", default: "20")[起始区间最多可对半的次数。]
#param("max_segments", type: "int", default: "4096")[结果最多的线段数。]
#param("error_samples", type: "int", default: "9")[每段的测量参数个数，至少 3。]

#api(("fit_graph",), syntax: [
  #raw("fit_graph(")#meta("function")#raw(", ")#meta("derivative")#raw(", *, x0, x1, tolerance, ...)")
])[
  拟合图形 $y = f(x)$，$x in [x_0, x_1]$：即以 $C(x) = (x, f(x))$、$C'(x) = (1, f'(x))$ 调用 `fit_parametric`，选项相同，误差为 $(x, y)$ 平面上的欧氏距离。
]

```python
from bezierkit.fitting import fit_graph

path = fit_graph(lambda x: 4 / x**2, lambda x: -8 / x**3,
                 x0=0.8, x1=3, tolerance=1e-3)
print(len(path.segments))                    # 10
print(max(s.fit_error for s in path))        # 0.000676
```

#fig("/figures/fitting/adaptive.pdf", width: auto, caption: [
  $4 slash x^2$ 的自适应拟合。
]) <fig-adaptive>

曲线弯曲剧烈处线段较短，接近直线处线段较长（参见#ref(<fig-adaptive>)，相邻线段以不同颜色区分）。Hermite 误差界限可预估二分需要的深度：

#corollary(name: [自适应拟合的深度])[
  设 $C$ 的每个坐标在 $[t_0, t_1]$ 上四阶连续可微且 $|C_k^((4))| <= M$，令 $H = |t_1 - t_0|$，$d$ 为维度。深度
  $ k >= 1/4 log_2 (sqrt(d) M H^4 / (384 epsilon)) $
  的每个区间都能通过容差 $epsilon$ 的检查；因此除非先达到 `max_depth` 或 `max_segments`，二分最迟在此深度停止。
] <cor-depth>

实测误差是线段真实最大误差的下界，因为只在测量参数上检查。若曲线可能在测量点之间起伏，请增加 `error_samples`。

== 折线简化

#api(("fit_polyline",), syntax: [
  #raw("fit_polyline(")#meta("points")#raw(", *, tolerance, closed=False, duplicate_tolerance=1e-12, preserve_corners=True, corner_angle=pi/4)")
])[
  把采样点简化为由直线弦组成的路径，每条弦以精确的三次曲线表示（详见#ref(<prop-elevation>)）。步骤如下：

  + 删除与前一点距离在 `duplicate_tolerance` 以内的点。闭合折线另外删除结尾重复的起点，并旋转为从字典序最小的点开始，使结果与采样起点无关。
  + 保留两端点；启用 `preserve_corners` 时，另保留方向转折至少 `corner_angle` 弧度的顶点。
  + 在相邻的保留顶点之间套用 Ramer–Douglas–Peucker 算法 #citep(<ramer1972>)#citep(<douglas1973>)：若离弦最远的顶点距离不超过 `tolerance`，以弦取代整段；否则保留该顶点，两侧递回处理。

  每条弦的 `fit_error` 是被它取代的顶点到弦的最大距离（参见#ref(<fig-polyline>)）。
]

#proposition(name: [折线容差])[
  通过步骤 1 的每个输入顶点，到取代它的输出线段之弦的距离都不超过 `tolerance`。
] <prop-rdp>

#fig("/figures/fitting/polyline.pdf", width: auto, caption: [
  以容差 $0.08$ 简化 41 个噪声样本。
]) <fig-polyline>

#api(("maximum_polyline_deviation",), syntax: [
  #raw("maximum_polyline_deviation(")#meta("points")#raw(", ")#meta("path")#raw(")")
])[
  各点到路径中最近之弦 $P_0 P_3$ 的最大距离：可用来检查#ref(<prop-rdp>)，也涵盖步骤 1 删除的点。
]

如同所有只看得到样本的方法，`fit_polyline` 限制的是与样本的偏差，而非与样本之间未知连续曲线的偏差；需要更贴近时请加密采样。

#import "/template/manual.typ": *

= 简介 <sec-intro>

#changed("0.5.0rc1")[首次发布到 PyPI：任意次数的 Bézier 曲线、三次线段与路径、构造、Hermite 插值、拟合、等值线描绘、采样、导出器与命令行界面]
#changed("1.0.0")[第一个正式版；公开 API 按语义化版本管理]

#pkg("bezierkit") 是处理 Bézier 曲线的小型数学工具软件包。它可由控制点或端点条件构造曲线，计算曲线值与导数，分割与截取曲线，将曲线拟合到函数、采样点与等值线，并输出为 JSON、SVG 路径数据或 TikZ。软件包本身不绘图。Matplotlib、#pkg("mosaickit") 或 #LaTeX 文档等绘图端接收精确的三次控制点，再负责绘制。

== 符号

点或向量位于某个维度 $d >= 1$ 的 $RR^d$ 中；多数图使用 $d = 2$。$x in RR^d$ 的欧氏范数为
$ norm(x) = sqrt(x_1^2 + dots + x_d^2), $
$norm(x)_oo = max_k |x_k|$ 为最大范数。集合 $S subset.eq RR^d$ 若对所有 $p, q in S$ 与 $lambda in [0, 1]$ 都有 $lambda p + (1 - lambda) q in S$，称为凸集；有限个点的凸包是它们所有凸组合 $sum_i lambda_i P_i$（$lambda_i >= 0$ 且 $sum_i lambda_i = 1$）的集合。映射 $A: RR^d -> RR^e$ 若可写成 $A(x) = M x + v$（$M$ 为矩阵，$v$ 为向量），称为仿射映射。函数若有直到 $k$ 阶的连续导数，称为 $C^k$。

$n$ 次 Bézier 曲线有 $n + 1$ 个控制点 $P_0, dots, P_n$，定义为映射
$ B(t) = sum_(i=0)^n b_(i,n)(t) P_i, quad t in [0, 1], $
其中
$ b_(i,n)(t) = binom(n, i) t^i (1-t)^(n-i) $
为 Bernstein 多项式（详见#ref(<sec-curves>)）。依次连接控制点即为控制多边形。软件包中每条曲线的参数范围都是 $[0, 1]$；超出范围的参数会抛出 `ParameterOutOfDomain`。符号 $d$ 一律表示维度，容差写作 $epsilon$。

== 数学与证明

各章先回顾所用的标准定义并附出处，再以编号的引理、命题、定理与推论陈述算法所依据的性质：Bernstein 基底、de Casteljau 算法的求值与分割、Hermite 误差界，以及导出器的舍入误差。证明集中在#ref(<app-proofs>)，只想了解 API 时可略过。属于本软件包而不见于文献的约定，称为软件包约定。标准参考书为 #citet(<farin2002>) 与 #citet(<prautzsch2002>)；Bernstein 基底另见 #citet(<farouki2012>)。

== 阅读指引

#tbl(caption: [章节主题])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([主题], [内容], [章节]),
    table.cell(rowspan: 3)[基础],
    [点、向量、参数、异常], [#ref(<sec-geometry>)],
    [Bernstein 基底、曲线、求值], [#ref(<sec-curves>)],
    [导数、反转、分割], [#ref(<sec-operations>)],
    table.cell(rowspan: 2)[三次曲线],
    [三次线段与分段路径], [#ref(<sec-paths>)],
    [构造与 Hermite 插值], [#ref(<sec-construction>)],
    table.cell(rowspan: 2)[近似],
    [拟合函数与折线], [#ref(<sec-fitting>)],
    [描绘等值线], [#ref(<sec-implicit>)],
    table.cell(rowspan: 2)[输出],
    [采样、JSON、SVG、TikZ、Matplotlib], [#ref(<sec-export>)],
    [命令行], [#ref(<sec-cli>)],
  )
] <tab-guide>

初次使用时，先读#ref(<sec-quickstart>)与#ref(<sec-curves>)。本手册的图本身就是 #pkg("bezierkit") 的输出：每条曲线都由#ref(<sec-export>)的 TikZ 导出器写出，再以 #LaTeX 编译。

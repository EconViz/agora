#import "/template/manual.typ": *

= 采样与导出 <sec-export>

导出器只写出几何数据，不选择颜色、线宽、主题、坐标轴、标签或画布，也绝不把三次曲线摊平成折线：TikZ 收到原生的 `.. controls ..` 曲线，SVG 收到原生的 `C` 命令。

== 采样

#api(("UniformSampler",), syntax: [
  #raw("UniformSampler(")#meta("int")#raw(").sample(")#meta("curve")#raw(")")
])[
  在曲线或路径的定义域上，以 `count` 个等距参数求值（含两端，`count` $>= 2$），位于 `bezierkit.sampling`。
]

#api(("Sample",))[
  采样的结果：唯读的参数 `t` 与 `points`，提供坐标数组 `x`、`y`，并可逐一取出 `(t, point)`。
]

```python
from bezierkit.sampling import UniformSampler

sample = UniformSampler(5).sample(curve)
print(sample.x)   # [0.      0.90625 2.      3.09375 4.     ]
```

== 四舍五入与坐标变换

文本格式的导出器以固定的小数字数 `precision` 写出每个坐标，并接受 `transform`：在写出前把每个控制点（`Point`）对应到二维 `Point`，例如由数据坐标转为页面坐标。

#proposition(name: [四舍五入误差])[
  设 $B$、$tilde(B)$ 是同为 $n$ 次的 $RR^d$ 中 Bézier 曲线，控制点分别为 $P_i$ 与 $tilde(P)_i$，且对每个 $i$ 与每个坐标 $k$ 有 $|tilde(P)_(i,k) - P_(i,k)| <= epsilon$。则对每个 $t in [0, 1]$ 与每个 $k$，
  $ |tilde(B)_k (t) - B_k (t)| <= epsilon, quad norm(tilde(B)(t) - B(t))_2 <= sqrt(d) epsilon. $
  将每个坐标四舍五入到小数点后 $p$ 位时，$epsilon = 1/2 dot 10^(-p)$。
] <prop-rounding>

因此在默认的 `precision=6` 下，导出的平面曲线处处与原曲线相差不超过 $0.71 times 10^(-6)$，不只在控制点上成立。依#ref(<prop-affine>)，仿射的 `transform` 是精确的；非仿射的变换能正确移动控制点，但一般不能正确移动控制点之间的曲线。

== JSON

#api(("dumps",), syntax: [
  #raw("dumps(")#meta("path")#raw(", *, metadata=None, indent=None)")
])[
  位于 `bezierkit.export.json`。以#ref(<tab-json>)的版本化格式写出路径，键依字母排序，不含 NaN 或无穷大。
]

#api(("loads",), syntax: [
  #raw("loads(")#meta("str")#raw(")")
])[
  验证文档并回传 `PathDocument`，内含 `path` 与 `metadata`。格式或版本不明、线段不是恰好四个点、点的维度不符或数值非有限时，抛出 `ValueError`。
]

#api(("PathDocument",))[
  路径与调用端的 metadata，即 `loads()` 的回传值。
]

#tbl(caption: [JSON 路径格式第 1 版])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([键], [值]),
    [`schema`], [字符串 `"bezierkit.path"`],
    [`version`], [整数 `1`；读取端拒绝其他版本],
    [`dimension`], [每个点的维度 $d$],
    [`subpaths`], [非空数组，元素为 `{"closed": bool, "segments": [...]}`，每个线段是四个含 $d$ 个数值的点],
    [`metadata`], [JSON 对象，原样传递、不解读],
  )
] <tab-json>

```python
from bezierkit.export.json import dumps, loads

text = dumps(path, metadata={"name": "arch"})
# {"dimension":2,"metadata":{"name":"arch"},"schema":"bezierkit.path",
#  "subpaths":[{"closed":false,"segments":[[[0.0,0.0],[1.0,2.0],...]]}],"version":1}
assert loads(text).path.segments == path.segments
```

第 1 版已冻结：添加必要的键、改变封闭的语意或控制点的排列方式，都需要第 2 版。

== SVG

#api(("to_svg_path_data", "from_svg_path_data"), syntax: [
  #raw("to_svg_path_data(")#meta("path")#raw(", *, precision=6, transform=None)") \
  #raw("from_svg_path_data(")#meta("str")#raw(")")
])[
  位于 `bezierkit.export.svg`。回传平面路径的路径数据字符串（即 `d` 属性），只使用绝对坐标的 `M`、`C` 与 `Z` 命令，每条子路径一个 `M`；不产生 SVG 文档或样式。`from_svg_path_data()` 解析同一子集；相对命令、直线与圆弧抛出 `ValueError`。
]

```python
from bezierkit.export.svg import to_svg_path_data

print(to_svg_path_data(path, precision=2))   # M 0.00 0.00 C 1.00 2.00 3.00 2.00 4.00 0.00
```

== TikZ

#api(("to_tikz", "segment_to_tikz"), syntax: [
  #raw("to_tikz(")#meta("path")#raw(", *, precision=6, transform=None, options=None)") \
  #raw("segment_to_tikz(")#meta("segment")#raw(", *, precision=6, transform=None, include_start=True)")
])[
  位于 `bezierkit.export.tikz`。每条子路径一个 `\draw` 命令，每个线段写成 `.. controls (P1) and (P2) .. (P3)`，封闭子路径以 `-- cycle` 结尾。`options` 原样放入 `\draw[options]`；默认不加任何选项。`segment_to_tikz()` 只写出一个线段、不含 `\draw`，供需要自行组合命令的调用端使用。
]

```python
from bezierkit.export.tikz import to_tikz

print(to_tikz(path, precision=2, options="thick"))
# \draw[thick] (0.00,0.00) .. controls (1.00,2.00) and (3.00,2.00) .. (4.00,0.00);
```

本手册的每张图都是这样产生的：脚本以 #pkg("bezierkit") 创建曲线，用 `to_tikz()` 写进 `standalone` #LaTeX 文档，与坐标轴、标签放在一起，再编译成 PDF。每张图的 `.tex` 源文件都随手册提供。

== Matplotlib <sec-matplotlib>

#api(("from_path", "to_path", "approximate_path"), syntax: [
  #raw("from_path(")#meta("path")#raw(", *, transform=None)") \
  #raw("to_path(")#meta("path")#raw(")") \
  #raw("approximate_path(")#meta("path")#raw(", ")#meta("transform")#raw(", *, tolerance, max_depth=20)")
])[
  位于 `bezierkit.adapters.matplotlib`，需安装 `matplotlib` 选用依赖。`from_path()` 精确转换 Matplotlib `Path`：`MOVETO`、`LINETO`、`CURVE3`、`CURVE4` 与 `CLOSEPOLY` 都转为三次曲线，直线与二次曲线依#ref(<prop-elevation>)升阶。仿射的 `transform` 直接套用在控制点上，结果精确（详见#ref(<prop-affine>)）；非仿射的变换抛出 `ValueError`。`to_path()` 反向转换，每个线段一个 `CURVE4`。
]

非仿射变换（例如对数坐标轴）不会把三次曲线对应到三次曲线。`approximate_path()` 是明确的选择：它细分每个变换后的线段，直到中点与弦的距离在 `tolerance / 2` 以内，再以 `tolerance / 2` 对这些点调用 `fit_polyline`。它不宣称结果精确。

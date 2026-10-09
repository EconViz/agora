#import "/template/manual.typ": *

= 快速开始 <sec-quickstart>

== 基本示例

本章以 Cobb-Douglas 消费者问题说明完整流程：

$
  max_(x, y) & u(x, y) = x^(1/2) y^(1/2) \
      "s.t." & 2x + 3y = 30
$

程序先求解最优消费组合，再绘制无差异曲线、预算集与均衡点（参见#ref(<fig-quickstart>)）。

#example([```python
from utility_viz import Canvas, levels, solve
from utility_viz.models import CobbDouglas

model = CobbDouglas(alpha=0.5, beta=0.5)
eq    = solve(model, px=2.0, py=3.0, income=30.0)
lvls  = levels.around(eq.utility, n=5)

cvs = Canvas(
    x_max=20, y_max=15,
    x_label="x", y_label="y",
    title=r"Cobb-Douglas $x^{0.5} y^{0.5}$"
)
cvs.add_utility(model, levels=lvls)
cvs.add_budget(2.0, 3.0, 30.0, fill=True)
cvs.add_equilibrium(eq, show_ray=True)
cvs.save("cobb_douglas.png")
```])

#fig("/figures/models/cobb_douglas.svg", caption: [
  消费者均衡。
]) <fig-quickstart>

运行主程序 `main.py` 后，会在当前工作目录创建 `cobb_douglas.png`。本例的最优消费量为 $x^* = 7.5$、$y^* = 5$，支出为 $2 times 7.5 + 3 times 5 = 30$，恰好等于收入。预算线的两个轴截距则为 $I / p_x = 15$ 与 $I / p_y = 10$。

== 逐步说明

绘图流程依次为：创建模型、求解均衡、选取效用水平、创建画布、添加图层与导出。

#api(("utility_viz.models",), syntax: [
  ```python
  from utility_viz.models import CobbDouglas
  model = CobbDouglas(alpha=0.5, beta=0.5)
  ```
])[
  创建效用模型。内置模型详见#ref(<sec-models>)；自定义函数使用 `CustomUtility`，详见#ref(<sec-advanced>)。
]

#api(("solve",), syntax: [
  #raw("solve(")#meta("model")#raw(", px=")#meta("float")#raw(", py=")#meta("float")#raw(", income=")#meta("float")#raw(
    ")",
  )
])[
  根据价格与收入求解，返回不可变的 `Equilibrium` 对象。

  #param("x", type: "float")[最优消费量 $x^*$。]
  #param("y", type: "float")[最优消费量 $y^*$。]
  #param("utility", type: "float")[模型在最优点的效用值。]
  #param("bundle_type", type: "str")[
    解的类型：`"interior"` 为内部解、`"boundary"` 为数值解位于数量下界（例如 Stone-Geary 的最低消费限制）、`"kink"` 为完全互补的折点解、`"corner"` 为完全替代的角解。
  ]

  ```python
  from utility_viz import solve
  eq = solve(model, px=2.0, py=3.0, income=30.0)
  print(eq.x, eq.y, round(eq.utility, 3))

  # 7.5 5.0 6.124
  ```
]

#api(("levels.around",), syntax: [
  #raw("levels.around(")#meta("utility")#raw(", n=")#meta("int")#raw(")")
])[
  以指定效用值为中心，生成 $n$ 个效用水平。#ref(<fig-quickstart>) 使用 `n=5`，因此绘制五条无差异曲线。

  `levels.around()` 会保留指定的效用值，均衡点会落在其中一条无差异曲线上。若直接传入 `levels=5`，画布会依采样到的效用范围选取水平，不保证包含均衡效用。要比较多张图上的同一组偏好，可先计算一次 `lvls`，再让各张图使用相同水平。
]

#api(("Canvas",), syntax: [
  #raw("Canvas(x_max=")#meta("float")#raw(", y_max=")#meta("float")#raw(", ...)")
])[
  创建画布并设置坐标范围，其余参数详见#ref(<sec-canvas>)。

  坐标范围只控制显示区域，不参与 `solve()` 的计算。均衡点未出现在图中时，检查 `eq.x` 与 `eq.y` 是否超出范围，再调整坐标上限。
]

#api(("Canvas.add_*",))[
  在同一张画布上添加无差异曲线、预算线或均衡点。这些方法可以链式调用（详见#ref(<sec-chaining>)）。`add_equilibrium()` 使用现有的求解结果，不会重新求解；若之后修改价格、收入或模型，需重新调用 `solve()`，并创建对应的新图。
]

#api(("Canvas.save", "Canvas.show"))[
  `save()` 根据扩展名导出文件（详见#ref(<sec-export>)）；`show()` 打开 #pkg("matplotlib") 交互窗口。输出路径以运行程序时的工作目录为准，若需指定子目录，请事先创建目录。
]

=== 检查输入与求解失败

价格与收入必须为正；输入不符合条件时，`solve()` 抛出 `InvalidParameterError`#footnote[一般平滑模型使用#term("序列最小二乘法", english: "sequential least squares programming, SLSQP") 求解。]。

求解未收敛时，`solve()` 抛出 `OptimizationError`，不会返回无效的均衡点。

```python
from utility_viz import InvalidParameterError, OptimizationError, solve

try:
    eq = solve(model, px=2.0, py=3.0, income=30.0)
except (InvalidParameterError, OptimizationError) as error:
    print(error)
else:
    print(round(eq.x, 3), round(eq.y, 3), eq.bundle_type)
```

#changed("2.0.0b1", label: "UtilityVizError")[`UtilityVizError` 成为基础异常类；`EconVizError` 保留为同一个类的别名]
软件包抛出的所有异常都继承自 `UtilityVizError`，捕获它即可一并处理。1.x 的名称 `EconVizError` 是同一个类。

数值解可能有微小误差，例如结果接近但不恰好等于 `7.5`。验证时应使用适当容差；显示结果时再用 `round()` 格式化，避免过早四舍五入影响后续计算。

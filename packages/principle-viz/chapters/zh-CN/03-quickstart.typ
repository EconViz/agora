#import "/template/manual.typ": *

= 快速开始 <sec-quickstart>

== 基本范例

本章以一个市场说明完整流程，后续各章也沿用这个市场：
$
  "需求：" & quad p = 10 - Q, \
  "供给：" & quad p = 2 + Q.
$

#example(```python
from principle_viz import MarketFigure, line_from_inverse, solve_equilibrium

demand = line_from_inverse(10.0, -1.0)   # p = 10 - Q
supply = line_from_inverse(2.0, 1.0)     # p = 2 + Q
eq = solve_equilibrium(demand, supply)
print(eq.q_star, eq.p_star)              # 4.0 6.0

fig = MarketFigure(x_max=12, y_max=12, title="Basic Equilibrium")
fig.add_curves(demand, supply, q_max=10)
fig.add_equilibrium(eq)
fig.finalize()
fig.save("basic_equilibrium.png")
```)

#fig("/figures/quickstart/equilibrium.svg", width: 46%, caption: [
  本章的市场（省略标题）。
]) <fig-quickstart>

由 $10 - Q = 2 + Q$ 得 $Q^* = 4$、$p^* = 6$。输出参见#ref(<fig-quickstart>)。

== 逐步说明

每张图依序经过描述市场、求解、绘图、完成并保存四个步骤。

#api(("line_from_inverse",), syntax: [
  #raw("line_from_inverse(")#meta("float")#raw(", ")#meta("float")#raw(")")
])[
  描述市场。`line_from_inverse(a, b)` 创建直线 $p = a + b Q$（详见#ref(<sec-markets>)）。
]

#api(("solve_equilibrium",), syntax: [
  #raw("solve_equilibrium(")#meta("demand")#raw(", ")#meta("supply")#raw(")")
])[
  求解。`solve_equilibrium()` 等求解函数返回由数值组成的不可变 dataclass，此时尚未绘图。
]

#api(("MarketFigure",), syntax: [
  #raw("MarketFigure(x_max=")#meta("float")#raw(", y_max=")#meta("float")#raw(", ...)")
])[
  绘图。`MarketFigure` 是含价格轴与数量轴的正方形图。坐标范围只控制显示区域，不参与计算；均衡点未出现在图中时，检查 `eq.q_star` 与 `eq.p_star` 是否超出范围，再调整坐标上限。
]

#api(("MarketFigure.add_*",))[
  `add_*` 方法接收曲线与结果，加入对应的图层；每个方法都返回图形本身，可串接调用。
]

#api(("MarketFigure.finalize", "MarketFigure.save"))[
  完成并保存。`finalize()` 隐藏会把阴影面积切成两半的辅助线；`save()` 依扩展名写出 PNG、SVG 或 PDF，并创建不存在的目录（详见#ref(<sec-figures>)）。
]

计算与绘图互不依赖：结果可以不经绘图直接打印、比较或导出，同一个结果也可以画在多张图上。

== 结果

结果是不可变的 dataclass，字段为浮点数、字符串与 tuple。`solve_equilibrium()` 返回 `EquilibriumResult`：

#param("q_star", type: "float")[均衡数量 $Q^*$。]
#param("p_star", type: "float")[均衡价格 $p^*$。]
#param("is_valid_market", type: "bool")[均衡数量为负时为 `False`；价格为负只会加入一则说明。]
#param("notes", type: "tuple[str, ...]")[说明解的特殊情况。]

== 检查输入与求解失败

#api(("PrincipleVizError",))[
  软件包抛出的所有异常都继承自 `principle_viz.exceptions` 中的 `PrincipleVizError`，捕获它即可一并处理（各异常详见#ref(<sec-errors>)）。
]

两条直线平行时没有均衡，`solve_equilibrium()` 抛出 `ParallelLinesError`，不会返回无效的结果：

```python
from principle_viz import line_from_inverse, solve_equilibrium
from principle_viz.exceptions import PrincipleVizError

demand = line_from_inverse(10.0, -1.0)
supply = line_from_inverse(8.0, -1.0)   # parallel to demand

try:
    eq = solve_equilibrium(demand, supply)
except PrincipleVizError as error:
    print(type(error).__name__)
else:
    print(eq.q_star, eq.p_star)

# ParallelLinesError
```

均衡数量为负时不抛出异常，而是将 `is_valid_market` 设为 `False`。使用结果前，先检查 `is_valid_market` 与 `notes`。

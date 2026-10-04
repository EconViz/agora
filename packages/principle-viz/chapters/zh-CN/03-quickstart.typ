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

由 $10 - Q = 2 + Q$ 得 $Q^* = 4$、$p^* = 6$。结果如#ref(<fig-quickstart>)：曲线名称标在末端，均衡点为实心点并标为 $e^*$，坐标轴名称 $p$ 与 $Q$ 位于箭头外侧。

== 步骤说明

每张图都按以下四个步骤创建。

+ *描述市场。*`line_from_inverse(a, b)` 创建直线 $p = a + b Q$（详见#ref(<sec-markets>)）。
+ *求解。*`solve_equilibrium()` 等求解函数返回由数值组成的不可变 dataclass，此时尚未绘图。
+ *绘图。*`MarketFigure` 是含价格轴与数量轴的正方形图。其 `add_*` 方法接收曲线与结果，加入对应的图层；每个方法都返回图形本身，可链式调用。
+ *完成并保存。*`finalize()` 隐藏会把阴影面积切成两半的辅助线；`save()` 按扩展名写出 PNG、SVG 或 PDF。

计算与绘图互不依赖：结果可以不经绘图直接打印、比较或导出，同一个结果也可以画在多张图上。

== 结果

结果是不可变的 dataclass，字段为浮点数、字串与 tuple。`solve_equilibrium()` 返回 `EquilibriumResult`：

#param("q_star", type: "float")[均衡数量 $Q^*$。]
#param("p_star", type: "float")[均衡价格 $p^*$。]
#param("is_valid_market", type: "bool")[均衡数量为负时为 `False`；价格为负只会加入一则说明。]
#param("notes", type: "tuple[str, ...]")[说明解的特殊情况。]

无效的输入会抛出继承自 `PrincipleVizError` 的异常（详见#ref(<sec-errors>)），求解失败不会被误当成结果。

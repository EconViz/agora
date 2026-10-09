#import "/template/manual.typ": *

= 进阶模型 <sec-advanced>

`CustomUtility` 定义二元效用函数。`MultiGoodCD` 表示多商品 Cobb-Douglas；固定其他商品的数量后，可将模型投影为二维图。

=== 自定义效用函数

#api(("CustomUtility",), syntax: [#raw("CustomUtility(func=")#meta("callable")#raw(", name=")#meta("str")#raw(")")])[
  接受向量化的 Python 函数，返回的模型可用于 `solve()` 与 `Canvas`。函数须接受两个 #pkg("NumPy") 数组，并返回相同形状的效用数组。以下以对数效用为例：
  $ u(x, y) = ln x + ln y. $
]

#param("func")[以 $x$ 与 $y$ 为变量的向量化效用函数。]
#param("name")[模型的显示名称。]

```python
import numpy as np
from utility_viz import Canvas, levels, solve
from utility_viz.models import CustomUtility

model = CustomUtility(
    func=lambda x, y: np.log(x) + np.log(y),
    name="log+log",
)
eq = solve(model, px=2.0, py=3.0, income=30.0)

(
    Canvas(x_max=20, y_max=15, title="Custom Utility")
    .add_utility(model, levels=levels.around(eq.utility, n=5))
    .add_budget(2.0, 3.0, 30.0)
    .add_equilibrium(eq)
    .save("custom.png")
)
```

#fig("/figures/models/custom.svg", width: 42%, caption: [
  对数自定义模型。
])

=== 多商品 Cobb-Douglas

#api(("MultiGoodCD", "MultiGoodCD.freeze"), syntax: [
  #raw("MultiGoodCD(")#meta("shares")#raw(")") \
  #raw(".freeze(")#meta("good")#raw("=")#meta("quantity")#raw(", ...)")
])[
  `MultiGoodCD` 表示 $N$ 种商品的 Cobb-Douglas：
  $ u(x_1, ..., x_N) = product_(i=1)^N x_i^(alpha_i). $
  使用 `freeze()` 固定 $x$、$y$ 以外的商品数量，返回可用于二维 `Canvas` 的 `CustomUtility`。
]

#param("shares")[商品名称与指数 $alpha_i$ 的对应。]
#param("freeze(...)")[$x$、$y$ 以外商品的固定数量。]

```python
from utility_viz import Canvas, levels, solve
from utility_viz.models import MultiGoodCD

model = MultiGoodCD({"x": 0.3, "y": 0.3, "z": 0.4})
two_good_model = model.freeze(z=10.0)
eq = solve(two_good_model, px=2.0, py=3.0, income=30.0)

(
    Canvas(x_max=20, y_max=15, title="Multi-Good Cobb-Douglas")
    .add_utility(
        two_good_model,
        levels=levels.around(eq.utility, n=5),
    )
    .add_budget(2.0, 3.0, 30.0, fill=True)
    .add_equilibrium(eq)
    .save("multigood.png")
)
```

#fig("/figures/models/multigood.svg", width: 42%, caption: [
  三商品固定 $z=10$。
])


=== 与后端无关的场景 <sec-scenes>

#changed("2.0.0b1", label: "core.scenes")[添加与后端无关的 #pkg("mosaickit") 图层工厂，涵盖预算线、均衡与无差异曲线，并可导出原生 Bézier TikZ]

`utility_viz.core.scenes` 生成与 `Canvas` 相同的经济元素，但输出为不可变的 #pkg("mosaickit") 图层，而非直接绘制在 #pkg("matplotlib") 坐标轴上。每个图层都有固定的 id（`budget`、`budget.fill`、`equilibrium.drop`、`ic.2` 等）与以点分隔的主题角色（`utility.budget`、`utility.indifference.secondary` 等），因此场景可供检查、修改，并交由任何 #pkg("mosaickit") 后端渲染。这是额外添加的高级 API，`Canvas` 与其他图形不受影响。

#api(("budget_layers", "equilibrium_layers", "indifference_layers"), added: "v2.0.0b1", syntax: [
  #raw("budget_layers(")#meta("float")#raw(", ")#meta("float")#raw(", ")#meta("float")#raw(", fill=False, ...)") \
  #raw("equilibrium_layers(")#meta("equilibrium")#raw(", drop_lines=True, ...)") \
  #raw("indifference_layers(")#meta("model")#raw(", ")#meta("levels")#raw(", ")#meta("max")#raw(", ")#meta("max")#raw(", ...)")
])[
  分别返回预算线 $p_x x + p_y y = I$、均衡消费组合，以及模型在 $[0, x_max] times [0, y_max]$ 范围内无差异曲线的图层 tuple。样式来自主题角色，也可传入部分字段的 `Stroke`、`Marker` 与 `Fill` 覆盖。`indifference_layers` 返回 `(layers, levels)`，并以 #pkg("bezierkit") 将曲线描成 Bézier 路径，因此也能处理非单调与有折角的效用函数。
]

#api(("UTILITY_THEME", "canvas_to_tikz"), added: "v2.0.0b1")[
  `UTILITY_THEME` 是含 `utility.*` 角色的 #pkg("mosaickit") 主题，配色与默认主题相同。`canvas_to_tikz(canvas)` 将场景导出为 TikZ，曲线使用原生的 `.. controls ..` 语法。
]

```python
from mosaickit import Canvas, CanvasSpec, quadrant_axes

from utility_viz.core.scenes import (
    UTILITY_THEME,
    budget_layers,
    canvas_to_tikz,
    equilibrium_layers,
    indifference_layers,
)
from utility_viz.models import CobbDouglas, solve

model = CobbDouglas(alpha=0.5, beta=0.5)
eq = solve(model, px=2.0, py=3.0, income=30.0)
u = eq.utility
ic, _ = indifference_layers(model, [0.6 * u, u, 1.4 * u], 18, 12)

spec = CanvasSpec(x_range=(0, 18), y_range=(0, 12))
canvas = (
    Canvas(spec, theme=UTILITY_THEME)
    .extend(quadrant_axes(18, 12))
    .extend(ic)
    .extend(budget_layers(2.0, 3.0, 30.0, fill=True))
    .extend(equilibrium_layers(eq))
)
canvas.save("scene.png")
tex = canvas_to_tikz(canvas)
```

TikZ 导出支持路径、填充、标记与文本图层。描绘的效用函数在绘图范围内必须为有限值。


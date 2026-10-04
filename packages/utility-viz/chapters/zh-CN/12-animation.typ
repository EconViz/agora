#import "/template/manual.typ": *

= 动画 <sec-animation>

#changed("1.4.0", label: "Animator")[`Animator` 以 #pkg("Pillow") 生成 GIF 参数变动动画，不需要 `ffmpeg`]
#changed("1.4.0", label: "Animator")[添加效用参数、价格、收入与仅显示预算线的 GIF 示例]
#changed("1.6.0", label: "Animator")[动画示例移到 `examples/scripts/animation.py`]
#changed("2.0.0b1", label: "Animator")[#modify[移至 `utility_viz.core.animation`]]

`Animator` 根据指定的参数序列调用绘图函数，将返回的 `Canvas` 或 `Figure` 导出为 GIF。使用前需安装 `animation` 可选依赖（详见#ref(<sec-extras>)）。#modify[从 `utility_viz.core.animation` 导入；1.x 为 `econ_viz.animation`。]

#api(("Animator",), added: "v1.4.0", syntax: [
  #raw("Animator(")#meta("draw")#raw(", frames=")#meta("values")#raw(").save(")#meta("path")#raw(
    ", fps=12, dpi=120, loop=0)",
  )
])[
  依次将 `frames` 的值传入 `draw`，每次返回的图形对应一个帧。

  - `save()` 使用 #pkg("Pillow")，不需要 `ffmpeg`。
  - 导出前将帧合成至白色背景，避免残影。
  - `fps`、`dpi` 与 `loop` 分别设置帧率、分辨率与循环次数。
]

#example(modify[```python
import numpy as np

from utility_viz import Canvas, levels, solve
from utility_viz.core.animation import Animator
from utility_viz.models import CobbDouglas

def draw(px: float) -> Canvas:
    model = CobbDouglas(alpha=0.5, beta=0.5)
    eq = solve(model, px=px, py=2.0, income=20.0)
    lvls = levels.around(eq.utility, n=5)

    return (
        Canvas(
            x_max=14, y_max=12,
            x_label="X_1", y_label="X_2",
            title="Price sweep"
        )
        .add_utility(model, levels=lvls)
        .add_budget(px=px, py=2.0, income=20.0, fill=True)
        .add_equilibrium(eq, show_ray=True, drop_dashes=True)
    )

Animator(draw, frames=np.linspace(1.0, 6.0, 45)).save(
    "price_sweep.gif",
    fps=12,
    dpi=120,
)
```])

`examples/scripts/animation.py` 提供四种示例#footnote[各示例均包含 Cobb-Douglas、CES、完全替代与完全互补模型。]：

- 参数变动：固定价格与收入，调整效用函数参数。
- 价格变动：固定效用函数与 $p_y$，调整 $p_x$，呈现预算线旋转，写法见上例。
- 收入变动：固定效用函数与价格，调整收入，呈现预算线平移。
- 预算线变动：仅显示预算线，省略效用图层。

四种示例的差异只在于 `draw()` 每次固定哪些值、调整哪个值。以参数变动为例，将上例的 `draw()` 改为接收 `alpha`，价格固定为 $p_x = 2$：

```python
def draw(alpha: float) -> Canvas:
    model = CobbDouglas(alpha=alpha, beta=1.0 - alpha)
    eq = solve(model, px=2.0, py=2.0, income=20.0)
    ...

Animator(draw, frames=np.linspace(0.1, 0.9, 45)).save("parameter_sweep.gif")
```

收入变动将 `draw()` 的参数改为 `income`，并把该值传入 `add_budget()` 与 `solve()`。只呈现预算线时，省略 `add_utility()` 与 `add_equilibrium()`。

#ref(<fig-sweep-param>)至#ref(<fig-sweep-income>)各节录四个帧。

#fig("/figures/animation/parameter_sweep.svg", width: 94%, caption: [
  参数变动。
]) <fig-sweep-param>

#fig("/figures/animation/price_sweep.svg", width: 94%, caption: [
  价格变动。
]) <fig-sweep-price>

#fig("/figures/animation/income_sweep.svg", width: 94%, caption: [
  收入变动。
]) <fig-sweep-income>


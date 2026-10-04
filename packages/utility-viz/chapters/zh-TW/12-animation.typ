#import "/template/manual.typ": *

= 動畫 <sec-animation>

#changed("1.4.0", label: "Animator")[`Animator` 以 #pkg("Pillow") 產生 GIF 參數變動動畫，不需要 `ffmpeg`]
#changed("1.4.0", label: "Animator")[新增效用參數、價格、所得與僅顯示預算線的 GIF 範例]
#changed("1.6.0", label: "Animator")[動畫範例移到 `examples/scripts/animation.py`]
#changed("2.0.0b1", label: "Animator")[#modify[移至 `utility_viz.core.animation`]]

`Animator` 依指定的參數序列呼叫繪圖函數，將回傳的 `Canvas` 或 `Figure` 匯出為 GIF。使用前需安裝 `animation` 選用依賴（詳見#ref(<sec-extras>)）。#modify[從 `utility_viz.core.animation` 匯入；1.x 為 `econ_viz.animation`。]

#api(("Animator",), added: "v1.4.0", syntax: [
  #raw("Animator(")#meta("draw")#raw(", frames=")#meta("values")#raw(").save(")#meta("path")#raw(
    ", fps=12, dpi=120, loop=0)",
  )
])[
  依序將 `frames` 的值傳入 `draw`，每次回傳的圖形對應一個影格。

  - `save()` 使用 #pkg("Pillow")，不需要 `ffmpeg`。
  - 匯出前將影格合成至白色背景，避免殘影。
  - `fps`、`dpi` 與 `loop` 分別設定影格率、解析度與循環次數。
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

`examples/scripts/animation.py` 提供四種範例#footnote[各範例均包含 Cobb-Douglas、CES、完全替代與完全互補模型。]：

- 參數變動：固定價格與所得，調整效用函數參數。
- 價格變動：固定效用函數與 $p_y$，調整 $p_x$，呈現預算線旋轉，寫法見上例。
- 所得變動：固定效用函數與價格，調整所得，呈現預算線平移。
- 預算線變動：僅顯示預算線，省略效用圖層。

四種範例的差異只在於 `draw()` 每次固定哪些值、調整哪個值。以參數變動為例，將上例的 `draw()` 改為接收 `alpha`，價格固定為 $p_x = 2$：

```python
def draw(alpha: float) -> Canvas:
    model = CobbDouglas(alpha=alpha, beta=1.0 - alpha)
    eq = solve(model, px=2.0, py=2.0, income=20.0)
    ...

Animator(draw, frames=np.linspace(0.1, 0.9, 45)).save("parameter_sweep.gif")
```

所得變動將 `draw()` 的引數改為 `income`，並把該值傳入 `add_budget()` 與 `solve()`。只呈現預算線時，省略 `add_utility()` 與 `add_equilibrium()`。

#ref(<fig-sweep-param>)至#ref(<fig-sweep-income>)各節錄四個影格。

#fig("/figures/animation/parameter_sweep.svg", width: 94%, caption: [
  參數變動。
]) <fig-sweep-param>

#fig("/figures/animation/price_sweep.svg", width: 94%, caption: [
  價格變動。
]) <fig-sweep-price>

#fig("/figures/animation/income_sweep.svg", width: 94%, caption: [
  所得變動。
]) <fig-sweep-income>

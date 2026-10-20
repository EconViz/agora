#import "/template/manual.typ": *

= Animation <sec-animation>

#changed("1.4.0", label: "Animator")[`Animator` produces GIF parameter sweeps with #pkg("Pillow"), without `ffmpeg`]
#changed("1.4.0", label: "Animator")[GIF examples for utility-parameter, price, income and budget-only sweeps]
#changed("1.6.0", label: "Animator")[Animation examples moved to `examples/scripts/animation.py`]
#changed("2.0.0b1", label: "Animator")[Moved to `utility_viz.core.animation`]

`Animator` calls a drawing function over a sequence of parameter values and
exports the returned `Canvas` or `Figure` objects as a GIF. It needs the
`animation` extra (@sec-extras). Import it from
`utility_viz.core.animation`; it was `econ_viz.animation` in 1.x.

#api(("Animator",), added: "v1.4.0", syntax: [
  #raw("Animator(")#meta("draw")#raw(", frames=")#meta("values")#raw(").save(")#meta("path")#raw(", fps=12, dpi=120, loop=0)")
])[
  Call `draw(value)` for every value in `frames` and write the canvases as
  the frames of a GIF.

  - `save()` uses #pkg("Pillow"), so no `ffmpeg` dependency is required.
  - Frames are composited onto white before export, which prevents
    frame-stacking artefacts.
  - `fps`, `dpi` and `loop` set the frame rate, resolution and loop count.
]

#example([```python
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

`examples/scripts/animation.py` provides four examples#footnote[Each example covers Cobb-Douglas, CES, perfect substitutes and perfect complements.]:

- Parameter sweep: prices and income fixed, a utility-function parameter
  varies.
- Price sweep: utility function and $p_y$ fixed, $p_x$ varies and the
  budget line rotates, as in the example above.
- Income sweep: utility function and prices fixed, income varies and the
  budget line shifts.
- Budget-only sweep: the budget line alone, without the utility layers.

The four differ only in which values `draw()` holds fixed and which one it
varies. For the parameter sweep, let the `draw()` above take `alpha` and fix
the price at $p_x = 2$:

```python
def draw(alpha: float) -> Canvas:
    model = CobbDouglas(alpha=alpha, beta=1.0 - alpha)
    eq = solve(model, px=2.0, py=2.0, income=20.0)
    ...

Animator(draw, frames=np.linspace(0.1, 0.9, 45)).save("parameter_sweep.gif")
```

For the income sweep, `draw()` takes `income` and passes it to
`add_budget()` and `solve()`. For the budget line alone, leave out
`add_utility()` and `add_equilibrium()`.

#ref(<fig-sweep-param>) to #ref(<fig-sweep-income>) each show four frames.

#example([```python
import numpy as np

from utility_viz import Canvas, Config, levels, solve
from utility_viz.core.animation import Animator
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # figure settings


def draw(alpha: float) -> Canvas:
    """One frame: the weight on x is alpha, the weight on y is 1 - alpha."""
    model = CobbDouglas(alpha=alpha, beta=1.0 - alpha)
    eq = solve(model, px=2.0, py=2.0, income=20.0)
    cvs = Canvas(x_max=14, y_max=12, x_label="$x_1$", y_label="$x_2$")
    cvs.add_utility(model, levels=levels.around(eq.utility, n=5))
    cvs.add_budget(2.0, 2.0, 20.0, fill=True)
    cvs.add_equilibrium(eq, show_ray=True)
    return cvs


Animator(draw, frames=np.linspace(0.1, 0.9, 45)).save("parameter_sweep.gif", fps=12, dpi=120)
```])

#fig("/figures/animation/parameter_sweep.svg", width: 94%, caption: [
  Parameter sweep $alpha$ varies with $beta = 1 - alpha$
]) <fig-sweep-param>

Each figure below shows four frames of its GIF, which has 45.

#example([```python
import numpy as np

from utility_viz import Canvas, Config, levels, solve
from utility_viz.core.animation import Animator
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # figure settings

model = CobbDouglas(alpha=0.5, beta=0.5)
# same curves in every frame
fixed = levels.around(solve(model, px=2.0, py=2.0, income=20.0).utility, n=5)


def draw(px: float) -> Canvas:
    """One frame: the price of x is px."""
    eq = solve(model, px=px, py=2.0, income=20.0)
    cvs = Canvas(x_max=14, y_max=12, x_label="$x_1$", y_label="$x_2$")
    cvs.add_utility(model, levels=fixed)
    cvs.add_budget(px, 2.0, 20.0, fill=True)
    cvs.add_equilibrium(eq, show_ray=True)
    return cvs


Animator(draw, frames=np.linspace(1.0, 6.0, 45)).save("price_sweep.gif", fps=12, dpi=120)
```])

#fig("/figures/animation/price_sweep.svg", width: 94%, caption: [
  Price sweep
]) <fig-sweep-price>

#example([```python
import numpy as np

from utility_viz import Canvas, Config, levels, solve
from utility_viz.core.animation import Animator
from utility_viz.models import CobbDouglas

Config.load("manual.toml").use()  # figure settings

model = CobbDouglas(alpha=0.5, beta=0.5)
# same curves in every frame
fixed = levels.around(solve(model, px=2.0, py=2.0, income=20.0).utility, n=5)


def draw(income: float) -> Canvas:
    """One frame: income is `income`."""
    eq = solve(model, px=2.0, py=2.0, income=income)
    cvs = Canvas(x_max=14, y_max=12, x_label="$x_1$", y_label="$x_2$")
    cvs.add_utility(model, levels=fixed)
    cvs.add_budget(2.0, 2.0, income, fill=True)
    cvs.add_equilibrium(eq, show_ray=True)
    return cvs


Animator(draw, frames=np.linspace(8.0, 36.0, 45)).save("income_sweep.gif", fps=12, dpi=120)
```])

#fig("/figures/animation/income_sweep.svg", width: 94%, caption: [
  Income sweep
]) <fig-sweep-income>

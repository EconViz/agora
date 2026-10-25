#import "/template/manual.typ": *

= Adding a figure <sec-adding>

Which figures exist is decided by the issues and milestones of the repository. Statistics charts and box-and-arrow flowcharts are not drawn. A new figure follows five steps.

+ *Model.* Put the equations in a frozen dataclass in `micro_viz/<topic>.py`. Check the inputs and raise a subclass of the package's errors. No renderer is imported.
+ *Builder.* Write `micro_viz/visuals/<topic>.py`. `Plane` collects curves, guides, points, marks, regions and arrows with stable layer ids (`micro.<prefix>.<kind>.<n>`).
+ *Text.* Add the words to `locale/labels.json` in all three languages. Never write display text in the builder.
+ *Export and example.* Add the names to `micro_viz/__init__.py`, `visuals/__init__.py` and `tests/test_package.py`; write `examples/scripts/<topic>.py` with the shared `parser` and `Session` from `common.py`, so ranges and options are arguments.
+ *Tests and changelog.* Test the model, that a changed parameter changes the figure, that `title=None` draws no title, that labels find free places, and that the example runs.

```python
from micro_viz.visuals.plane import Plane, linear


def demand_canvas(
    intercept: float, slope: float, x_max: float, *, title: str | None = None
):
    plane = Plane(
        prefix="demo",
        x_label="Q",
        y_label="p",
        x_max=x_max,
        y_max=intercept,
        title=title,
    )
    plane.line(linear(intercept, -slope, x_max), plane.t("monopoly.demand"))
    return plane.finish()
```

== The plane kit <sec-plane>

#api(("Plane",), syntax: [
  ```python
  Plane(
      *,
      prefix,
      x_label,
      y_label,
      x_max,
      y_max,
      theme=None,
      labels=None,
      title=None,
      margin=0.1,
      y_range=None,
      size=(6.0, 6.0),
      dpi=150,
  )
  ```
])[
  One plane diagram in `micro_viz.visuals.plane`. Its methods add layers with stable ids built from `prefix`; `finish()` returns the `Canvas`.
]

#param("line(points, name=None, *, role=\"micro.curve.marginal\", at=1.0)")[A curve through `points`, named at the fraction `at` along it (1 is the right end).]
#param("thin(points, name=None, *, at=1.0)")[A curve after a change: thin and solid.]
#param("guide(a, b)")[A dashed guide between two points.]
#param("dot(point)")[A dot.]
#param("point(x, y, *, xtext=None, ytext=None, name=None, marker=True)")[A dot with dashed guides to the axes and the given axis marks.]
#param("xmark(x, text)")[A mark on the horizontal axis.]
#param("ymark(y, text)")[A mark on the vertical axis.]
#param("area(polygon, name=None, *, shade=\"mid\")")[A shaded region, optionally named inside it.]
#param("arrow(a, b, *, rotate=False, label=None)")[A solid movement arrow: straight for a shift, curved with `rotate` for a slope change.]
#param("t(key, **fields)")[The built-in (or overridden) text for a label id.]
#param("finish()")[The finished `Canvas`.]

#api(("linear",), syntax: [
  ```python
  linear(intercept, slope, x_max, x_min=0.0)
  ```
])[
  The segment $y = "intercept" + "slope" dot x$ from `x_min` to `x_max`, as two points.
]

== Conventions

- A changed curve is a thin solid line, never dashed. A parallel shift is a straight arrow from the old point onto the new curve; a curved arrow means rotation.
- Curve names sit at the line end, point labels beside the point, and nothing overlaps.
- Direction logic of shifts stays in `visuals/movement.py`.
- The theme is always on white. The examples use `manual`.

== Checks

```bash
uv run ruff check . && uv run ruff format --check .
uv run mypy
uv run pytest
```

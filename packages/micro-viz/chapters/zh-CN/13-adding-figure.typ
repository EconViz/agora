#import "/template/manual.typ": *

= 添加图形 <sec-adding>

有哪些图形由保存库的议题与里程碑决定。统计图与方块加箭头的流程图不在绘制范围内。添加一张图分五个步骤。

+ *模型。* 把方程序放进 `micro_viz/<topic>.py` 的冻结数据类别，检查输入，并抛出套件例外的子类别。不引入任何绘图器。
+ *绘图函数。* 撰写 `micro_viz/visuals/<topic>.py`。`Plane` 以稳定的图层编号（`micro.<prefix>.<kind>.<n>`）收集曲线、辅助线、点、标记、区域与箭头。
+ *文本。* 把文本以三种语言加入 `locale/labels.json`。绘图函数中不写显示用的文本。
+ *导出与范例。* 把名称加入 `micro_viz/__init__.py`、`visuals/__init__.py` 与 `tests/test_package.py`；以 `common.py` 的共用 `parser` 与 `Session` 撰写 `examples/scripts/<topic>/<script>.py`，让范围与选项成为参数。
+ *测试与变更记录。* 测试模型、改变参数会改变图形、`title=None` 不画标题、标签找得到空位，以及范例可以运行。

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

== 平面工具组 <sec-plane>

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
  `micro_viz.visuals.plane` 中的一张平面图。它的方法以 `prefix` 为基础加入有稳定编号的图层；`finish()` 回传 `Canvas`。
]

#param("line(points, name=None, *, role=\"micro.curve.marginal\", at=1.0)")[经过 `points` 的曲线，名称放在沿曲线 `at` 的比例处（1 是右端）。]
#param("thin(points, name=None, *, at=1.0)")[变动后的曲线：细实线。]
#param("guide(a, b)")[两点之间的虚线辅助线。]
#param("dot(point)")[一个点。]
#param("point(x, y, *, xtext=None, ytext=None, name=None, marker=True)")[一个点，附有通到座标轴的虚线辅助线与给定的轴上记号。]
#param("xmark(x, text)")[横轴上的记号。]
#param("ymark(y, text)")[纵轴上的记号。]
#param("area(polygon, name=None, *, shade=\"mid\")")[上色的区域，可在区域内标示名称。]
#param("arrow(a, b, *, rotate=False, label=None)")[实线的移动箭头：缺省为直线表示平行移动，`rotate` 为弯箭头表示斜率改变。]
#param("t(key, **fields)")[标签编号对应的内置（或已取代的）文本。]
#param("finish()")[完成的 `Canvas`。]

#api(("linear",), syntax: [
  ```python
  linear(intercept, slope, x_max, x_min=0.0)
  ```
])[
  从 `x_min` 到 `x_max` 的线段 $y = "intercept" + "slope" dot x$，以两个点表示。
]

== 惯例

- 变动后的曲线是细实线，不用虚线。平行移动是从旧点指向新曲线的直箭头；弯箭头表示转动。
- 曲线名称放在线的末端，点的标签放在点旁，任何东西都不重叠。
- 移动方向的逻辑留在 `visuals/movement.py`。
- 主题一律在白底上。范例使用 `manual`。

== 检查

```bash
uv run ruff check . && uv run ruff format --check .
uv run mypy
uv run pytest
```

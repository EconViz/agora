#import "/template/manual.typ": *

= 添加图形 <sec-adding>

有哪些图形由保存库的议题与里程碑决定。统计图与方块加箭头的流程图不在绘制范围内。添加一张图分五个步骤。

+ *模型。* 把方程序放进 `micro_viz/<topic>.py` 的冻结数据类别，检查输入，并抛出套件例外的子类别。不引入任何绘图器。
+ *绘图函数。* 撰写 `micro_viz/visuals/<topic>.py`。`Plane` 以稳定的图层编号（`micro.<prefix>.<kind>.<n>`）收集曲线、辅助线、点、标记、区域与箭头。
+ *文本。* 把文本以三种语言加入 `locale/labels.json`。绘图函数中不写显示用的文本。
+ *导出与范例。* 把名称加入 `micro_viz/__init__.py`、`visuals/__init__.py` 与 `tests/test_package.py`；以 `common.py` 的共用 `parser` 与 `Session` 撰写 `examples/scripts/<topic>.py`，让范围与选项成为参数。
+ *测试与变更记录。* 测试模型、改变参数会改变图形、`title=None` 不画标题、标签找得到空位，以及范例可以运行。

```python
from micro_viz.visuals.plane import Plane, linear, sample


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

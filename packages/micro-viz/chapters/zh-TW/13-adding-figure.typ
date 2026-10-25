#import "/template/manual.typ": *

= 新增圖形 <sec-adding>

有哪些圖形由儲存庫的議題與里程碑決定。統計圖與方塊加箭頭的流程圖不在繪製範圍內。新增一張圖分五個步驟。

+ *模型。* 把方程式放進 `micro_viz/<topic>.py` 的凍結資料類別，檢查輸入，並拋出套件例外的子類別。不引入任何繪圖器。
+ *繪圖函式。* 撰寫 `micro_viz/visuals/<topic>.py`。`Plane` 以穩定的圖層編號（`micro.<prefix>.<kind>.<n>`）收集曲線、輔助線、點、標記、區域與箭頭。
+ *文字。* 把文字以三種語言加入 `locale/labels.json`。繪圖函式中不寫顯示用的文字。
+ *匯出與範例。* 把名稱加入 `micro_viz/__init__.py`、`visuals/__init__.py` 與 `tests/test_package.py`；以 `common.py` 的共用 `parser` 與 `Session` 撰寫 `examples/scripts/<topic>.py`，讓範圍與選項成為參數。
+ *測試與變更記錄。* 測試模型、改變參數會改變圖形、`title=None` 不畫標題、標籤找得到空位，以及範例可以執行。

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

== 平面工具組 <sec-plane>

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
  `micro_viz.visuals.plane` 中的一張平面圖。它的方法以 `prefix` 為基礎加入有穩定編號的圖層；`finish()` 回傳 `Canvas`。
]

#param("line(points, name=None, *, role=\"micro.curve.marginal\", at=1.0)")[經過 `points` 的曲線，名稱放在沿曲線 `at` 的比例處（1 是右端）。]
#param("thin(points, name=None, *, at=1.0)")[變動後的曲線：細實線。]
#param("guide(a, b)")[兩點之間的虛線輔助線。]
#param("dot(point)")[一個點。]
#param("point(x, y, *, xtext=None, ytext=None, name=None, marker=True)")[一個點，附有通到座標軸的虛線輔助線與給定的軸上記號。]
#param("xmark(x, text)")[橫軸上的記號。]
#param("ymark(y, text)")[縱軸上的記號。]
#param("area(polygon, name=None, *, shade=\"mid\")")[上色的區域，可在區域內標示名稱。]
#param("arrow(a, b, *, rotate=False, label=None)")[實線的移動箭頭：預設為直線表示平行移動，`rotate` 為彎箭頭表示斜率改變。]
#param("t(key, **fields)")[標籤編號對應的內建（或已取代的）文字。]
#param("finish()")[完成的 `Canvas`。]

#api(("linear",), syntax: [
  ```python
  linear(intercept, slope, x_max, x_min=0.0)
  ```
])[
  從 `x_min` 到 `x_max` 的線段 $y = "intercept" + "slope" dot x$，以兩個點表示。
]

== 慣例

- 變動後的曲線是細實線，不用虛線。平行移動是從舊點指向新曲線的直箭頭；彎箭頭表示轉動。
- 曲線名稱放在線的末端，點的標籤放在點旁，任何東西都不重疊。
- 移動方向的邏輯留在 `visuals/movement.py`。
- 主題一律在白底上。範例使用 `manual`。

== 檢查

```bash
uv run ruff check . && uv run ruff format --check .
uv run mypy
uv run pytest
```

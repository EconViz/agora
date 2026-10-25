#import "/template/manual.typ": *

= 快速開始 <sec-quickstart>

畫一張圖分兩步：建立模型，再把模型的結果交給 `micro_viz` 的繪圖函式。

```python
from micro_viz import CubicCost, analyze_costs, unit_cost_canvas

cost = CubicCost(fixed_cost=50, linear=36, quadratic=-8, cubic=0.6)
analysis = analyze_costs(cost, output_range=(1, 11))

unit_cost_canvas(analysis).save("unit_cost.svg")
```

#fig("/figures/costs/unit_cost.zh-TW.svg", width: 46%, caption: [
  單位成本曲線
]) <fig-quick-unit-cost>

`save()` 依副檔名寫出 PNG、SVG 或 PDF。模型不可變，不畫圖也能回答問題：

```python
analysis.minimum_average_total_cost    # 最低 ATC 與其產量
cost.marginal_cost(5.0)                # 某一產量的 MC
```

== 標題、標籤與設定

- `title=None` 不畫標題，`title="..."` 設定標題。
- 內建文字（座標軸標題、曲線名稱、點名）是語系表的標籤編號；`labels={"id": "text"}` 可取代其中任何一個（參見 @sec-labels）。
- 顏色、線寬、字型與大小來自主題與共用 `econ-viz.toml` 的 `[micro]` 表（參見 @sec-settings），繪圖程式碼不含這些值。
- 範圍、產量標記與取樣數等數字是繪圖函式的參數。

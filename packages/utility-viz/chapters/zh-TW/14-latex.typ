#import "/template/manual.typ": *

= #LaTeX 解析 <sec-latex>

#api(("parse_latex",), syntax: [#raw("parse_latex(")#meta("expression")#raw(")")])[
  將 #LaTeX 效用函數解析為模型，回傳值可用於 `solve()`、`Canvas` 或其他接受模型的 API。

  ```python
  from utility_viz import parse_latex

  model = parse_latex(r"x^{0.4} y^{0.6}")  # CobbDouglas(alpha=0.4, beta=0.6)
  model = parse_latex(r"\min(2x, 3y)")     # Leontief(a=2.0, b=3.0)
  model = parse_latex(r"2x + 3y")          # PerfectSubstitutes(a=2.0, b=3.0)
  ```
]

== 支援的形式

支援的輸入形式參見#ref(<tab-latex>)。省略的係數或指數預設為 1。

#tbl(caption: [支援的效用函數。])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([類型], [格式], [範例]),
    [Cobb-Douglas],
    [`x^{α} y^{β}` 或 `x^α y^β`],
    [`x^{0.3} y^{0.7}`],
    [完全互補],
    [`\min(ax, by)` 或 `min(ax, by)`],
    [`\min(2x, y)`],
    [完全替代],
    [`ax + by`],
    [`3x + 1.5y`],
    [CES],
    [`(αx^ρ + βy^ρ)^{1/ρ}`],
    [`(0.4x^{-0.5}+0.6y^{-0.5})^{-2}`],
  )
] <tab-latex>

可省略開頭的 `U =` 或 `u(x, y) =`：

```text
U(x,y) = x^{0.5} y^{0.5}
U = x^{0.5} y^{0.5}
x^{0.5} y^{0.5}
```

#fig("/figures/latex/leontief.svg", width: 42%, caption: [
  Leontief 範例。
])

#fig("/figures/latex/perfect_substitutes.svg", width: 42%, caption: [
  完全替代輸入範例。
])

== 錯誤處理

無法解析時會拋出 `utility_viz.ParseError`，錯誤訊息包含支援的格式：

```python
from utility_viz import ParseError, parse_latex

try:
    model = parse_latex(r"x^2 + y^2")
except ParseError as e:
    print(e)

# Unrecognised LaTeX utility function: 'x^2 + y^2'
# Supported forms:
#   Cobb-Douglas       : x^{alpha} y^{beta}
#   Leontief           : \min(ax, by)
#   Perfect Substitutes: ax + by
#   CES                : (alpha x^{rho} + beta y^{rho})^{1/rho}
```

== 在命令列工具中使用

`utility-viz plot --latex` 使用相同的解析器，接受相同的輸入格式（詳見#ref(<sec-cli-plot>)）：

```bash
utility-viz plot --latex "x^{0.4} y^{0.6}" --px 2 --py 3 --income 30 -o out.png
```

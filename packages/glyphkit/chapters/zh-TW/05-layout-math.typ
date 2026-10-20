#import "/template/manual.typ": *

= 文字與數學式排版 <sec-layout-math>

== 段落與測量

#api(("layout_paragraph",))[處理每個文字片段的字形，依 Unicode 合法換行位置分行，再回傳不可變的 `TextLayout`。]
#api(("TextMeasurement",))[不必實際繪圖，就能取得邏輯與墨跡範圍、基線、行數及溢位。]
#api(("LineLayout",))[一行的排版結果，包括字形列、基線、字幅、範圍、原文區段與是否明確換行。]

`TextStyle` 包含字族、字級、字重、斜體、語言、方向、字距與 OpenType 功能。同一段可以混用樣式和書寫系統。設定 `max_width` 時，會在 Unicode 換行演算法定義的合法位置換行 #citep(<unicode-linebreak2026>)；不設定則排成不受寬度限制的單行。

== 結構化數學式

#example(```python
from glyphkit import FontLibrary, FontSource
from glyphkit.math import MathStyle, parse_math

library = FontLibrary.from_sources(
    (FontSource.path("fonts/STIXTwoMath-Regular.otf"),)
)
formula = parse_math(r"U(x_1, x_2) = x_1^\alpha x_2^{1-\alpha}")
box = library.layout_math(formula, style=MathStyle(18, ("STIX Two Math",)))
print(box.bounds)
```)

#api(("parse_math",))[把支援的類 LaTeX 輸入解析成結構化語法樹，涵蓋符號、上下標、分數、根號、定界符號、矩陣、重音與上下限。]
#api(("MathStyle",))[控制數學字族、字級、上下標層級、英文字母斜體、上下標比例與 OpenType MATH 常數自訂值。]
#api(("MathBox",))[數學排版樹中的一個節點，包含範圍、基線、子節點原點、字形排版與可繪製線條。]

這是一套定義清楚的類 LaTeX 輸入子集，不是 TeX 直譯器。字型專屬的常數與字形變體來自 OpenType MATH 表 #citep(<opentype-math2025>)。不認得的指令或錯誤群組會拋出 `MathSyntaxError`。從 1.0.0b2 起，`MathStyle` 可覆寫上下標縮放、具名數學常數，以及英文字母使用的斜體樣式。

#fig("/figures/math/utility.svg", width: 56%, caption: [
  以 OpenType MATH 度量與精確字形輪廓排出的 Cobb–Douglas 效用函數
]) <fig-glyph-math>

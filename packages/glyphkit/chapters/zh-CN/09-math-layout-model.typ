#import "/template/manual.typ": *

= OpenType 数学排版模型 <sec-glyph-math-model>

== 数学公式的排版树

GlyphKit 先把限定的数学语法解析成结构化语法树，再排成由数学排版框（`MathBox`）组成的树。字形、子框原点、范围、基线与横线彼此分开，因此渲染器不必实现 TeX 也能重现 @fig-glyph-math。

== 上下标

行间公式的基准字号为 $s$、`ScriptPercentScaleDown` 为 $r$ 时，上下标字号是 $s_1 = s r / 100$。第二层再使用 `ScriptScriptPercentScaleDown`。水平起点为 $x_("script") = w_("base") + k$，其中 $k$ 是斜体修正；垂直位置来自 `SuperscriptShiftUp` 与 `SubscriptShiftDown`。

== 分数、根号与极限

分子、分母宽度为 $w_n, w_d$ 时，分数宽度取 $w = max(w_n, w_d) + 0.2 s$，两者居中。分数线位于 `AxisHeight`，线宽至少为 $s / 1000$。根号横线放在被开方表达式的墨迹上缘加 `RadicalVerticalGap`；上下限与重音符号也优先使用 MATH 表中的具名字段。

== 自定义样式与数学常量

#api(("MathStyle",))[
  设置字号、字体族、层级、英文字母斜体，以及上下标比例与 MATH 常量的自定义值。自定义值采用 em 比例；字体表中的值则由字体单位换算。
]

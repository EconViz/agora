#import "/template/manual.typ": *

= OpenType 數學排版模型 <sec-glyph-math-model>

== 數學式的排版樹

GlyphKit 先把限定的數學語法解析成結構化語法樹，再排成由數學排版方框（`MathBox`）組成的樹。字形、子框原點、範圍、基線與橫線彼此分開，因此繪圖端不必實作 TeX 也能重現 @fig-glyph-math。

== 上下標

行間公式的基準字級為 $s$、`ScriptPercentScaleDown` 為 $r$ 時，上下標字級是 $s_1 = s r / 100$。第二層再用 `ScriptScriptPercentScaleDown`。水平起點為 $x_("script") = w_("base") + k$，其中 $k$ 是斜體修正；垂直位置來自 `SuperscriptShiftUp` 與 `SubscriptShiftDown`。

== 分數、根號與極限

分子、分母寬度為 $w_n, w_d$ 時，分數寬度取 $w = max(w_n, w_d) + 0.2 s$，兩者置中。分數線位於 `AxisHeight`，線寬至少為 $s / 1000$。根號橫線放在被開方式墨跡上緣加 `RadicalVerticalGap`；上下限與重音符號也優先使用 MATH 表中的具名欄位。

== 自訂樣式與數學常數

#api(("MathStyle",))[
  設定字級、字族、層級、英文字母斜體，以及上下標比例與 MATH 常數的自訂值。自訂值採 em 比例；字型表中的值則由字型單位換算。
]

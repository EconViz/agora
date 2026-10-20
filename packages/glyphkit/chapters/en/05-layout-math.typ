#import "/template/manual.typ": *

= Text layout and mathematics <sec-layout-math>

== Paragraphs and measurement

#api(("layout_paragraph",))[Shapes every span, wraps at legal Unicode break opportunities, and returns an immutable `TextLayout`.]
#api(("TextMeasurement",))[Summarises logical and ink bounds, baselines, line count, and overflow without drawing.]
#api(("LineLayout",))[One laid-out line with its runs, baseline, advance, bounds, source range, and explicit-ending status.]

`TextStyle` carries the font families, size, weight, slant, language, direction, spacing, and OpenType features. A paragraph may mix styles and scripts. Set `max_width` to wrap at Unicode line-break opportunities #citep(<unicode-linebreak2026>); leave it unset for one unconstrained line.

== Structured mathematics

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

#api(("parse_math",))[Parses the supported LaTeX-like subset into a structured tree of symbols, scripts, fractions, roots, delimiters, matrices, accents, and limits.]
#api(("MathStyle",))[Controls math families, size, script level, alphabetic slant, script scales, and OpenType MATH constant overrides.]
#api(("MathBox",))[One node in the laid-out math tree, containing bounds, baseline, child origins, glyph layouts, and drawable rules.]

This is a defined subset of LaTeX-like input, not a TeX interpreter. Its font-specific constants and glyph variants come from the OpenType MATH table #citep(<opentype-math2025>). Unknown commands and malformed groups raise `MathSyntaxError`. In 1.0.0b2, `MathStyle` can override script scales, named math constants, and the slant used for alphabetic symbols.

#fig("/figures/math/utility.svg", width: 56%, caption: [
  A Cobb–Douglas utility function laid out with OpenType MATH metrics and exact glyph outlines
]) <fig-glyph-math>

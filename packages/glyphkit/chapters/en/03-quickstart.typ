#import "/template/manual.typ": *

= Quick start <sec-quickstart>

This example uses an explicit font file. GlyphKit snapshots its contents while the library is built, so later path changes do not alter the layout.

#example(```python
from glyphkit import FontLibrary, FontSource, Paragraph, TextSpan, TextStyle

library = FontLibrary.from_sources(
    (FontSource.path("fonts/SourceSans3-Regular.ttf"),)
)
family = library.faces[0].family
paragraph = Paragraph(
    (TextSpan("Utility U(x₁, x₂)", TextStyle((family,), 18)),),
    max_width=360,
)
layout = library.layout(paragraph)

print(layout.logical_bounds)
print(layout.lines[0].runs[0].glyphs[0])
```)

#api(("FontSource",), syntax: [#raw("FontSource") \
  #raw("FontSource.path(path)") \
  #raw("FontSource.bytes(data, label=...)")])[
  A caller-owned font source. Paths and streams are read when a `FontLibrary` is created; byte sources keep the supplied bytes.
]

#api(("FontLibrary",), syntax: [#raw("FontLibrary") \
  #raw("FontLibrary.from_sources(sources, *, generic_families={})")])[
  The main typography engine. Its face catalog, matching rules, and source identity are fixed after construction.
]

#api(("Paragraph",))[An immutable sequence of styled text spans plus optional width, height, alignment, indentation, and line settings.]
#api(("TextSpan",))[A source-text fragment paired with one `TextStyle`.]
#api(("TextStyle",))[Font families, size, weight, width, slant, language, direction, spacing, and OpenType features for a span.]
#api(("TextLayout",))[The immutable result of paragraph layout: lines, shaped runs, positioned glyphs, source ranges, bounds, baselines, overflow, and font uses.]

GlyphKit uses logical units, not pixels tied to a particular DPI. The consumer decides how those units map to its canvas.

#fig("/figures/layout/metrics-en.svg", width: 92%, floating: false, caption: [
  Baselines, width, and vertical font metrics
]) <fig-glyph-metrics>

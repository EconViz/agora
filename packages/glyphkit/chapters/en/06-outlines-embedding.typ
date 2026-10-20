#import "/template/manual.typ": *

= Outlines, subsets, and portable data <sec-outlines-embedding>

== Glyph geometry

#api(("GlyphOutline",))[An exact glyph outline: ordered path commands, bounds, and units per em.]
#api(("MoveTo",))[Starts a new contour at the given font-space point.]
#api(("LineTo",))[Adds a straight segment from the current point to its endpoint.]
#api(("QuadraticTo",))[Adds a quadratic Bézier segment with one control point and one endpoint.]
#api(("CubicTo",))[Adds a cubic Bézier segment with two control points and one endpoint.]
#api(("ClosePath",))[Closes the current contour by connecting it to its starting point.]

#api(("flatten",))[Approximates curved outline commands with line segments at a caller-selected tolerance.]
#api(("Polyline",))[One open or closed sequence of points returned by curve flattening.]

```python
glyph = layout.lines[0].runs[0].glyphs[0]
outline = library.outline(glyph)
```

== Permission-aware subsets

#api(("EmbeddingUse",))[Declares why the subset will be embedded, so font permissions can be enforced for that use.]
#api(("FontContainer",))[Selects the returned font container, such as OpenType or WOFF2.]
#api(("FontSubsetBundle",))[The complete subsetting result: portable fonts, source-to-subset mapping, warnings, and metadata.]
#api(("PortableFont",))[One permission-checked font payload with family, format, bytes, covered glyphs, and embedding metadata.]

```python
from glyphkit.embedding import EmbeddingUse, FontContainer

bundle = library.subset(
    layout,
    embedding_use=EmbeddingUse.WEB,
    container=FontContainer.WOFF2,
)
```

Restricted fonts are rejected. Unknown permissions are also rejected unless the caller passes an explicit override and records that decision. GlyphKit returns bytes and metadata; the consumer decides whether and where to write them.

== Serialization

#api(("to_data",))[Converts a supported immutable public value into versioned ordinary data suitable for JSON-like storage.]
#api(("from_data",))[Validates versioned data and reconstructs the corresponding public value within configured limits.]

#fig("/figures/outlines/glyph-g.svg", width: 30%, caption: [
  The exact Bézier outline and selected control polygons of a shaped glyph
]) <fig-glyph-outline>

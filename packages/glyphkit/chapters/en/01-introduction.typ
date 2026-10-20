#import "/template/manual.typ": *

= Introduction <sec-intro>

#changed("1.0.0b1")[First public beta: explicit font sources, Unicode shaping, paragraph and math layout, outlines, serialization, and permission-aware subsets]
#changed("1.0.0b2")[Added math metric overrides and companion italic or oblique faces]

#pkg("glyphkit") turns caller-provided fonts and text into immutable layout data. It selects faces, shapes Unicode, lays out paragraphs and mathematical expressions, measures text, extracts glyph outlines, and builds font subsets. A drawing package can consume the same result for SVG, HTML, raster output, or another backend.

GlyphKit does not draw, animate, create scenes, download fonts, interpret licenses, or write output files. Fonts enter through explicit paths, bytes, or streams. System font discovery exists, but it runs only when the caller asks for it.

== Where it fits

- Use GlyphKit when a renderer needs exact glyph positions, bounds, paths, or portable font bytes.
- Use #pkg("kinetickit") when those text assets need to be placed in a scene and animated.
- Keep the final renderer responsible for pixels, vector elements, files, and DPI.

The everyday workflow is: build a `FontLibrary`, describe text with `Paragraph` and `TextStyle`, call `layout()`, then pass the resulting `TextLayout` to a consumer. The following chapters keep that boundary visible.

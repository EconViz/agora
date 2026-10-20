#import "/template/manual.typ": *

= Coordinates, metrics, and bounds <sec-glyph-coordinates>

== Font units and layout scale

Font files store outlines and metrics in font units. If a face has $U$ units per em and the requested size is $s$, GlyphKit uses $lambda = s / U$. A font-space point $p = (x, y)$ reaches layout space as $lambda p$. A positioned glyph adds the shaping origin and offset:
$ p' = (x_g + delta_x, y_g + delta_y) + lambda p. $
@fig-glyph-metrics marks the baseline, $x$-height, ascender line, and descender line in font units. GlyphKit maps those values into layout space with $lambda$; width and depth are measured in the same coordinate system.

== Advances are not ink

The pen position after glyph $i$ is $x_(i+1) = x_i + a_i$, where $a_i$ is its shaped advance. The visible outline may begin before $x_i$ or extend beyond $x_(i+1)$. GlyphKit therefore reports both a logical box $L$ and an ink box $I$.

#definition(name: [Bounds union])[
  For non-empty axis-aligned boxes $B_j$, their union has $x_min = min_j x_(min,j)$, $y_min = min_j y_(min,j)$, $x_max = max_j x_(max,j)$, and $y_max = max_j y_(max,j)$.
]

== Choosing the correct box

Use logical bounds to align lines and reserve space. Use ink bounds for cropping, collision tests, and tight export. A renderer should keep the baseline explicit instead of inferring it from either rectangle.

== DPI enters only at the edge

GlyphKit does not choose pixels. A consumer exporting at $d$ dots per inch maps $q$ typographic points to $q d / 72$ pixels. Keeping this conversion outside the layout engine makes one `TextLayout` reusable in SVG, PDF, raster, and animation renderers.

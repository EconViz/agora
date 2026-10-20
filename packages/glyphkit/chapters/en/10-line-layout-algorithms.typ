#import "/template/manual.typ": *

= Line construction and spacing <sec-glyph-lines>

== Clusters and break opportunities

Paragraph layout begins with Unicode line-break opportunities, but never splits a shaped cluster. Glyphs sharing one source cluster form one atom. If atom advances are $a_i$ and the indent is $h$, the candidate width is $W = h + sum_i a_i$. A new atom wraps when adding it would exceed `max_width` and an earlier legal break exists.

== Tabs and indentation

At horizontal position $x$, a tab advances to the first configured stop greater than $x$. Without one, the default interval $T$ gives $Delta x = T - (x mod T)$. The first line uses `first_line_indent`; later lines use `hanging_indent`.

== Alignment and justification

For available width $M$ and line width $W$, start, centre, and end alignment use offsets $0$, $(M-W)/2$, and $M-W$. A justified non-final line distributes remaining width across eligible spaces:
$ delta = (M-W)/N_("space"). $
The extra amount changes advances, not glyph outlines.

== Vertical layout

With explicit line height $H$, adjacent baselines differ by $H$. Otherwise GlyphKit derives it from the largest style. `max_height` limits accepted lines and records vertical overflow instead of mutating glyph data.

#api(("Paragraph",))[Carries styled spans and the width, height, indentation, alignment, tab-stop, and line-height constraints used by the algorithm.]
#api(("LineLayout",))[Records one line's runs, advance, logical and ink bounds, baseline, source range, and ending status.]
#api(("TextMeasurement",))[Collects paragraph-wide bounds, baselines, line count, reading order, and horizontal or vertical overflow.]

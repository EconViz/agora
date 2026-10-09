#import "/template/manual.typ": *

= Region and point labels <sec-labels>

A label names something already drawn: a filled region or a point. Label
layers are drawn in deferred passes, after every other layer, so they can
see what they must avoid. Point labels are placed before region labels, and
every label placed becomes an obstacle for the ones after it.

#changed("0.3.0", label: "mosaickit")[Point labels are placed before region labels, so region callouts avoid them; label text is measured with its rotation]

== Region labels

#api(("RegionLabelLayer",), added: "0.2.0", syntax: [
  #raw("RegionLabelLayer(region, text, short_text=None, placement=\"auto\", style=None,") \
  #raw("                 stroke=Stroke(width=0.8), *, role=\"text\", ...)")
])[
  Names a filled region, given as the id of a `FillLayer` or as a polygon of
  at least three points. `stroke` styles the callout leader.
]

#param("placement=\"auto\"")[Inside the region when the text fits, centred on its pole (@def-pole), trying `short_text` second; otherwise a callout with `text`.]
#param("placement=\"inside\"")[As `"auto"`, but when neither text fits, `short_text` (or `text`) is centred on the pole regardless.]
#param("placement=\"callout\"")[Always a callout: unboxed text outside the region and a thin leader from the pole to the text.]

A text fits inside when its rectangle, padded by 2 pt on each side and
centred on the pole, lies in the region (@thm-rect-inside) and touches no
line, marker, text or other region. @fig-regions shows both outcomes.

#fig("/figures/labels/regions.pdf", width: auto, caption: [
  An inside label and a callout.
]) <fig-regions>

== Point labels

#api(("PointLabelLayer",), added: "0.3.0", syntax: [#raw("PointLabelLayer(point, text, style=None, *, role=\"text\", ...)")])[
  Names a point with text right beside it, with no leader. The point's
  _footprint_ is its marker, if a marker is drawn there, or the bare point.
  #changed("0.3.1")[A point label may sit inside a filled region that contains its point]
  #changed("0.3.2")[A region counts as the point's own only when the point is strictly inside it; a point on a region's edge keeps its label outside]
]

The label tries 16 directions around the footprint, at gaps of 4, 7, 11 and
16 pt from its edge, nearest gap first. Within a gap the directions are
tried in the order of @def-candidate-order (@fig-candidates), and the first
position that covers nothing wins; if none does, the one with the fewest
violations wins, earliest first, and a `LayoutWarning` names the layer. A
region the point lies strictly inside, more than 1.5 px from its edge, is
where the label belongs rather than an obstacle.

#definition(name: [Candidate order])[
  Number the directions $k = 0, dots, 15$ counter-clockwise from $+x$, at
  angles $2 pi k slash 16$. Point labels try them in increasing order of
  the key $(min(s, 16 - s), [s > 8])$ with $s = (k - 2) mod 16$: by angular
  distance from the upper-right direction $k = 2$, and among two directions
  at the same distance, the counter-clockwise one first.
] <def-candidate-order>

#fig("/figures/geometry/candidates.pdf", width: auto, caption: [
  The order in which directions are tried.
]) <fig-candidates>

#fig("/figures/labels/points.pdf", width: auto, caption: [
  Point labels beside their points.
]) <fig-points>

== Hard constraints

Both kinds of label obey the same rule: cover nothing. Obstacles are
collected from what is on the axes: line segments of paths, rectangles of
markers and text, and polygons of filled regions. The searches below are in
`mosaickit.layout.placement`, and all but `place_beside` are also exported
from `mosaickit.layout`; like the geometry they work in display pixels, and
`scale` converts their point-based gaps to pixels.

#api(("Obstacles", "Placement"), syntax: [
  #raw("Obstacles(segments=(), rects=(), polygons=())") \
  #raw("Placement(rect, leader, violations)")
])[
  What a label must avoid, and where it went: its rectangle, its leader
  segment (`None` for labels drawn without one) and how many constraints it
  breaks. `Obstacles.extended(segments=..., rects=...)` adds the label just
  placed.
  #changed("0.3.0")[`Placement.leader` may be `None`]
]

#definition(name: [Violations])[
  For a candidate rectangle $R$, obstacles $O$, plot bounds $B$ and a set
  of polygons $cal(P)$, the _violation count_ is
  $ V(R) = [R subset.eq.not B] + \#{s in O_"seg" : R inter s != emptyset}
    + \#{Q in O_"rect" : R inter Q != emptyset}
    + \#{P in cal(P) : R inter overline(P) != emptyset}, $
  where $[dot]$ is 1 for a true condition and 0 otherwise. A candidate
  _covers nothing_ when $V(R) = 0$.
] <def-violations>

Each term is computed exactly by @lem-rect-segment, by
`Rect.intersects` and by @cor-rect-overlap.

== Callouts

#api(("place_callout",), added: "0.2.0", syntax: [#raw("place_callout(polygon, size, obstacles, bounds, *, scale=1.0) -> Placement")])[
  Searches positions around a region for a callout of the given size. From
  the pole $o$, along 16 directions $r$, a candidate rectangle is put at
  distance `ray_exit(o, r, P)` plus a gap of 12, 24 or 40 pt (the near
  ring), anchored by the side or corner facing the pole so that it extends
  away from the region. Its leader runs from the pole to the rectangle's
  nearest point (@lem-nearest), stopping 2 pt short. A candidate is charged
  $V(R)$ (with the region itself among the polygons), plus one if its centre
  is not in open space, plus one for each line, text or other region its
  leader crosses after leaving its own region, plus one for each crossing
  it lies beyond (@def-beyond).
]

#definition(name: [Open space and crossings])[
  _Open space_ is the union of the connected free areas, on a 4 pt grid of
  the plot, that cover at least a tenth of it; smaller free areas are
  _pockets_, such as an unfilled strip between two shaded regions, and text
  there would seem to name the pocket. A _crossing_ of a region is a point
  $x$ where two obstacle segments cross properly (each passes strictly
  through the other) on or within 1.5 px of the region's boundary. A point
  $p$ lies _beyond_ $x$, seen from the pole $o$, when
  $(p - x) dot (x - o) > 0$.
] <def-beyond>

Past a crossing the lines diverge away from the region, and a label there
would sit next to where they extend instead of next to what it names. The
crossing point itself is found from the orientation tests.

#lemma(name: [Crossing point])[
  If $[a, b]$ and $[c, d]$ cross properly, they meet at the single point
  $a + t (b - a)$ with
  $ t = ((c - a) times (d - c)) / ((b - a) times (d - c)) in (0, 1), $
  where $u times v = u_x v_y - u_y v_x$.
] <lem-crossing>

#proposition(name: [Choice of a callout])[
  Order candidates by the key (charge, leader length), compared
  lexicographically, and enumerate them direction by direction, nearest gap
  first. If some candidate in the near ring has charge 0, `place_callout`
  returns the first such candidate with the shortest leader. Otherwise it
  also tries the far ring (gaps of 60 and 90 pt) and returns the first
  candidate with the smallest key over both rings. The result depends only
  on the arguments.
] <prop-callout>

When the returned charge is not zero, the renderer still draws the callout
there and emits a `LayoutWarning` naming the layer; enlarging the canvas or
shortening the text usually removes it.

#api(("fits_inside", "place_point_label", "place_beside"), syntax: [
  #raw("fits_inside(polygon, size, obstacles, bounds) -> Rect | None") \
  #raw("place_point_label(footprint, size, obstacles, bounds, *, scale=1.0) -> Placement") \
  #raw("place_beside(anchor, size, *, axis, direction, reach, obstacles, bounds, scale=1.0)")
])[
  The other searches: a rectangle centred on the pole if it fits and
  touches nothing but its own region; the point-label search above; and the
  search beside a brace tip, which tries gaps of 3 to 45 pt past the tip
  and slides along the span by up to `reach` in 3 pt steps, smallest shift
  first. `place_beside` returns the rectangle and its violation count. When
  a brace label is not free there, the renderer tries a callout from the tip
  and keeps whichever breaks fewer constraints.
  #changed("0.3.0")[`place_point_label` and `place_beside` added]
]

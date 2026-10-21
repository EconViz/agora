#import "/template/manual.typ": *

= Styles and colors <sec-styles>

== Sparse styles

Every style is a frozen dataclass whose fields may all be `None`. `None`
means inherit: the value comes from a style below it (@sec-themes). Falsy
values are not `None`, so `opacity=0`, `width=0` and
`LegendStyle(visible=False)` are explicit overrides.

#definition(name: [Sparse merge])[
  Let $a$ and $b$ be styles of the same type with fields $F$. The style
  $a triangle.r b$ (`a.merged_over(b)`) has, for each $phi in F$,
  $ (a triangle.r b)_phi = cases(a_phi & "if" a_phi != "None", b_phi & "otherwise".) $
  The empty style $epsilon$ has every field `None`. For style bundles the
  merge is taken slot by slot, a `None` slot acting as $epsilon$.
] <def-merge>

#proposition(name: [Merging is a monoid])[
  For styles $a, b, c$ of one type,
  (i) associativity states
  $ (a triangle.r b) triangle.r c = a triangle.r (b triangle.r c); $
  (ii) the empty style is an identity,
  $ epsilon triangle.r a = a triangle.r epsilon = a; $
  and (iii) merging is idempotent,
  $ a triangle.r a = a. $
  Field by field, $a_1 triangle.r dots.c triangle.r a_n$ takes the first
  value that is not `None`.
] <prop-monoid>

A stack of styles can therefore be merged in any grouping. The result acts
as a priority list: the first source that sets a field wins.

#api(("SparseStyle",), syntax: [#raw("style.merged_over(base)")])[
  The merge of @def-merge. Styles of different types raise `TypeError`.
]

== Style types

#api(("Stroke",), syntax: [
  #raw("Stroke(color=None, width=None, dash=None, arrow=None, opacity=None)")
])[
  Line styles. `width` is in points; `dash` is a `DashStyle` (`SOLID`,
  `DASHED`, `DOTTED`, `DASHDOT`); `arrow` is an `ArrowStyle` (`OPEN`,
  `TRIANGLE`, `FANCY`, `WEDGE`) drawn at the layer's `ArrowPlacement`
  (`START`, `END`, `BOTH`).
]

#changed("0.8.0", label: "DashStyle")[`DashStyle` and `ArrowStyle` accept short forms, so a package can use them as its own line and arrow style enums]
#api(("DashStyle",), syntax: [
  `DashStyle.SOLID`, `DASHED`, `DOTTED`, `DASHDOT`
])[
  Line patterns of a `Stroke`. The short forms `-`, `--`, `:` and `-.` are accepted too.
]

#param("SOLID", type: "DashStyle")[Solid line.]
#param("DASHED", type: "DashStyle")[Dashed line.]
#param("DOTTED", type: "DashStyle")[Dotted line.]
#param("DASHDOT", type: "DashStyle")[Dash-dot line.]

#api(("ArrowStyle",), syntax: [
  `ArrowStyle.OPEN`, `TRIANGLE`, `FANCY`, `WEDGE`
])[
  Arrowheads of a `Stroke`. `SIMPLE` is another name for `OPEN`, and the Matplotlib spellings `->` and `-|>` are accepted.
]

#param("OPEN", type: "ArrowStyle")[Open arrowhead.]
#param("TRIANGLE", type: "ArrowStyle")[Filled triangle.]
#param("FANCY", type: "ArrowStyle")[Curved, tapering arrowhead.]
#param("WEDGE", type: "ArrowStyle")[Thin wedge-shaped arrowhead.]

#api(("ArrowPlacement",), syntax: [
  `ArrowPlacement.START`, `END`, `BOTH`
])[
  Where a layer's arrowhead is drawn.
]

#param("START", type: "ArrowPlacement")[At the first point.]
#param("END", type: "ArrowPlacement")[At the last point.]
#param("BOTH", type: "ArrowPlacement")[At both ends.]

#api(("Fill",), syntax: [#raw("Fill(color=None, opacity=None, hatch=None)")])[
  Styles for region interiors. `hatch` is a Matplotlib hatch pattern such as
  `"//"`; `""` means no hatch.
]

#api(("Marker",), syntax: [#raw("Marker(color=None, size=None, shape=None, opacity=None, edge_color=None, edge_width=None)")])[
  Point-marker styles. As in Matplotlib's `scatter`, `size` is the area in
  square points (36 is a 6 pt disc). `shape` is a Matplotlib marker such as
  `"o"`, `"s"` or `"X"`.
]

#api(("TextStyle",), syntax: [#raw("TextStyle(color=None, size=None, font=None, weight=None, opacity=None, rotation=None)")])[
  Text styles. `size` is in points, `font` is a generic font (`"sans"`,
  `"serif"` or `"mono"`, @sec-fonts), `weight` is an integer from 1 to 1000,
  `"normal"` or `"bold"`, and `rotation` is in degrees counter-clockwise.
  `family`, a font-family name, still works but is deprecated: it draws
  through Matplotlib and ignores #pkg("glyphkit"). It will go in 1.0.
  #changed("0.9.0", label: "TextStyle")[`weight` is no longer deprecated]
  #changed("0.9.1", label: "TextStyle")[New `font` field; `family` is deprecated]
]

== Fonts <sec-fonts>

Text is set by #pkg("glyphkit") from font files. Three generic fonts name
them: `"sans"` (the default), `"serif"` and `"mono"`. MosaicKit starts with
DejaVu Sans, DejaVu Serif and DejaVu Sans Mono, the files Matplotlib ships.
It never searches the system for fonts, so any other face is a file you pass.

#api(("TextFonts",), syntax: [
  #raw("TextFonts(sans=None, serif=None, mono=None)")
])[
  Font files that replace the generic fonts. Each slot takes one file or a
  list; list every face it needs, such as a regular and a bold file. A style's
  `weight` picks the nearest listed face, and the order of the files is the
  order tried for a character the first one lacks. The slots you leave out
  keep the DejaVu defaults.
  #changed("0.9.0", label: "TextFonts")[Added; one list of files for sans]
  #changed("0.9.1", label: "TextFonts")[`serif` and `mono` slots; defaults to DejaVu]
]

#api(("MathFont",), syntax: [
  #raw("MathFont(path, italic=True)")
])[
  An OpenType math font such as STIX Two Math, Libertinus Math or Fira Math.
  The file needs a `MATH` table. `italic` sets single Latin and lowercase
  Greek letters in the italic alphabet, as TeX does. Without a math font,
  math in `$...$` is set by Matplotlib.
]

```python
from mosaickit import Canvas, CanvasSpec, Config, MathFont, TextFonts, TextLayer, TextStyle, use_config

fonts = TextFonts(serif=["fonts/Pagella-Regular.otf", "fonts/Pagella-Bold.otf"])
config = Config(fonts=fonts, math_font=MathFont("fonts/Pagella-Math.otf"))

with use_config(config):
    canvas = Canvas(CanvasSpec(x_range=(0, 1), y_range=(0, 1)))
    canvas.add(TextLayer((0.5, 0.5), "$u = x^{0.5}$", style=TextStyle(font="serif")))
```

The TikZ renderer maps `sans`, `serif` and `mono` to `\sffamily`, `\rmfamily`
and `\ttfamily`.
#changed("0.9.2", label: "TikZ")[`font` maps to the TeX font families]


#api(("LegendStyle",), syntax: [#raw("LegendStyle(visible=None, location=None, frame=None, size=None)")])[
  Legend styles, including a Matplotlib location such as `"best"` or
  `"upper right"`, a frame setting and the font size.
]

Sizes, widths and opacities are checked when a style is created: sizes must
be finite and non-negative, opacities in $[0, 1]$, rotation finite.

#tbl(caption: [Primitive defaults])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Style], [Values]),
    [`Stroke`], [`grey-800`, width 1.5, solid, opacity 1],
    [`Fill`], [`grey-200`, opacity 0.3, no hatch],
    [`Marker`], [`grey-800`, size 36, `"o"`, opacity 1, edge `grey-800` of width 0],
    [`TextStyle`], [`grey-900`, 12 pt, DejaVu Sans, normal weight, opacity 1, no rotation],
    [`LegendStyle`], [visible, location `"best"`, no frame, 10 pt],
  )
] <tab-primitive>

== Colors

#api(("Color", "TRANSPARENT"), syntax: [
  #raw("Color(red, green, blue, alpha=1.0)") \
  #raw("Color.from_hex(\"#RGB\" | \"#RRGGBB\" | \"#RRGGBBAA\")")
])[
  An immutable RGBA color with channels in $[0, 1]$. `channels` returns the
  four values, `from_channels()` builds one, and
  `to_hex(include_alpha=None)` writes `#RRGGBB`, adding `AA` when
  `include_alpha` is true, or by default when alpha is not 1.
  `TRANSPARENT` is `Color(0, 0, 0, 0)`.
]

#proposition(name: [Hex round trip])[
  For every string $h$ of the form `#RRGGBB` or `#RRGGBBAA` in hexadecimal
  digits, `Color.from_hex(h).to_hex(include_alpha=len(h) == 9)` equals $h$
  in upper case. A three-digit `#RGB` is read as `#RRGGBB`.
] <prop-hex>

A style `color` or `edge_color` takes a `Color`, a `"#hex"` string (parsed
at once) or any other string, which is kept as a _palette name_.

== Palettes

#api(("Palette", "DEFAULT_PALETTE"), added: "0.2.0", syntax: [#raw("Palette(name, colors)")])[
  A named table of colors. Values may be `Color`s or hex strings.
  `palette[name]` looks up a color and raises `ConfigurationError`, naming
  the palette, when the name is unknown. `name in palette` tests whether a
  name exists.
]

#tbl(caption: [`DEFAULT_PALETTE`])[
  #booktabs(
    columns: (auto, auto, 1fr),
    header: ([Name], [Value], [Used by the default theme for]),
    [`grey-900`], [`#222222`], [Text],
    [`grey-800`], [`#333333`], [Lines, markers, axes],
    [`grey-600`], [`#666666`], [Axis notes],
    [`grey-400`], [`#999999`], [Guides],
    [`grey-200`], [`#CCCCCC`], [Fills],
    [`grey-100`], [`#E6E6E6`], [],
    [`white`], [`#FFFFFF`], [The canvas background],
    [`blue`], [`#01A2D9`], [`primary`],
    [`red`], [`#E3120B`], [`secondary`],
    [`teal`], [`#00887D`], [`accent`],
  )
] <tab-palette>

Themes and styles name their colors, and the names are looked up in the
active palette (`Config.palette`) when a canvas builds its render plan, so
renderers only ever see concrete colors. Changing a palette entry recolors
every role that names it. A missing name raises
`ConfigurationError` at render time, naming the role, the style field and
the palette. A Python `Palette` replaces the default palette, so build it
from `DEFAULT_PALETTE.colors` to keep the names the built-in theme uses:

```python
from mosaickit import DEFAULT_PALETTE, Canvas, Config, Palette, use_config

brand = Palette("brand", {**DEFAULT_PALETTE.colors, "blue": "#0072B2"})
with use_config(Config(palette=brand)):
    canvas = Canvas()          # primary now draws in #0072B2
```

#changed("0.2.0", label: "DEFAULT_PALETTE")[Added: a grey ramp, `white`, `blue`, `red` and `teal`; the default theme takes its colors from it, so `primary`, `secondary` and `accent` become blue, red and teal]
#changed("0.3.0", label: "Palette")[Themes and styles refer to colors by palette name, resolved against `Config.palette` when the render plan is built; an unknown name raises `ConfigurationError` naming the role, field and palette]

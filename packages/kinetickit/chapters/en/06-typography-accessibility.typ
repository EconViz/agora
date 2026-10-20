#import "/template/manual.typ": *

= Typography and accessibility <sec-typography-accessibility>

== GlyphKit integration

#example(```python
from glyphkit import FontLibrary, FontSource
from kinetickit import Animation, Bounds2D, Scene2D, Text2D, Vec2
from kinetickit.integrations.glyphkit import GlyphKitTypography

library = FontLibrary.from_sources(
    (FontSource.path("fonts/SourceSans3-Regular.ttf"),)
)
typography = GlyphKitTypography(
    library,
    families=(library.faces[0].family,),
    size=48,
)
title = Text2D(
    id="title",
    asset=typography.asset("HELLO"),
    position=Vec2(1, 1),
    scale=0.05,
)
scene = Scene2D(title).bind(
    {"camera.view": Bounds2D(Vec2(0, 0), Vec2(10, 6))}
)
motion = title.animate.position.to(Vec2(4, 3), duration=1.5)
Animation(scene, motion).save("text.svg")
```)

#api(("GlyphKitTypography",))[A configured adapter that turns text or mathematics into renderer-neutral KineticKit `TextAsset` values.]
#api(("text_asset_from_layout",))[Converts an existing GlyphKit `TextLayout` into positioned paths, metrics, and optional portable font data.]
#api(("text_asset_from_math",))[Converts a GlyphKit `MathBox` tree, including glyphs and rules, into a KineticKit text asset.]

Installing KineticKit installs a compatible GlyphKit. Core KineticKit imports remain lazy: only `kinetickit.integrations.glyphkit` imports the typography package.

#fig("/figures/typography/glyphkit-text.svg", width: 92%, caption: [
  GlyphKit outlines embedded in a KineticKit animated SVG
]) <fig-kinetic-type>

== Semantics and reduced motion

#api(("Semantics",))[Per-node accessibility metadata: role, label, description, reading order, and decorative status.]
#api(("AccessibilityInfo",))[Animation-level title, description, language, and ordered semantic information.]
#api(("ReducedMotion",))[Specifies the representative static state and autoplay behaviour when reduced motion is requested.]

`ReducedMotion` corresponds to the web platform's `prefers-reduced-motion` user preference #citep(<mediaqueries5>); it is an authored alternative, not an automatic reduction in frame rate.

SVG and HTML preserve titles, descriptions, stable object ids, and per-node semantics. HTML adds keyboard-operable controls and an ordered object list. GIF cannot carry those runtime semantics, so accessibility output requires a text description and may include a representative PNG.

== Interaction

#api(("Event",))[A portable interaction trigger such as hover, click, focus, or playback progress.]
#api(("Binding",))[Connects one event to a data-only action and marks whether that interaction is required.]
#api(("InteractionSpec",))[The validated collection of bindings attached to an animation.]

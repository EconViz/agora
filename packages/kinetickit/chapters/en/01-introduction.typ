#import "/template/manual.typ": *

= Introduction <sec-intro>

#changed("1.0.0b1")[First public beta: deterministic timelines, 2D and 3D scenes, morphing, SVG, GIF and HTML output, interaction, accessibility, typography ports, and conformance tools]
#changed("1.0.0b2")[GlyphKit became a required dependency; added streaming GIF assembly from encoded PNG frames]

#pkg("kinetickit") is a domain-neutral animation engine. It owns scenes, motions, deterministic frame scheduling, renderer capabilities, interactions, accessibility metadata, and file export. Economics packages and other applications translate their own objects into ordinary KineticKit nodes.

One immutable scene and one motion can drive three outputs: animated SVG, streamed GIF, and self-contained interactive HTML. The same scene and time always produce the same snapshot; wall-clock timing and a particular renderer do not affect the model.

KineticKit does not import #pkg("mosaickit"), #pkg("utility-viz"), or another domain package. Font processing belongs to #pkg("glyphkit") and enters through one adapter described in #ref(<sec-typography-accessibility>).

#import "/template/manual.typ": *

= Output formats <sec-outputs>

#tbl(caption: [Built-in outputs])[
  #booktabs(
    columns: (auto, auto, 1fr),
    header: ([Format], [Capability], [What it keeps]),
    [Animated SVG], [`vector`], [Native 2D vectors; deterministic projected 3D],
    [GIF], [`raster`], [Streamed frames, up to 1200 DPI],
    [HTML], [`interactive`], [Player controls, interactions, native 2D or 3D presentation],
  )
]

#api(("ExportManifest",))[The immutable export report: format, generated files, dimensions, duration, preserved semantics, degradations, warnings, and network dependencies.]
#api(("available_formats",))[Returns the output formats currently available with the installed optional dependencies.]
#api(("export",))[The lower-level registry entry point for exporting an animation to a chosen format. Most callers use `Animation.save()`.]

#api(("RendererCapabilities",))[Declares which scene dimensions, interactions, typography features, and packaging modes a renderer supports.]
#api(("Requirements",))[The capabilities an animation needs after KineticKit analyses its scene, motion, interactions, and accessibility data.]
#api(("requirements_for",))[Computes an animation's `Requirements` before any destination file is written.]

Animated SVG uses SVG's vector scene model #citep(<svg2>) and declarative SMIL timing elements #citep(<smil3>). KineticKit writes explicit values and durations so the exported document does not depend on Python at playback time.

== GIF settings

#api(("GifSettings",))[Controls GIF frame rate, palette, dithering, looping, disposal, dimensions, and DPI.]
#api(("export_png_frames",))[Streams encoded PNG frames into a GIF without retaining every decoded frame in memory.]

GIF frame intervals below 10 ms are rejected. Timing is distributed in integer centiseconds while preserving the requested total duration. Expensive raster jobs issue `RenderCostWarning`; they do not lower the requested size or DPI silently.

== HTML packaging

`packaging="offline"` embeds runtime assets and has no network dependency. `packaging="compact"` references a pinned CDN asset and records that URL in the manifest. A no-JavaScript fallback remains available: 2D uses the embedded SVG, while 3D includes a static final-state SVG.

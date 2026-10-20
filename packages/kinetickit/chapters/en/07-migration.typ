#import "/template/manual.typ": *

= Migrating animation code <sec-migration>

MosaicKit and utility-viz previously owned small animation helpers. Their deprecated entry points remain for one release cycle, but new animation code should build KineticKit scenes and motions directly.

== From a parameter sweep

1. Give every source layer a stable id.
2. Write a depiction function that translates a layer into a KineticKit node.
3. Turn adjacent snapshots into `SceneTransition`s and join their motions with `then()`.
4. Export through `Animation.save()`.

KineticKit deliberately has no MosaicKit compatibility import. The adapter belongs in the consuming package, where the domain objects are understood.

== From a factory-style animator

Translate the returned objects with `adapt(objects, depict)`, then express changes with `node.animate.<property>.to(...)` or `SceneTransition.between()`. The exporter owns the file path, frame rate, DPI, and output-specific fallbacks.

== Font handling

Replace renderer-specific font paths with caller-owned `FontSource` values and a `FontLibrary`. Convert layouts through `GlyphKitTypography`; do not ask the scene model or an optional renderer to discover fonts.

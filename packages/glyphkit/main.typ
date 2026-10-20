// GlyphKit manual — shared entry point for every language edition.

#import "/template/manual.typ": *

#let edition = sys.inputs.at("edition", default: "en")
#show: manual.with(toml("manual.toml"), root: "/packages/glyphkit", edition: edition)

#let chapters = (
  "01-introduction",
  "02-installation",
  "03-quickstart",
  "04-fonts-shaping",
  "05-layout-math",
  "06-outlines-embedding",
  "07-coordinate-metrics",
  "08-bezier-geometry",
  "09-math-layout-model",
  "10-line-layout-algorithms",
  "11-reproducibility",
)

#for name in chapters {
  include "chapters/" + edition + "/" + name + ".typ"
}

#include "chapters/" + edition + "/changelog.typ"

#command-index()
#references(read("config/refs.bib", encoding: none))

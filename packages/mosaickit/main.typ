// MosaicKit manual — shared entry point for every language edition.

#import "/template/manual.typ": *

#let edition = sys.inputs.at("edition", default: "en")
#show: manual.with(toml("manual.toml"), root: "/packages/mosaickit", edition: edition)

#let chapters = (
  "01-introduction",
  "02-installation",
  "03-quickstart",
  "04-canvas",
  "05-layers",
  "06-annotations",
  "07-geometry",
  "08-labels",
  "09-styles",
  "10-themes",
  "11-parameters",
  "12-rendering",
)

#for name in chapters {
  include "chapters/" + edition + "/" + name + ".typ"
}

// Proofs of the statements in the chapters, then the back matter.
#show: appendix
#include "chapters/" + edition + "/a-proofs.typ"
#include "chapters/" + edition + "/changelog.typ"

#command-index()
#references(read("config/refs.bib", encoding: none))

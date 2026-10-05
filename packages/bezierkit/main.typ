// BezierKit manual — shared entry point for every language edition.

#import "/template/manual.typ": *

#let edition = sys.inputs.at("edition", default: "en")
#show: manual.with(toml("manual.toml"), root: "/packages/bezierkit", edition: edition)

#let chapters = (
  "01-introduction",
  "02-installation",
  "03-quickstart",
  "04-geometry",
  "05-curves",
  "06-operations",
  "07-paths",
  "08-construction",
  "09-fitting",
  "10-implicit",
  "11-export",
  "12-cli",
)

#for name in chapters {
  include "chapters/" + edition + "/" + name + ".typ"
}

// Proofs of the theorems stated in the chapters, then the back matter.
#show: appendix
#include "chapters/" + edition + "/a-proofs.typ"
#include "chapters/" + edition + "/a-proofs-b.typ"
#include "chapters/" + edition + "/changelog.typ"

#command-index()
#references(read("config/refs.bib", encoding: none))

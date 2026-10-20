// KineticKit manual — shared entry point for every language edition.

#import "/template/manual.typ": *

#let edition = sys.inputs.at("edition", default: "en")
#show: manual.with(toml("manual.toml"), root: "/packages/kinetickit", edition: edition)

#let chapters = (
  "01-introduction",
  "02-installation",
  "03-quickstart",
  "04-scenes-motion",
  "05-outputs",
  "06-typography-accessibility",
  "07-migration",
  "08-time-easing",
  "09-interpolation-transforms",
  "10-projection",
  "11-morphing",
  "12-sampling-encoding",
)

#for name in chapters {
  include "chapters/" + edition + "/" + name + ".typ"
}

#include "chapters/" + edition + "/changelog.typ"

#command-index()
#references(read("config/refs.bib", encoding: none))

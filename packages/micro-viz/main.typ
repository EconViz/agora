// micro-viz manual — single entry point for every language edition.
//
// Compiled from the repository root, which is Typst's --root:
//   make micro-viz              # English (default)
//   make micro-viz EDITION=zh-TW
//   typst compile --root . --input edition=zh-TW packages/micro-viz/main.typ
//
// Chapters live in chapters/<edition>/ with the same file names in every
// edition, so the list below is shared. Settings for this manual are in
// manual.toml; the shared template and its settings are in /template.

#import "/template/manual.typ": *

#let edition = sys.inputs.at("edition", default: "en")
#show: manual.with(toml("manual.toml"), root: "/packages/micro-viz", edition: edition)

#let chapters = (
  "01-introduction",
  "02-installation",
  "03-quickstart",
  "04-model-figure",
  "05-production-costs",
  "06-competition",
  "07-monopoly",
  "08-oligopoly",
  "09-inputs",
  "10-uncertainty",
  "11-settings",
  "12-labels",
  "13-adding-figure",
  "14-animation",
  "15-changelog",
)

#for name in chapters {
  include "chapters/" + edition + "/" + name + ".typ"
}

#command-index()
#references(read("config/refs.bib", encoding: none))

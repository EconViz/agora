// principle-viz manual — single entry point for every language edition.
//
// Compiled from the repository root, which is Typst's --root:
//   make principle-viz              # English (default)
//   make principle-viz EDITION=zh-TW
//   typst compile --root . --input edition=zh-TW packages/principle-viz/main.typ
//
// Chapters live in chapters/<edition>/ with the same file names in every
// edition, so the list below is shared. Settings for this manual are in
// manual.toml; the shared template and its settings are in /template.

#import "/template/manual.typ": *

#let edition = sys.inputs.at("edition", default: "en")
#show: manual.with(toml("manual.toml"), root: "/packages/principle-viz", edition: edition)

#let chapters = (
  "01-introduction",
  "02-installation",
  "03-quickstart",
  "04-markets",
  "05-discrete",
  "06-aggregation",
  "07-elasticity",
  "08-welfare",
  "09-taxes",
  "10-controls",
  "11-trade",
  "12-failures",
  "13-factor-markets",
  "14-ppf",
  "15-figures",
  "16-cli",
  "17-changelog",
)

#for name in chapters {
  include "chapters/" + edition + "/" + name + ".typ"
}

#command-index()
#references(read("config/refs.bib", encoding: none))

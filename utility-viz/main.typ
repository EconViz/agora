// utility-viz manual — single entry point for every language edition.
//
// Compiled from the repository root, which is Typst's --root:
//   make utility-viz              # English (default)
//   make utility-viz EDITION=zh-TW
//   typst compile --root . --input edition=zh-TW utility-viz/main.typ
//
// Chapters live in chapters/<edition>/ with the same file names in every
// edition, so the list below is shared. Settings for this manual are in
// manual.toml; the shared template and its settings are in /template.

#import "/template/manual.typ": *

#let edition = sys.inputs.at("edition", default: "en")
#show: manual.with(toml("manual.toml"), root: "/utility-viz", edition: edition)

#let chapters = (
  "01-introduction",
  "02-installation",
  "03-quickstart",
  "04-canvas",
  "05-figures",
  "06-models",
  "07-advanced",
  "08-analysis",
  "09-themes",
  "10-export",
  "11-cli",
  "12-animation",
  "13-widgets",
  "14-latex",
  "15-changelog",
)

#for name in chapters {
  include "chapters/" + edition + "/" + name + ".typ"
}

#command-index()
#references(read("config/refs.bib", encoding: none))

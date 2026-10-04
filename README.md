<p align="center">
  <img src="https://raw.githubusercontent.com/EconViz/econ-viz-docs/main/docs/assets/banner.svg" alt="Econ-Viz" width="480">
</p>

<p align="center">
  <a href="https://typst.app/"><img alt="Typst" src="https://img.shields.io/badge/Typst-0.15-181818?style=flat-square&color=181818&labelColor=f3f3f3"></a>
  <img alt="Editions" src="https://img.shields.io/badge/editions-en%20%7C%20zh--TW%20%7C%20zh--CN-181818?style=flat-square&color=181818&labelColor=f3f3f3">
  <a href="https://opensource.org/licenses/MIT"><img alt="License" src="https://img.shields.io/badge/License-MIT-181818?style=flat-square&color=181818&labelColor=f3f3f3"></a>
</p>

# agora

The printable reference manuals of the [EconViz](https://github.com/EconViz)
packages, gathered in one place, like the market square the name comes from.
Every manual is written in Typst and shares one template, laid out in the
l3doc / ctxdoc style: API names, version notes and parameters hang in a wide
left margin, and every change is tagged next to the feature it describes and
collected in a change history.

| Manual | Package | Editions |
|--------|---------|----------|
| [`packages/utility-viz/`](packages/utility-viz/) | [utility-viz](https://github.com/EconViz/utility-viz) 2.0.0b1 (formerly econ-viz) | English, 繁體中文, 简体中文 |
| [`packages/principle-viz/`](packages/principle-viz/) | [principle-viz](https://github.com/EconViz/principle-viz) 0.10.1 | English, 繁體中文, 简体中文 |

The published PDFs can be downloaded from [econ-viz.org](https://econ-viz.org/project/manual/).

## Requirements

- [Typst](https://typst.app/) 0.15 or later
- TeX Live or TinyTeX with TeX Gyre Pagella, TeX Gyre Heros, TeX Gyre Pagella
  Math and CMU Typewriter Text (`tlmgr install tex-gyre tex-gyre-math cm-unicode`)
- [uv](https://docs.astral.sh/uv/), only to regenerate figures
- For the Chinese editions, Kaiti SC / TC (see [Fonts](#fonts))

System fonts are ignored, so every machine builds the same PDF.

## Building

```bash
make                                  # utility-viz, English
make utility-viz EDITION=zh-TW        # one edition of one manual
make editions MANUAL=utility-viz      # every edition of one manual
make all                              # every edition of every manual
make watch MANUAL=utility-viz EDITION=zh-CN
make figures MANUAL=utility-viz       # regenerate packages/utility-viz/figures/
make publish MANUAL=utility-viz       # build every edition, copy to econ-viz-docs
make clean
```

PDFs are written to `build/<manual>/<manual>-<edition>.pdf`, for example
`build/utility-viz/utility-viz-zh-TW.pdf`. The Makefile finds the TeX fonts
through `kpsewhich`; if TeX Live is not on your `PATH`, pass
`TEXMFDIST=/path/to/texmf-dist`.

## Layout

| Path | Contents |
|------|----------|
| `template/manual.typ` | Page layout and the l3doc-style commands (`api`, `param`, `changed`, `fig`, `tbl`, `modify`, …) |
| `template/config/strings.toml` | Interface strings for each edition, shared by every manual |
| `template/config/fonts.toml` | Font stacks for each edition |
| `template/config/layout.toml` | Page geometry and paragraph settings |
| `fonts/` | CJK fonts (Noto Serif TC / SC; Kaiti is added locally) |
| `packages/<manual>/main.typ` | Entry point; `--input edition=<en\|zh-TW\|zh-CN>` picks the edition |
| `packages/<manual>/manual.toml` | Package, title, editions, authors, release dates, placeholder names, publish name |
| `packages/<manual>/chapters/<edition>/` | Chapter sources, with the same file names in every edition |
| `packages/<manual>/figures/` | Generated SVG figures, shared by all editions |
| `packages/<manual>/scripts/`, `config/` | Figure script and its settings, references (`refs.bib`) |
| `build/<manual>/` | Built PDFs (not tracked) |

## Adding a manual

1. Create `packages/<package>/` with a `manual.toml` (copy
   `packages/utility-viz/manual.toml`
   and change the keys), a `main.typ` and `chapters/<edition>/` for every
   entry in `editions`.
2. In `main.typ`, pass the config and the manual's directory to the template:

   ```typst
   #import "/template/manual.typ": *
   #show: manual.with(toml("manual.toml"), root: "/packages/<package>", edition: edition)
   ```

   The config is a plain dictionary, so `yaml("manual.yml")` works just as
   well. Figure paths such as `#fig("/figures/x.svg")` are resolved against
   `root`.
3. Run `make <package>`; `make all` picks up every directory under
   `packages/` that has a `manual.toml`.

## Publishing

The PDFs on econ-viz.org are served from
[econ-viz-docs](https://github.com/EconViz/econ-viz-docs). With both
repositories side by side, run

```bash
make publish MANUAL=utility-viz   # or add DOCS=/path/to/econ-viz-docs
```

to build every edition and copy it to `docs/assets/manual/` there under the
name set in `[publish]` of the manual's `manual.toml`, then commit and push
econ-viz-docs. `make publish` stops if Kaiti is missing, so the published PDFs
always use the same fonts as a local build.

## Continuous integration

[`.github/workflows/build.yml`](.github/workflows/build.yml) builds every
edition of every manual on each push and pull request, and fails on any Typst
warning other than the missing Kaiti. It only checks the sources; it
publishes nothing.

## Fonts

Noto Serif TC and Noto Serif SC ship in `fonts/` under the
[SIL Open Font License](fonts/OFL.txt).

Kaiti, used for emphasis in the Chinese editions, is licensed by Apple and is
not in this repository. On macOS, download **Kaiti SC** in Font Book; the
Makefile then finds it automatically. Otherwise, copy `Kaiti.ttc` into
`fonts/`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Report security issues as described in
[SECURITY.md](SECURITY.md).

## Authors

- Pin Yue Sung (corresponding author), Department of International Business,
  National Chengchi University
- Ling Tak Douglas Chung, Department of International Business, National
  Chengchi University

Questions about the manuals: <contact@econ-viz.org>.

## License

MIT © Pin Yue Sung. The bundled Noto fonts are under the SIL Open Font License 1.1.

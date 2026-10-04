# Contributing to agora

Thank you for helping improve the EconViz manuals. This guide covers the
build setup and the conventions every manual and edition follows.

## Setting up

```bash
git clone https://github.com/EconViz/agora.git
cd agora
make all
```

See the [README](README.md#requirements) for the required tools and fonts.
Run `uv sync` inside a manual's directory (e.g. `packages/utility-viz/`) before
`make figures MANUAL=<manual>` to install its package.

## How to contribute

- **Errors in the manual**: open an issue that names the edition, the page or
  section, and what is wrong.
- **Errors in a package itself**: report them in that package's repository,
  for example [EconViz/utility-viz](https://github.com/EconViz/utility-viz/issues).
- **Pull requests**: fork the repository, create a branch, and open a PR
  against `main`.

Before you submit a PR, check that `make all` finishes without warnings, and
review the pages you changed in every edition. Changes to `template/` affect
every manual: look through each of them.

## Keeping the editions in step

The editions of a manual share the same structure. A change in one chapter
goes into the same file in `chapters/en/`, `chapters/zh-TW/` and
`chapters/zh-CN/` of that manual:

- the same APIs, parameters, figures, tables and labels;
- the same `#changed(...)` entries, one per release note, placed next to the
  feature they describe;
- code, mathematics and cross-references unchanged across editions.

## Writing conventions

- Describe parameters, methods and returned fields with `#param(...)`, one per
  entry, never several in one sentence of prose.
- English uses British spelling.
- The Chinese editions follow [WRITING-STYLE-ZH.md](WRITING-STYLE-ZH.md).
  zh-CN is localised, not just converted to simplified characters.
- In CJK text, write a reference followed directly by a CJK character as
  `#ref(<label>)`; `@label` would swallow the following characters.
- Cite works in the manual's `config/refs.bib` with `#citep` or `#citet`.
- While a revision is under review, wrap changed text in `#modify[...]`; it
  is set in alizarin red. Remove the markers before publishing.

## Figures

Figures contain no prose, so every edition of a manual shares its
`figures/`. Change figures in the manual's `scripts/make_figures.py` or
`config/figures.toml`, then run `make figures MANUAL=<manual>`. Do not edit
the SVG files by hand.

## Updating for a new package release

1. In the manual's `manual.toml`, update `version` and `date` under
   `[package]` and add the release to `[releases]`.
2. Add a `#changed(...)` entry for each user-facing change, in all three
   editions. Leave out documentation-only changes.
3. Document new APIs and parameters, and regenerate figures if their output
   changed.
4. Once `main` builds cleanly, run `make publish MANUAL=<manual>` and commit the updated PDFs
   in econ-viz-docs (see the [README](README.md#publishing)).

## License

By contributing you agree that your work will be released under the
[MIT License](LICENSE).

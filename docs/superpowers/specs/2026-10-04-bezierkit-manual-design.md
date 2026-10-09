# BezierKit Manual Design

## Goal

Add a complete, three-language BezierKit reference manual to Agora, sharing
the existing manual template and build system with utility-viz and
principle-viz. Figures must be produced from BezierKit geometry via
`to_tikz()`, compiled as standalone PDFs, and embedded in the Typst manual.

## Repository Structure

Agora remains the canonical multi-manual repository. Shared typography,
layout, translated interface strings, theorem rendering, and reference
behavior live under `template/`. Package-specific sources live under
`packages/<package>/`.

The BezierKit package directory contains:

- `manual.toml` for package metadata, translations, releases, and editions;
- `main.typ` for the chapter manifest and appendix boundary;
- `chapters/{en,zh-TW,zh-CN}/` with matching filenames;
- `config/refs.bib` and `config/figures.toml`;
- `scripts/make_figures.py` for TikZ and standalone PDF generation;
- `figures/**/*.tex` and `figures/**/*.pdf` as inspectable generated assets.

Existing utility-viz and principle-viz package layouts remain unchanged.

## Build Interface

`PACKAGE` is the public Make variable. `MANUAL` remains a compatibility alias.
The default is `utility-viz`; the default edition is `en`.

Supported commands include:

```console
make PACKAGE=bezierkit EDITION=zh-TW
make bezierkit EDITION=zh-CN
make bezierkit-zh-TW
make watch PACKAGE=bezierkit EDITION=en
make figures PACKAGE=bezierkit
make editions PACKAGE=bezierkit
make all
```

Outputs use `build/<package>/<package>-<edition>.pdf`. Unknown packages and
editions fail with a concise list of valid values. Make command composition
must preserve whitespace between Typst flags and `--input`.

## Writing And Content

The manual follows utility-viz's l3doc/ctxdoc-inspired style: API names and
parameters in the hanging margin, executable examples, numbered figures and
tables, cross-references, a command index, and references. The three editions
have the same chapter structure and technical coverage.

The chapter sequence is:

1. Introduction
2. Installation
3. Quick start
4. Bernstein basis and Bezier curves
5. Evaluation, derivatives, and subdivision
6. Cubic segments and piecewise paths
7. Construction and Hermite interpolation
8. Adaptive fitting
9. Implicit-curve tracing
10. Exporters and adapters
11. Command-line interface
12. Change history
13. Appendix: mathematical proofs

The main chapters state mathematical results and explain their API relevance.
Proofs live in the appendix. Every proof uses the shared `proof` environment
and ends with a QED square. The appendix covers partition of unity, the convex
hull property, endpoint derivatives, de Casteljau subdivision, exact degree
elevation, Hermite control points, and the cubic Hermite error bound.

## Figure Pipeline

The figure generator depends on `bezierkit==1.0.0` and no longer uses
Matplotlib. It constructs BezierKit curves and paths, serializes curve geometry
with `bezierkit.export.tikz.to_tikz()`, adds only explanatory TikZ annotations
and axes, writes standalone `.tex`, then invokes `latexmk -pdf` to produce a
cropped PDF. Generated TeX is retained beside the PDF so readers can inspect
the emitted native cubic commands.

The ten existing SVG compositions are retained as visual references while the
new generator reproduces them as `basis`, `cubic`, `casteljau`, `split`,
`bbox`, `hermite`, `adaptive`, `polyline`, `contours`, and `saddle` PDFs.
Manual sources embed only the PDFs.

## Verification

- Dry-run Make invocations select the requested package and edition.
- Unknown package and edition values fail before Typst starts.
- The figure script generates all ten `.tex` and `.pdf` pairs with no SVG or
  Matplotlib dependency.
- Typst compiles BezierKit in English, Traditional Chinese, and Simplified
  Chinese without unresolved references.
- Existing utility-viz and principle-viz English builds still compile.
- The appendix contains no proof without a terminal QED square.

## Boundaries

This work does not modify the BezierKit library, publish PDFs, push branches,
or change any remote repository. Intersections, B-splines, and NURBS remain
outside the documented 1.0 API.

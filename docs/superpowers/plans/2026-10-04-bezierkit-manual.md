# BezierKit Manual Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a complete three-language BezierKit manual, selectable through Agora's Makefile, with figures generated as standalone PDFs from `to_tikz()` output.

**Architecture:** Keep Agora's shared manual template and one package directory per manual. Make selects `packages/<package>/main.typ`; BezierKit owns its chapters, metadata, bibliography, generator, and generated TeX/PDF assets.

**Tech Stack:** GNU Make, Typst 0.15, Python 3.13, BezierKit 1.0.0, TikZ, latexmk, standalone class

**Spec:** `docs/superpowers/specs/2026-10-04-bezierkit-manual-design.md`

## Global Constraints

- Work only on local branch `feat/bezierkit-manual`; do not push or publish.
- Preserve existing utility-viz, principle-viz, and shared-template work.
- Expose `PACKAGE` publicly and retain `MANUAL` as a compatibility alias.
- Generate figure geometry through `bezierkit.export.tikz.to_tikz()`.
- Retain generated `.tex` and `.pdf`; embed PDF in Typst.
- Provide matching `en`, `zh-TW`, and `zh-CN` chapter trees.
- Put derivations in the appendix and terminate every proof with a QED square.

## Review Focus

- `PACKAGE=bezierkit` must not silently build utility-viz.
- Typst flags must remain separate from `--input` when optional font paths expand.
- Invalid editions must fail before a missing chapter produces a Typst stack trace.
- Figure generation must work from a clean tree with no Matplotlib installation.
- Every generated TikZ path must remain valid when coordinates are negative or rounded.

---

### Task 1: Make Package And Edition Selection Reliable

**Files:**
- Modify: `Makefile`
- Create: `tests/test_makefile.sh`

**Interfaces:**
- Consumes: `packages/*/manual.toml` and each package's `editions` array
- Produces: `PACKAGE`, compatibility `MANUAL`, package-edition targets, and validated Typst commands

- [ ] Add shell assertions covering default selection, `PACKAGE=bezierkit`, `MANUAL=principle-viz`, `bezierkit-zh-TW`, invalid package, invalid edition, and the whitespace before `--input`.
- [ ] Run `bash tests/test_makefile.sh` and verify the BezierKit cases fail against the current Makefile.
- [ ] Update Make variables, validation targets, aliases, and command construction.
- [ ] Run `bash tests/test_makefile.sh`; expect all assertions to pass.

### Task 2: Complete Shared Theorem, Proof, And Appendix Support

**Files:**
- Modify: `template/manual.typ`
- Modify: `template/config/strings.toml`
- Create: `tests/fixtures/theorem-proof.typ`
- Create: `tests/test_template.sh`

**Interfaces:**
- Produces: `theorem(name:, body)`, `proof(of:, body)`, and `appendix(body)` with translated labels and references

- [ ] Add a fixture containing a theorem, a referenced proof, an appendix heading, and a second proof without `of`.
- [ ] Compile the fixture in all three editions and verify page text contains the translated theorem/proof/appendix labels.
- [ ] Finish the existing shared-template implementation, including robust QED placement at paragraph end.
- [ ] Re-run `bash tests/test_template.sh`; expect all three PDFs and no Typst errors.

### Task 3: Replace Matplotlib Figures With TikZ Standalone PDFs

**Files:**
- Modify: `packages/bezierkit/pyproject.toml`
- Modify: `packages/bezierkit/config/figures.toml`
- Replace: `packages/bezierkit/scripts/make_figures.py`
- Create: `tests/test_bezierkit_figures.sh`
- Generate: `packages/bezierkit/figures/**/*.tex`
- Generate: `packages/bezierkit/figures/**/*.pdf`

**Interfaces:**
- Consumes: BezierKit `PiecewiseBezier` geometry and `to_tikz(path, precision, options)`
- Produces: ten named standalone TeX/PDF figure pairs and `--list`/group CLI behavior

- [ ] Assert `--list` names all groups, the script source imports `to_tikz` but not Matplotlib, and a full run creates ten nonempty TeX/PDF pairs containing native `.. controls` paths.
- [ ] Run `bash tests/test_bezierkit_figures.sh`; verify it fails before replacement.
- [ ] Implement small helpers for curve-to-path conversion, standalone document assembly, atomic TeX writes, and `latexmk` compilation.
- [ ] Recreate the ten reference compositions with geometry from BezierKit and annotations in TikZ.
- [ ] Run the figure test and inspect representative PDFs (`cubic`, `casteljau`, `contours`) for framing and labels.

### Task 4: Add BezierKit Manual Metadata And Entry Point

**Files:**
- Create: `packages/bezierkit/manual.toml`
- Create: `packages/bezierkit/main.typ`
- Create: `packages/bezierkit/config/refs.bib`

**Interfaces:**
- Consumes: shared `manual.with(...)`, theorem/proof/appendix helpers, and generated PDFs
- Produces: one entry point with a shared chapter manifest for all editions

- [ ] Add metadata for BezierKit 1.0.0, all three editions, authors, release dates, package-specific placeholder translations, and publish name.
- [ ] Add the 12 main chapters followed by an appendix wrapper around chapter 13.
- [ ] Add primary references used by the mathematical appendix.
- [ ] Run `make -n PACKAGE=bezierkit EDITION=zh-TW`; expect the BezierKit entry point and output path.

### Task 5: Write English Chapters And Mathematical Appendix

**Files:**
- Create: `packages/bezierkit/chapters/en/01-introduction.typ` through `13-mathematical-proofs.typ`

**Interfaces:**
- Consumes: BezierKit 1.0 public API, retained figure PDFs, and shared documentation macros
- Produces: complete English reference content, API index entries, and labeled mathematical results/proofs

- [ ] Write chapters 1-3 with scope, installation, renderer-neutral quick start, and first `to_tikz()` workflow.
- [ ] Write chapters 4-6 covering basis, evaluation strategies, derivatives, subdivision, cubic segments, and piecewise/compound paths.
- [ ] Write chapters 7-9 covering constructions, Hermite interpolation, fitting guarantees, and implicit tracing limitations.
- [ ] Write chapters 10-12 covering TikZ/SVG/JSON, Matplotlib adapters, CLI, errors, and change history.
- [ ] Write appendix proofs for all seven results in the spec, each using `#proof`.
- [ ] Compile `make PACKAGE=bezierkit EDITION=en`; expect a PDF with no unresolved references.

### Task 6: Write Traditional And Simplified Chinese Editions

**Files:**
- Create: `packages/bezierkit/chapters/zh-TW/*.typ`
- Create: `packages/bezierkit/chapters/zh-CN/*.typ`

**Interfaces:**
- Consumes: the English chapter structure and `WRITING-STYLE-ZH.md` terminology conventions
- Produces: technically equivalent CJK editions with matching labels and API coverage

- [ ] Translate all chapters into Taiwanese Traditional Chinese, preserving code and equations and introducing English technical terms on first use.
- [ ] Adapt the Traditional Chinese edition to Simplified Chinese terminology and punctuation; do not mechanically alter identifiers or code.
- [ ] Compile both CJK editions and verify no missing chapter, reference, or glyph warnings beyond documented Kaiti availability.

### Task 7: Regression Verification And Documentation

**Files:**
- Modify: `README.md`
- Modify: `.github/workflows/build.yml`

**Interfaces:**
- Consumes: package-aware Make targets
- Produces: documented local commands and CI coverage for every package/edition pair

- [ ] Document package/edition selection, figure prerequisites, and generated asset policy.
- [ ] Update CI to discover or explicitly build every package's declared editions.
- [ ] Run Makefile, template, and figure tests.
- [ ] Build all three BezierKit editions plus utility-viz/en and principle-viz/en.
- [ ] Check `git diff --check`, generated PDF presence, command index population, and appendix QED coverage.

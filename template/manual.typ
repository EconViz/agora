// template/manual.typ
// ctxdoc / l3doc-style manual template with a hanging left column.
//
// The page has a wide left margin. Names of API entries, parameters,
// figure captions and side notes hang in that margin, right-aligned against
// the text block; everything else stays in the text column.
//
// Every manual in this repository, and every edition of it (en, zh-TW,
// zh-CN), uses the same template. Settings shared by all manuals live next to
// this file: interface strings (config/strings.toml), fonts
// (config/fonts.toml) and page geometry (config/layout.toml). Everything
// about one manual (package, title, authors, release dates, placeholder
// names) comes from that manual's own config, passed in as a dictionary, so
// it can be written in TOML, YAML or any format Typst reads.
//
// Usage (from <manual>/main.typ, compiled with --root at the repository):
//   #import "/template/manual.typ": *
//   #show: manual.with(toml("manual.toml"), root: "/packages/utility-viz", edition: "en")
//   ...chapters...
//   #references(read("config/refs.bib", encoding: none))

#let layout-cfg = toml("config/layout.toml")
#let fonts-cfg = toml("config/fonts.toml")
#let i18n = toml("config/strings.toml")

// The current manual's config (see manual()) and its directory under the
// repository root, set once at the start of the document.
#let _manual = state("manual", (:))
#let _root = state("manual-root", "")

#let mp-width = layout-cfg.page.margin-width * 1in
#let mp-sep = layout-cfg.page.margin-sep * 1in
#let hang = mp-width + mp-sep

// ---------------------------------------------------------------------------
// Edition lookup
// ---------------------------------------------------------------------------

#let edition-state = state("edition", "en")

#let strings-for(key) = i18n.at("en") + i18n.at(key, default: (:))
#let fmt(pattern, n) = pattern.replace("{}", n)
#let is-cjk(key) = strings-for(key).script == "cjk"
#let par-for(key) = if is-cjk(key) { layout-cfg.par.cjk } else { layout-cfg.par.latin }

// (latin, cjk) stacks: Latin letters come from the Latin
// font, CJK characters fall through to the CJK font.
#let font-stack(key, kind) = {
  let latin = fonts-cfg.latin.at(kind, default: fonts-cfg.latin.serif)
  if not is-cjk(key) { return latin }
  let cjk = fonts-cfg.at(key)
  let latin-part = if kind == "heading" { cjk.at("heading-latin", default: latin) } else { latin }
  latin-part + cjk.at(kind, default: cjk.serif)
}

#let heading-weight(key) = if is-cjk(key) {
  fonts-cfg.at(key).at("heading-weight", default: fonts-cfg.latin.heading-weight)
} else { fonts-cfg.latin.heading-weight }

// Interface string for the current edition (needs context).
#let tr(key) = context strings-for(edition-state.get()).at(key)

// ---------------------------------------------------------------------------
// Inline markup (l3doc equivalents)
// ---------------------------------------------------------------------------

// Package/software names: sans, matching l3doc.cls's `\DeclareRobustCommand
// \pkg {\textsf}` (ctxdoc uses this everywhere).
#let pkg(name) = context text(font: font-stack(edition-state.get(), "sans"), name) // \pkg
#let opt(name) = raw(name)                                                   // \opt
#let file(name) = raw(name)                                                  // \file
// CJK editions translate the placeholder word inside ⟨...⟩; an English
// name with no entry in meta-terms (e.g. a literal type like `Theme`)
// passes through unchanged.
#let meta(name) = context {
  let key = edition-state.get()
  let terms = strings-for(key).at("meta-terms", default: (:))
  terms += _manual.get().at("meta-terms", default: (:)).at(key, default: (:))
  let shown = terms.at(name, default: name)
  [⟨#emph(shown)⟩]
}                                                                              // \meta
#let oarg(name) = [#raw("[")#meta(name)#raw("]")]                            // \oarg

#let url(address) = link(address, raw(address))                             // \url

// A field of the documented package from the manual's config, e.g.
// #pkg-meta("version") or #pkg-meta("python").
#let pkg-meta(key) = context str(_manual.get().package.at(key))

// Introduce a term: the CJK gloss in the heading face, with its English
// original set in parentheses on first use. In a non-CJK
// edition there is no separate gloss to add, so `name` alone is shown.
#let term(name, english: none) = context {
  let key = edition-state.get()
  if not is-cjk(key) { return emph(name) }
  text(font: font-stack(key, "heading"), name)
  if english != none {
    [ (]
    text(font: fonts-cfg.latin.serif, english)
    [)]
  }
}

// Logos.
#let TeX = box[T#h(-0.1667em)#box(move(dy: 0.215em)[E])#h(-0.125em)X]
#let LaTeX = box[L#h(-0.36em)#box(move(dy: -0.21em, text(size: 0.7em)[A]))#h(-0.15em)#TeX]

// Side note in the left column, level with the line it is attached to.
#let aside(body) = context {
  let x = here().position().x
  let p = par-for(edition-state.get())
  box(width: 0pt, place(
    top + left,
    dx: layout-cfg.page.left * 1in - hang - x,
    box(width: mp-width, align(right, text(size: p.note-size * 1pt, style: "italic", body))),
  ))
}

#let _in-example = state("in-example", false)
// Set while rendering an #api()/#param() `syntax:` block, so a code fence
// there starts flush with the margin name instead of leaving its usual
// 1em gap above (the margin label has no matching gap of its own).
#let _in-syntax = state("in-syntax", false)

// Typst skips first-line-indent on a paragraph not preceded by another
// paragraph (heading, code, figure, table, ...) — right after a heading
// that is what we want, but hanging()/_code-frame()/example() also count,
// wrongly leaving the *next* real paragraph flush too. A trailing empty
// paragraph fixes that: it is itself "a paragraph", so whatever follows
// it is "preceded by a paragraph" again and indents normally.
#let _indent-anchor = metadata(none)

// Two cells: `margin` hangs in the left column, `body` fills the text column.
// Margin labels (api()/param() names) are raw text set right next to body
// prose in the same row; they need to sit at the body's own size for the row
// to line up, not the 1.2x bump inline code gets inside a sentence (see the
// raw show rules in manual()).
#let _margin(content) = align(right, {
  show raw.where(block: false): set text(size: 1em)
  // A name wider than the margin column (Canvas.add_decomposition) may wrap
  // after "." or "_" instead of running off the page edge.
  content
})

#let hanging(margin, body, above: 1.2em, below: 1.2em, breakable: true) = {
  block(
    above: above,
    below: below,
    breakable: breakable,
    pad(left: -hang, grid(
      columns: (mp-width, 1fr),
      column-gutter: mp-sep,
      _margin(margin),
      body,
    )),
  )
  _indent-anchor
}

// Side notes ("New: v1.4.0") are smaller than the body, so their line box is
// given the body's own top edge: the note's baseline then lands exactly on
// the baseline of the body line beside it.
#let _note-lines(lines) = context {
  let p = par-for(edition-state.get())
  let edge = if "top-edge" in p { p.at("top-edge") * p.size * 1pt } else {
    measure(text(size: p.size * 1pt, top-edge: "cap-height", bottom-edge: "baseline", "X")).height
  }
  text(size: p.note-size * 1pt, style: "italic", top-edge: edge, lines.join(linebreak()))
}

// l3doc `function` environment: names in the margin, syntax + description.
//   names:  array of strings, typeset verbatim
//   added / updated: version or date shown under the names
// Tag for the command index (l3doc \PrintIndex): a zero-width marker left
// at every #api() name's position, collected by command-index() at the
// end of the document.
#let _idx-entry(name) = [#raw(name)#metadata(name) <idx-entry>]

// l3doc \changes{version}{date}{text}: which #api()/#param() name is
// currently being documented, so #changed() inside its body can tag
// itself with that name without being told explicitly. none = not inside
// one, i.e. a general, package-level change.
#let _current-cmd = state("current-cmd", none)

// "v1.4.0" in a margin note links to that version's entry in changelog()
// (the <change-version> anchor on its heading); plain text if none exists.
#let _version-link(version) = context {
  let v = version.trim("v", at: start)
  let hits = query(<change-version>).filter(m => m.value == v)
  if hits.len() > 0 { link(hits.first().location(), version) } else { version }
}

#let api(names, added: none, updated: none, syntax: none, body) = {
  let notes = ()
  if added != none { notes.push([#tr("new")#tr("note-sep")#_version-link(added)]) }
  if updated != none { notes.push([#tr("updated")#tr("note-sep")#_version-link(updated)]) }
  let label = names.map(_idx-entry).join(linebreak())
  let note = if notes.len() > 0 { _note-lines(notes) }
  if syntax == none {
    // The note is the margin's second line, level with the body's second.
    hanging(
      { label; if note != none { linebreak(); note } },
      { _current-cmd.update(names.first()); body; _current-cmd.update(none) },
      above: 1.5em,
      below: 1.5em,
    )
  } else {
    // Two rows: names beside the syntax, the note beside the first line of
    // the description, so the note never floats between the two.
    block(above: 1.5em, below: 1.5em, breakable: true, pad(left: -hang, grid(
      columns: (mp-width, 1fr),
      column-gutter: mp-sep,
      row-gutter: 0.9em,
      _margin(label),
      {
        _current-cmd.update(names.first())
        _in-syntax.update(true)
        // A signature is code, not prose: never stretch its spaces, and
        // break only between arguments, not inside an identifier.
        set par(justify: false)
        show sym.zws: none
        syntax
        _in-syntax.update(false)
      },
      _margin(note),
      { body; _current-cmd.update(none) },
    )))
    _indent-anchor
  }
}

// ctxdoc `optdesc`: one option / parameter / flag per entry.
#let param(name, type: none, default: none, body) = hanging(
  {
    raw(name)
    if type != none or default != none {
      linebreak()
      context {
        let p = par-for(edition-state.get())
        set text(size: p.note-size * 1pt)
        if type != none { emph(type) }
        if type != none and default != none { [ · ] }
        if default != none { [#tr("default") #raw(default)] }
      }
    }
  },
  {
    _current-cmd.update(name)
    body
    _current-cmd.update(none)
  },
  above: 0.75em,
  below: 0.75em,
)

// A labelled variant, e.g. a platform or output format.
#let variant(label, body) = hanging(
  context text(font: font-stack(edition-state.get(), "sans"), size: 9pt, label),
  body,
  above: 0.8em,
  below: 0.8em,
)

// Arguments list: #1: … #2: …
#let arguments(..items) = enum(
  numbering: n => raw("#" + str(n) + ":"),
  indent: 0pt,
  body-indent: 0.5em,
  spacing: 0.45em,
  ..items,
)

// ---------------------------------------------------------------------------
// Code, examples, figures, tables
// ---------------------------------------------------------------------------

#let _code-frame(it, above: auto) = context {
  let p = par-for(edition-state.get())
  // Same gap above and below: the body text's line spacing. CJK body lines
  // are set to the cap height (top-edge), so the ideographs rise ~0.2em out
  // of their line box; the gap above code, measured from that line box,
  // must shrink by as much to look equal to the gap below.
  let key = edition-state.get()
  let gap = p.leading * p.size * 1pt
  let optical = if is-cjk(key) { 0.2 * p.size * 1pt } else { 0pt }
  block(
    width: 100%,
    inset: (x: 9pt, y: 0pt),
    above: if above == auto { gap - optical } else { above },
    below: gap,
    breakable: true,
    {
      set text(size: p.code-size * 1pt)
      set par(justify: false, leading: 0.45em)
      it
    },
  )
  _indent-anchor
}

// ctexexam: framed code with a centred “Example N” in the top rule.
#let example(body) = figure(kind: "example", supplement: none, numbering: "1", body)

// Figure with its caption hanging in the left column. A path string is
// taken from the manual's directory ("/figures/x.svg" is
// <root>/figures/x.svg); an image() can be passed as well.
#let fig(path, caption: none, width: 55%) = figure(
  if type(path) == str { context image(_root.get() + path, width: width) } else { path },
  caption: caption,
  kind: image,
)

// booktabs-style table.
// Table cells are never justified: short cells would get stretched gaps.
#let booktabs(columns: auto, align: left, header: (), ..cells) = {
  set par(justify: false)
  table(
  columns: columns,
  align: align,
  stroke: none,
  inset: (x: 5pt, y: 7pt),
  table.header(
    table.hline(stroke: 0.8pt),
    ..header.map(cell => context text(
      font: font-stack(edition-state.get(), "serif"),
      weight: "bold",
      cell,
    )),
    table.hline(stroke: 0.5pt),
  ),
  ..cells,
  table.hline(stroke: 0.8pt),
  )
}

#let tbl(body, caption: none) = figure(body, caption: caption, kind: table)

// ---------------------------------------------------------------------------
// Theorems, proofs and appendices
// ---------------------------------------------------------------------------

// Numbered statements, amsthm style: definitions, lemmas, propositions,
// theorems and corollaries share one counter ("Definition 1", "Lemma 2",
// "Theorem 3", ...). Label one to refer to it; the reference names its
// kind ("Lemma 2", "引理 2"):
//   #theorem(name: [Partition of unity])[...] <thm-unity>
// The kind travels as the figure's supplement, a key into the interface
// strings (config/strings.toml: theorem, lemma, ...).
#let _statement(kind, name, body) = figure(
  body,
  kind: "theorem",
  supplement: kind,
  numbering: "1",
  caption: name,
  outlined: false,
)
#let definition(name: none, body) = _statement("definition", name, body)
#let lemma(name: none, body) = _statement("lemma", name, body)
#let proposition(name: none, body) = _statement("proposition", name, body)
#let theorem(name: none, body) = _statement("theorem", name, body)
#let corollary(name: none, body) = _statement("corollary", name, body)

// The interface-string key of a statement figure ("theorem", "lemma", ...).
#let _statement-kind(it) = {
  let key = it.supplement
  if type(key) == content { key = key.text }
  if key in ("definition", "lemma", "proposition", "theorem", "corollary") { key } else { "theorem" }
}

// The proof of a statement, ending in the QED box (amsthm's \qedsymbol).
// `of` names the theorem it proves: #proof(of: <thm-unity>)[...].
#let proof(of: none, body) = context {
  let p = par-for(edition-state.get())
  let s = strings-for(edition-state.get())
  block(above: 0.6em, below: (1 + p.leading) * 1em, width: 100%, {
    set par(first-line-indent: 0pt)
    if of == none { emph(s.proof) } else {
      let (before, after) = s.proof-of.split("{}")
      emph[#before#ref(of)#after]
    }
    if is-cjk(edition-state.get()) [：] else [. ]
    body
    h(1fr)
    box($square$)
  })
}

// Chapters after this are appendices, numbered A, B, ...:
//   #show: appendix
#let _is-appendix(h) = h.numbering == "A.1"
#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  body
}

// Back matter (change history, index) spans the margin column too: no
// hanging names there, so the page is used edge to edge like \twocolumn.
#let full-width(body) = pad(
  // Extend through the hanging margin column, but keep the page's right
  // margin and align the new left edge with that same page margin.
  left: -1in,
  right: 0.2in,
  body,
)
// Release dates come from the manual's config ([releases]: version =
// date), so call sites only name the version (l3doc's \changes repeats the
// date at every call; we keep one source of truth instead).

// l3doc \changes{version}{date}{text}: a zero-width marker left wherever a
// change is documented, tagged with the #api()/#param() name currently in
// scope (or `label:` when given explicitly). Collected by changelog() at
// the end of the document, the same way _idx-entry feeds command-index().
#let changed(version, label: auto, body) = context {
  let lbl = if label == auto { _current-cmd.get() } else { label }
  [#metadata((version: version, label: lbl, body: body)) <change-entry>]
}

#let _ver-pad(n) = {
  let s = str(int(n))
  while s.len() < 6 { s = "0" + s }
  s
}
// PEP 440 pre-releases (2.0.0a1, 2.0.0b1, 2.0.0rc1) sort after the previous
// release and before their own final version.
#let _ver-key(v) = {
  let m = v.match(regex("^(\d+)\.(\d+)\.(\d+)(?:(a|b|rc)(\d+))?$"))
  let (major, minor, patch, phase, n) = m.captures
  let stage = if phase == none { "9" + _ver-pad(0) }
    else { str(("a", "b", "rc").position(p => p == phase)) + _ver-pad(n) }
  (major, minor, patch).map(_ver-pad).join("") + stage
}

// l3doc \PrintChanges: every #changed() entry, grouped by version (newest
// first) then by the command it was tagged under, each line ending in a
// dotted leader and the real page it was documented on.
// Dotted leader raised off the baseline to the middle of the CJK glyphs,
// so it reads level with the text instead of sitting at its foot.
#let _leader(color) = text(fill: color, box(width: 1fr, move(dy: -0.25em, repeat[.])))

#let changelog(compact: false) = context {
  let key = edition-state.get()
  let p = par-for(key)
  let s = strings-for(key)
  let general = s.at("changelog-general", default: "General")
  let entries = query(<change-entry>).map(e => (
    version: e.value.version,
    date: _manual.get().at("releases", default: (:)).at(e.value.version, default: none),
    label: e.value.label,
    body: e.value.body,
    page: str(e.location().page()),
    loc: e.location(),
  ))
  let versions = entries.map(e => e.version).dedup().sorted(key: _ver-key).rev()
  set par(first-line-indent: 0pt, justify: false)
  set text(size: p.size * 1pt)
  // hyperref's colorlinks default (never overridden by ctxdoc/l3doc): pure
  // red, used for every \PrintChanges/\PrintIndex page-number link.
  let link-color = rgb("#ff0000")
  // One pitch everywhere, as in l3doc. `compact` reduces only the space
  // between entries; it leaves wrapped-entry leading and body text unchanged.
  let gap = p.leading * (if compact { 0.65em } else { 1em })
  full-width({
    columns(2, gutter: 1.8em, {
      for v in versions {
        let items = entries.filter(e => e.version == v)
        let date = items.first().date
        block(above: gap, below: gap, breakable: false, {
          [#strong("v" + v)#metadata(v) <change-version>]
          h(1fr)
          if date != none { "(" + date + ")" }
        })
        let labels = ()
        for it in items { if it.label not in labels { labels.push(it.label) } }
        for lbl in labels {
          let its = items.filter(e => e.label == lbl)
          block(above: gap, below: gap, {
            for (i, it) in its.enumerate() {
              // Label, text, leader and page number form one link target.
              link(it.loc, {
                if i == 0 {
                  strong(if lbl == none { general } else { raw(lbl) })
                  s.note-sep
                }
                it.body
                h(0.3em, weak: true)
                _leader(link-color)
                h(0.25em, weak: true)
                text(fill: link-color, it.page)
              })
              if i < its.len() - 1 { linebreak() }
            }
          })
        }
      }
    })
  })
}

// natbib-style citations in APA: \citet "Haagsma (2012)" and \citep
// "(Haagsma, 2012)". Adjacent #citep calls merge into one parenthesis.
// Always in English ("et al.", "&"), even in the CJK editions.
#let citet(key) = text(lang: "en", region: none, cite(key, form: "prose"))
#let citep(key) = text(lang: "en", region: none, cite(key))

// Works cited, after the command index, in APA style. `source` is the
// manual's BibTeX file read as bytes: #references(read("refs.bib", encoding: none)).
#let references(source) = context {
  pagebreak()
  full-width({
    heading(numbering: none, tr("references"))
    set par(first-line-indent: 0pt, justify: false)
    set text(lang: "en", region: none)
    bibliography(source, title: none, style: "apa")
  })
}

// l3doc \PrintIndex: every #api() name, alphabetised, with the pages it
// was documented on. Call once, after the last chapter.
#let command-index() = context {
  let key = edition-state.get()
  let p = par-for(key)
  pagebreak()
  full-width({
    heading(numbering: none, tr("command-index"))
    let entries = query(<idx-entry>)
    let by-name = (:)
    for e in entries {
      let name = e.value
      let page = str(e.location().page())
      let hit = (page: page, loc: e.location())
      if name in by-name {
        if by-name.at(name).all(h => h.page != page) { by-name.at(name).push(hit) }
      } else {
        by-name.insert(name, (hit,))
      }
    }
    let sorted-names = by-name.keys().sorted(key: n => lower(n))
    set par(first-line-indent: 0pt, justify: false)
    set text(size: p.size * 1pt)
    let last-letter = none
    // hyperref's colorlinks default: pure red, same as changelog()'s leader.
    let link-color = rgb("#ff0000")
    let gap = p.leading * 1em
    columns(2, gutter: 1.8em, {
      for name in sorted-names {
        let letter = upper(name.at(0))
        if letter != last-letter {
          last-letter = letter
          let above = if name == sorted-names.first() { 0pt } else { gap }
          block(above: above, below: gap, breakable: false, strong(letter))
        }
        block(above: gap, below: gap, breakable: false, {
          // Name, leader and page form one link to the first occurrence;
          // later page numbers each link to their own page.
          let hits = by-name.at(name)
          link(hits.first().loc, {
            raw(name)
            h(0.3em, weak: true)
            _leader(link-color)
            h(0.25em, weak: true)
            text(fill: link-color, hits.first().page)
          })
          for h in hits.slice(1) {
            text(fill: link-color, [, ])
            link(h.loc, text(fill: link-color, h.page))
          }
        })
      }
    })
  })
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

// Figures float like LaTeX's [tbp]: nearest of page top or bottom, so one
// that no longer fits does not leave a hole the height of the figure.
#let _float(body) = place(auto, float: true, clearance: 1.6em, body)

// config: the manual's settings as a dictionary (toml("manual.toml") or
//   yaml("manual.yml")); see packages/utility-viz/manual.toml for the keys.
// root: the manual's directory under the repository root, e.g.
//   "/packages/utility-viz"; figure paths are resolved against it.
// edition: one of config.editions.
#let manual(config, root: "", edition: "en", body) = {
  let editions = config.at("editions", default: ("en",))
  assert(edition in editions, message: "edition " + repr(edition) + " is not one of " + repr(editions))
  let s = strings-for(edition)
  s.insert("title", config.title.at(edition, default: config.title.en))
  let doc-meta = config
  let p = par-for(edition)
  let cjk = is-cjk(edition)
  let serif = font-stack(edition, "serif")
  let mono = font-stack(edition, "mono")
  let authors = doc-meta.authors
  let author-name(a) = a.name.at(edition, default: a.name.en)

  // Update the state before anything that reads it.
  edition-state.update(edition)
  _manual.update(config)
  _root.update(root)

  set document(title: s.title, author: authors.map(author-name))

  set page(
    paper: layout-cfg.page.paper,
    margin: (
      left: layout-cfg.page.left * 1in,
      right: layout-cfg.page.right * 1in,
      top: layout-cfg.page.top * 1in,
      bottom: layout-cfg.page.bottom * 1in,
    ),
    // \pagestyle{headings}: first section on the page (or the last one
    // before it), page number on the right.
    header: context {
      let pg = here().page()
      if pg == 1 { return }
      let all = query(heading.where(level: 1, outlined: true))
      let on-page = all.filter(h => h.location().page() == pg)
      let before = all.filter(h => h.location().page() < pg)
      let sec = if on-page.len() > 0 { on-page.first() }
        else if before.len() > 0 { before.last() }
        else { none }
      // Back matter (change history, index) is the only unnumbered
      // outlined level-1 heading; its header spans the margin like its text.
      let back = sec != none and sec.numbering == none
      let header-body = {
        set text(size: p.size * 1pt)
        if sec != none {
          let mark = if s.header-upper { upper(sec.body) } else { sec.body }
          if sec.numbering != none {
            let n = numbering(sec.numbering, counter(heading).at(sec.location()).first())
            let pattern = if _is-appendix(sec) { s.appendix-number } else { s.section-number }
            mark = [#fmt(pattern, n)#h(1em)#mark]
          }
          if cjk { text(font: font-stack(edition, "emph"), mark) } else { emph(mark) }
        }
        h(1fr)
        counter(page).display()
      }
      if back { full-width(header-body) } else { header-body }
    },
    footer: context {
      if here().page() == 1 { align(center, counter(page).display()) }
    },
  )

  set text(
    font: serif,
    size: p.size * 1pt,
    top-edge: if "top-edge" in p { p.at("top-edge") * 1em } else { "cap-height" },
    bottom-edge: "baseline",
    lang: s.lang,
    region: if s.region == "" { none } else { s.region },
  )
  set par(
    justify: true,
    leading: p.leading * 1em,
    spacing: p.at("spacing", default: p.leading) * 1em,
    // First paragraph after a heading stays flush (Typst default); every
    // later paragraph indents 2em, including right after a code block or
    // figure, via the trailing _indent-anchor those add (see its def).
    first-line-indent: (amount: p.indent * 1em, all: false),
  )

  // CJK has no italics: emphasis switches the CJK part to Kai; bold CJK
  // uses the bold cut of the edition's Song face.
  show emph: set text(font: font-stack(edition, "emph")) if cjk
  show strong: set text(font: font-stack(edition, "strong")) if cjk

  // Code *blocks* stay at the plain code-size with no compensation, like
  // ctxdoc's `\fvset{fontsize=\small}` applied straight to CMU Typewriter.
  // Inline code sits directly in a CJK sentence, where CMU's optical size
  // reads smaller than a full-width CJK glyph at the same nominal size;
  // 1.15x there brings it back level with the surrounding characters.
  let mono-weight = fonts-cfg.latin.at("mono-weight", default: 400)
  show raw.where(block: true): set text(font: mono, weight: mono-weight)
  show raw.where(block: false): set text(font: mono, size: 1.2em, weight: mono-weight)
  // Long identifiers in running text (TOP_TWO_BOTTOM_ONE, Canvas.add_path,
  // ComparativeStatics) may break after "_" or "." or between camel-case
  // words, like LaTeX's \path; otherwise a line holding
  // one would be justified by prying the CJK characters apart.
  show raw.where(block: false): it => {
    show regex("[_.]"): m => m + sym.zws
    show regex("[a-z][A-Z]"): m => m.text.first() + sym.zws + m.text.last()
    it
  }
  // Syntax highlighting marks comments with emph/strong; keep them monospaced.
  show raw: it => {
    show emph: set text(font: mono)
    show strong: set text(font: mono)
    it
  }
  // Code keeps Typst's built-in syntax colours (the usual per-language
  // palette: keywords, strings, numbers and comments each tinted).
  show raw.where(block: true): it => context {
    if _in-example.get() { it }
    else if _in-syntax.get() { _code-frame(it, above: 0pt) }
    else { _code-frame(it) }
  }

  show math.equation: set text(font: fonts-cfg.latin.math)
  show link: it => it

  // Headings.
  set heading(numbering: "1.1")
  show heading: set par(justify: false, first-line-indent: 0pt)
  show heading.where(level: 1): it => block(above: 2.3em, below: 1.2em, {
    let face = font-stack(edition, "heading")
    set text(size: 14.4pt, font: face, weight: heading-weight(edition))
    // Typst may wrap heading bodies in emphasis. Keep every heading level in
    // the dedicated Song face; Kai is reserved for running headers/emphasis.
    show emph: set text(font: face, weight: heading-weight(edition))
    show strong: set text(font: face, weight: heading-weight(edition))
    if it.numbering != none {
      let n = numbering(it.numbering, counter(heading).get().first())
      fmt(if _is-appendix(it) { s.appendix-number } else { s.section-number }, n)
      h(1em)
    }
    it.body
  })
  show heading.where(level: 2): it => block(above: 1.9em, below: 1em, {
    let face = font-stack(edition, "heading")
    set text(size: 12pt, font: face, weight: heading-weight(edition))
    show emph: set text(font: face, weight: heading-weight(edition))
    show strong: set text(font: face, weight: heading-weight(edition))
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(1em)
    }
    it.body
  })
  show heading.where(level: 3): it => block(above: 1.5em, below: 0.8em, {
    let face = font-stack(edition, "heading")
    set text(size: p.size * 1pt, font: face, weight: heading-weight(edition))
    show emph: set text(font: face, weight: heading-weight(edition))
    show strong: set text(font: face, weight: heading-weight(edition))
    it.body
  })

  // Figures and tables: caption hangs in the left column.
  show figure.where(kind: image): it => _float(hanging(
    align(bottom, {
      set text(size: p.caption-size * 1pt, costs: (runt: 800%))
      set par(justify: false, first-line-indent: 0pt, linebreaks: "optimized")
      strong[#s.figure #context it.counter.display(it.numbering)]
      if it.caption != none { [\ #it.caption.body] }
    }),
    align(left, it.body),
    above: 0pt,
    below: 0pt,
    breakable: false,
  ))
  // A figure is an unbreakable block unless told otherwise; tables may split.
  show figure.where(kind: table): set block(breakable: true)
  show figure.where(kind: table): it => hanging(
    {
      set text(size: p.caption-size * 1pt, costs: (runt: 800%))
      set par(justify: false, first-line-indent: 0pt, linebreaks: "optimized")
      strong[#s.table #context it.counter.display(it.numbering)]
      if it.caption != none { [\ #it.caption.body] }
    },
    align(left, it.body),
    above: 1em,
    below: 1.6em,
    breakable: true,
  )
  // ctxdoc's ctexexam/frameverb keep frame=single even though plain code
  // (_code-frame) does not; only the labelled, numbered example box does.
  show figure.where(kind: "example"): it => {
    block(
      above: 1.7em,
      below: 1.5em,
      width: 100%,
      stroke: 0.4pt,
      inset: (x: 10pt, top: 12pt, bottom: 9pt),
      breakable: true,
      {
        place(
          top + center,
          dy: -12pt - 0.5em,
          box(fill: white, inset: (x: 4pt), text(
            size: p.size * 1pt,
            weight: "bold",
            context fmt(s.example, str(it.counter.at(it.location()).first())),
          )),
        )
        set text(size: p.code-size * 1pt)
        set par(justify: false, leading: 0.45em)
        set align(left)
        _in-example.update(true)
        it.body
        _in-example.update(false)
      },
    )
    _indent-anchor
  }

  // amsthm styles: "plain" (lemma, proposition, theorem, corollary) sets the
  // body in italics, Kai in the CJK editions; "definition" keeps it upright.
  // A statement sits one blank line away from the body text on both sides:
  // the figure's own block carries the gap (a spacing set inside the show
  // rule would only apply within the figure).
  let statement-gap = (1 + p.leading) * 1em
  show figure.where(kind: "theorem"): set block(above: statement-gap, below: statement-gap)
  show figure.where(kind: "theorem"): it => block(width: 100%, {
    set align(left)
    set par(first-line-indent: 0pt)
    let kind = _statement-kind(it)
    strong[#s.at(kind) #context it.counter.display(it.numbering)]
    if it.caption != none [ (#it.caption.body)]
    if cjk [ ] else [. ]
    if kind == "definition" { it.body } else { emph(it.body) }
  })

  // Cross-references: “section 2”, “table 1”, “第 2 節”, “表 1”.
  show ref: it => {
    let el = it.element
    if el == none { return it }
    if el.func() == heading and el.numbering != none {
      let n = numbering(el.numbering, ..counter(heading).at(el.location()))
      let pattern = if _is-appendix(el) and el.level == 1 { s.appendix-ref } else { s.section-ref }
      link(el.location(), fmt(pattern, n))
    } else if el.func() == figure {
      let n = numbering("1", ..el.counter.at(el.location()))
      let pattern = if el.kind == table { s.table-ref }
        else if el.kind == image { s.figure-ref }
        else if el.kind == "theorem" { s.at(_statement-kind(el) + "-ref") }
        else { s.example-ref }
      link(el.location(), fmt(pattern, n))
    } else { it }
  }

  set footnote(numbering: "1")
  // Footnotes get their own, tighter leading: about 70% of the body's, and
  // the same gap between entries so each note reads as one small block.
  let fn-leading = p.leading * 0.7em
  // The title page is centred on the page (see \maketitle below), so its
  // footnote area, rule included, extends left through the margin column
  // by the same amount.
  let title-extra = (layout-cfg.page.left - layout-cfg.page.right) * 1in
  // The rule sits at the text block's left edge on every page. (Choosing it
  // with here().page() inside the separator does not work: there `here()`
  // always reports page 1, which shifted the rule on every page.)
  // The title page is the only one whose footnote area extends into the
  // margin column, so its rule is shifted; the page break that ends it
  // switches back to the plain rule (see below). The separator comes from the
  // styles in effect where a page starts, not from the footnote itself.
  let plain-rule = line(length: 30%, stroke: 0.4pt)
  set footnote.entry(
    separator: move(dx: -title-extra, plain-rule),
    gap: fn-leading,
  )
  show footnote.entry: set par(leading: fn-leading)
  // Title-page author notes (*, †): unjustified, and as wide as the title.
  show footnote.entry: it => {
    if it.note.numbering == "*" {
      set par(justify: false)
      pad(left: -title-extra, it)
    } else { it }
  }
  set list(indent: 0.4em, body-indent: 0.5em, marker: [•])
  set enum(indent: 0.4em)

  // Title (\maketitle), centred on the page rather than the text block:
  // extend left through the margin column until both sides keep the
  // page's right margin.
  v(1.2em)
  pad(left: -title-extra, align(center, {
    set par(justify: false, first-line-indent: 0pt)

    let title-face = font-stack(edition, "heading")
    // A title that fits on one line across the whole centred width stays on
    // one line; a longer one breaks at the text block's width, as before, so
    // its lines stay balanced instead of leaving one word on the second.
    let title = text(size: 17.28pt, font: title-face, weight: heading-weight(edition), {
      show doc-meta.package.name: pkg
      s.title
    })
    layout(size => {
      let one-line = measure(title).width <= size.width
      block(width: if one-line { 100% } else { 100% - title-extra }, title)
    })
    v(1.1em)
    // Authors with \thanks-style notes, as in journals: one note per
    // affiliation, marked on every author who shares it, then a note for
    // each author with an email, flagged when corresponding (*, †, ‡, ...).
    // Numbered apart from the body footnotes.
    {
      set footnote(numbering: "*")
      let aff-of(a) = {
        let aff = a.at("affiliation", default: none)
        if aff == none { none } else { aff.at(edition, default: aff.en) }
      }
      let affs = authors.map(aff-of).filter(x => x != none).dedup()
      let (email-before, email-after) = s.email.split("{}")
      text(size: 12pt, authors.map(a => {
        let aff = aff-of(a)
        let aff-mark = if aff != none {
          let i = affs.position(x => x == aff)
          let key = label("author-aff-" + str(i))
          // The first author with this affiliation carries the note; the
          // others point to it.
          if authors.find(b => aff-of(b) == aff) == a {
            let end = if is-cjk(edition) [。] else [.]
            [#footnote(aff + end)#key]
          } else { footnote(key) }
        }
        let email = a.at("email", default: none)
        let email-mark = if email != none {
          footnote({
            if a.at("corresponding", default: false) { s.corresponding }
            email-before
            link("mailto:" + email, email)
            email-after
          })
        }
        box(author-name(a)) + aff-mark + email-mark
      }).join(h(2em)))
    }
    counter(footnote).update(0)
    v(0.6em)
    // Date · version · repository · website, the last two as clickable
    // icons in place of a \thanks footnote.
    let icon(path, url) = link(url, box(image(path, height: 0.85em), baseline: 0.1em))
    text(size: 12pt, {
      s.version-date
        .replace("{date}", doc-meta.package.date)
        .replace("{version}", doc-meta.package.version)
      [ · ]
      // The icon is an image, so the changed repository link is not tinted.
      icon("/template/icons/github.svg", doc-meta.package.repo)
      [ · ]
      icon("/template/icons/globe.svg", doc-meta.package.site)
    })
  }))
  v(1.6em)

  // Two-column table of contents (multitoc), same geometry in every edition.
  pad(
    left: -0.8in,
    {
      heading(numbering: none, outlined: false, s.contents)
      show outline.entry: it => context {
        // Let entries flow naturally between columns; a fixed chapter
        // boundary becomes invalid when fonts or section counts change.
        block(
          above: if it.level == 1 { 3pt } else { 0pt },
          below: 0pt,
          inset: (y: 1.8pt),
          breakable: false,
          {
            set text(size: p.note-size * 1pt, top-edge: "ascender", bottom-edge: "descender")
            set par(leading: 0.35em, spacing: 0pt, justify: false)
            let entry = link(it.element.location(), it.indented(it.prefix(), it.inner()))
            if it.level == 1 { strong(entry) } else { entry }
          },
        )
      }
      set par(first-line-indent: 0pt)
      columns(2, gutter: 2em, outline(title: none, depth: 2, indent: 1.2em))
    },
  )

  set footnote.entry(separator: plain-rule, gap: fn-leading)
  pagebreak()

  body
}

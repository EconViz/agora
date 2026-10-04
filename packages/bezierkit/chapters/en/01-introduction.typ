#import "/template/manual.typ": *

= Introduction <sec-intro>

#changed("0.5.0rc1")[First release on PyPI: degree-generic Bézier curves, cubic segments and paths, constructions, Hermite interpolation, fitting, level-set tracing, sampling, exporters and a command-line interface]
#changed("1.0.0")[First stable release; the public API follows semantic versioning]

The #pkg("bezierkit") package is a small mathematical toolkit for Bézier
curves. It builds curves from control points or from endpoint conditions,
evaluates and differentiates them, splits and restricts them, fits them to
functions, sampled points and level sets, and writes them out as JSON, SVG
path data or TikZ. It draws nothing: plotting is left to renderers such as
Matplotlib, #pkg("mosaickit") or a #LaTeX document, which receive exact
cubic control points.

== Notation

A point or vector lives in $RR^d$ for some dimension $d >= 1$; most figures
use $d = 2$. A Bézier curve of degree $n$ has $n + 1$ control points
$P_0, dots, P_n$ and is the map
$ B(t) = sum_(i=0)^n b_(i,n)(t) P_i, quad t in [0, 1], $
where $b_(i,n)(t) = binom(n, i) t^i (1-t)^(n-i)$ are the Bernstein
polynomials (@sec-curves). The control points, joined in order, form the
control polygon. Every curve in the package is parameterized over
$[0, 1]$; a parameter outside it raises `ParameterOutOfDomain`.

== Mathematics and proofs

The chapters state the properties the algorithms rely on as numbered
theorems: what the Bernstein basis guarantees, why de Casteljau's algorithm
evaluates and subdivides a curve, how far a Hermite interpolant can stray,
what the exporters lose to rounding. Their proofs are collected in
@app-proofs, so the chapters can be read for the API alone. The standard
references are #citet(<farin2002>) and #citet(<prautzsch2002>).

== Reading guide

#tbl(caption: [Chapter guide])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([Topic], [Contents], [Section]),
    table.cell(rowspan: 3)[Foundations],
    [Points, vectors, parameters, errors], [#ref(<sec-geometry>)],
    [Bernstein basis, curves, evaluation], [#ref(<sec-curves>)],
    [Derivatives, subdivision, reversal], [#ref(<sec-operations>)],
    table.cell(rowspan: 2)[Cubics],
    [Cubic segments and piecewise paths], [#ref(<sec-paths>)],
    [Constructions and Hermite interpolation], [#ref(<sec-construction>)],
    table.cell(rowspan: 2)[Approximation],
    [Fitting functions and polylines], [#ref(<sec-fitting>)],
    [Tracing level sets], [#ref(<sec-implicit>)],
    table.cell(rowspan: 2)[Output],
    [Sampling, JSON, SVG, TikZ, Matplotlib], [#ref(<sec-export>)],
    [Command line], [#ref(<sec-cli>)],
  )
] <tab-guide>

On first use, read @sec-quickstart and @sec-curves. The figures in this
manual are themselves #pkg("bezierkit") output: every curve in them was
written by the TikZ exporter of @sec-export and compiled with #LaTeX.

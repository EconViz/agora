#import "/template/manual.typ": *

= Introduction <sec-intro>

#changed("0.5.0rc1")[First release on PyPI: degree-generic Bézier curves, cubic segments and paths, constructions, Hermite interpolation, fitting, level-set tracing, sampling, exporters and a command-line interface]
#changed("1.0.0")[First stable release; the public API follows semantic versioning]

The #pkg("bezierkit") package is a small mathematical toolkit for Bézier
curves. It builds curves from control points or from endpoint conditions,
evaluates and differentiates them, splits and restricts them, fits them to
functions, sampled points and level sets, and writes them out as JSON, SVG
path data or TikZ. It does not plot. Renderers such as Matplotlib,
#pkg("mosaickit") or a #LaTeX document receive exact cubic control points
and draw them.

== Notation

A point or vector lives in $RR^d$ for some dimension $d >= 1$; most figures
use $d = 2$. The Euclidean norm of $x in RR^d$ is
$ norm(x) = sqrt(x_1^2 + dots + x_d^2), $
and $norm(x)_oo = max_k |x_k|$ is the maximum norm. A set $S subset.eq RR^d$
is convex if $lambda p + (1 - lambda) q in S$ whenever $p, q in S$ and
$lambda in [0, 1]$; the convex hull of a finite set of points is the set of
all their convex combinations $sum_i lambda_i P_i$ with $lambda_i >= 0$ and
$sum_i lambda_i = 1$. A map $A: RR^d -> RR^e$ is affine if
$A(x) = M x + v$ for a matrix $M$ and a vector $v$. A function is
$C^k$ if it has continuous derivatives up to order $k$.

A Bézier curve of degree $n$ has $n + 1$ control points $P_0, dots, P_n$ and
is the map
$ B(t) = sum_(i=0)^n b_(i,n)(t) P_i, quad t in [0, 1], $
where
$ b_(i,n)(t) = binom(n, i) t^i (1-t)^(n-i) $
are the Bernstein polynomials (@sec-curves). The control points, joined in
order, form the control polygon. Every curve in the package is parameterized
over $[0, 1]$; a parameter outside it raises `ParameterOutOfDomain`. The
letter $d$ always denotes the dimension; tolerances are written $epsilon$.

== Mathematics and proofs

Each chapter first recalls the standard definitions it uses, with a
reference, and then states the properties the algorithms rely on as numbered
lemmas, propositions, theorems and corollaries: the Bernstein basis,
evaluation and subdivision by de Casteljau's algorithm, the Hermite error
bound and the rounding error of the exporters.
Their proofs are collected in @app-proofs, so the chapters can be read for
the API alone. Conventions that belong to this package, and not to the
literature, are called package conventions. The standard references are
#citet(<farin2002>), #citet(<prautzsch2002>) and, for the Bernstein basis,
#citet(<farouki2012>).

== Reading guide

#tbl(caption: [Chapter guide])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([Topic], [Contents], [Section]),
    table.cell(rowspan: 3)[Foundations],
    [Points, vectors, parameters, errors], [#ref(<sec-geometry>)],
    [Bernstein basis, curves, evaluation], [#ref(<sec-curves>)],
    [Derivatives, reversal, subdivision], [#ref(<sec-operations>)],
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

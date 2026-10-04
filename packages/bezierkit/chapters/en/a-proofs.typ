#import "/template/manual.typ": *

= Proofs <app-proofs>

This appendix proves the lemmas, propositions, theorems and corollaries
stated in the chapters, in the order they appear. Throughout, $b_(i,n)$ is
the Bernstein polynomial of @def-bernstein and $B$ the Bézier curve of
@def-curve, of degree $n$ with control points $P_0, dots, P_n$.

== The Bernstein basis and evaluation

#proof(of: <lem-binomial>)[
  Both sides of each identity vanish when the indices leave the stated
  ranges, so assume $0 <= j <= n$ and $1 <= i <= n$. For the first, write
  both terms over the common denominator $j! (n - j)!$:
  $ (n-1)! / (j! (n-1-j)!) + (n-1)! / ((j-1)! (n-j)!)
    = ((n-1)! ((n - j) + j)) / (j! (n-j)!) = binom(n, j). $
  For the second,
  $i binom(n, i) = n! slash ((i-1)! (n-i)!) = n binom(n-1, i-1)$.
]

#proof(of: <prop-unity>)[
  For $t in [0, 1]$ both $t$ and $1 - t$ are non-negative, hence so is every
  $b_(i,n)(t)$. By the binomial theorem,
  $ sum_(i=0)^n binom(n, i) t^i (1-t)^(n-i) = (t + (1 - t))^n = 1. $
]

#proof(of: <prop-endpoints>)[
  At $t = 0$ the factor $t^i$ vanishes unless $i = 0$, and
  $b_(0,n)(0) = (1 - 0)^n = 1$. At $t = 1$ the factor $(1-t)^(n-i)$ vanishes
  unless $i = n$, and $b_(n,n)(1) = 1$. Hence
  $B(0) = sum_i b_(i,n)(0) P_i = P_0$ and likewise $B(1) = P_n$.
]

#proof(of: <cor-hull>)[
  By @prop-unity, $B(t) = sum_i lambda_i P_i$ with $lambda_i = b_(i,n)(t) >= 0$
  and $sum_i lambda_i = 1$. A convex combination of points lies in their
  convex hull by definition.
]

#proof(of: <prop-affine>)[
  Using linearity of $M$ and @prop-unity,
  $ A(B(t)) = M sum_i b_(i,n)(t) P_i + (sum_i b_(i,n)(t)) v
            = sum_i b_(i,n)(t) (M P_i + v)
            = sum_i b_(i,n)(t) A(P_i). $
]

#proof(of: <thm-casteljau>)[
  By induction on $r$. For $r = 0$, $P_i^((0)) = P_i = b_(0,0)(t) P_i$.
  Assume the claim for $r - 1$. Then
  $ P_i^((r)) &= (1 - t) sum_(j=0)^(r-1) b_(j,r-1)(t) P_(i+j)
                + t sum_(j=0)^(r-1) b_(j,r-1)(t) P_(i+1+j) \
              &= sum_(j=0)^r [(1 - t) b_(j,r-1)(t) + t b_(j-1,r-1)(t)] P_(i+j). $
  By @lem-binomial the bracket equals
  $[binom(r-1, j) + binom(r-1, j-1)] t^j (1-t)^(r-j) = b_(j,r)(t)$.
  With $r = n$ and $i = 0$ the claim reads $P_0^((n)) = B(t)$.
]

== Derivatives, subdivision and reversal

#proof(of: <lem-bernstein-derivative>)[
  By the product rule,
  $ b'_(i,n)(t) = binom(n, i) [i t^(i-1) (1-t)^(n-i) - (n - i) t^i (1-t)^(n-i-1)]. $
  By @lem-binomial, $i binom(n, i) = n binom(n-1, i-1)$; applied to $n - i$
  in place of $i$, with $binom(n, i) = binom(n, n-i)$, it also gives
  $(n - i) binom(n, i) = n binom(n-1, i)$. The two terms are therefore
  $n b_(i-1,n-1)(t)$ and $n b_(i,n-1)(t)$; at $i = 0$ and $i = n$ the
  vanishing term matches the convention $b_(-1,n-1) = b_(n,n-1) = 0$.
]

#proof(of: <thm-hodograph>)[
  By @lem-bernstein-derivative,
  $ B'(t) = n sum_(i=0)^n [b_(i-1,n-1)(t) - b_(i,n-1)(t)] P_i
          = n sum_(i=0)^(n-1) b_(i,n-1)(t) (P_(i+1) - P_i), $
  by shifting the index in the first sum.
]

#proof(of: <cor-end-tangents>)[
  By @thm-hodograph, $B'$ is the curve of degree $n - 1$ with control
  points $n(P_(i+1) - P_i)$, $i = 0, dots, n - 1$; apply @prop-endpoints to
  it.
]

#proof(of: <lem-symmetry>)[
  $ b_(i,n)(1 - t) = binom(n, i) (1-t)^i t^(n-i) = binom(n, n-i) t^(n-i) (1-t)^i = b_(n-i,n)(t). $
]

#proof(of: <prop-reversal>)[
  Re-indexing with $j = n - i$,
  $ sum_(i=0)^n b_(i,n)(t) P_(n-i) = sum_(j=0)^n b_(n-j,n)(t) P_j, $
  and $b_(n-j,n)(t) = b_(j,n)(1 - t)$ by @lem-symmetry, so the sum is
  $B(1 - t)$.
]

#proof(of: <thm-subdivision>)[
  _Left part._ Write $1 - c s = (1 - s) + s(1 - c)$ and expand both powers:
  $ B(c s) &= sum_(i=0)^n binom(n, i) (c s)^i [(1 - s) + s(1 - c)]^(n-i) P_i \
           &= sum_(i=0)^n sum_(k=0)^(n-i) binom(n, i) binom(n-i, k) c^i (1-c)^k s^(i+k) (1-s)^(n-i-k) P_i. $
  Put $j = i + k$ and use $binom(n, i) binom(n-i, j-i) = binom(n, j) binom(j, i)$:
  $ B(c s) = sum_(j=0)^n binom(n, j) s^j (1-s)^(n-j) sum_(i=0)^j binom(j, i) c^i (1-c)^(j-i) P_i
           = sum_(j=0)^n b_(j,n)(s) P_0^((j)), $
  where the inner sum is $P_0^((j))$ at $t = c$ by @thm-casteljau. This is
  the claim for the $L_j$.

  _Right part._ Let $overline(B)$ be the reversed curve, with controls
  $overline(P)_i = P_(n-i)$, so $overline(B)(u) = B(1 - u)$ by
  @prop-reversal. The left part applied to $overline(B)$ at
  $overline(c) = 1 - c$ gives
  $overline(B)(overline(c) s) = sum_j b_(j,n)(s) overline(L)_j$ with
  $ overline(L)_j = sum_(i=0)^j b_(i,j)(1 - c) P_(n-i)
                  = sum_(l=0)^j b_(l,j)(c) P_(n-j+l) = P_(n-j)^((j)) = R_(n-j), $
  using @lem-symmetry, the substitution $l = j - i$, and @thm-casteljau.
  Therefore, again by @lem-symmetry,
  $ B(c + (1 - c) s) = overline(B)((1 - c)(1 - s))
                     = sum_(j=0)^n b_(j,n)(1 - s) R_(n-j)
                     = sum_(j=0)^n b_(n-j,n)(s) R_(n-j)
                     = sum_(k=0)^n b_(k,n)(s) R_k. $
]

#proof(of: <cor-segment>)[
  Write $a = t_0$ and $e = t_1$, so $e > a >= 0$. Splitting at $e$ and
  keeping the left part gives, by @thm-subdivision, the curve
  $u |-> B(e u)$. Splitting that curve at $a slash e in [0, 1)$ and keeping
  the right part gives
  $ s |-> B(e (a/e + (1 - a/e) s)) = B(a + (e - a) s). $
]

== Cubic segments and paths

#proof(of: <prop-bbox>)[
  Expanding the cubic Bernstein form,
  $ B(t) = (1-t)^3 P_0 + 3t(1-t)^2 P_1 + 3t^2(1-t) P_2 + t^3 P_3
         = a t^3 + b t^2 + c t + P_0 $
  with $a$, $b$, $c$ as stated. Each coordinate $B_k$ is continuous on the
  compact interval $[0, 1]$, so it attains its minimum and maximum there.
  An extremum at an interior point $t^*$ is a critical point,
  $B'_k(t^*) = 3 a_k t^(*2) + 2 b_k t^* + c_k = 0$; otherwise it lies at
  $0$ or $1$. If $B'_k$ is identically zero, $B_k$ is constant and every
  candidate gives the extremum. The minima and maxima found are values of
  the curve, so no smaller box contains it.
]

#proof(of: <lem-basis-elevation>)[
  _1._ For $n = 0$ both sides vanish. For $n >= 1$, @lem-binomial gives
  $i b_(i,n)(t) = n t b_(i-1,n-1)(t)$, so
  $sum_i i b_(i,n)(t) = n t sum_i b_(i-1,n-1)(t) = n t$ by @prop-unity.

  _2._ Multiplying $b_(i,n)(t)$ by $(1 - t) + t = 1$,
  $ b_(i,n)(t) = binom(n, i) t^i (1-t)^(n+1-i) + binom(n, i) t^(i+1) (1-t)^(n-i). $
  Since $binom(n, i) slash binom(n+1, i) = (n + 1 - i) slash (n + 1)$ and
  $binom(n, i) slash binom(n+1, i+1) = (i + 1) slash (n + 1)$, the two terms
  are the stated multiples of $b_(i,n+1)(t)$ and $b_(i+1,n+1)(t)$.
]

#proof(of: <prop-elevation>)[
  _Line._ With $Q_i = P_0 + i/3 (P_3 - P_0)$, by @prop-unity and part 1 of
  @lem-basis-elevation,
  $ sum_(i=0)^3 b_(i,3)(t) Q_i = P_0 + (P_3 - P_0) sum_i i/3 b_(i,3)(t) = P_0 + t (P_3 - P_0). $

  _Quadratic._ By part 2 of @lem-basis-elevation with $n = 2$,
  $ b_(i,2)(t) = (3 - i)/3 b_(i,3)(t) + (i + 1)/3 b_(i+1,3)(t). $
  For quadratic controls
  $R_0 = P_0$, $R_1 = C$, $R_2 = P_3$ this gives
  $ sum_(i=0)^2 b_(i,2)(t) R_i = sum_(k=0)^3 b_(k,3)(t) [k/3 R_(k-1) + (3 - k)/3 R_k], $
  whose controls are $R_0 = P_0$, $1/3 P_0 + 2/3 C$, $2/3 C + 1/3 P_3$ and
  $R_2 = P_3$, as stated. Both identities hold for every $t$, so the
  parameterization is unchanged.
]

#proof(of: <prop-continuity>)[
  Let the join be at the global parameter $u_0$. On its span $S$ is
  evaluated at $s = (u - u_0 + h_S) slash h_S$, and $T$ at
  $s = (u - u_0) slash h_T$. By the chain rule and @cor-end-tangents the
  one-sided derivatives at $u_0$ are $S'(1) slash h_S = 3(P_3 - P_2) slash h_S$
  and $T'(0) slash h_T = 3(Q_1 - Q_0) slash h_T$. The curve is continuous
  since $P_3 = Q_0$, and it is $C^1$ at the join exactly when the two
  derivatives agree. A path of $m$ segments under the uniform
  parameterization has $h_S = h_T = 1 slash m$.
]

== Constructions and interpolation

#proof(of: <prop-endpoint>)[
  By @prop-endpoints, $B(0) = P_0$ and $B(1) = P_3$; by @cor-end-tangents,
  $B'(0) = 3(P_1 - P_0) = D_0$ and $B'(1) = 3(P_3 - P_2) = D_1$. Conversely,
  the cubic Bernstein polynomials form a basis, so a cubic curve has exactly
  one set of controls, and these four conditions determine them:
  $P_0 = B(0)$, $P_3 = B(1)$, $P_1 = P_0 + B'(0) slash 3$,
  $P_2 = P_3 - B'(1) slash 3$.
]

#proof(of: <prop-hermite>)[
  At $t = t_0$ and $t = t_1$ the segment is evaluated at $s = 0$ and
  $s = 1$, so $H(t_0) = P_0$ and $H(t_1) = P_3$ by @prop-endpoints. By the
  chain rule $H'(t) = B'(s) slash h$. By @cor-end-tangents,
  $B'(0) = 3(P_1 - P_0) = h D_0$ and $B'(1) = 3(P_3 - P_2) = h D_1$, so
  $H'(t_0) = D_0$ and $H'(t_1) = D_1$. Nothing requires $h > 0$.
]

#proof(of: <thm-hermite-error>)[
  The $x$-coordinate of the segment from `graph_hermite` interpolates the
  linear function $x$ with its derivative 1, so by uniqueness of cubic
  Hermite interpolation it is linear in $x$, and the segment is the graph of
  the cubic polynomial $H$ with $H(x_i) = f(x_i)$ and $H'(x_i) = f'(x_i)$.

  Fix $x in (x_0, x_1)$ and put $w(t) = (t - x_0)^2 (t - x_1)^2$, which is
  positive at $x$. Choose $K$ so that
  $g(t) = f(t) - H(t) - K w(t)$ vanishes at $t = x$. Then $g$ vanishes at
  $x_0$, $x$ and $x_1$, and so does $g'$ at $x_0$ and $x_1$, because $f - H$
  and $w$ both have double roots there. By Rolle's theorem $g'$ has a zero
  in each of $(x_0, x)$ and $(x, x_1)$, hence four distinct zeros in
  $[x_0, x_1]$; repeating, $g''$ has three, $g'''$ two and $g^((4))$ one, at
  some $xi$. Since $H$ is cubic and $w$ is a monic quartic,
  $0 = g^((4))(xi) = f^((4))(xi) - 24 K$, so
  $ f(x) - H(x) = f^((4))(xi) / 24 (x - x_0)^2 (x - x_1)^2. $
  On the interval $|(x - x_0)(x - x_1)| <= h^2 slash 4$, attained at the
  midpoint, so $|f(x) - H(x)| <= M h^4 slash (24 dot 16) = M h^4 slash 384$.
  #citep(<burden2011>)
]

== Fitting and level sets

#proof(of: <cor-depth>)[
  An interval at depth $k$ has width $h = H slash 2^k$. On it, each
  coordinate of the Hermite segment interpolates the corresponding
  coordinate of $C$ with its derivative at both ends (@prop-hermite), so it
  is the cubic Hermite interpolant of that coordinate, and
  @thm-hermite-error bounds its error by $M h^4 slash 384$. The Euclidean
  error is therefore at most $sqrt(d) M h^4 slash 384$ everywhere, in
  particular at the probe parameters, where the measured error is taken.
  This is at most $epsilon$ when
  $2^(4k) >= sqrt(d) M H^4 slash (384 epsilon)$, that is, for the stated
  $k$.
]

#proof(of: <prop-rdp>)[
  Consider the recursive step on the vertices with indices $i < j$. We show
  by induction on $j - i$ that for any two consecutive indices $u < v$ it
  returns, every vertex strictly between $u$ and $v$ lies within the
  tolerance of the chord $P_u P_v$. If $j <= i + 1$ there is no vertex in
  between. If the farthest vertex from the chord $P_i P_j$ is within the
  tolerance, the step returns $(i, j)$ and the claim holds. Otherwise it
  returns the results for $(i, m)$ and $(m, j)$, $i < m < j$, joined at
  $m$; each consecutive pair comes from one of the two calls, and the
  induction hypothesis applies. The outer algorithm runs this step between
  consecutive kept vertices, and every output segment joins two
  consecutive returned indices. Distances are to the chord as a segment, the
  same distance that `fit_error` reports.
]

#proof(of: <thm-gradient>)[
  Since $nabla F(p) != 0$, assume $F_y(p) != 0$; the case $F_x(p) != 0$ is
  symmetric with the roles of $x$ and $y$ exchanged. By the implicit
  function theorem there is a $C^1$ function $phi$ near $p_x$ with
  $phi(p_x) = p_y$ such that near $p$ the level set is the graph
  $gamma(x) = (x, phi(x))$. Differentiating $F(gamma(x)) = c$ gives
  $F_x + F_y phi' = 0$, so
  $ gamma'(x) = (1, -F_x / F_y) = 1 / F_y (F_y, -F_x), $
  which is parallel to $(F_y, -F_x)$ at $p$.
]

== Export

#proof(of: <prop-rounding>)[
  Let $tilde(P)_i = P_i + delta_i$ with $|delta_(i,k)| <= epsilon$ for every
  coordinate $k$. The perturbed curve differs from $B$ by
  $tilde(B)(t) - B(t) = sum_i b_(i,n)(t) delta_i$. By @prop-unity, on each
  coordinate
  $ |sum_i b_(i,n)(t) delta_(i,k)| <= sum_i b_(i,n)(t) |delta_(i,k)| <= epsilon, $
  so the Euclidean distance is at most $sqrt(d epsilon^2) = epsilon sqrt(d)$.
  Rounding a number to $p$ decimal places changes it by at most
  $1/2 dot 10^(-p)$; the exporters' replacement of values smaller than that
  by $0$ is a rounding of the same size.
]

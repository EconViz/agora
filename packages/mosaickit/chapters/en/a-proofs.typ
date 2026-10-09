#import "/template/manual.typ": *

= Proofs <app-proofs>

This appendix proves the lemmas, propositions, theorems and corollaries in
the order they appear in the chapters. The proofs assume exact arithmetic.
The code computes the same quantities in floating point, so it may decide a
configuration either way when it is within rounding error of a degenerate
case, such as a point on an edge or three nearly collinear points. For plane
vectors $u, v$, define $u times v = u_x v_y - u_y v_x$.

== Packing and lanes

#proof(of: <thm-spread>)[
  _Change of variables._ Put $o_k = sum_(j < k) (s_j + g) + s_k slash 2$,
  $y_k = x_k - o_k$ and $z_k = c_k - o_k$. Since
  $o_(k+1) - o_k = (s_k + s_(k+1)) slash 2 + g$, the constraints of
  @def-packing read $y_1 <= dots.c <= y_n$, and the objective is
  $sum_k (y_k - z_k)^2$. The problem is therefore to find the closest
  non-decreasing vector to $z$ in the least-squares sense.

  _What the code computes._ A cluster $B$ of consecutive items starting at
  $i$, with start $S_B$, places item $k in B$ at
  $ x_k = S_B + sum_(i <= l < k) (s_l + g) + s_k slash 2 = S_B + o_k - O_i, $
  where $O_i = sum_(l < i) (s_l + g)$. Hence $y_k = S_B - O_i =: Y_B$ is
  constant on $B$, and the code's choice of $S_B$ as the mean of
  $c_k - (o_k - O_i)$ makes $Y_B$ the mean of $z_k$ over $B$; a new item
  alone has $Y = z_k$. Clusters $A$ and $B$ (with $B$ after $A$) are left
  apart when $S_A + "length"(A) + g <= S_B$; since
  $"length"(A) + g = O_(i_B) - O_(i_A)$, this says $Y_A <= Y_B$. The code is
  therefore the pool-adjacent-violators algorithm: append $z_k$ as a block,
  and while the last two blocks have decreasing means, replace them by
  their union with its mean.

  _Invariants._ (a) Consecutive blocks have non-decreasing means: merging
  stops exactly when the last pair is in order, and earlier pairs are not
  touched. (b) In every block $B$ with mean $mu_B$, every initial segment
  has mean at least $mu_B$. A single item satisfies (b). When $A$ and $B$
  merge, $mu_A > mu_B$, and the merged mean $mu$ lies strictly between them.
  An initial segment inside $A$ has mean at least $mu_A > mu$. Any other
  initial segment is $A$ followed by an initial segment $B'$ of $B$; if
  $B'$ is all of $B$ its mean is $mu$, and otherwise the rest $B''$ of $B$
  has mean at most $mu_B < mu$ by (b) for $B$, so the segment, being the
  complement of $B''$ in a set with mean $mu$, has mean at least $mu$.

  _Optimality._ The objective is strictly convex and the constraints
  $y_k - y_(k+1) <= 0$ are linear, so a point satisfying the
  Karush–Kuhn–Tucker conditions is the unique minimizer
  #citep(<boyd2004>). Let $lambda_k = 2 sum_(l <= k) (z_l - y_l)$ for
  $k = 0, dots, n$. Stationarity,
  $2 (y_k - z_k) + lambda_k - lambda_(k-1) = 0$, holds by construction.
  Within a block the deviations $z_l - Y_B$ sum to zero, so $lambda$ is zero
  at every block end, $lambda_n = 0$ included. Inside a block starting at
  $i$, $lambda_k = 2 sum_(l=i)^k (z_l - Y_B) >= 0$ by (b). Finally
  $lambda_k > 0$ only when $k$ and $k + 1$ lie in the same block, where
  $y_k = y_(k+1)$ and the constraint is tight. With (a) for feasibility, all
  conditions hold.
]

#proof(of: <cor-spread>)[
  (i) Number the items in sorted order and let $i < j$. Summing the
  constraints from $i$ to $j - 1$,
  $ x_j - x_i >= sum_(k=i)^(j-1) ((s_k + s_(k+1)) slash 2 + g) >= (s_i + s_j) slash 2 + g $
  since every term is non-negative and the first and last contribute
  $s_i slash 2$ and $s_j slash 2$. (ii) If $c$ is a packing, it attains the
  objective $0$, so it is the unique minimizer of @thm-spread. (iii) With
  the notation of that proof,
  $ sum_(k in B) (x_k - c_k) = sum_(k in B) (y_k - z_k) = |B| Y_B - sum_(k in B) z_k = 0. $
]

#proof(of: <thm-lanes>)[
  An interval joins a lane only when it conflicts with nothing in it, and it
  never moves afterwards, so the result is a lane assignment. Any lane
  assignment puts $omega$ pairwise conflicting intervals in $omega$ distinct
  lanes, so at least $omega$ lanes are needed.

  Conversely, write $J = [a_J, b_J]$ and suppose the intervals come in
  increasing order of $a$. By @def-conflict, $I$ and $J$ conflict exactly
  when the half-open intervals $[a_I, b_I + g)$ and $[a_J, b_J + g)$ meet.
  Let $I$ be an interval placed in the highest lane $k$ used. Each lane
  $j < k$ held, when $I$ came, an interval $J_j$ conflicting with $I$. Each
  $J_j$ came earlier, so $a_(J_j) <= a_I$, and conflicting with $I$ it has
  $b_(J_j) + g > a_I$. Hence every $[a_(J_j), b_(J_j) + g)$ contains $a_I$,
  and so does $[a_I, b_I + g)$ because $b_I - a_I + g > 0$. Half-open
  intervals sharing a point meet pairwise, so $J_0, dots, J_(k-1), I$ are
  $k + 1$ pairwise conflicting intervals and $k + 1 <= omega$.
]

== Rectangles, segments and polygons

#proof(of: <lem-nearest>)[
  $|q - p|^2 = (q_x - p_x)^2 + (q_y - p_y)^2$, and $R$ is the product of
  $[x_0, x_1]$ and $[y_0, y_1]$, so the two coordinates are minimized
  separately. On an interval, $t |-> (t - p_x)^2$ is strictly convex with
  unconstrained minimum at $p_x$, so its minimum over $[x_0, x_1]$ is
  attained only at $min(max(p_x, x_0), x_1)$; likewise for $y$.
]

#proof(of: <lem-orient>)[
  Subtracting the first row from the others,
  $ "orient"(a, b, c) = det mat(1, a_x, a_y; 1, b_x, b_y; 1, c_x, c_y). $
  A cyclic permutation of the rows is even and a swap is odd, which gives
  the symmetries. Also
  $ "orient"(a, b, c) = (b - a) times (c - a) = |b - a| |c - a| sin theta, $
  where $theta$ is the signed angle from
  $b - a$ to $c - a$; it is positive exactly when $theta in (0, pi)$, that
  is when $c$ is left of the directed line, negative when it is right, and
  zero exactly when the two vectors are parallel or one vanishes, that is
  when the points are collinear.
]

#proof(of: <thm-segments>)[
  First observe that if $"orient"(c, d, p) = 0$ and $p$ lies in the bounding box
  of $[c, d]$, then $p in [c, d]$. Indeed, if $c = d$ the box is the point
  $c$; otherwise $p = c + t (d - c)$ for some real $t$ by collinearity, and
  on a coordinate where $d - c$ is non-zero the box condition forces
  $t in [0, 1]$.

  _If._ Suppose $d_1 d_2 < 0$ and $d_3 d_4 < 0$. The orientation
  $"orient"(c, d, dot)$ is affine along $[a, b]$ and changes sign, so
  $[a, b]$ meets the line $L_(c d)$ at one point; likewise $[c, d]$ meets
  $L_(a b)$. The lines are not parallel, since $a$ and $b$ lie on opposite sides of
  $L_(c d)$, so they share exactly one point $z$, and
  both crossing points equal $z$, which therefore lies on both segments. In
  the other case some $d_i = 0$ and its endpoint lies in the other segment's
  box, hence on the other segment by the note.

  _Only if._ Let $z$ be a common point. If $d_1 d_2 > 0$, then $a$ and $b$
  lie strictly on one side of $L_(c d)$, and so does all of $[a, b]$,
  contradicting $z in L_(c d)$; so $d_1 d_2 <= 0$, and likewise
  $d_3 d_4 <= 0$. If both are negative we are done. Otherwise some $d_i$ is
  zero; say $d_1 = 0$, the other cases being symmetric. If $d_2 != 0$,
  $[a, b]$ meets $L_(c d)$ only at $a$, so $z = a$ and $a in [c, d]$: the
  test for $d_1$ succeeds. If $d_2 = 0$ too, all four points are collinear,
  the segments are overlapping intervals of one line, and an endpoint of
  one lies in the other, so one of the four tests succeeds.
]

#proof(of: <lem-rect-segment>)[
  The edges of $R$ lie in $R$, so either test succeeding gives a common
  point (@thm-segments). Conversely, let $[a, b]$ meet $R$ while neither
  endpoint lies in $R$. The segment is connected and contains points in
  $R$ and outside it, so it meets the boundary of $R$, which is the union of
  the four edges; @thm-segments detects that edge.
]

#proof(of: <lem-segment-distance>)[
  $t |-> |a + t (b - a) - p|^2$ is a convex quadratic with unconstrained
  minimum at $(p - a) dot (b - a) slash |b - a|^2$; over $[0, 1]$ its
  minimum is at the clamp of that value, as in the proof of
  @lem-nearest.
]

#proof(of: <prop-even-odd>)[
  Write $p = (x, y)$ and choose $epsilon > 0$ smaller than every positive
  difference $|y_i - y|$ between a vertex height and $y$, and small enough
  that $p_epsilon = (x, y + epsilon)$ lies in the same component of
  $RR^2 without partial P$ as $p$ (possible because $p in.not partial P$ and
  the components are open). No vertex lies on the line $Y = y + epsilon$,
  and for every vertex $y_i > y$ if and only if $y_i > y + epsilon$. So an
  edge passes the code's height test exactly when it crosses the line
  $Y = y + epsilon$, at the abscissa
  $ X_epsilon = x_0 + (y + epsilon - y_0)(x_1 - x_0) slash (y_1 - y_0). $
  The code compares $x$ with $X_0$. If $x = X_0$, the point $(X_0, y)$ lies
  on the edge, because the height test puts $y$ between the endpoint
  heights, and $p in partial P$, which is excluded; so $x != X_0$, and by
  continuity $x < X_0$ if and only if $x < X_epsilon$ for small $epsilon$.
  Hence the code counts the edges crossed by the rightward ray from
  $p_epsilon$, which passes through no vertex. Each such crossing moves the
  ray between the interior and the exterior, and far to the right it is
  outside, so the count is odd exactly when $p_epsilon in "int" P$, that is
  when $p in "int" P$ #citep(<haines1994>).
]

#proof(of: <thm-rect-inside>)[
  If $R subset "int" P$, then $R$ misses $partial P$, so no edge touches it
  (@lem-rect-segment), and its corners lie in $"int" P$, off the boundary,
  so they pass the even-odd test (@prop-even-odd). Conversely, if no edge
  touches $R$, then $R inter partial P = emptyset$ (@lem-rect-segment); in
  particular the corners are off the boundary, and passing the test puts
  them in $"int" P$. Since $R$ is connected and misses $partial P$, it lies in
  one component of $RR^2 without partial P$; it contains a corner of
  $"int" P$, so $R subset "int" P$.
]

#proof(of: <cor-rect-overlap>)[
  If a corner passes the test, it lies in $"int" P$ when it is off the
  boundary (@prop-even-odd) and in $partial P$ otherwise; either way
  $R inter overline(P) != emptyset$. If an edge touches $R$, then $R$ meets
  $partial P$. Conversely, suppose $R$ meets $overline(P)$. If it meets
  $partial P$, some edge touches it. Otherwise $R$ misses $partial P$ and
  meets $"int" P$, so, being connected, $R subset "int" P$ and its corners
  pass the test.
]

#proof(of: <prop-ray-exit>)[
  Suppose $p = o + t r in partial P$ for some $t > T$, on an edge $e$. If $e$
  is not parallel to $r$, the code solves $o + t r = a + u (b - a)$ for $e$
  and finds this $t >= 0$ with $u in [0, 1]$, so $T >= t$, a contradiction.
  If $e$ is parallel to $r$, it lies on the ray's line $ell$. Take the
  maximal run of consecutive edges on $ell$ containing $e$. It is not all of
  $P$, whose vertices are not all collinear, so each end of the run is a
  vertex shared with an edge not on $ell$, hence not parallel to $r$.
  Consecutive edges of the run cannot double back, since two edges leaving
  a vertex in the same direction along $ell$ would overlap and $P$ is
  simple; so the run is a segment of $ell$ whose far end, in the direction
  $r$, is an end vertex $v = o + t_v r$ with $t_v >= t > T$. The adjacent
  non-parallel edge contains $v$ (with $u in {0, 1}$), so $T >= t_v$, again
  a contradiction. Thus ${o + t r : t > T}$ misses $partial P$; it is
  connected and unbounded, so it lies in the exterior.
]

== The pole of inaccessibility

#proof(of: <lem-lipschitz>)[
  For any set $S$, $|d(p, S) - d(q, S)| <= |p - q|$ by the triangle
  inequality, which settles the case of $p, q$ on the same side. Let
  $p in overline(P)$ and $q in.not overline(P)$, and let $z$ be the last
  point of $overline(P)$ on the segment from $p$ to $q$ (it exists since
  $overline(P)$ is closed). Points just past $z$ are outside, so
  $z in.not "int" P$ and $z in partial P$. Then
  $ |f(p) - f(q)| = d(p, partial P) + d(q, partial P) <= |p - z| + |z - q| = |p - q|. $
]

#proof(of: <thm-polylabel>)[
  The code computes $f$ exactly: off the boundary the sign is right by
  @prop-even-odd, and on it the distance is $0$. Let $b$ denote the best
  value so far; it only increases, and is always $f$ of an evaluated centre.

  _Termination._ Each split halves the half-size $h$. When a cell with
  $h sqrt(2) <= epsilon$ is popped, $b >= f(c)$ after the update, so its
  bound exceeds $b$ by at most $h sqrt(2) <= epsilon$ and it is dropped,
  not split. The cells therefore form a finite tree, each pushed and popped
  once.

  _Invariant._ Every point of the bounding box lies in the closed square of
  a cell that is either in the queue or was dropped with
  $f(c) + h sqrt(2) <= b + epsilon$ for the $b$ of that moment. The initial
  squares, laid from the lower left corner in steps of the shorter side
  until they pass the far edges, cover the box; dropping keeps the
  invariant by the drop rule; splitting replaces a square by four that
  cover it.

  _Conclusion._ At the end the queue is empty. Let $p^*$ be a pole; it lies
  in $overline(P)$, inside the box, in the square of a dropped cell with
  centre $c$ and half-size $h$. By @lem-lipschitz and
  $|p^* - c| <= h sqrt(2)$,
  $ f^* = f(p^*) <= f(c) + h sqrt(2) <= b + epsilon <= f(q) + epsilon, $
  where $q$ is the returned point and $f(q)$ the final $b$. If
  $f^* > epsilon$ then $f(q) > 0$, so $q$ is at positive distance from
  $partial P$ inside $overline(P)$, that is in $"int" P$.
]

#proof(of: <prop-brace>)[
  Write $r$ for the radius and $sigma = delta slash 2r >= 1$ for the
  stretch. Before stretching, the curve consists of: the arc $A_1$ of the
  circle of centre $(0, ell + r)$ from angle $-90 degree$ to $0 degree$; the
  segment $u = r$ from $v = ell + r$ to $v = m - r$; the arc $A_2$ of centre
  $(2 r, m - r)$ from $180 degree$ to $90 degree$; the arc $A_3$ of centre
  $(2 r, m + r)$ from $270 degree$ to $180 degree$; the segment $u = r$ from
  $m + r$ to $h - r$; and the arc $A_4$ of centre $(0, h - r)$ from
  $0 degree$ to $90 degree$. (When $r = (h - ell) slash 4$ the segments have
  length zero.) It starts at $(0, ell)$, ends at $(0, h)$, and $A_2$ and
  $A_3$ meet at $(2 r, m)$, which the stretch $(u, v) |-> (sigma u, v)$
  sends to $(delta, m)$.

  (i) On $A_1$ and $A_4$, $u in [0, r]$; on the segments $u = r$; on $A_2$
  and $A_3$, $u in [r, 2 r]$. After stretching, $u in [0, delta]$.

  (ii) The reflection $v |-> ell + h - v$ swaps the centres of $A_1$ and
  $A_4$ and of $A_2$ and $A_3$, maps angles $theta |-> -theta$, and so maps
  $A_1$ onto $A_4$, $A_2$ onto $A_3$, and the two segments onto each other.

  (iii) Along an arc traversed with increasing angle the direction of
  motion is $(-sin theta, cos theta)$, and with decreasing angle
  $(sin theta, -cos theta)$. At the end of $A_1$ ($theta = 0$) and the start
  of $A_2$ ($theta = 180 degree$) both give $(0, 1)$, the direction of the
  segment between them; likewise at the end of $A_3$ and the start of $A_4$.
  At the tip, $A_2$ arrives with direction $(1, 0)$ ($theta = 90 degree$)
  and $A_3$ leaves with $(-1, 0)$ ($theta = 270 degree$): a cusp. The stretch
  and the final placement are invertible affine maps, which carry tangent
  directions along and keep them non-zero, so continuity and the cusp
  survive.
]

== Labels

#proof(of: <lem-crossing>)[
  A common point satisfies $a + t r = c + u s$ with $r = b - a$ and
  $s = d - c$. Taking the cross product with $s$ removes $u$:
  $t (r times s) = (c - a) times s$. A proper crossing puts $a$ and $b$
  strictly on opposite sides of $L_(c d)$, so the lines are not parallel,
  $r times s != 0$, and the point is unique. Since $"orient"(c, d, dot)$ is
  affine along $[a, b]$ with opposite signs at the ends, its zero is at
  some $t in (0, 1)$.
]

#proof(of: <prop-callout>)[
  The code keeps one best candidate and replaces it only by a candidate
  with a strictly smaller key, so after any prefix of the enumeration it
  holds the first candidate with the smallest key seen. After the near ring,
  if the smallest charge is $0$, the smallest key is $(0, ell_min)$ and the
  search stops: the result is the first zero-charge candidate with the
  shortest leader. Otherwise the far ring is enumerated with the same best
  candidate, and the result is the first candidate with the smallest key
  over both rings. Every step is a function of the arguments (the pole, the
  exit distances, the open area, the crossings), with no randomness and a
  fixed enumeration order.
]

== Styles, themes and binding

#proof(of: <prop-monoid>)[
  Per field the merge is the operation $x circle.small y = x$ if
  $x != "None"$ and $y$ otherwise. Both $(x circle.small y) circle.small z$
  and $x circle.small (y circle.small z)$ equal the first of $x, y, z$ that is
  not `None` (or `None`), `None` is a two-sided identity, and
  $x circle.small x = x$. Styles are equal when their fields are, which gives
  (i)–(iii), and induction gives the first-non-`None` description. For
  bundles the same holds slot by slot, a `None` slot behaving as the empty
  style.
]

#proof(of: <prop-hex>)[
  A pair of hex digits $k in {0, dots, 255}$ is read as $k slash 255$ and
  written as the two upper-case digits of $"round"(255 dot k slash 255)$.
  In double precision the computed product differs from $k$ by at most
  $255 dot 2^(-52) < 1 slash 2$, so it rounds to $k$. The alpha pair is
  written exactly when `include_alpha` is true, that is for the nine-character
  form. A three-digit form doubles each digit before reading.
]

#proof(of: <thm-resolution>)[
  Write $triangle.r$ for the merge. Resolution starts from $D$ and, for the
  mappings $T$, $G$, $C$ in that order, merges $M[k_n], dots, M[k_1]$ over
  the result in that order (least specific first), a missing key giving the
  empty bundle; the layer's explicit bundle $E$, built from the fields named
  in `style_slots`, is merged last. Unwinding, and using associativity
  (@prop-monoid) to drop the brackets, the resolved bundle is
  $ E triangle.r C[k_1] triangle.r dots.c triangle.r C[k_n] triangle.r
    G[k_1] triangle.r dots.c triangle.r T[k_n] triangle.r D, $
  whose fields are the first non-`None` values in that order. Binding the
  palette afterwards replaces color names by colors and leaves the other
  fields alone.
]

#proof(of: <cor-override>)[
  A text layer with role `axes.note` has the chain (`axes.note`, `axes`,
  `text`), and in the sequence of @thm-resolution the entry $G["text"]$
  comes before $T["axes.note"]$. By hypothesis no earlier entry sets the
  size, so the first non-`None` size is that of $G["text"]$.
]

#proof(of: <thm-binding>)[
  By induction on $e$. If $"free"(e) subset.eq "dom" beta$ (in particular for
  constants and for parameters in $"dom" beta$), $"bind"(e, beta)$ is the
  plain value $e(beta)$: it has no free parameters, as (i) requires, and
  evaluates to $e(beta) = e(beta union gamma)$, since the value of an
  expression depends only on the values of its free parameters. If $e$ is a
  parameter $p in.not "dom" beta$, the result is $p$, with
  $"free" = {p} = "free"(e) without "dom" beta$ and value
  $gamma(p) = (beta union gamma)(p)$. Otherwise
  $e = e_1 circle.small e_2$ and the result is
  $"bind"(e_1, beta) circle.small "bind"(e_2, beta)$ (plain values wrapped as
  constants). Its free parameters are
  $("free"(e_1) without "dom" beta) union ("free"(e_2) without "dom" beta)
   = "free"(e) without "dom" beta$, and $gamma$ binds those of each part, so
  by induction its value is
  $e_1(beta union gamma) circle.small e_2(beta union gamma) = e(beta union gamma)$.
]

#proof(of: <cor-stages>)[
  By @thm-binding (i) twice, both have the free parameters
  $"free"(e) without "dom" (beta_1 union beta_2)$. For a binding $gamma$ of
  them, disjoint from $beta_1$ and $beta_2$, (ii) twice gives
  $"bind"("bind"(e, beta_1), beta_2)(gamma)
   = "bind"(e, beta_1)(beta_2 union gamma) = e(beta_1 union beta_2 union gamma)
   = "bind"(e, beta_1 union beta_2)(gamma)$. A canvas binds every
  expression in its scene in this way.
]

#proof(of: <prop-grid-shape>)[
  From $r = ceil(n slash c)$, $r c >= n > (r - 1) c$, so the first $r - 1$
  rows are full and the last holds $n - (r - 1) c in [1, c]$ cells, leaving
  $r c - n < c$ empty. From $c = ceil(sqrt(n))$, $n <= c^2$, so
  $n slash c <= c$ and $r <= c$.
]

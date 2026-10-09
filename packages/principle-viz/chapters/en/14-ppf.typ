#import "/template/manual.typ": *

= Production possibilities <sec-ppf>

#api(("ProductionPossibilitiesFrontier",), syntax: [
  #raw("ProductionPossibilitiesFrontier(x_intercept, y_intercept, curvature=1.0, x_good=\"Good X\", y_good=\"Good Y\")")
])[
  The frontier
  $ y = Y (1 - (x slash X)^c), $
  through the intercepts $X$ and $Y$. A curvature $c = 1$ gives a straight
  line (constant opportunity cost); $c > 1$ bows it out (increasing
  opportunity cost). Intercepts and curvature must be positive and
  $c >= 1$, otherwise `PPFError` is raised.
]

#param("y_at(x)")[Output of $y$ when $x$ units of the first good are produced.]
#param("opportunity_cost_x(x)")[Units of $y$ given up for one more unit of $x$, $abs(dif y slash dif x)$.]
#param("assess(x, y)")[A `PointStatus`: `EFFICIENT` on the frontier, `INEFFICIENT` inside it, `UNATTAINABLE` outside.]

```python
from principle_viz import ProductionPossibilitiesFrontier

ppf = ProductionPossibilitiesFrontier(
    10, 8, curvature=2,
    x_good="Consumer goods", y_good="Capital goods",
)
print(ppf.y_at(6), ppf.opportunity_cost_x(6))  # 5.12 0.96
print(ppf.assess(4, 3), ppf.assess(7, 6))
# PointStatus.INEFFICIENT PointStatus.UNATTAINABLE
```

#api(("analyze_ppf", "ppf_canvas"), syntax: [
  #raw("analyze_ppf(")#meta("frontier")#raw(", points=(), *, samples=101)") \
  #raw("ppf_canvas(")#meta("result")#raw(", *, theme=None, labels=None, visibility=None)")
])[
  Sample the frontier and assess named points, given as `(x, y, label)`
  triples; `ppf_canvas()`, in `principle_viz.visuals.ppf`, draws it with the
  attainable set shaded and the points labelled (@fig-ppf).
]

```python
from principle_viz import analyze_ppf
from principle_viz.visuals.ppf import ppf_canvas

points = ((6, ppf.y_at(6), "A"), (4, 3, "B"), (7, 6, "C"))
result = analyze_ppf(ppf, points=points)
ppf_canvas(result).save("ppf_points.png")
```

#fig("/figures/ppf/points.svg", width: 46%, caption: [
  Efficient, inefficient and unattainable points.
]) <fig-ppf>

#api(("PPFGrowthScenario", "analyze_ppf_growth", "ppf_growth_canvas"), syntax: [
  #raw("PPFGrowthScenario(x_growth_rate=0.0, y_growth_rate=0.0)") \
  #raw("analyze_ppf_growth(")#meta("frontier")#raw(", ")#meta("scenario")#raw(", *, samples=101)") \
  #raw("ppf_growth_canvas(")#meta("result")#raw(", *, theme=None, labels=None, visibility=None)")
])[
  Economic growth scales each intercept by one plus its growth rate; the
  result holds the `baseline` and `shifted` frontiers and their sampled
  points. `ppf_growth_canvas()` draws both, named $P P F_0$ and $P P F_1$
  (see @fig-ppf-growth).
]

#fig("/figures/ppf/growth.svg", width: 46%, caption: [
  Growth of 20% in consumer goods and 10% in capital goods.
]) <fig-ppf-growth>

== Comparative advantage <sec-comparative-advantage>

#api(("compare_linear_ppfs",), syntax: [
  #raw("compare_linear_ppfs(name_a, frontier_a, name_b, frontier_b)")
])[
  For two straight-line frontiers, the opportunity cost of $x$ for each
  producer and who has the comparative advantage in each good (`"tie"` when
  the costs are equal). Curved frontiers raise `PPFError`.
]

```python
from principle_viz import compare_linear_ppfs

ann = ProductionPossibilitiesFrontier(10, 5)  # x costs 0.5 y
bob = ProductionPossibilitiesFrontier(6, 6)   # x costs 1 y
result = compare_linear_ppfs("Ann", ann, "Bob", bob)
print(result.comparative_advantage_x, result.comparative_advantage_y)
# Ann Bob
```

Ann has the comparative advantage in $x$ (0.5 against 1) and Bob in $y$
(1 against 2).

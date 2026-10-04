#import "/template/manual.typ": *

= Introduction <sec-intro>

#changed("0.1.0")[Initial release as `principle-econ`: linear markets, taxes, welfare, plotting and a command-line interface]
#changed("0.10.0")[Renamed from `principle-econ` to #pkg("principle-viz"), joining the EconViz family; the Python package is `principle_viz`]
#changed("0.10.0")[Figures are built on #pkg("mosaickit") (`mosaickit>=0.5.1,<0.6.0`)]
#changed("0.10.0")[Project tooling moved from Poetry to #pkg("uv")]
#changed("0.10.1")[CI tests Python 3.10--3.13]

The #pkg("principle-viz") package is a Python toolkit for the market diagrams
of a principles-of-economics course: supply and demand, equilibrium and its
shifts, taxes and subsidies, price controls, welfare, international trade,
market failures, factor markets and the production possibilities frontier.
Every topic comes as a calculation, which returns plain numbers, and as a
figure drawn in the conventions of the textbooks: curves named at their
ends rather than in a legend, welfare areas named inside them, values marked
on the axes, and labels placed so they cover nothing.

== Scope

Markets are *linear*. A demand or supply curve is a straight line in the
inverse form
$ p = a + b Q, $
where $a$ is the price intercept and $b$ the slope ($b < 0$ for demand,
$b > 0$ for supply). Price is always on the vertical axis and quantity on the
horizontal one, as in #citet(<marshall1890>). Two extensions leave the
straight line: discrete unit schedules (@sec-discrete), and market curves
summed from individual curves, which are piecewise linear
(@sec-aggregation).

The package keeps calculation and drawing apart. The solvers in
`principle_viz.core`, `principle_viz.policy` and `principle_viz.welfare`
return frozen dataclasses and never import a plotting library; the figures in
`principle_viz.plot` take those results and turn them into #pkg("mosaickit")
scenes. A result can therefore be printed, tested, sent to JSON by the
command-line tool, or drawn.

#pkg("principle-viz") belongs to the EconViz family of packages. Its
sibling #pkg("utility-viz") covers consumer theory: indifference curves,
budget constraints and demand derived from utility.

== Reading guide

@tab-guide groups the chapters by topic.

#tbl(caption: [Chapter guide])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([Topic], [Contents], [Section]),
    table.cell(rowspan: 4)[Markets],
    [Lines, equilibrium, shifts], [#ref(<sec-markets>)],
    [Discrete unit schedules], [#ref(<sec-discrete>)],
    [Market curves from individuals], [#ref(<sec-aggregation>)],
    [Elasticity and total revenue], [#ref(<sec-elasticity>)],
    table.cell(rowspan: 3)[Policy],
    [Surplus and deadweight loss], [#ref(<sec-welfare>)],
    [Taxes and subsidies], [#ref(<sec-taxes>)],
    [Price ceilings and floors], [#ref(<sec-controls>)],
    table.cell(rowspan: 4)[Applications],
    [International trade], [#ref(<sec-trade>)],
    [Externalities, public goods, commons], [#ref(<sec-failures>)],
    [Labor and loanable funds], [#ref(<sec-factor>)],
    [Production possibilities], [#ref(<sec-ppf>)],
    table.cell(rowspan: 2)[Tools],
    [Figures, labels, palettes], [#ref(<sec-figures>)],
    [Command line], [#ref(<sec-cli>)],
  )
] <tab-guide>

On first use, read @sec-quickstart, then @sec-markets and @sec-figures. Each
later chapter describes one topic: its calculation first, then its figure.

#import "/template/manual.typ": *

= Introduction <sec-intro>

#changed("0.1.0")[Initial release as `principle-econ`: linear markets, taxes, welfare, plotting and a command-line interface]
#changed("0.10.0")[Renamed from `principle-econ` to #pkg("principle-viz"), joining the EconViz family; the Python package is `principle_viz`]
#changed("0.10.0")[Figures are built on #pkg("mosaickit") (`mosaickit>=0.5.1,<0.6.0`)]
#changed("0.10.0")[Project tooling moved from Poetry to #pkg("uv")]
#changed("0.10.1")[CI tests Python 3.10--3.13]

#pkg("principle-viz") is a Python package for the diagrams of a
principles-of-economics course: supply and demand, equilibrium and its
shifts, taxes and subsidies, price controls, welfare, international trade,
market failures, factor markets and the production possibilities frontier.
Each topic has a calculation, which returns numbers, and a figure drawn in
textbook conventions.

Figures are written as PNG, SVG or PDF; the command-line tool prints
calculation results as JSON.

#pkg("principle-viz") belongs to the EconViz family of packages and draws
with #pkg("mosaickit"), a domain-independent scene and drawing library. Its
sibling #pkg("utility-viz") is a microeconomics package covering utility
models, optimal-bundle solving, indifference curves, budget lines, consumer
equilibrium, demand curves and Edgeworth boxes; #pkg("principle-viz") does
not include these.

== Scope

#pkg("principle-viz") handles linear markets, and its features fall into
four parts: markets, policy, applications and tools. Calculations and
figures can be used separately: a result can be printed, written as JSON or
passed to `MarketFigure` to be drawn.

== Reading guide

The manual is organized in four parts: markets, policy, applications and
tools (see @tab-guide).

#tbl(caption: [Chapter guide])[
  #booktabs(
    columns: (auto, auto, 1fr, auto),
    header: ([Part], [Topic], [Description], [Section]),
    table.cell(rowspan: 4)[Markets],
    [Linear markets],
    [Lines, equilibrium and shifts],
    [#ref(<sec-markets>)],
    [Discrete markets],
    [Unit-by-unit demand and supply schedules],
    [#ref(<sec-discrete>)],
    [Market curves from individuals],
    [Horizontal sum of individual curves],
    [#ref(<sec-aggregation>)],
    [Elasticity and total revenue],
    [Point and arc elasticity, total revenue curve],
    [#ref(<sec-elasticity>)],
    table.cell(rowspan: 3)[Policy],
    [Welfare],
    [Consumer surplus, producer surplus and deadweight loss],
    [#ref(<sec-welfare>)],
    [Taxes and subsidies],
    [Tax wedge and subsidy cost],
    [#ref(<sec-taxes>)],
    [Price controls],
    [Price ceilings, price floors and shortages],
    [#ref(<sec-controls>)],
    table.cell(rowspan: 4)[Applications],
    [International trade],
    [Free trade, tariffs and import quotas],
    [#ref(<sec-trade>)],
    [Market failures],
    [Externalities, common resources and public goods],
    [#ref(<sec-failures>)],
    [Labor and loanable funds],
    [Minimum wage and government borrowing],
    [#ref(<sec-factor>)],
    [Production possibilities],
    [Opportunity cost, growth and comparative advantage],
    [#ref(<sec-ppf>)],
    table.cell(rowspan: 2)[Tools],
    [Figures],
    [Labels, layers and palettes],
    [#ref(<sec-figures>)],
    [Command line],
    [Calculation results as JSON],
    [#ref(<sec-cli>)],
  )
] <tab-guide>

On first use, read @sec-quickstart, @sec-markets and @sec-figures in that
order. Each later chapter covers one topic: the calculation first, then the
figure. For the options of a specific command, go to @sec-cli.

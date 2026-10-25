#import "/template/manual.typ": *

= Introduction <sec-intro>

#changed("0.2.0.dev0")[First manual edition for the development version: producer theory, market structure, factor markets, uncertainty and information]
#changed("0.2.0.dev0")[Figures are built on #pkg("mosaickit") (`mosaickit>=1.0.0rc9,<2.0.0`)]

#pkg("micro-viz") is a Python package for the firm side of microeconomics: production, costs, perfect competition, monopoly and pricing, oligopoly, factor markets, uncertainty and information. Each topic has a model, which answers questions with numbers, and a figure drawn in textbook conventions from that model.

Figures are written as PNG, SVG or PDF. Statistics-style data charts and box-and-arrow flowcharts are outside the package.

#pkg("micro-viz") belongs to the EconViz family of packages and draws with #pkg("mosaickit"), a domain-independent scene and drawing library. Consumer theory and general equilibrium belong to #pkg("utility-viz"); introductory supply-and-demand diagrams belong to #pkg("principle-viz"); game theory is outside the package.

== Scope

The package covers six groups of topics, each with its own chapter (@tab-guide). Models never import a renderer, so a result can be used without drawing, and a builder only places what the model computed.

== Reading guide

#tbl(caption: [Chapter guide])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([Topic], [Description], [Section]),
    [Model and figure],
    [How models, builders, layer ids and panels fit together],
    [#ref(<sec-model-figure>)],
    [Production and costs],
    [Short-run production, cost functions, stepped and kinked cost],
    [#ref(<sec-production-costs>)],
    [Competition],
    [Price-taking firms, industry supply, long-run costs, entry],
    [#ref(<sec-competition>)],
    [Monopoly and pricing],
    [Monopoly, monopolistic competition, regulation, discrimination, tariffs, bundling, advertising, exhaustible resources],
    [#ref(<sec-monopoly>)],
    [Oligopoly],
    [Duopoly, kinked demand, dominant firm, vertical chains],
    [#ref(<sec-oligopoly>)],
    [Inputs and technology],
    [Isoquants, cost minimisation, learning and scope, factor markets, monopsony and unions],
    [#ref(<sec-inputs>)],
    [Uncertainty and information],
    [Expected utility, risk, auctions, adverse selection, signalling, moral hazard],
    [#ref(<sec-uncertainty>)],
    [Settings],
    [The `[micro]` tables of `econ-viz.toml`],
    [#ref(<sec-settings>)],
    [Labels and placement],
    [The locale table, replacing text, moving labels],
    [#ref(<sec-labels>)],
    [Adding a figure],
    [Model, builder, text, export, tests],
    [#ref(<sec-adding>)],
    [Animation],
    [Animating a figure over a parameter],
    [#ref(<sec-animation>)],
  )
] <tab-guide>

On first use, read @sec-quickstart and @sec-model-figure. Each topic chapter then shows the model first and the figures second.

The scripts that draw the figures of this manual come as one zip, sorted by topic: #link("https://econ-viz.org/assets/micro-viz/agora/micro-viz-examples.zip")[micro-viz-examples.zip].

#import "/template/manual.typ": *

= Introduction <sec-intro>

#changed("2.0.0b1")[#modify[Renamed from #pkg("econ-viz") to #pkg("utility-viz"): distribution, import package, command and configuration file]]
#changed("2.0.0b1")[#modify[Internals reorganised into `core` and `models`; the public API is the package root and `utility_viz.models`]]
#changed("2.0.0b1")[#modify[New dependencies #pkg("mosaickit") and #pkg("bezierkit")]]
#changed("2.0.0b1")[#modify[The whole repository passes `mypy`; Ruff enforces line length, complexity and statement limits]]
#changed("1.7.0")[CI tests Python 3.10--3.13, enforces branch coverage, and smoke-tests runnable examples]
#changed("1.12.0")[Focal and secondary indifference-curve levels, with numeric or ordinal labels]
#changed("1.11.0")[Complete theme system: one visual language across canvases, multi-panel figures, demand diagrams, decompositions and Edgeworth boxes]
#changed("1.10.1")[Ships `py.typed`; CI runs Ruff and Mypy]
#changed("1.7.0")[Tagged releases publish only after tests pass]
#changed("1.6.0")[Generated files under `examples/output/` are no longer tracked]
#changed("1.5.0")[New example scripts for decomposition, demand diagrams, PCC/ICC paths, multi-panel layouts and TikZ export]
#changed("1.5.0")[Regression tests for TikZ export and price-effect decomposition]
#changed("1.4.0")[Tests for `Animator` and `WidgetViewer`]
#changed("1.3.2")[Publish workflow skips versions already on PyPI]
#changed("1.3.1")[Package-root exports load lazily, with the public API unchanged]
#changed("1.3.0")[`examples/edgeworth_box.py` covering common utility-function combinations]
#changed("1.3.0")[Dedicated Edgeworth tests]
#changed("1.2.2")[Dedicated PCC/ICC example generator and tests]

The #modify[#pkg("utility-viz")] package is a Python toolkit for producing
publication-quality microeconomics diagrams: indifference curves, budget
constraints, consumer equilibria, demand curves and exchange economies. It
draws in the conventions of textbook figures---first-quadrant axes with
arrow tips, #LaTeX;-style labels and no numeric ticks---and exports to PNG,
PDF, SVG, TikZ or animated GIF.

#modify[Up to version 1.12 the package was called #pkg("econ-viz"). It was
renamed #pkg("utility-viz") in 2.0.0; @sec-migrate describes what changed
and how existing code keeps working. This manual describes the pre-release
2.0.0b1.]

#modify[#pkg("utility-viz") belongs to the EconViz family of packages. It
draws through #pkg("mosaickit"), a domain-neutral scene and rendering
library, and traces curves with #pkg("bezierkit"). The sibling package
#pkg("principle-viz") covers principles-of-economics diagrams.]

== Scope

#modify[#pkg("utility-viz")] is organised in five parts: utility models, equilibrium solving, utility levels, drawing layers, and output formats. Models and solutions remain usable on their own, and the same model can be passed to a canvas, multi-panel figure, demand diagram, or analysis API.

== Reading guide

The manual is organised in four parts (@tab-guide):

#tbl(caption: [Chapter guide])[
  #booktabs(
    columns: (auto, auto, 1fr, auto),
    header: ([Topic], [Subtopic], [Description], [Section]),
    table.cell(rowspan: 4)[Drawing & export],
    [Canvas & layers],
    [Axes, curves, equilibria],
    [#ref(<sec-canvas>)],
    [Figures & demand],
    [Panels & demand],
    [#ref(<sec-figures>)],
    [Themes & config],
    [Colours, styles, config],
    [#ref(<sec-themes>)],
    [Output formats],
    [Image files and TikZ],
    [#ref(<sec-export>)],
    table.cell(rowspan: 3)[Models & analysis],
    [Built-in models],
    [Utility functions],
    [#ref(<sec-models>)],
    [Custom & many-good],
    [Custom, $N$ goods#modify[, scenes]],
    [#ref(<sec-advanced>)],
    [Comparative statics],
    [Derivatives & Slutsky],
    [#ref(<sec-analysis>)],
    table.cell(rowspan: 2)[Animation & interaction],
    [GIF animation],
    [Sweeps as GIFs],
    [#ref(<sec-animation>)],
    [Jupyter widgets],
    [Sliders in notebooks],
    [#ref(<sec-widgets>)],
    table.cell(rowspan: 2)[Other inputs],
    [Command line],
    [Plots from the shell],
    [#ref(<sec-cli>)],
    [#LaTeX parser],
    [Models from formulas],
    [#ref(<sec-latex>)],
  )
] <tab-guide>

On first use, read @sec-quickstart and @sec-canvas in order. To look up a
particular API, go straight to its section or to the command index.
#modify[Users upgrading from #pkg("econ-viz") 1.x should start with
@sec-migrate.]

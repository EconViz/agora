#import "/template/manual.typ": *

= Command-line interface <sec-cli>

#changed("1.7.0", label: "econ-viz")[`econ-viz --version` prints the installed package version]
#changed("1.3.1", label: "econ-viz")[CLI errors raise `CliConfigError`, with exit handling centralised in `cli.main`]
#changed("1.2.3", label: "econ-viz models")[CLI supports `QuasiLinear`, `StoneGeary` and `Translog`]
#changed("1.10.0", label: "econ-viz init")[Configuration-template command and `plot --config`]
#changed("1.11.0", label: "econ-viz plot")[`--theme` accepts every built-in CLI theme]
#changed("2.0.0b1", label: "utility-viz")[The command is now `utility-viz`; `econ-viz` prints a deprecation warning and forwards to it]
#changed("2.0.0b1", label: "utility-viz plot")[Without `--config`, reads `utility-viz.toml` (or legacy `econ-viz.toml`) from the current directory]
#changed("2.0.0b1", label: "utility-viz init")[New `--migrate` option]

The command-line interface plots diagrams, runs batches and prints demand
formulas. Install it as a standalone tool with `uv tool install utility-viz`,
or prefix each command with `uv run` inside a #pkg("uv") project
(@sec-install-cli). The 1.x command `econ-viz`, installed by the
#pkg("econ-viz") compatibility distribution, still works in 2.x: it warns
that it is deprecated and runs `utility-viz` with the same arguments
(@sec-migrate).

#tbl(caption: [CLI commands])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Command], [Description]),
    [#raw("utility-viz help [")#meta("command")#raw("]")],
    [Show help for the CLI or a specific command],
    [`utility-viz models`],
    [List all supported utility models],
    [`utility-viz plot ...`],
    [Generate and export a diagram],
    [`utility-viz solve-tex ...`],
    [Print a closed-form Marshallian demand as TeX],
    [`utility-viz init [path]`],
    [Create an `utility-viz.toml` configuration template],
  )
]

== Help and models

#api(("utility-viz help",), syntax: [#raw("utility-viz help [")#meta("command")#raw("]")])[
  Without an argument, list all commands; with one, show its options.

  ```bash
  utility-viz help          # all commands
  utility-viz help plot     # plot options
  utility-viz help models   # models options
  ```
]

#api(("utility-viz models",))[
  List the model names and parameters the CLI supports. `--model` takes
  kebab-case names, which differ from the Python class names
  (@tab-models). The parameter options are described in @sec-cli-plot.

  #tbl(caption: [CLI models])[
    #booktabs(
      columns: (auto, auto, auto, 1fr),
      header: ([Model], [`--model` value], [Required], [Optional]),
      [Cobb-Douglas], [`cobb-douglas`], [`alpha`, `beta`], [--],
      [CES], [`ces`], [`rho`], [`alpha`, `beta`],
      [Perfect complements], [`leontief`], [`a`, `b`], [--],
      [Perfect substitutes], [`perfect-substitutes`], [`a`, `b`], [--],
      [Satiation], [`satiation`], [`bliss-x`, `bliss-y`], [`a`, `b`],
      [Quasi-linear], [`quasi-linear`], [--], [`v-func`, `linear-in`],
      [Stone-Geary], [`stone-geary`], [--], [`alpha`, `beta`, `bar-x`, `bar-y`],
      [Translog], [`translog`], [--], [`alpha-0`, `alpha-x`, `alpha-y`, `beta-xx`, `beta-yy`, `beta-xy`],
    )
  ] <tab-models>
]

== Plotting <sec-cli-plot>

#api(("utility-viz plot",), syntax: [
  #raw("utility-viz plot --model ")#meta("name")#raw(" ")#meta("options") \
  #raw("utility-viz plot --latex ")#meta("expression")#raw(" ")#meta("options")
])[
  Give the model with `--model`, or the utility function with `--latex`,
  not both. With `--output` the diagram is written to a file; without it an
  interactive window opens.

  The budget line and equilibrium need both prices and income.
  `--no-budget`, `--no-equilibrium` and `--no-curves` each omit one layer
  and can be combined (@tab-plot-flags).

  #tbl(caption: [Layer options])[
    #booktabs(
      columns: (auto, 1fr),
      header: ([Case], [Result]),
      [`--px`, `--py` and `--income` all given], [Budget line drawn and equilibrium solved],
      [Any price or income missing], [Indifference curves only, no budget line or equilibrium],
      [`--no-equilibrium` added], [No solve and no equilibrium, even with prices and income],
      [`--no-budget` added], [Budget line hidden, even with prices and income],
      [`--no-curves` with prices and income], [Budget line and equilibrium only, no indifference curves],
    )
  ] <tab-plot-flags>

  ```bash
  # named model
  utility-viz plot --model cobb-douglas --alpha 0.5 --beta 0.5 ...

  # LaTeX expression
  utility-viz plot --latex "x^{0.4} y^{0.6}" ...
  ```
]

#example([```bash
# Cobb-Douglas, shaded budget set
utility-viz plot --model cobb-douglas --alpha 0.5 --beta 0.5 \
              --px 2 --py 3 --income 30 \
              --fill --output cobb_douglas.png

# LaTeX input, Nord theme, expansion path
utility-viz plot --latex "x^{0.4} y^{0.6}" \
              --px 2 --py 3 --income 30 \
              --theme nord --show-ray \
              --output cd_latex.png

# perfect complements, larger canvas
utility-viz plot --model leontief --a 1 --b 2 \
              --px 2 --py 3 --income 30 \
              --x-max 20 --y-max 15 \
              --output leontief.png

# CES, curves only
utility-viz plot --model ces --rho -0.5 \
              --x-max 20 --y-max 15 --n-curves 6 \
              --no-budget --no-equilibrium \
              --output ces.png

# satiation (bliss point)
utility-viz plot --model satiation --bliss-x 6 --bliss-y 4 \
              --x-max 12 --y-max 10 \
              --no-budget --no-equilibrium \
              --output satiation.png

# no --output: open a window
utility-viz plot --model cobb-douglas --px 2 --py 3 --income 30
```])

=== Model selection

#param("--model, -m")[
  Model name; `utility-viz models` lists them all.
]
#param("--latex, -l")[
  #LaTeX expression for Cobb-Douglas, perfect complements, perfect
  substitutes or CES (@sec-latex).
]

=== Prices and income

#param("--px")[Price of good $x$.]
#param("--py")[Price of good $y$.]
#param("--income")[Consumer income.]

=== Model parameters

#param("--alpha", default: "0.5")[Alpha parameter (Cobb-Douglas, CES).]
#param("--beta", default: "0.5")[Beta parameter (Cobb-Douglas, CES).]
#param("--a", default: "1.0")[Parameter $a$ (perfect complements, perfect substitutes, satiation).]
#param("--b", default: "1.0")[Parameter $b$ (perfect complements, perfect substitutes, satiation).]
#param("--rho", default: "0.5")[Substitution parameter (CES).]
#param("--bliss-x", default: "5.0")[Bliss-point $x$-coordinate (satiation).]
#param("--bliss-y", default: "5.0")[Bliss-point $y$-coordinate (satiation).]

Quasi-linear, Stone-Geary and Translog take these further options:

#param("--v-func", default: "log")[Non-linear function of the quasi-linear model, `log` or `sqrt`.]
#param("--linear-in", default: "y")[Good that enters the quasi-linear model linearly, `x` or `y`.]
#param("--bar-x", default: "1.0")[Stone-Geary subsistence quantity $overline(x)$.]
#param("--bar-y", default: "1.0")[Stone-Geary subsistence quantity $overline(y)$.]
#param("--alpha-0", default: "0.0")[Translog intercept.]
#param("--alpha-x", default: "0.5")[Translog first-order weight on $ln x$.]
#param("--alpha-y", default: "0.5")[Translog first-order weight on $ln y$.]
#param("--beta-xx", default: "0.0")[Translog curvature in $x$.]
#param("--beta-yy", default: "0.0")[Translog curvature in $y$.]
#param("--beta-xy", default: "0.0")[Translog interaction between $x$ and $y$.]

```bash
utility-viz plot --model stone-geary --bar-x 2 --bar-y 2 \
              --px 2 --py 3 --income 30 \
              --x-max 20 --y-max 15 --output stone_geary.png
```

Subsistence spending here is $2 times 2 + 3 times 2 = 10$, below the income
of $30$. With an income of $10$ or less, the solve fails because the budget
lies outside the model's domain.

=== Canvas and layers

#param("--x-max", default: "10")[Horizontal axis limit.]
#param("--y-max", default: "10")[Vertical axis limit.]
#param("--x-label", default: "x")[Horizontal axis label.]
#param("--y-label", default: "y")[Vertical axis label.]
#param("--title")[Figure title.]
#param("--theme", default: "default")[Theme name: `default`, `nord`, `paper`, `monochrome`, `presentation` or `dark` (@sec-themes).]
#param("--config")[Path to a TOML configuration file. Command-line options take precedence over the file. Without it, `utility-viz.toml` (or the legacy `econ-viz.toml`) in the current directory is used if present (@sec-config-lookup).]
#param("--n-curves", default: "5")[Number of indifference curves.]
#param("--dpi", default: "300")[Raster output resolution.]
#param("--fill")[Shade the feasible set below the budget line.]
#param("--show-ray")[Draw the expansion-path ray through the optimum.]
#param("--no-budget")[Omit the budget line.]
#param("--no-equilibrium")[Omit the equilibrium point.]
#param("--no-curves")[Omit the indifference curves.]
#param("--output, -o")[
  Output file (`.png`, `.pdf`, `.svg`, `.tex`); omit it to open an
  interactive window.
]

For batch runs, give each parameter set its own file name and create the
output directory first. `--x-max` and `--y-max` do not follow the prices;
when an intercept or the optimum falls outside the canvas, raise the limits
as well.

== Creating a configuration file <sec-cli-init>

#api(("utility-viz init",), added: "v1.10.0", syntax: [
  #raw("utility-viz init [")#meta("path")#raw("] [--force]")#raw(" [--migrate]")
])[
  Write a commented `utility-viz.toml` template. Without a path it goes in the
  current directory; an existing file is overwritten only with `--force`.
  `--migrate` instead creates `utility-viz.toml` from a legacy
  `econ-viz.toml` in the same directory and keeps the old file.

  ```bash
  utility-viz init
  utility-viz init config/figures.toml
  utility-viz init --migrate
  utility-viz plot --config utility-viz.toml --model cobb-douglas \
                --px 2 --py 3 --income 30 --output figure.png
  ```
]

== Demand formulas

#api(("utility-viz solve-tex",), syntax: [
  #raw("utility-viz solve-tex --model ")#meta("name")#raw(" ")#meta("options")
])[
  Print the closed-form Marshallian demand as TeX, for any document that
  supports TeX math.

  ```bash
  # numeric parameters
  utility-viz solve-tex --model cobb-douglas --alpha 0.4 --beta 0.6

  # symbolic parameters
  utility-viz solve-tex --model cobb-douglas --symbolic-params

  # custom price and income symbols
  utility-viz solve-tex --model leontief --a 2 --b 3 \
                     --px-symbol p_1 --py-symbol p_2 --income-symbol M
  ```

  Supports `cobb-douglas`, `leontief`, `perfect-substitutes` and their
  #LaTeX expressions. The command prints the formula only and writes no
  figure.
]

#param("--symbolic-params")[Keep model parameters as symbols, such as $alpha$ and $beta$; without it the given values are substituted.]
#param("--px-symbol", default: "p_x")[Symbol for the price of $x$.]
#param("--py-symbol", default: "p_y")[Symbol for the price of $y$.]
#param("--income-symbol", default: "I")[Symbol for income.]

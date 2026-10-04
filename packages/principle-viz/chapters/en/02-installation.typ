#import "/template/manual.typ": *

= Installation <sec-install>

== Requirements

#changed("0.10.0", label: "principle-viz")[The only runtime dependency is #pkg("mosaickit")]

#pkg("principle-viz") requires Python #pkg-meta("python") or
later#footnote[The Python website provides installers for every operating system: #url("https://www.python.org/downloads/").].
Its only runtime dependency is #pkg("mosaickit"), which draws the figures
through #pkg("matplotlib"); the calculations themselves need nothing beyond
the standard library.

== Installing the package

With #pkg("uv")#footnote[#pkg("uv") is a Python package and project manager by Astral: #url("https://docs.astral.sh/uv/").],
create a project and add the package:

```bash
uv init my-diagrams
cd my-diagrams
uv add principle-viz
uv run python main.py
```

To pin the version this manual describes:

```bash
uv add "principle-viz==0.10.1"
```

In an existing virtual environment, use #pkg("pip"):

```bash
python -m pip install -U principle-viz
```

The distribution is named `principle-viz`; the Python import name is
`principle_viz`:

```python
import principle_viz
from principle_viz import solve_equilibrium, MarketFigure
```

The package was published as `principle-econ` before version 0.10.0. That
distribution receives no further updates; install `principle-viz` instead
and change imports from `principle_econ` to `principle_viz`.

== Installing the command-line tool <sec-install-cli>

To use only the command-line interface (@sec-cli), install it as a tool:

```bash
uv tool install principle-viz
principle-viz equilibrium --demand-intercept 10 --demand-slope -1 \
                          --supply-intercept 2 --supply-slope 1
```

== Development setup

```bash
git clone https://github.com/EconViz/principle-viz.git
cd principle-viz
uv sync
uv run pytest -q
uv run ruff check src tests examples/scripts
```

The test suite enforces 90% statement coverage. The example scripts write
every figure of the project gallery to `examples/output/`:

```bash
uv run python examples/scripts/run_all.py
```

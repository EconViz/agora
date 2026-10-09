#import "/template/manual.typ": *

= Installation <sec-install>

== Requirements

#changed("0.10.0", label: "principle-viz")[The only runtime dependency is #pkg("mosaickit")]

#pkg("principle-viz") requires Python #pkg-meta("python") or
later#footnote[The Python website provides installers for every operating system: #url("https://www.python.org/downloads/").].
Its only runtime dependency is #pkg("mosaickit"), which draws the figures
through #pkg("matplotlib")\; the calculations use only the standard library.

== Installing #pkg("uv")

The commands in this manual use
#pkg("uv")#footnote[#pkg("uv") is a fast Python package and project manager by Astral that also manages Python versions. Installation and full documentation: #url("https://docs.astral.sh/uv/").].
Existing projects can keep using #pkg("pip"), #pkg("pipx") or #pkg("Poetry")\;
the package API does not depend on the tool.

Run the command for the operating system.

=== macOS and Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

=== Windows

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

== Installing #pkg("principle-viz")

Create a project and add the package:

```bash
uv init my-diagrams
cd my-diagrams
uv add principle-viz
uv run python main.py
```

Save the example of @sec-quickstart as `main.py` in the project directory
before running the commands above. `uv add` records the project dependency
and `uv run` uses the project's Python environment. Installing and running
must use the same environment.

To pin the version this manual describes, name it when adding the
dependency:

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

An `import` statement cannot contain a hyphen. When `ModuleNotFoundError`
occurs, check that the interpreter running the program belongs to the
environment where the package was installed.

The package was published as `principle-econ` before version 0.10.0. That
distribution receives no further updates; install `principle-viz` and change
imports from `principle_econ` to `principle_viz`.

== Installing the command-line tool <sec-install-cli>

To use only the command-line interface, install #pkg("principle-viz") as a
standalone tool (@sec-cli):

```bash
uv tool install principle-viz
principle-viz equilibrium --demand-intercept 10 --demand-slope -1 \
                          --supply-intercept 2 --supply-slope 1
```

This installs the tool in its own environment. Importing the package in
Python code still requires `uv add principle-viz` in that project. Calling
`uv run principle-viz` inside a project makes the command line and the
Python code use the same version.

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

== Verifying the installation

This command checks that Python can import the solver and plotting
interface:

```bash
uv run python -c "import principle_viz; print('OK')"
```

`uv run principle-viz --help` checks the command-line tool and lists all
commands. In a server or other environment without a display, write files
with `save()`.

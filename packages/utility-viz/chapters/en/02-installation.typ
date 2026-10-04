#import "/template/manual.typ": *

= Installation <sec-install>

== Requirements

#changed("1.0.2", label: "econ-viz")[NumPy upper bound removed to avoid conflicts on Colab]
#changed("1.0.1", label: "econ-viz")[Pin `numpy<2` to avoid ABI mismatches on Colab and local installs]
#changed("1.0.1", label: "econ-viz")[Relaxed Python and NumPy bounds; `pytest` pinned to 8.x]
#changed("1.7.0", label: "econ-viz")[Package management and builds migrated to #pkg("uv")]
#changed("1.10.0", label: "econ-viz")[Python 3.10 reads TOML configuration files with #pkg("tomli")]
#changed("2.0.0b1", label: "utility-viz")[#modify[New dependencies `mosaickit>=0.5.1,<0.6.0` and `bezierkit>=0.5.0rc1,<0.6.0`]]
#changed("2.0.0b1", label: "utility-viz")[#modify[The repository is a #pkg("uv") workspace releasing #pkg("utility-viz") and #pkg("econ-viz") in lockstep]]

#modify[#pkg("utility-viz")] requires Python #pkg-meta("python") or
later#footnote[The Python website provides installers for every operating system: #url("https://www.python.org/downloads/").].
This chapter manages packages and projects with
#pkg("uv")#footnote[#pkg("uv") is a fast Python package and project manager by Astral that can also manage Python versions; see its documentation for installation and usage: #url("https://docs.astral.sh/uv/").]
and gives the matching #pkg("pip") command where useful.

Installing the package also installs #pkg("NumPy"), #pkg("SciPy"),
#pkg("matplotlib") and #pkg("SymPy"), for array computation, numerical
solving, plotting and symbolic
algebra#modify[, together with #pkg("mosaickit") and #pkg("bezierkit"), for
backend-neutral scenes and Bézier curves]#footnote[Ordinary Python plotting needs no #LaTeX installation; a #LaTeX distribution is only required to compile exported TikZ code.].

== Installing #pkg("uv")

The commands in this manual use #pkg("uv"). Existing projects can keep using
#pkg("pip"), #pkg("pipx") or #pkg("Poetry"); the package API does not depend
on the tool that installed it.

Run the installer for your operating system.

=== macOS, Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

=== Windows

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

== Installing #modify[#pkg("utility-viz")]

Create a project and add #modify[#pkg("utility-viz")] as a dependency:

#modify[```bash
uv init my-diagrams
cd my-diagrams
uv add utility-viz
```]

Run scripts inside the project environment with `uv run`:

```bash
uv run python main.py
```

Save the basic example of @sec-quickstart as `main.py` in the project
directory, then run the command above. `uv add` records the dependency and
`uv run` uses the project's Python environment; install and run in the same
environment.

To pin the version this manual describes, give it when adding the
dependency:

#modify[```bash
uv add "utility-viz==2.0.0b1"
```]

#modify[2.0.0b1 is a pre-release. While no stable 2.x release exists,
`uv add utility-viz` and `pip install utility-viz` pick it up; once a stable
release is published alongside it, opt in to pre-releases with
`uv add --prerelease allow utility-viz` or `pip install --pre utility-viz`.]

In an existing Python virtual environment, install it with #pkg("pip"):

#modify[```bash
python -m pip install -U utility-viz
```]

The package is named #modify[`utility-viz`]; its Python import name is #modify[`utility_viz`]:

#modify[```python
from utility_viz import Canvas, solve
```]

An `import` statement cannot contain a hyphen. On `ModuleNotFoundError`,
check that the interpreter running the script is the one the package was
installed into.

== Optional dependencies <sec-extras>

#changed("1.4.0", label: "econ-viz[extras]")[Optional extras `animation`, `interactive` and `all`]

Animation and Jupyter widgets need optional dependencies. Install the group
you need:

#param("animation")[
  GIF export with `Animator` (@sec-animation); pulls in #pkg("Pillow").
]
#param("interactive")[
  Notebook widgets with `WidgetViewer` (@sec-widgets); pulls in
  #pkg("ipywidgets") and #pkg("IPython").
]
#param("all")[
  Every optional dependency.
]

#modify[```bash
uv add "utility-viz[animation]"    # GIF export (Pillow)
uv add "utility-viz[interactive]"  # notebook widgets
uv add "utility-viz[all]"          # all extras
```]

Installing an extra does not run an animation or open a notebook by itself;
call the API as shown in the relevant chapter.

== Installing the command-line tool <sec-install-cli>

To use only the command-line interface, install #modify[#pkg("utility-viz")] as a
standalone tool (@sec-cli):

#modify[```bash
uv tool install utility-viz
```]

This installs the tool in an environment of its own. To import the package
in your own Python code, still run #modify[`uv add utility-viz`] in that project; calling
#modify[`uv run utility-viz`] inside the project keeps the CLI and your code on the same
version.

== Development setup

#modify[```bash
git clone https://github.com/EconViz/utility-viz.git
cd utility-viz
uv sync --all-packages --all-extras
```]

#modify[The repository is a #pkg("uv") workspace with two distributions
released in lockstep: #pkg("utility-viz") at the root and #pkg("econ-viz")
in `packages/econ-viz/`, the compatibility package of @sec-migrate.
`uv sync --all-packages --all-extras` installs both in editable mode,
together with the development dependencies and every optional dependency.
Then run the full quality gate:]

#modify[```bash
uv run pytest
uv run ruff check .
uv run ruff format --check .
uv run mypy .
```]

== Verifying the installation

#changed("1.7.0", label: "econ-viz")[All example scripts run from a clean checkout]
#changed("1.5.0", label: "econ-viz")[Notebook install flow on Colab is restart-safe]

#modify[```bash
uv run utility-viz --version   # utility-viz 2.0.0b1
uv run utility-viz help
```]

The version in the comment is only an example; the output reflects the
installed version. To check that Python can import the drawing and solving
API:

#modify[```bash
uv run python -c "from utility_viz import Canvas, solve; print('OK')"
```]

On a server or any environment without a display, write files with `save()`
or the CLI's `--output`. `show()` needs an interactive plotting backend, so a
window that fails to open does not mean the installation failed.

#modify[
== Migrating from #pkg("econ-viz") <sec-migrate>

#changed("2.0.0b1", label: "econ-viz")[#modify[Renamed to #pkg("utility-viz"); the `econ_viz` package, the `econ-viz` command and `econ-viz.toml` lookup remain as a deprecated compatibility layer until 3.0.0]]
#changed("2.0.0b1", label: "econ-viz")[#modify[The compatibility layer ships as a separate #pkg("econ-viz") distribution, so upgrading a 1.x installation no longer deletes files shared with #pkg("utility-viz")]]

#pkg("econ-viz") was renamed #pkg("utility-viz") in 2.0.0 (@tab-migrate).

#tbl(caption: [Names in 1.x and 2.x])[
  #booktabs(
    columns: (auto, auto, auto),
    header: ([], [1.x], [2.x]),
    [Distribution], [`pip install econ-viz`], [`pip install utility-viz`],
    [Import], [`import econ_viz`], [`import utility_viz`],
    [Command], [`econ-viz`], [`utility-viz`],
    [Configuration file], [`econ-viz.toml`], [`utility-viz.toml`],
  )
] <tab-migrate>

=== Which package to install

#pkg("utility-viz") ships only the `utility_viz` package and the
`utility-viz` command. #pkg("econ-viz") 2.x, released with the same version
number, is a thin compatibility distribution: it depends on #pkg("utility-viz")
of that version and adds the `econ_viz` package and the `econ-viz` command.
Upgrading a 1.x installation with `pip install --upgrade econ-viz` (add
`--pre` for a pre-release) therefore moves it onto 2.x and keeps old code
running. Switch to `pip install utility-viz` once the code no longer imports
`econ_viz`.

=== Compatibility layer

Throughout 2.x, documented 1.x code keeps working:

- `import econ_viz` emits one deprecation warning per process.
- `from econ_viz import ...` and the documented submodules
  (`econ_viz.models`, `econ_viz.optimizer`, `econ_viz.themes`, ...) resolve
  to their `utility_viz` equivalents; names that did not change are the very
  same objects.
- Constructing `econ_viz.Canvas`, `econ_viz.Figure` or
  `econ_viz.animation.Animator`, or accessing `econ_viz.Layout`, emits a
  `UtilityVizDeprecationWarning` naming the replacement.
- The `econ-viz` command prints a deprecation warning and forwards its
  arguments to `utility-viz`.
- A legacy `econ-viz.toml` is still read, with a warning (@sec-config-lookup);
  `utility-viz init --migrate` copies it to `utility-viz.toml`
  (@sec-cli-init).

#api(("UtilityVizDeprecationWarning",), added: "v2.0.0b1")[
  A `FutureWarning` subclass, so it is shown by default. Its message states
  the version that deprecated the feature, the version that removes it and
  the replacement, for example:

  ```text
  econ_viz.Canvas is deprecated since 2.0.0 and will be removed in 3.0.0;
  use utility_viz.Canvas instead.
  ```
]

=== Updating code

Most code only needs the import name changed. Modules that were importable
on their own in 1.x now live elsewhere (@tab-migrate-modules); their names
are also available from the package root.

#tbl(caption: [Moved modules])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([1.x], [2.x]),
    [`econ_viz.optimizer`], [`utility_viz` (root) or `utility_viz.models`],
    [`econ_viz.analysis`], [`utility_viz.models`],
    [`econ_viz.exceptions`], [`utility_viz` (root)],
    [`econ_viz.animation`], [`utility_viz.core.animation`],
    [`econ_viz.interactive`], [`utility_viz.core.interactive`],
  )
] <tab-migrate-modules>

The public API is the package root (`from utility_viz import Canvas, ...`)
and `utility_viz.models`. Other `utility_viz.core.*` modules are advanced
APIs that may move between minor releases.

=== Removal in 3.0.0

The `econ_viz` package, the `econ-viz` command and `econ-viz.toml` lookup
are removed in 3.0.0, not 2.0.0. Only the documented 1.x API is covered;
undocumented deep paths such as `econ_viz.canvas.renderers` resolve on a
best-effort basis and may disappear at any time.
]

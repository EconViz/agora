#import "/template/manual.typ": *

= Installation <sec-install>

== Requirements

#pkg("micro-viz") requires Python #pkg-meta("python") or later#footnote[The Python website provides installers for every operating system: #url("https://www.python.org/downloads/").]. Its only runtime dependency is #pkg("mosaickit") (1.0.0rc9 or later, below 2), which draws the figures through #pkg("matplotlib").

== Installing #pkg("uv")

The commands in this manual use #pkg("uv")#footnote[#pkg("uv") is a fast Python package and project manager by Astral that also manages Python versions. Installation and full documentation: #url("https://docs.astral.sh/uv/").]. Existing projects can keep using #pkg("pip"); the package API does not depend on the tool.

=== macOS and Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

=== Windows

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

== Installing #pkg("micro-viz")

#pkg("micro-viz") is not on PyPI yet. Install the development version from GitHub:

```bash
uv init my-diagrams
cd my-diagrams
uv add "micro-viz @ git+https://github.com/EconViz/micro-viz"
```

With #pkg("pip"), use `python -m pip install "micro-viz @ git+https://github.com/EconViz/micro-viz"`. #pkg("mosaickit") 1.0.0rc9 is a pre-release, so add `--prerelease allow` to `uv` (or `--pre` to #pkg("pip")) until 1.0 final is published.

== Optional dependencies <sec-extras>

`micro-viz[animation]` adds #pkg("kinetickit"), which animates a figure over a parameter (@sec-animation). Static figures never import it.

```bash
uv add "micro-viz[animation] @ git+https://github.com/EconViz/micro-viz"
```

== Development setup

```bash
git clone https://github.com/EconViz/micro-viz.git
cd micro-viz
uv sync --locked
uv run pytest
```

== Running the examples <sec-run-examples>

The scripts in `examples/scripts/<topic>/` write SVG files into `examples/output/<topic>/`. They use the black-and-white `manual` look, which needs the TeX Gyre Pagella fonts; pass the directory of the font files with `--fonts-dir` if they are not found automatically.

```bash
uv run python examples/scripts/production/production.py
uv run python examples/scripts/production/production.py \
    --config examples/econ-viz.zh-TW.toml \
    --fonts-dir path/to/NotoSerifTC
```

The figures of this manual are drawn by these scripts; the archive linked in @sec-intro holds them together with the three settings files.

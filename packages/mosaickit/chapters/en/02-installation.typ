#import "/template/manual.typ": *

= Installation <sec-install>

== Requirements

#pkg("mosaickit") requires Python #pkg-meta("python") or later, #pkg("NumPy")
1.24 or later and #pkg("Matplotlib") 3.6 or later (below 4). On Python 3.10,
it also installs #pkg("tomli") to read TOML. GIF output uses #pkg("Pillow"),
which Matplotlib already depends on. MP4 output needs `ffmpeg` on the
`PATH`.

== Installing the package

```bash
uv add mosaickit                 # the library
uv add "mosaickit==0.5.1"        # the version this manual describes
```

With #pkg("pip"), use `python -m pip install mosaickit`. Importing
`mosaickit` does not import Matplotlib: the built-in renderer is loaded by
name the first time a canvas renders (@sec-rendering).

#changed("0.2.0", label: "mosaickit")[Built-in renderers are loaded by name on first use; the core no longer imports the Matplotlib backend]

== Development setup

```bash
git clone https://github.com/EconViz/mosaickit.git
cd mosaickit
uv sync --locked
uv run pre-commit install
uv run pytest
uv run ruff check .
uv run ruff format --check .
uv run mypy
uv run lint-imports
uv build
```

The lockfile pins every development dependency. The continuous-integration
workflow runs the same commands on Python 3.10, 3.11, 3.12 and 3.13. It then
installs the built wheel into a clean environment, checks that #pkg("bezierkit")
is absent, and runs the test suite against the wheel. Import contracts enforce
the module boundaries: scenes, styles, themes and parameters never import the
rendering or canvas modules, and the core never imports a domain package.

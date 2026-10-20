#import "/template/manual.typ": *

= Installation <sec-install>

#pkg("kinetickit") supports Python 3.10 through 3.13. Every installation includes NumPy and GlyphKit.

```bash
uv add --prerelease allow kinetickit               # animated SVG
uv add --prerelease allow "kinetickit[raster]"     # SVG and GIF
uv add --prerelease allow "kinetickit[interactive]"# SVG and HTML
uv add --prerelease allow "kinetickit[studio]"     # every built-in output
uv add "kinetickit[studio]==1.0.0b2"               # version in this manual
```

`raster` installs Matplotlib and Pillow. `interactive` installs Plotly. These libraries stay behind private adapters and do not appear in KineticKit's public scene or renderer interfaces.

For development:

```bash
git clone https://github.com/EconViz/kinetickit.git
cd kinetickit
uv sync --all-extras
uv run pytest
uv run ruff check .
uv run mypy
uv run lint-imports
uv run python -m kinetickit.conformance
```

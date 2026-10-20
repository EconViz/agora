#import "/template/manual.typ": *

= Installation <sec-install>

#pkg("glyphkit") supports Python 3.10 through 3.13.

```bash
uv add --prerelease allow glyphkit
uv add --prerelease allow "glyphkit[portable]"  # WOFF2 subset payloads
uv add "glyphkit==1.0.0b2"                       # version in this manual
```

The base installation includes FontTools, HarfBuzz bindings, Unicode segmentation, and bidirectional-text support. The `portable` extra adds Brotli for WOFF2 output. No renderer is installed.

For development:

```bash
git clone https://github.com/EconViz/glyphkit.git
cd glyphkit
uv sync --all-extras
uv run pytest
uv run ruff check .
uv run mypy
uv run lint-imports
```

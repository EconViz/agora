#import "/template/manual.typ": *

= 安裝 <sec-install>

#pkg("kinetickit") 支援 Python 3.10 到 3.13。每種安裝都會包含 NumPy 與 GlyphKit。

```bash
uv add --prerelease allow kinetickit               # 動態 SVG
uv add --prerelease allow "kinetickit[raster]"     # SVG 與 GIF
uv add --prerelease allow "kinetickit[interactive]"# SVG 與 HTML
uv add --prerelease allow "kinetickit[studio]"     # 全部內建格式
uv add "kinetickit[studio]==1.0.0b2"               # 本手冊使用的版本
```

`raster` 會安裝 Matplotlib 與 Pillow，`interactive` 會安裝 Plotly。這些套件只出現在私有轉接器後面，不會進入 KineticKit 的公開場景或繪圖端介面。

開發環境的設定方式如下：

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

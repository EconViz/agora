#import "/template/manual.typ": *

= 安装 <sec-install>

#pkg("kinetickit") 支持 Python 3.10 到 3.13。每种安装都会包含 NumPy 与 GlyphKit。

```bash
uv add --prerelease allow kinetickit               # 动态 SVG
uv add --prerelease allow "kinetickit[raster]"     # SVG 与 GIF
uv add --prerelease allow "kinetickit[interactive]"# SVG 与 HTML
uv add --prerelease allow "kinetickit[studio]"     # 全部内建格式
uv add "kinetickit[studio]==1.0.0b2"               # 本手册使用的版本
```

`raster` 会安装 Matplotlib 与 Pillow，`interactive` 会安装 Plotly。这些软件包只出现在私有适配器之后，不会进入 KineticKit 的公开场景或渲染器接口。

开发环境的设置方式如下：

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

#import "/template/manual.typ": *

= 安裝 <sec-install>

#pkg("glyphkit") 支援 Python 3.10 到 3.13。

```bash
uv add --prerelease allow glyphkit
uv add --prerelease allow "glyphkit[portable]"  # 加入 WOFF2 子集資料
uv add "glyphkit==1.0.0b2"                       # 本手冊使用的版本
```

基本安裝包含 FontTools、HarfBuzz 綁定、Unicode 分段與雙向文字支援。`portable` 額外安裝 Brotli，供 WOFF2 輸出使用；兩種安裝都不包含繪圖端。

開發環境的設定方式如下：

```bash
git clone https://github.com/EconViz/glyphkit.git
cd glyphkit
uv sync --all-extras
uv run pytest
uv run ruff check .
uv run mypy
uv run lint-imports
```

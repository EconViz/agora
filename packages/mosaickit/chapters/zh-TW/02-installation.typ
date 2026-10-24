#import "/template/manual.typ": *

= 安裝 <sec-install>

== 系統需求

#pkg("mosaickit") 需要 Python #pkg-meta("python") 以上、#pkg("NumPy") 1.24 以上、#pkg("Matplotlib") 3.6 以上（4 以下）與負責排版文字的 #pkg("glyphkit") 1.0.0b3 以上（2 以下）；在 Python 3.10 上還會安裝 #pkg("tomli") 來讀取 TOML。

== 安裝套件

```bash
uv add mosaickit                 # the library
uv add "mosaickit==1.0.0rc6"     # the version this manual describes
```

1.0.0rc6 是預覽版。在 1.0 正式版發布之前，直接執行 `uv add mosaickit` 或 `pip install mosaickit` 安裝的是 0.9.2；需以 `uv add --prerelease allow mosaickit` 或 `pip install --pre mosaickit` 才能安裝預覽版。

若使用 #pkg("pip")，請執行 `python -m pip install mosaickit`。匯入 `mosaickit` 時不會一併匯入 Matplotlib：內建繪製器要到畫布第一次繪製時，才會依名稱載入（詳見#ref(<sec-rendering>)）。

#changed("0.2.0", label: "mosaickit")[內建繪製器在第一次使用時依名稱載入；核心不再匯入 Matplotlib 後端]

== 開發環境

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

鎖定檔固定了所有開發相依套件的版本。持續整合流程會在 Python 3.10、3.11、3.12 與 3.13 上執行相同命令，再將建置完成的 wheel 安裝到乾淨環境，確認其中不含 #pkg("bezierkit")，最後以該 wheel 執行測試。匯入規則維持分層：場景、樣式、主題與參數模組不會匯入繪製與畫布模組，核心也不會匯入任何領域套件。

#import "/template/manual.typ": *

= 安裝 <sec-install>

== 系統需求

#pkg("mosaickit") 需要 Python #pkg-meta("python") 以上、#pkg("NumPy") 1.24 以上與 #pkg("Matplotlib") 3.6 以上（4 以下）；在 Python 3.10 上另會安裝 #pkg("tomli") 以讀取 TOML。GIF 輸出使用 #pkg("Pillow")，Matplotlib 本身已依賴它；MP4 輸出需要 `PATH` 上有 `ffmpeg`。

== 安裝套件

```bash
uv add mosaickit                 # the library
uv add "mosaickit==0.5.1"        # the version this manual describes
```

使用 #pkg("pip") 時執行 `python -m pip install mosaickit`。匯入 `mosaickit` 不會匯入 Matplotlib：內建繪製器在畫布第一次繪製時才依名稱載入（詳見#ref(<sec-rendering>)）。

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

鎖定檔固定所有開發相依套件的版本。持續整合流程在 Python 3.10、3.11、3.12 與 3.13 上執行相同命令，接著把建置出的 wheel 安裝到乾淨環境，確認其中沒有 #pkg("bezierkit")，再以該 wheel 執行測試。匯入規約維持分層：場景、樣式、主題與參數模組不匯入繪製與畫布模組，核心也不匯入任何領域套件。

#import "/template/manual.typ": *

= 安裝 <sec-install>

== 系統需求

#changed("1.0.2", label: "econ-viz")[移除 NumPy 的版本上限，避免在 Colab 上發生衝突]
#changed("1.0.1", label: "econ-viz")[固定 `numpy<2`，避免 Colab 與本機安裝時 ABI 不相容]
#changed("1.0.1", label: "econ-viz")[放寬 Python 與 NumPy 的版本限制；`pytest` 固定在 8.x]
#changed("1.7.0", label: "econ-viz")[套件管理與建置改用 #pkg("uv")]
#changed("1.10.0", label: "econ-viz")[Python 3.10 使用 #pkg("tomli") 讀取 TOML 設定檔]
#changed("2.0.0b1", label: "utility-viz")[新增依賴 `mosaickit>=0.5.1,<0.6.0` 與 `bezierkit>=0.5.0rc1,<0.6.0`]
#changed("2.0.0b1", label: "utility-viz")[儲存庫改為 #pkg("uv") workspace，#pkg("utility-viz") 與 #pkg("econ-viz") 同步發布]

#pkg("utility-viz") 需要 Python #pkg-meta("python") 以上版本#footnote[Python 官方網站提供各作業系統的安裝程式：#url("https://www.python.org/downloads/")。]。本章以 #pkg("uv")#footnote[#pkg("uv") 是 Astral 開發的 Python 套件與專案管理工具，速度快且可一併管理 Python 版本；安裝方式與完整說明見官方文件：#url("https://docs.astral.sh/uv/")。] 管理套件與專案，並附上對應的 #pkg("pip") 指令。

安裝套件時會一併安裝 #pkg("NumPy")、#pkg("SciPy")、#pkg("matplotlib") 與 #pkg("SymPy")，分別用於陣列運算、數值求解、繪圖與符號運算，以及用於與後端無關之場景與 Bézier 曲線的 #pkg("mosaickit") 與 #pkg("bezierkit")#footnote[一般 Python 繪圖不需要另外安裝 #LaTeX；只有要編譯匯出的 TikZ 原始碼時，才需要 #LaTeX 環境。]。

== 安裝 #pkg("uv")

本手冊的指令以 #pkg("uv") 為準。既有專案仍可使用 #pkg("pip")、#pkg("pipx") 或 #pkg("Poetry")；套件 API 不受管理工具影響。

依作業系統執行下列安裝指令。

=== macOS、Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```
=== Windows

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

== 安裝 #pkg("utility-viz")

建立專案並加入 #pkg("utility-viz")：

```bash
uv init my-diagrams
cd my-diagrams
uv add utility-viz
```

使用 `uv run` 在專案環境中執行程式：

```bash
uv run python main.py
```

將#ref(<sec-quickstart>)的基本範例存為專案目錄下的 `main.py`，再執行上述指令。`uv add` 記錄專案依賴，`uv run` 使用該專案的 Python 環境。安裝與執行必須使用同一個環境。

若要固定本手冊使用的版本，可在加入依賴時指定版本號：

```bash
uv add "utility-viz==2.0.0b1"
```

2.0.0b1 是預覽版。在沒有 2.x 正式版之前，`uv add utility-viz` 與 `pip install utility-viz` 會直接安裝此版本；正式版發布後，需以 `uv add --prerelease allow utility-viz` 或 `pip install --pre utility-viz` 才能安裝預覽版。

若使用既有的 Python 虛擬環境，可透過 #pkg("pip") 安裝：

```bash
python -m pip install -U utility-viz
```

套件名稱是 `utility-viz`，Python 匯入名稱是 `utility_viz`：

```python
from utility_viz import Canvas, solve
```

`import` 陳述式不得使用連字號。若發生 `ModuleNotFoundError`，檢查執行程式的直譯器是否與安裝套件時使用的環境相同。

== 選用依賴 <sec-extras>

#changed("1.4.0", label: "econ-viz[extras]")[新增選用依賴 `animation`、`interactive` 與 `all`]

動畫與 Jupyter 互動元件需要選用依賴。依用途安裝其中一組：

#param("animation")[供 `Animator` 寫出 GIF（詳見#ref(<sec-animation>)）；安裝 #pkg("Pillow")。]
#param("interactive")[供 `WidgetViewer` 在 Jupyter 顯示控制項（詳見#ref(<sec-widgets>)）；安裝 #pkg("ipywidgets") 與 #pkg("IPython")。]
#param("all")[全部選用依賴。]

```bash
uv add "utility-viz[animation]"    # GIF 匯出（Pillow）
uv add "utility-viz[interactive]"  # 筆記本互動元件
uv add "utility-viz[all]"          # 全部選用依賴
```

安裝選用依賴不會自動執行動畫或開啟筆記本，仍需依各章範例呼叫對應的 API。

== 安裝命令列工具 <sec-install-cli>

僅使用命令列介面時，可將 #pkg("utility-viz") 安裝為獨立工具（詳見#ref(<sec-cli>)）：

```bash
uv tool install utility-viz
```

此方式將命令列工具安裝在獨立環境。需要在 Python 程式中匯入套件時，仍須在該專案執行 `uv add utility-viz`。在專案內以 `uv run utility-viz` 呼叫工具，可讓命令列與 Python 程式使用同一版本。

== 開發環境設定

```bash
git clone https://github.com/EconViz/utility-viz.git
cd utility-viz
uv sync --all-packages --all-extras
```

此儲存庫是 #pkg("uv") workspace，包含兩個同步發布的套件：根目錄的 #pkg("utility-viz")，以及 `packages/econ-viz/` 中的 #pkg("econ-viz")，即#ref(<sec-migrate>)所述的相容套件。`uv sync --all-packages --all-extras` 會以可編輯模式安裝兩者，並安裝開發依賴與所有選用依賴。完成後執行完整的品質檢查：

```bash
uv run pytest
uv run ruff check .
uv run ruff format --check .
uv run mypy .
```

== 驗證安裝

#changed("1.7.0", label: "econ-viz")[修正範例腳本，使其可在新簽出的原始碼目錄中直接執行]
#changed("1.5.0", label: "econ-viz")[Colab 上的筆記本安裝流程在重新啟動後也能正常運作]

```bash
uv run utility-viz --version   # utility-viz 2.0.0b1
uv run utility-viz help
```

註解中的版本號僅為範例，實際輸出依安裝版本而定。也可用以下指令確認 Python 能匯入繪圖與求解介面：

```bash
uv run python -c "from utility_viz import Canvas, solve; print('OK')"
```

在伺服器或其他沒有圖形介面的環境中，請以 `save()` 或命令列的 `--output` 輸出檔案。`show()` 需要可用的互動式繪圖後端，視窗打不開不代表安裝失敗。


== 從 #pkg("econ-viz") 遷移 <sec-migrate>

#changed("2.0.0b1", label: "econ-viz")[更名為 #pkg("utility-viz")；`econ_viz` 套件、`econ-viz` 指令與 `econ-viz.toml` 查找保留為已棄用的相容層，於 3.0.0 移除]
#changed("2.0.0b1", label: "econ-viz")[相容層改由獨立的 #pkg("econ-viz") 發行套件提供，升級 1.x 安裝時不再刪除與 #pkg("utility-viz") 共用的檔案]

#pkg("econ-viz") 於 2.0.0 更名為 #pkg("utility-viz")（參見#ref(<tab-migrate>)）。

#tbl(caption: [1.x 與 2.x 的名稱])[
  #booktabs(
    columns: (auto, auto, auto),
    header: ([], [1.x], [2.x]),
    [發行套件], [`pip install econ-viz`], [`pip install utility-viz`],
    [匯入], [`import econ_viz`], [`import utility_viz`],
    [指令], [`econ-viz`], [`utility-viz`],
    [設定檔], [`econ-viz.toml`], [`utility-viz.toml`],
  )
] <tab-migrate>

=== 應安裝哪個套件

#pkg("utility-viz") 只提供 `utility_viz` 套件與 `utility-viz` 指令。版本號相同的 #pkg("econ-viz") 2.x 是精簡的相容套件：它依賴同版本的 #pkg("utility-viz")，並另外提供 `econ_viz` 套件與 `econ-viz` 指令。因此以 `pip install --upgrade econ-viz` 升級 1.x 安裝（預覽版需加 `--pre`）會改用 2.x，舊程式碼仍可執行。程式碼不再匯入 `econ_viz` 後，再改為 `pip install utility-viz`。

=== 相容層

在整個 2.x 期間，依文件撰寫的 1.x 程式碼仍可執行：

- `import econ_viz` 在每個行程中發出一次棄用警告。
- `from econ_viz import ...` 與文件記載的子模組（`econ_viz.models`、`econ_viz.optimizer`、`econ_viz.themes` 等）會對應到 `utility_viz` 的同名物件；名稱未變更者是同一個物件。
- 建立 `econ_viz.Canvas`、`econ_viz.Figure` 或 `econ_viz.animation.Animator`，或存取 `econ_viz.Layout` 時，會發出指明替代名稱的 `UtilityVizDeprecationWarning`。
- `econ-viz` 指令會印出棄用警告，再以相同參數執行 `utility-viz`。
- 舊的 `econ-viz.toml` 仍可讀取，但會發出警告（詳見#ref(<sec-config-lookup>)）；`utility-viz init --migrate` 可將其複製為 `utility-viz.toml`（詳見#ref(<sec-cli-init>)）。

#api(("UtilityVizDeprecationWarning",), added: "v2.0.0b1")[
  `FutureWarning` 的子類別，預設會顯示。訊息列出棄用版本、移除版本與替代方式，例如：

  ```text
  econ_viz.Canvas is deprecated since 2.0.0 and will be removed in 3.0.0;
  use utility_viz.Canvas instead.
  ```
]

=== 更新程式碼

多數程式碼只需更改匯入名稱。1.x 中可單獨匯入的模組已移至他處（參見#ref(<tab-migrate-modules>)），其中的名稱也可從套件根目錄匯入。

#tbl(caption: [已搬移的模組])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([1.x], [2.x]),
    [`econ_viz.optimizer`], [`utility_viz`（根目錄）或 `utility_viz.models`],
    [`econ_viz.analysis`], [`utility_viz.models`],
    [`econ_viz.exceptions`], [`utility_viz`（根目錄）],
    [`econ_viz.animation`], [`utility_viz.core.animation`],
    [`econ_viz.interactive`], [`utility_viz.core.interactive`],
  )
] <tab-migrate-modules>

公開 API 為套件根目錄（`from utility_viz import Canvas, ...`）與 `utility_viz.models`。其他 `utility_viz.core.*` 模組屬進階 API，可能在次要版本間搬移。

=== 3.0.0 的移除範圍

`econ_viz` 套件、`econ-viz` 指令與 `econ-viz.toml` 查找於 3.0.0 移除，而非 2.0.0。相容層只涵蓋文件記載的 1.x API；未記載的深層路徑（例如 `econ_viz.canvas.renderers`）僅盡力對應，隨時可能移除。


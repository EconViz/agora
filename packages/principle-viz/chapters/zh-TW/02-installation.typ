#import "/template/manual.typ": *

= 安裝 <sec-install>

== 系統需求

#changed("0.10.0", label: "principle-viz")[唯一的執行期依賴為 #pkg("mosaickit")]

#pkg("principle-viz") 需要 Python #pkg-meta("python") 以上版本#footnote[Python 官方網站提供各作業系統的安裝程式：#url("https://www.python.org/downloads/")。]。唯一的執行期依賴是 #pkg("mosaickit")，它透過 #pkg("matplotlib") 繪製圖形；計算部分只使用標準函式庫。

== 安裝套件

使用 #pkg("uv")#footnote[#pkg("uv") 是 Astral 開發的 Python 套件與專案管理工具：#url("https://docs.astral.sh/uv/")。] 建立專案並加入套件：

```bash
uv init my-diagrams
cd my-diagrams
uv add principle-viz
uv run python main.py
```

固定為本手冊說明的版本：

```bash
uv add "principle-viz==0.10.1"
```

在既有的虛擬環境中，可透過 #pkg("pip") 安裝：

```bash
python -m pip install -U principle-viz
```

發行套件名稱是 `principle-viz`，Python 匯入名稱是 `principle_viz`：

```python
import principle_viz
from principle_viz import solve_equilibrium, MarketFigure
```

0.10.0 版以前，本套件以 `principle-econ` 名稱發布。該發行套件已停止更新；請改裝 `principle-viz`，並將匯入的 `principle_econ` 改為 `principle_viz`。

== 安裝命令列工具 <sec-install-cli>

只使用命令列介面時（詳見#ref(<sec-cli>)），可將其安裝為工具：

```bash
uv tool install principle-viz
principle-viz equilibrium --demand-intercept 10 --demand-slope -1 \
                          --supply-intercept 2 --supply-slope 1
```

== 開發環境設定

```bash
git clone https://github.com/EconViz/principle-viz.git
cd principle-viz
uv sync
uv run pytest -q
uv run ruff check src tests examples/scripts
```

測試要求至少 90% 的陳述式覆蓋率。範例腳本會將專案圖庫中的所有圖形寫入 `examples/output/`：

```bash
uv run python examples/scripts/run_all.py
```

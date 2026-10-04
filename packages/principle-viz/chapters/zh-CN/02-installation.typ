#import "/template/manual.typ": *

= 安装 <sec-install>

== 系统需求

#changed("0.10.0", label: "principle-viz")[唯一的运行时依赖为 #pkg("mosaickit")]

#pkg("principle-viz") 需要 Python #pkg-meta("python") 以上版本#footnote[Python 官方网站提供各操作系统的安装程序：#url("https://www.python.org/downloads/")。]。唯一的运行时依赖是 #pkg("mosaickit")，它通过 #pkg("matplotlib") 绘制图形；计算部分只使用标准库。

== 安装软件包

使用 #pkg("uv")#footnote[#pkg("uv") 是 Astral 开发的 Python 软件包与项目管理工具：#url("https://docs.astral.sh/uv/")。] 创建项目并添加软件包：

```bash
uv init my-diagrams
cd my-diagrams
uv add principle-viz
uv run python main.py
```

固定为本手册说明的版本：

```bash
uv add "principle-viz==0.10.1"
```

在既有的虚拟环境中，可通过 #pkg("pip") 安装：

```bash
python -m pip install -U principle-viz
```

发行包名称是 `principle-viz`，Python 导入名称是 `principle_viz`：

```python
import principle_viz
from principle_viz import solve_equilibrium, MarketFigure
```

0.10.0 版以前，本软件包以 `principle-econ` 名称发布。该发行包已停止更新；请改为安装 `principle-viz`，并将导入的 `principle_econ` 改为 `principle_viz`。

== 安装命令行工具 <sec-install-cli>

只使用命令行界面时（详见#ref(<sec-cli>)），可将其安装为工具：

```bash
uv tool install principle-viz
principle-viz equilibrium --demand-intercept 10 --demand-slope -1 \
                          --supply-intercept 2 --supply-slope 1
```

== 开发环境设置

```bash
git clone https://github.com/EconViz/principle-viz.git
cd principle-viz
uv sync
uv run pytest -q
uv run ruff check src tests examples/scripts
```

测试要求至少 90% 的语句覆盖率。范例脚本会将项目图库中的所有图形写入 `examples/output/`：

```bash
uv run python examples/scripts/run_all.py
```

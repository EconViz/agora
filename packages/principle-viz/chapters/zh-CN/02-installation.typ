#import "/template/manual.typ": *

= 安装 <sec-install>

== 系统需求

#changed("0.10.0", label: "principle-viz")[唯一的运行时依赖为 #pkg("mosaickit")]

#pkg("principle-viz") 需要 Python #pkg-meta("python") 以上版本#footnote[Python 官方网站提供各操作系统的安装程序：#url("https://www.python.org/downloads/")。]。唯一的运行期依赖是 #pkg("mosaickit")，它通过 #pkg("matplotlib") 绘制图形；计算部分只使用标准函数库。

== 安装 #pkg("uv")

本手册的命令以 #pkg("uv")#footnote[#pkg("uv") 是 Astral 开发的 Python 软件包与项目管理工具，速度快且可一并管理 Python 版本；安装方式与完整说明见官方文档：#url("https://docs.astral.sh/uv/")。] 为准。既有项目仍可使用 #pkg("pip")、#pkg("pipx") 或 #pkg("Poetry")；软件包 API 不受管理工具影响。

依操作系统运行下列安装命令。

=== macOS、Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

=== Windows

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

== 安装 #pkg("principle-viz")

创建项目并加入软件包：

```bash
uv init my-diagrams
cd my-diagrams
uv add principle-viz
uv run python main.py
```

将#ref(<sec-quickstart>)的基本范例存为项目目录下的 `main.py`，再运行上述命令。`uv add` 记录项目依赖，`uv run` 使用该项目的 Python 环境。安装与运行必须使用同一个环境。

若要固定本手册使用的版本，可在加入依赖时指定版本号：

```bash
uv add "principle-viz==0.10.1"
```

若使用既有的 Python 虚拟环境，可通过 #pkg("pip") 安装：

```bash
python -m pip install -U principle-viz
```

发行软件包名称是 `principle-viz`，Python 导入名称是 `principle_viz`：

```python
import principle_viz
from principle_viz import solve_equilibrium, MarketFigure
```

`import` 陈述式不得使用连字号。若发生 `ModuleNotFoundError`，检查运行程序的解释器是否与安装软件包时使用的环境相同。

0.10.0 版以前，本软件包以 `principle-econ` 名称发布。该发行软件包已停止更新；请改装 `principle-viz`，并将导入的 `principle_econ` 改为 `principle_viz`。

== 安装命令行工具 <sec-install-cli>

仅使用命令行接口时，可将 #pkg("principle-viz") 安装为独立工具（详见#ref(<sec-cli>)）：

```bash
uv tool install principle-viz
principle-viz equilibrium --demand-intercept 10 --demand-slope -1 \
                          --supply-intercept 2 --supply-slope 1
```

此方式将命令行工具安装在独立环境。需要在 Python 程序中导入软件包时，仍须在该项目运行 `uv add principle-viz`。在项目内以 `uv run principle-viz` 调用工具，可让命令行与 Python 程序使用同一版本。

== 开发环境设置

```bash
git clone https://github.com/EconViz/principle-viz.git
cd principle-viz
uv sync
uv run pytest -q
uv run ruff check src tests examples/scripts
```

测试要求至少 90% 的陈述式覆盖率。范例脚本会将项目图库中的所有图形写入 `examples/output/`：

```bash
uv run python examples/scripts/run_all.py
```

== 验证安装

以下命令确认 Python 能导入求解与绘图接口：

```bash
uv run python -c "import principle_viz; print('OK')"
```

命令行工具以 `uv run principle-viz --help` 确认，会列出所有命令。在服务器或其他没有图形接口的环境中，请以 `save()` 输出文件。

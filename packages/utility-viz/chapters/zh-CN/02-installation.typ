#import "/template/manual.typ": *

= 安装 <sec-install>

== 系统需求

#changed("1.0.2", label: "econ-viz")[删除 NumPy 的版本上限，避免在 Colab 上发生冲突]
#changed("1.0.1", label: "econ-viz")[固定 `numpy<2`，避免 Colab 与本机安装时 ABI 不兼容]
#changed("1.0.1", label: "econ-viz")[放宽 Python 与 NumPy 的版本限制；`pytest` 固定在 8.x]
#changed("1.7.0", label: "econ-viz")[软件包管理与构建改用 #pkg("uv")]
#changed("1.10.0", label: "econ-viz")[Python 3.10 使用 #pkg("tomli") 读取 TOML 配置文件]
#changed("2.0.0b1", label: "utility-viz")[#modify[添加依赖 `mosaickit>=0.5.1,<0.6.0` 与 `bezierkit>=0.5.0rc1,<0.6.0`]]
#changed("2.0.0b1", label: "utility-viz")[#modify[仓库改为 #pkg("uv") workspace，#pkg("utility-viz") 与 #pkg("econ-viz") 同步发布]]

#modify[#pkg("utility-viz")] 需要 Python #pkg-meta("python") 以上版本#footnote[Python 官方网站提供各操作系统的安装程序：#url("https://www.python.org/downloads/")。]。本章以 #pkg("uv")#footnote[#pkg("uv") 是 Astral 开发的 Python 软件包与项目管理工具，速度快且可一并管理 Python 版本；安装方式与完整说明见官方文档：#url("https://docs.astral.sh/uv/")。] 管理软件包与项目，并附上对应的 #pkg("pip") 命令。

安装软件包时会一并安装 #pkg("NumPy")、#pkg("SciPy")、#pkg("matplotlib") 与 #pkg("SymPy")，分别用于数组运算、数值求解、绘图与符号运算#modify[，以及用于与后端无关的场景与 Bézier 曲线的 #pkg("mosaickit") 与 #pkg("bezierkit")]#footnote[一般 Python 绘图不需要另外安装 #LaTeX；只有要编译导出的 TikZ 源代码时，才需要 #LaTeX 环境。]。

== 安装 #pkg("uv")

本手册的命令以 #pkg("uv") 为准。现有项目仍可使用 #pkg("pip")、#pkg("pipx") 或 #pkg("Poetry")；软件包 API 不受管理工具影响。

依操作系统运行下列安装命令。

=== macOS、Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```
=== Windows

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

== 安装 #modify[#pkg("utility-viz")]

创建项目并添加 #modify[#pkg("utility-viz")]：

#modify[```bash
uv init my-diagrams
cd my-diagrams
uv add utility-viz
```]

使用 `uv run` 在项目环境中运行程序：

```bash
uv run python main.py
```

将#ref(<sec-quickstart>)的基本示例存为项目目录下的 `main.py`，再运行上述命令。`uv add` 记录项目依赖，`uv run` 使用该项目的 Python 环境。安装与运行必须使用同一个环境。

若要固定本手册使用的版本，可在添加依赖时指定版本号：

#modify[```bash
uv add "utility-viz==2.0.0b1"
```]

#modify[2.0.0b1 是预览版。在没有 2.x 正式版之前，`uv add utility-viz` 与 `pip install utility-viz` 会直接安装此版本；正式版发布后，需以 `uv add --prerelease allow utility-viz` 或 `pip install --pre utility-viz` 才能安装预览版。]

若使用现有的 Python 虚拟环境，可通过 #pkg("pip") 安装：

#modify[```bash
python -m pip install -U utility-viz
```]

软件包名称是 #modify[`utility-viz`]，Python 导入名称是 #modify[`utility_viz`]：

#modify[```python
from utility_viz import Canvas, solve
```]

`import` 语句不得使用连字符。若发生 `ModuleNotFoundError`，检查运行程序的解释器是否与安装软件包时使用的环境相同。

== 可选依赖 <sec-extras>

#changed("1.4.0", label: "econ-viz[extras]")[添加可选依赖 `animation`、`interactive` 与 `all`]

动画与 Jupyter 交互组件需要可选依赖。按用途安装其中一组：

#param("animation")[供 `Animator` 写入 GIF（详见#ref(<sec-animation>)）；安装 #pkg("Pillow")。]
#param("interactive")[供 `WidgetViewer` 在 Jupyter 显示控件（详见#ref(<sec-widgets>)）；安装 #pkg("ipywidgets") 与 #pkg("IPython")。]
#param("all")[全部可选依赖。]

#modify[```bash
uv add "utility-viz[animation]"    # GIF 导出（Pillow）
uv add "utility-viz[interactive]"  # 笔记本交互组件
uv add "utility-viz[all]"          # 全部可选依赖
```]

安装可选依赖不会自动运行动画或打开笔记本，仍需按各章示例调用对应的 API。

== 安装命令行工具 <sec-install-cli>

仅使用命令行接口时，可将 #modify[#pkg("utility-viz")] 安装为独立工具（详见#ref(<sec-cli>)）：

#modify[```bash
uv tool install utility-viz
```]

此方式将命令行工具安装在独立环境。需要在 Python 程序中导入软件包时，仍须在该项目运行 #modify[`uv add utility-viz`]。在项目内以 #modify[`uv run utility-viz`] 调用工具，可让命令行与 Python 程序使用同一版本。

== 开发环境设置

#modify[```bash
git clone https://github.com/EconViz/utility-viz.git
cd utility-viz
uv sync --all-packages --all-extras
```]

#modify[此仓库是 #pkg("uv") workspace，包含两个同步发布的软件包：根目录的 #pkg("utility-viz")，以及 `packages/econ-viz/` 中的 #pkg("econ-viz")，即#ref(<sec-migrate>)所述的兼容包。`uv sync --all-packages --all-extras` 会以可编辑模式安装两者，并安装开发依赖与所有可选依赖。完成后运行完整的质量检查：]

#modify[```bash
uv run pytest
uv run ruff check .
uv run ruff format --check .
uv run mypy .
```]

== 验证安装

#changed("1.7.0", label: "econ-viz")[修正示例脚本，使其可在新检出的源代码目录中直接运行]
#changed("1.5.0", label: "econ-viz")[Colab 上的笔记本安装流程在重新启动后也能正常运作]

#modify[```bash
uv run utility-viz --version   # utility-viz 2.0.0b1
uv run utility-viz help
```]

注释中的版本号仅为示例，实际输出取决于安装版本。也可用以下命令确认 Python 能导入绘图与求解接口：

#modify[```bash
uv run python -c "from utility_viz import Canvas, solve; print('OK')"
```]

在服务器或其他没有图形界面的环境中，请以 `save()` 或命令行的 `--output` 输出文件。`show()` 需要可用的交互式绘图后端，窗口打不开不代表安装失败。

#modify[
== 从 #pkg("econ-viz") 迁移 <sec-migrate>

#changed("2.0.0b1", label: "econ-viz")[#modify[更名为 #pkg("utility-viz")；`econ_viz` 包、`econ-viz` 命令与 `econ-viz.toml` 查找保留为已弃用的兼容层，于 3.0.0 移除]]
#changed("2.0.0b1", label: "econ-viz")[#modify[兼容层改由独立的 #pkg("econ-viz") 发行包提供，升级 1.x 安装时不再删除与 #pkg("utility-viz") 共用的文件]]

#pkg("econ-viz") 于 2.0.0 更名为 #pkg("utility-viz")（参见#ref(<tab-migrate>)）。

#tbl(caption: [1.x 与 2.x 的名称])[
  #booktabs(
    columns: (auto, auto, auto),
    header: ([], [1.x], [2.x]),
    [发行包], [`pip install econ-viz`], [`pip install utility-viz`],
    [导入], [`import econ_viz`], [`import utility_viz`],
    [命令], [`econ-viz`], [`utility-viz`],
    [配置文件], [`econ-viz.toml`], [`utility-viz.toml`],
  )
] <tab-migrate>

=== 应安装哪个软件包

#pkg("utility-viz") 只提供 `utility_viz` 包与 `utility-viz` 命令。版本号相同的 #pkg("econ-viz") 2.x 是精简的兼容包：它依赖同版本的 #pkg("utility-viz")，并另外提供 `econ_viz` 包与 `econ-viz` 命令。因此以 `pip install --upgrade econ-viz` 升级 1.x 安装（预览版需加 `--pre`）会改用 2.x，旧代码仍可运行。代码不再导入 `econ_viz` 后，再改为 `pip install utility-viz`。

=== 兼容层

在整个 2.x 期间，按文档编写的 1.x 代码仍可运行：

- `import econ_viz` 在每个进程中发出一次弃用警告。
- `from econ_viz import ...` 与文档记载的子模块（`econ_viz.models`、`econ_viz.optimizer`、`econ_viz.themes` 等）会对应到 `utility_viz` 的同名对象；名称未变更者是同一个对象。
- 创建 `econ_viz.Canvas`、`econ_viz.Figure` 或 `econ_viz.animation.Animator`，或访问 `econ_viz.Layout` 时，会发出指明替代名称的 `UtilityVizDeprecationWarning`。
- `econ-viz` 命令会打印弃用警告，再以相同参数运行 `utility-viz`。
- 旧的 `econ-viz.toml` 仍可读取，但会发出警告（详见#ref(<sec-config-lookup>)）；`utility-viz init --migrate` 可将其复制为 `utility-viz.toml`（详见#ref(<sec-cli-init>)）。

#api(("UtilityVizDeprecationWarning",), added: "v2.0.0b1")[
  `FutureWarning` 的子类，默认会显示。消息列出弃用版本、移除版本与替代方式，例如：

  ```text
  econ_viz.Canvas is deprecated since 2.0.0 and will be removed in 3.0.0;
  use utility_viz.Canvas instead.
  ```
]

=== 更新代码

多数代码只需更改导入名称。1.x 中可单独导入的模块已移至别处（参见#ref(<tab-migrate-modules>)），其中的名称也可从软件包根目录导入。

#tbl(caption: [已迁移的模块])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([1.x], [2.x]),
    [`econ_viz.optimizer`], [`utility_viz`（根目录）或 `utility_viz.models`],
    [`econ_viz.analysis`], [`utility_viz.models`],
    [`econ_viz.exceptions`], [`utility_viz`（根目录）],
    [`econ_viz.animation`], [`utility_viz.core.animation`],
    [`econ_viz.interactive`], [`utility_viz.core.interactive`],
  )
] <tab-migrate-modules>

公开 API 为软件包根目录（`from utility_viz import Canvas, ...`）与 `utility_viz.models`。其他 `utility_viz.core.*` 模块属高级 API，可能在次要版本间迁移。

=== 3.0.0 的移除范围

`econ_viz` 包、`econ-viz` 命令与 `econ-viz.toml` 查找于 3.0.0 移除，而非 2.0.0。兼容层只涵盖文档记载的 1.x API；未记载的深层路径（例如 `econ_viz.canvas.renderers`）仅尽力对应，随时可能移除。
]

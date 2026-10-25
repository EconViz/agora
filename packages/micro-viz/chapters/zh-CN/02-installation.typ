#import "/template/manual.typ": *

= 安装 <sec-install>

== 系统需求

#pkg("micro-viz") 需要 Python #pkg-meta("python") 以上版本#footnote[Python 官方网站提供各操作系统的安装程序：#url("https://www.python.org/downloads/")。]。唯一的运行期依赖是 #pkg("mosaickit")（1.0.0rc9 以上、2 以下），它通过 #pkg("matplotlib") 绘制图形。

== 安装 #pkg("uv")

本手册的指令以 #pkg("uv")#footnote[#pkg("uv") 是 Astral 开发的 Python 套件与项目管理工具，速度快且可一并管理 Python 版本；安装方式与完整说明见官方文档：#url("https://docs.astral.sh/uv/")。] 为准。既有项目仍可使用 #pkg("pip")；套件 API 不受管理工具影响。

=== macOS、Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

=== Windows

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

== 安装 #pkg("micro-viz")

#pkg("micro-viz") 尚未发布到 PyPI。从 GitHub 安装开发版：

```bash
uv init my-diagrams
cd my-diagrams
uv add "micro-viz @ git+https://github.com/EconViz/micro-viz"
```

使用 #pkg("pip") 时，运行 `python -m pip install "micro-viz @ git+https://github.com/EconViz/micro-viz"`。#pkg("mosaickit") 1.0.0rc9 是预发行版，在 1.0 正式版发布之前，`uv` 需加上 `--prerelease allow`（#pkg("pip") 则加 `--pre`）。

== 选用依赖 <sec-extras>

`micro-viz[animation]` 会加装 #pkg("kinetickit")，让图形随参数变化成为动画（参见 @sec-animation）。静态图不会引入它。

```bash
uv add "micro-viz[animation] @ git+https://github.com/EconViz/micro-viz"
```

== 开发环境

```bash
git clone https://github.com/EconViz/micro-viz.git
cd micro-viz
uv sync --locked
uv run pytest
```

== 运行范例 <sec-run-examples>

`examples/scripts/` 中的脚本把 SVG 档写入 `examples/output/`。它们使用黑白的 `manual` 外观，需要 TeX Gyre Pagella 字体；找不到时，以 `--fonts-dir` 指定字库所在的目录。

```bash
uv run python examples/scripts/production.py
uv run python examples/scripts/production.py \
    --config examples/econ-viz.zh-TW.toml \
    --fonts-dir path/to/NotoSerifTC
```

本手册的图形就是由这些脚本绘制；@sec-intro 链接的压缩档包含这些脚本与三份设置档。

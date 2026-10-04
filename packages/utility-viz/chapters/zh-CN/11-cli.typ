#import "/template/manual.typ": *

= 命令行工具 <sec-cli>

#changed("1.7.0", label: "econ-viz")[添加 `econ-viz --version`，显示已安装的软件包版本]
#changed("1.3.1", label: "econ-viz")[命令行错误改为抛出 `CliConfigError`，结束处理集中在 `cli.main`]
#changed("1.2.3", label: "econ-viz models")[命令行工具支持 `QuasiLinear`、`StoneGeary` 与 `Translog`]
#changed("1.10.0", label: "econ-viz init")[添加配置文件模板命令与 `plot --config`]
#changed("1.11.0", label: "econ-viz plot")[`--theme` 支持所有命令行内置主题]
#changed("2.0.0b1", label: "utility-viz")[#modify[命令改为 `utility-viz`；`econ-viz` 会打印弃用警告并转交给新命令]]
#changed("2.0.0b1", label: "utility-viz plot")[#modify[未指定 `--config` 时，读取当前目录的 `utility-viz.toml`（或旧的 `econ-viz.toml`）]]
#changed("2.0.0b1", label: "utility-viz init")[#modify[添加 `--migrate` 选项]]

命令行工具可绘图、批量处理及输出需求公式。以 #modify[`uv tool install utility-viz`] 安装为独立工具，或在 #pkg("uv") 项目中于命令前加上 `uv run`（详见#ref(<sec-install-cli>)）。#modify[由 #pkg("econ-viz") 兼容包安装的 1.x 命令 `econ-viz` 在 2.x 仍可使用：它会发出弃用警告，再以相同参数运行 `utility-viz`（详见#ref(<sec-migrate>)）。]

#tbl(caption: [命令行命令])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([命令], [说明]),
    [#modify[#raw("utility-viz help [")]#meta("command")#raw("]")],
    [显示命令行工具或特定命令的说明],
    [#modify[`utility-viz models`]],
    [列出所有支持的效用模型],
    [#modify[`utility-viz plot ...`]],
    [生成并导出图形],
    [#modify[`utility-viz solve-tex ...`]],
    [以 TeX 格式输出 Marshall 需求的闭式解],
    [#modify[`utility-viz init [path]`]],
    [创建 #modify[`utility-viz.toml`] 配置模板],
  )
]

== 说明与模型

#api(("utility-viz help",), syntax: [#modify[#raw("utility-viz help [")]#meta("command")#raw("]")])[
  未指定参数时列出所有命令；指定命令名称时显示该命令的选项。

  #modify[```bash
  utility-viz help          # 所有命令
  utility-viz help plot     # plot 选项
  utility-viz help models   # models 选项
  ```]
]

#api(("utility-viz models",))[
  列出命令行接口支持的模型名称与参数。`--model` 使用 kebab-case 名称，与 Python 类名称不同（参见#ref(<tab-models>)）。参数选项详见#ref(<sec-cli-plot>)。

  #tbl(caption: [命令行模型])[
    #booktabs(
      columns: (auto, auto, auto, 1fr),
      header: ([模型], [`--model` 值], [必要参数], [可选参数]),
      [Cobb-Douglas], [`cobb-douglas`], [`alpha`、`beta`], [--],
      [CES], [`ces`], [`rho`], [`alpha`、`beta`],
      [完全互补], [`leontief`], [`a`、`b`], [--],
      [完全替代], [`perfect-substitutes`], [`a`、`b`], [--],
      [饱和偏好], [`satiation`], [`bliss-x`、`bliss-y`], [`a`、`b`],
      [准线性], [`quasi-linear`], [--], [`v-func`、`linear-in`],
      [Stone-Geary], [`stone-geary`], [--], [`alpha`、`beta`、`bar-x`、`bar-y`],
      [Translog], [`translog`], [--], [`alpha-0`、`alpha-x`、`alpha-y`、`beta-xx`、`beta-yy`、`beta-xy`],
    )
  ] <tab-models>
]

== 绘图 <sec-cli-plot>

#api(("utility-viz plot",), syntax: [
  #modify[#raw("utility-viz plot --model ")]#meta("name")#raw(" ")#meta("options") \
  #modify[#raw("utility-viz plot --latex ")]#meta("expression")#raw(" ")#meta("options")
])[
  使用 `--model` 指定模型，或使用 `--latex` 输入效用函数，两者择一。指定 `--output` 时导出文件，省略时打开交互窗口。

  预算线与均衡点需要完整的价格与收入。`--no-budget`、`--no-equilibrium`、`--no-curves` 可分别省略对应图层，且可并用（参见#ref(<tab-plot-flags>)）。

  #tbl(caption: [图层控制选项])[
    #booktabs(
      columns: (auto, 1fr),
      header: ([情况], [结果]),
      [提供完整 `--px`、`--py`、`--income`], [绘制预算线并求解均衡],
      [省略任一价格或收入], [仅绘制无差异曲线，不画预算线与均衡点],
      [加上 `--no-equilibrium`], [跳过求解与均衡标注，即使提供了价格与收入],
      [加上 `--no-budget`], [隐藏预算线，即使提供了价格与收入],
      [`--no-curves` 搭配完整价格与收入], [只呈现预算线与均衡点，不画无差异曲线],
    )
  ] <tab-plot-flags>

  #modify[```bash
  # 指定模型名称
  utility-viz plot --model cobb-douglas --alpha 0.5 --beta 0.5 ...

  # LaTeX 表达式
  utility-viz plot --latex "x^{0.4} y^{0.6}" ...
  ```]
]

#example(modify[```bash
# Cobb-Douglas，可行集合加阴影
utility-viz plot --model cobb-douglas --alpha 0.5 --beta 0.5 \
              --px 2 --py 3 --income 30 \
              --fill --output cobb_douglas.png

# LaTeX 输入，Nord 主题，扩张路径
utility-viz plot --latex "x^{0.4} y^{0.6}" \
              --px 2 --py 3 --income 30 \
              --theme nord --show-ray \
              --output cd_latex.png

# 完全互补，加大画布
utility-viz plot --model leontief --a 1 --b 2 \
              --px 2 --py 3 --income 30 \
              --x-max 20 --y-max 15 \
              --output leontief.png

# CES，只画无差异曲线
utility-viz plot --model ces --rho -0.5 \
              --x-max 20 --y-max 15 --n-curves 6 \
              --no-budget --no-equilibrium \
              --output ces.png

# 饱和（饱和点）
utility-viz plot --model satiation --bliss-x 6 --bliss-y 4 \
              --x-max 12 --y-max 10 \
              --no-budget --no-equilibrium \
              --output satiation.png

# 不加 --output：打开窗口
utility-viz plot --model cobb-douglas --px 2 --py 3 --income 30
```])

=== 选择模型

#param("--model, -m")[
  模型名称，完整列表可用 #modify[`utility-viz models`] 查询。
]
#param("--latex, -l")[
  #LaTeX 表达式，支持 Cobb-Douglas、完全互补、完全替代与 CES（详见#ref(<sec-latex>)）。
]

=== 价格与收入

#param("--px")[商品 $x$ 的价格。]
#param("--py")[商品 $y$ 的价格。]
#param("--income")[消费者的收入。]

=== 模型参数

#param("--alpha", default: "0.5")[alpha 参数（Cobb-Douglas、CES）。]
#param("--beta", default: "0.5")[beta 参数（Cobb-Douglas、CES）。]
#param("--a", default: "1.0")[参数 $a$（完全互补、完全替代、饱和）。]
#param("--b", default: "1.0")[参数 $b$（完全互补、完全替代、饱和）。]
#param("--rho", default: "0.5")[替代参数（CES）。]
#param("--bliss-x", default: "5.0")[饱和点的 $x$ 坐标（饱和）。]
#param("--bliss-y", default: "5.0")[饱和点的 $y$ 坐标（饱和）。]

准线性、Stone-Geary 与 Translog 另有下列选项，可按模型使用：

#param("--v-func", default: "log")[准线性的非线性函数，接受 `log` 或 `sqrt`。]
#param("--linear-in", default: "y")[准线性的线性商品，接受 `x` 或 `y`。]
#param("--bar-x", default: "1.0")[Stone-Geary 的最低消费量 $overline(x)$。]
#param("--bar-y", default: "1.0")[Stone-Geary 的最低消费量 $overline(y)$。]
#param("--alpha-0", default: "0.0")[Translog 的截距。]
#param("--alpha-x", default: "0.5")[Translog 中 $ln x$ 的一次项权重。]
#param("--alpha-y", default: "0.5")[Translog 中 $ln y$ 的一次项权重。]
#param("--beta-xx", default: "0.0")[Translog 中 $x$ 方向的曲率。]
#param("--beta-yy", default: "0.0")[Translog 中 $y$ 方向的曲率。]
#param("--beta-xy", default: "0.0")[Translog 中 $x$ 与 $y$ 的交叉项。]

#modify[```bash
utility-viz plot --model stone-geary --bar-x 2 --bar-y 2 \
              --px 2 --py 3 --income 30 \
              --x-max 20 --y-max 15 --output stone_geary.png
```]

此例的最低消费支出为 $2 times 2 + 3 times 2 = 10$，收入 $30$ 高于此限制。若将收入改为 $10$ 或更低，求解会因不符合模型定义域而失败。

=== 画布与图层

#param("--x-max", default: "10")[横轴上限。]
#param("--y-max", default: "10")[纵轴上限。]
#param("--x-label", default: "x")[横轴标签。]
#param("--y-label", default: "y")[纵轴标签。]
#param("--title")[图形标题。]
#param("--theme", default: "default")[主题名称：`default`、`nord`、`paper`、`monochrome`、`presentation` 或 `dark`（详见#ref(<sec-themes>)）。]
#param("--config")[TOML 配置文件路径。命令行参数的优先级高于配置文件。#modify[省略时，若当前目录有 `utility-viz.toml`（或旧的 `econ-viz.toml`）则自动使用（详见#ref(<sec-config-lookup>)）。]]
#param("--n-curves", default: "5")[无差异曲线的条数。]
#param("--dpi", default: "300")[位图输出分辨率。]
#param("--fill")[为预算线下方的可行集合加上阴影。]
#param("--show-ray")[画出通过最优点的扩张路径射线。]
#param("--no-budget")[不画预算线。]
#param("--no-equilibrium")[不画均衡点。]
#param("--no-curves")[不画无差异曲线。]
#param("--output, -o")[
  输出文件（`.png`、`.pdf`、`.svg`、`.tex`）；省略时打开交互窗口。
]

批量生成图形时，为每组参数指定不同文件名，并先创建输出目录。`--x-max` 与 `--y-max` 不会随价格自动调整；轴截距或最优点超出范围时，应同步增大画布上限。

== 创建配置文件 <sec-cli-init>

#api(("utility-viz init",), added: "v1.10.0", syntax: [
  #modify[#raw("utility-viz init [")]#meta("path")#raw("] [--force]")#modify[#raw(" [--migrate]")]
])[
  创建带注释的 #modify[`utility-viz.toml`] 模板。省略路径时写入当前目录；文件已存在时，必须使用 `--force` 才会覆盖。#modify[`--migrate` 则改为从同一目录中旧的 `econ-viz.toml` 创建 `utility-viz.toml`，并保留旧文件。]

  #modify[```bash
  utility-viz init
  utility-viz init config/figures.toml
  utility-viz init --migrate
  utility-viz plot --config utility-viz.toml --model cobb-douglas \
                --px 2 --py 3 --income 30 --output figure.png
  ```]
]

== 需求公式

#api(("utility-viz solve-tex",), syntax: [
  #modify[#raw("utility-viz solve-tex --model ")]#meta("name")#raw(" ")#meta("options")
])[
  以 TeX 格式输出 Marshall 需求的闭式解，可用于支持 TeX 数学式的文件。

  #modify[```bash
  # 数值参数
  utility-viz solve-tex --model cobb-douglas --alpha 0.4 --beta 0.6

  # 符号参数
  utility-viz solve-tex --model cobb-douglas --symbolic-params

  # 自定义价格与收入符号
  utility-viz solve-tex --model leontief --a 2 --b 3 \
                     --px-symbol p_1 --py-symbol p_2 --income-symbol M
  ```]

  支持 `cobb-douglas`、`leontief`、`perfect-substitutes` 及其 #LaTeX 表达式。此命令只输出公式文字，不生成图像文件。
]

#param("--symbolic-params")[保留模型参数符号，例如 $alpha$、$beta$；未使用时代入指定的参数值。]
#param("--px-symbol", default: "p_x")[商品 $x$ 价格的符号。]
#param("--py-symbol", default: "p_y")[商品 $y$ 价格的符号。]
#param("--income-symbol", default: "I")[收入的符号。]

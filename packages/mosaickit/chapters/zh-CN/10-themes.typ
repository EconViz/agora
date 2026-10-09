#import "/template/manual.typ": *

= 主题与配置 <sec-themes>

== 样式组与主题

#api(("StyleBundle",), syntax: [#raw("StyleBundle(stroke=None, fill=None, marker=None, text=None, legend=None)")])[
  每个槽一个稀疏样式。槽内类型错误时引发 `ConfigurationError`。`merged_over(base)` 逐槽合并（参见#ref(<def-merge>)）。
]

#api(("Theme",), syntax: [#raw("Theme(name, roles)")])[
  名称，以及从角色名称到样式组的不可变对应。角色名称是非空、以点分隔的字符串（`"axes"`、`"axes.note"`、`"mypkg.boundary"`）。`with_roles(**patch)` 返回新主题，每个修补的角色合并在原样式组之上；关键字名称不能含点，因此带点的角色写成 `with_roles(**{"mypkg.line": bundle})`。`resolve(role, fallback_category=...)` 仅按主题解析角色。
]

#tbl(caption: [`default` 主题])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([角色], [样式组]),
    [`primary`], [线条 `blue`],
    [`secondary`], [线条 `red`],
    [`accent`], [线条 `teal`],
    [`guide`], [线条 `grey-400`、虚线],
    [`axes`], [线条 `grey-800`、宽 1],
    [`axes.note`], [文字 9 pt、`grey-600`],
    [`canvas`], [填色 `white`、不透明度 1（背景）],
  )
] <tab-default-theme>

其余的值都来自#ref(<tab-primitive>)的基本默认值。此主题为 `mosaickit.themes.default`。

== 角色解析

图层的角色依次经由其上层角色，最后是图层类型的回退类别解析；回退类别是没有任何地方引用该角色时的最后依据。

#definition(name: [角色链])[
  对回退类别为 $phi$ 的角色 $rho = rho_1.rho_2 dots.c rho_m$，其#emph[链]为序列
  $ kappa(rho) = (rho_1 dots.c rho_m, thin rho_1 dots.c rho_(m-1), thin dots, thin rho_1, thin phi), $
  由最具体到最一般，重复的键只保留第一次出现。
] <def-chain>

例如文字图层的 `"axes.note"` 角色，其链为（`axes.note`, `axes`, `text`）。各回退类别为 `primary`（路径、群组）、`region`（填色）、`point`（标记）、`text`（文字、标签、坐标轴标记、注释、大括号）、`annotation`（箭头）与 `legend`。

#theorem(name: [解析顺序])[
  设某图层的自带样式为 $E$、角色链为 $kappa = (k_1, dots, k_n)$，画在角色覆盖为 $C$ 的画布上，所在配置的角色覆盖为 $G$、主题角色为 $T$，并令 $D$ 为基本默认值。则图层解析后样式的每个字段，是序列
  $ E, quad C[k_1], dots, C[k_n], quad G[k_1], dots, G[k_n], quad
    T[k_1], dots, T[k_n], quad D $
  中第一个不是 `None` 的值，其中不存在的角色视为空样式组。
] <thm-resolution>

#corollary(name: [覆盖优先于具体程度])[
  画布或设置对一般角色的覆盖，优先于主题对较具体角色的设置：若 $G["text"]$ 设置了文字大小，且#ref(<thm-resolution>)序列中在它之前没有来源设置大小，则角色为 `axes.note` 的文字图层采用该大小，而非主题的 9 pt。
] <cor-override>

本手册的图就依赖#ref(<cor-override>)：它们同时覆盖 `text`、`axes` 与 `axes.note` 的文字大小，因为只覆盖 `text` 也会放大注释。

#changed("0.2.0", label: "resolve")[`themes.resolve` 接受 `overrides`，在主题之后依次套用]

== 注册领域角色

#api(("ThemeRegistry",), syntax: [#raw("ThemeRegistry()")])[
  主题注册表，一开始就含有 `default`。`register(theme)` 加入主题（名称已被使用时引发 `ConfigurationError`），`get(name)` 查询主题，`register_roles(name, roles)` 把带点的领域角色合并到已注册的主题并返回它；不带点的角色引发 `ConfigurationError`，因此领域软件包无法遮蔽内建角色。
]

#api(("RolePack", "expand_roles"), syntax: [#raw("expand_roles(pack) -> dict[str, StyleBundle]")])[
  以类型描述领域软件包角色的方式。`RolePack` 是带有类变数 `_namespace` 的 dataclass；每个不为 `None` 的字段成为角色 `namespace.field`，字段名称中的底线转为点。
]

```python
from dataclasses import dataclass
from typing import ClassVar
from mosaickit import Stroke, StyleBundle, Theme, expand_roles
from mosaickit.themes import default

@dataclass(frozen=True)
class MyRoles:
    _namespace: ClassVar[str] = "mypkg"
    line: StyleBundle | None = StyleBundle(stroke=Stroke(color="blue", width=2))
    line_dashed: StyleBundle | None = None

roles = expand_roles(MyRoles())        # {"mypkg.line": ...}
mytheme = Theme("mypkg", {**default.roles, **roles})
```

== 配置 <sec-config>

#api(("Config",), syntax: [
  #raw("Config(theme=default, canvas_spec=CanvasSpec(), renderer=\"matplotlib\",") \
  #raw("       role_overrides={}, palette=DEFAULT_PALETTE)")
])[
  新画布的运行时默认值：主题、规格、渲染器（名称或 `Renderer`）、在主题之后套用的角色覆盖（#ref(<thm-resolution>)中的 $G$），以及调色板。
  #changed("0.3.0")[新增 `Config.palette`，默认为 `DEFAULT_PALETTE`]
]

#api(("use_config",), syntax: [#raw("with use_config(config): ...")])[
  在区块内使 `config` 成为生效的配置。此值存于 context variable，因此每个线程与异步任务各自看到自己的配置，而传给 `Canvas` 的参数一律优先。
]

#api(("Config.load", "Config.from_dict"), syntax: [
  #raw("Config.load(path)") \
  #raw("Config.from_dict(data, *, source=\"<dict>\")")
])[
  读取严格的 TOML 配置。最上层的键为 `theme`（只能是 `"default"`；自订主题须在 Python 中传入）、`canvas`（`CanvasSpec` 的字段）、`renderer`（只能是 `"matplotlib"`）、`palette` 与 `styles`。其他键、未知的样式、错误的值或无法读取的文件，都引发指明文件与键的 `ConfigurationError`。
]

```toml
[canvas]
x_range = [0, 20]
dpi = 150

[palette]
blue = "#0072B2"     # override a default color
accent = "#984EA3"   # add a new name

[styles."mypkg.boundary".stroke]
color = "accent"     # a palette name or a "#hex" value
width = 2
dash = "dashed"
```

`[palette]` 表叠加在 `DEFAULT_PALETTE` 之上，因此在此覆盖 `blue` 会改变 `primary` 以及所有引用 `blue` 的地方。样式的 `color` 与 `edge_color` 可以是调色板名称；未知名称在加载文件时（任何画布绘制之前）就引发指明文件与键的 `ConfigurationError`。

#changed("0.3.0", label: "Config.load")[TOML 接受 `[palette]` 表，样式颜色可以是调色板名称，并在加载文件时检查]

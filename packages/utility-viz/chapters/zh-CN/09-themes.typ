#import "/template/manual.typ": *

= 主题与设置 <sec-themes>

`Theme` 定义图形的默认外观；`Config` 从 TOML 文件加载主题覆盖与字体设置。`Canvas`、`Figure`、`DemandDiagram`、价格效应分解及 `EdgeworthBox` 共用这些样式对象。

== 内置主题

#changed("1.6.0", label: "themes.default")[默认配色改为色盲友好方案，并提供 `COLORBLIND_CYCLE_RGB` 与 `COLORBLIND_CYCLE_HEX`]
#changed("1.11.0", label: "Theme")[完成主题系统，添加背景色、标签比例及所有经济图层的默认样式]
#changed("1.11.0", label: "themes")[添加 `paper`、`monochrome`、`presentation` 与 `dark`]
#changed("1.12.0", label: "Theme")[添加次要无差异曲线的颜色、线宽与不透明度设置]

#api(("themes",), updated: "v1.11.0", syntax: [
  ```python
  from utility_viz import Canvas, themes

  cvs = Canvas(theme=themes.paper)
  ```
])[
  Python API 提供下列主题。主题对象不可变；需要调整字段时，可创建新的 `Theme`，或通过 `Config` 覆盖指定字段。

  #tbl(caption: [内置主题])[
    #booktabs(
      columns: (auto, 1fr),
      header: ([名称], [特性]),
      [`default`], [色盲友好的默认配色],
      [`colorblind`], [与 `default` 相同的配色别名],
      [`nord`], [采用 Nord 色盘的冷色系主题],
      [`paper`], [透明背景与出版用细线条],
      [`monochrome`], [以线型与标记区分图层的黑白主题],
      [`presentation`], [放大标签、线条与标记，供投影使用],
      [`dark`], [深色背景与相应的前景色],
    )
  ] <tab-themes>

  Python API 与配置文件的 `base` 可使用全部七个名称#footnote[在命令行中直接传入 `--theme` 时，只接受 `colorblind` 别名以外的六个主题。]。

  默认主题的颜色取自一组色盲友好的配色 #citep(<thriveth2014>)。

  `themes.COLORBLIND_CYCLE_HEX` 与 `themes.COLORBLIND_CYCLE_RGB` 提供这组配色的十六进制与 RGB 值。经济学教学大量依赖图形，因此不应只靠颜色传达含义，以免视觉障碍的学生无法辨识 #citep(<kugler1996>)。
]

== 自定义主题

#api(("Theme",), updated: "v1.12.0", syntax: [
  ```python
  from utility_viz import Theme

  my_theme = Theme(
      name="custom",
      background_color="white",
      label_scale=1.0,
      axis_color="#333333",
      label_color="#333333",
      ic_color="#2563eb",
      secondary_ic_color="#93c5fd",
      secondary_ic_opacity=0.45,
      budget_color="#dc2626",
      eq_color="#16a34a",
  )
  ```
])[
  `Theme` 保存图形元素的颜色、线宽与样式默认值。未指定的字段使用类默认值；绘图方法明确收到的样式参数优先于主题。
]

#param("name", type: "str")[主题标识名称。]
#param("background_color", type: "str | None", default: "None")[图形与坐标区域的背景色；`None` 保持透明。]
#param("label_scale", type: "float", default: "1.0")[普通标签字号的倍数。]
#param("axis_color", type: "str", default: "\"#222222\"")[坐标轴颜色。]
#param("label_color", type: "str", default: "\"#222222\"")[坐标标签与原点文字颜色。]
#param("ic_color", type: "str", default: "\"#377EB8\"")[无差异曲线颜色。]
#param("ic_linewidth", type: "float", default: "1.8")[无差异曲线线宽。]
#param("secondary_ic_color", type: "str | None", default: "None")[非焦点无差异曲线颜色；`None` 沿用 `ic_color`。]
#param("secondary_ic_linewidth", type: "float", default: "1.0")[非焦点无差异曲线线宽。]
#param("secondary_ic_opacity", type: "float", default: "0.45")[非焦点无差异曲线不透明度。]
#param("path_color", type: "str", default: "\"#4DAF4A\"")[PCC 与 ICC 路径颜色。]
#param("budget_color", type: "str", default: "\"#984EA3\"")[预算线颜色。]
#param("budget_fill_alpha", type: "float", default: "0.08")[预算集阴影不透明度。]
#param("eq_color", type: "str", default: "\"#E41A1C\"")[均衡点与投影线颜色。]
#param("eq_markersize", type: "float", default: "4.0")[均衡点标记大小。]

`Theme` 也包含射线、折点、补偿预算线与价格效应箭头的颜色和线宽。`axis_stroke`、`drop_stroke`、`projection_stroke`、`guide_stroke` 与 `box_stroke` 保存其他线条的默认值；标记、标签、填色及图例则由 `Marker`、`Label`、`Fill` 与 `Legend` 属性提供（详见#ref(<sec-styles>)）。

== 配置文件

#changed("1.10.0", label: "Config")[添加 `Config`、`econ-viz.toml`、`econ-viz init` 与 `plot --config`]
#changed("1.11.0", label: "Config")[配置文件可选择所有内置主题，并在各种图形间保留相同的视觉语义]
#changed("2.0.0b1", label: "Config")[默认配置文件更名为 `utility-viz.toml`；旧的 `econ-viz.toml` 仍可读取，但会发出警告]
#changed("2.0.0b1", label: "Config.discover")[添加 `Config.discover()`，找不到文件时改用内置默认值]

#api(("Config.load", "Config.use", "Config.reset"), added: "v1.10.0", syntax: [
  ```python
  from utility_viz import Config

  Config.load("utility-viz.toml").use()
  # 此后创建的图形使用该设置

  Config.reset()
  # 恢复内置默认值
  ```
])[
  `Config.load()` 读取 TOML 文件并返回 `Config`。`use()` 将其设为后续图形的默认配置；`reset()` 恢复内置默认值。
]

=== 教程：以配置文件统一图形样式

同一份讲义或论文的图形，通常要共用相同的颜色与线条。与其在每个 `Canvas` 重复传入参数，不如把样式写在项目根目录的 `utility-viz.toml`，让 Python 与命令行读取同一份配置。

+ *创建模板。*在项目根目录运行下列命令，会生成含注释的 `utility-viz.toml`，列出每个配置节可用的名称与字段：

  ```bash
  utility-viz init
  ```

  模板中的设置默认都是注释；只保留需要修改的项目即可，其余可以删除。

+ *选择基础主题。*`base` 指定起始的内置主题（#ref(<tab-themes>)），其余设置都在它之上覆盖：

  ```toml
  base = "paper"
  ```

+ *覆盖颜色与样式。*只写出要改的字段：

  ```toml
  [color]
  ic = "#1B4F72"
  eq = "#C0392B"

  [stroke.budget]
  width = 1.6
  style = "dashed"

  [marker.eq]
  size = 5

  [label.point]
  fontsize = 11
  position = "right"
  ```

  配置节名称对应主题属性：`[color]` 的 `ic` 对应 `ic_color`，`[stroke.budget]` 对应 `theme.budget_stroke`；配置节内的字段就是 `Stroke`、`Marker`、`Label`、`Fill`、`Legend` 的参数（详见#ref(<sec-styles>)）。字体写在 `[font]` 的 `text` 与 `math`。省略的字段保留基础主题的值。

+ *在 Python 中应用。*在创建任何图形之前加载一次：

  ```python
  from utility_viz import Config

  Config.load().use()   # 默认读取当前目录的 utility-viz.toml
  ```

  此后创建的 `Canvas`、`Figure`、`DemandDiagram` 与 `EdgeworthBox` 都使用这组配置；调用 `Config.reset()` 可恢复内置默认值。

+ *在命令行应用。*`utility-viz plot` 会自动读取当前目录的 `utility-viz.toml`；要使用其他文件时，以 `--config` 指定配置文件：

  ```bash
  utility-viz plot --config utility-viz.toml --model cobb-douglas \
    --px 2 --py 3 --income 30 --output figure.png
  ```

配置的优先级由高到低为：直接传入 `Canvas` 或绘图方法的参数、配置文件、基础主题。例如 `Canvas(theme=themes.default)` 会略过配置文件中的主题。

配置文件写错时，`Config.load()` 会抛出 `InvalidParameterError`，并列出可用的名称。例如把 `[stroke.budget]` 误写成 `[stroke.budgt]`：

```text
utility-viz.toml: [stroke.budgt]: no such setting (choose: axis, box, budget, ...)
```


=== 配置文件的查找顺序 <sec-config-lookup>

#api(("Config.discover",), added: "v2.0.0b1", syntax: [
  #raw("Config.discover(")#oarg("path")#raw(", directory=None)")
])[
  查找并读取配置文件；找不到时不会出错。
]

`Config.load()`、`Config.discover()` 与 `utility-viz plot` 按下列顺序确定配置文件：

+ 明确指定的路径（`Config.load("file.toml")` 或 `--config`）：文件必须存在，且只读取该文件；
+ 当前目录（或 `directory=`）中的 `utility-viz.toml`；
+ 旧的 `econ-viz.toml`，并发出弃用警告；
+ 内置默认值。

两个文件同时存在时，以 `utility-viz.toml` 为准，旧文件会被忽略并发出警告。两个函数只在找不到文件时有差异：`Config.load()` 与 1.x 相同，抛出 `InvalidParameterError`（"config file not found"）；`Config.discover()` 则返回内置默认值。`utility-viz init --migrate` 可将旧文件转为 `utility-viz.toml`（详见#ref(<sec-cli-init>)）。


#import "/template/manual.typ": *

= 画布与场景 <sec-canvas>

== 画布规格

#api(("CanvasSpec",), syntax: [
  #raw("CanvasSpec(x_range=(0, 10), y_range=(0, 10), width=6.0, height=6.0,") \
  #raw("           dpi=300, x_label=\"X\", y_label=\"Y\", title=None)")
])[
  图形的实体尺寸与坐标范围。`x_range` 与 `y_range` 是显示的数据范围；`width` 与 `height` 是以英寸计的图形大小；`dpi` 是 $[1, 1200]$ 内的整数。属性 `x_min`、`x_max`、`y_min`、`y_max` 读取范围，`replace(**changes)` 返回修改部分字段的副本。范围必须有限且 `lo < hi`，尺寸必须为有限正数，否则引发 `ConfigurationError`。
]

#api(("Interval",), syntax: [#raw("Interval(")#meta("lo")#raw(", ")#meta("hi")#raw(")")])[
  有限的递增区间，`lo < hi`，供规格与坐标轴共用。
]

== 画布

#api(("Canvas",), syntax: [
  #raw("Canvas(spec=None, theme=None, config=None, renderer=None, *,") \
  #raw("       role_overrides=None)")
])[
  包住不可变场景的流式构建器。设为 `None` 的参数取自创建画布时生效的配置（详见#ref(<sec-config>)）：其 `canvas_spec`、`theme` 与 `renderer`。`role_overrides` 把角色名称对应到 `StyleBundle`，套用在主题与配置之上（参见#ref(<thm-resolution>)）。
]

#param("add(layer), extend(layers)")[加入一个或多个图层；返回画布。]
#param("remove(layer_id), clear()")[移除该 id 的图层（含群组内）或所有图层；返回画布。未知的 id 引发 `ConfigurationError`。]
#param("snapshot()")[目前的 `Scene`。之后调用 `add()` 不会改变它。]
#param("copy()")[规格、主题、配置、渲染器、覆盖、场景与绑定都相同的新画布。]
#param("bind(parameter, value), bind(mapping)")[新画布，其场景中的这些参数换成数值（详见#ref(<sec-parameters>)）；原画布保留参数。]
#param("render(*, renderer=None, cache=None)")[绘制场景并返回渲染器的结果（详见#ref(<sec-rendering>)）。]
#param("save(target, *, renderer=None, cache=None, **options)")[绘制、写出 `.png`、`.pdf` 或 `.svg`、关闭结果并返回写出的路径。选项即 `SaveOptions` 的字段。]

构造方法会改变画布，但从不改变场景：每次调用都以新场景取代画布的场景，因此先前获取的快照、副本或绑定后的画布维持原有内容。

```python
from mosaickit import Canvas, PathLayer

canvas = Canvas()
before = canvas.snapshot()
canvas.add(PathLayer([(0, 0), (1, 1)], id="line"))
assert before.layers == ()             # the old snapshot is unchanged
assert canvas.snapshot().layers[0].id == "line"
```

== 场景

#api(("Scene",), syntax: [#raw("Scene(layers=(), metadata={})")])[
  持久且有序的图层集合。`add()`、`extend()`、`remove()` 与 `clear()` 返回新场景；`Scene.empty()` 是空场景。图层 id 在整个场景（含群组）中必须唯一，重复时引发 `ConfigurationError`。`ordered_layers` 按 `z_index` 排序最上层的图层，相同者维持加入顺序，这就是绘制顺序。
]

== 错误与警告

#tbl(caption: [异常与警告])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([类], [引发或发出的时机]),
    [`MosaicKitError`], [以下三个错误的基础类],
    [`ConfigurationError`], [模型、样式、主题、规格或配置值无效],
    [`BindingError`], [参数缺少值、类型错误，或表达式无法求值],
    [`RenderError`], [渲染器无法完成要求：未知的格式或渲染器、缺少的图例项目],
    [`LayoutWarning`], [自动配置无法避开所有障碍物（详见#ref(<sec-labels>)）],
    [`CacheBypassWarning`], [图层的模型无法哈希，因此不经缓存绘制],
  )
]

#changed("0.2.0", label: "LayoutWarning")[新增，在没有任何引线标注位置能避开所有障碍物时发出]

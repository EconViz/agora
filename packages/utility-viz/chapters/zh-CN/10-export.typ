#import "/template/manual.typ": *

= 导出 <sec-export>

== 输出格式

#changed("1.5.0", label: "Canvas.save")[纯 TikZ 导出后端；`Canvas.save()` 与 `Figure.save()` 接受 `.tex`]
#changed("1.6.0", label: "Canvas.save")[TikZ 坐标轴的回归测试不再依赖颜色索引]
#changed("1.3.1", label: "Canvas.save")[`Canvas`、`Figure` 与 `EdgeworthBox` 共享同一个图形导出器（`io.exporter`）]

#api(("Canvas.save",), syntax: [#raw("cvs.save(")#meta("path")#raw(")")])[
  根据 `path` 的扩展名决定输出格式。`Figure`、`DemandDiagram` 与 `EdgeworthBox` 使用相同接口。
]

- PNG：位图，分辨率由画布的 `dpi` 设置，默认为 300。
- PDF、SVG：向量图，可在打印或缩放时保留线条质量。
- TeX：TikZ 源代码（`.tex`），可嵌入 #LaTeX 文件。通过关键字参数 `tikz_scale` 与 `tikz_standalone` 调整输出。

```python
cvs.save("figure.png")   # PNG，依画布 DPI（默认 300）
cvs.save("figure.pdf")   # PDF（向量）
cvs.save("figure.svg")   # SVG（向量）
cvs.save("figure.tex")   # TikZ
```

`dpi` 仅影响位图。预览时可降低分辨率：

```python
cvs = Canvas(x_max=20, y_max=15, dpi=150)   # 降低 DPI，加快预览
```

== GIF 动画

#changed("1.4.0", label: "Animator.save")[导出前将帧合成至不透明背景，改善 GIF 导出稳定性]

使用 `Animator.save()` 导出 GIF，完整示例详见#ref(<sec-animation>)。

```python
from utility_viz.core.animation import Animator

Animator(draw_frame, frames=frames).save("animation.gif", fps=12, dpi=120)
```

== 交互窗口

`cvs.show()` 打开 #pkg("matplotlib") 交互窗口，不会保存文件。命令行的 `plot` 省略 `--output` 时也会打开窗口（详见#ref(<sec-cli-plot>)）：

```bash
utility-viz plot --model cobb-douglas --px 2 --py 3 --income 30
```


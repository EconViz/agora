#import "/template/manual.typ": *

= 输出格式 <sec-outputs>

#tbl(caption: [内建输出])[
  #booktabs(
    columns: (auto, auto, 1fr),
    header: ([格式], [能力], [保留内容]),
    [动态 SVG], [`vector`], [原生 2D 向量；可重现的 3D 投影],
    [GIF], [`raster`], [流式帧，最高 1200 DPI],
    [HTML], [`interactive`], [播放器控制、交互，以及原生 2D 或 3D 显示],
  )
]

#api(("ExportManifest",))[不可变的导出报告，记录格式、生成的文件、尺寸、时长、保留的语义、降级功能、警告与网络依赖。]
#api(("available_formats",))[返回当前已安装可选依赖能够提供的输出格式。]
#api(("export",))[通过导出器注册表输出动画的底层入口；一般用户通常调用 `Animation.save()`。]

#api(("RendererCapabilities",))[声明渲染器支持哪些场景维度、交互、字体功能与封装方式。]
#api(("Requirements",))[KineticKit 分析场景、动作、交互与无障碍数据后，整理出的动画需求。]
#api(("requirements_for",))[在写入任何目标文件之前，计算动画所需的 `Requirements`。]

动态 SVG 采用 SVG 的矢量场景模型 #citep(<svg2>) 与声明式 SMIL 时序元素 #citep(<smil3>)。KineticKit 会写入明确的数值与时间，播放时不需要 Python。

== GIF 设置

#api(("GifSettings",))[控制 GIF 的帧率、调色板、抖动、循环、处置方式、尺寸与 DPI。]
#api(("export_png_frames",))[把已编码的 PNG 帧流式写入 GIF，不必把所有解码后的帧保留在内存中。]

GIF 不接受短于 10 毫秒的帧间隔。时间会分配到整数百分之一秒，同时保持指定的总时长。位图工作量过大时会发出 `RenderCostWarning`，不会隐式降低尺寸或 DPI。

== HTML 封装

`packaging="offline"` 会嵌入运行环境，不需要网络；`packaging="compact"` 会引用固定版本的 CDN 资源，并把网址写入清单。没有 JavaScript 时仍有备用内容：2D 使用嵌入式 SVG，3D 则显示最终状态的静态 SVG。

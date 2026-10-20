#import "/template/manual.typ": *

= 简介 <sec-intro>

#changed("1.0.0b1")[第一个公开 Beta 版：可重现时间轴、2D 与 3D 场景、变形、SVG、GIF 与 HTML 输出、交互、无障碍信息、字体接口与兼容性测试工具]
#changed("1.0.0b2")[GlyphKit 改为必要依赖；加入由已编码 PNG 帧流式组装 GIF 的功能]

#pkg("kinetickit") 是不绑定特定用途的动画引擎。它负责场景、动作、可重现的帧调度、渲染器能力、交互、无障碍元数据与文件导出。经济学软件包和其他应用程序只需把自己的对象转换成普通的 KineticKit 节点。

同一个不可变场景和一段动作，可以输出为动态 SVG、流式 GIF 与单文件交互式 HTML。同一场景在同一时刻一定得到相同快照，不受系统时间或特定渲染器影响。

KineticKit 不会导入 #pkg("mosaickit")、#pkg("utility-viz") 或其他特定用途的软件包。字体处理由 #pkg("glyphkit") 负责，并通过#ref(<sec-typography-accessibility>)介绍的单一适配器接入。

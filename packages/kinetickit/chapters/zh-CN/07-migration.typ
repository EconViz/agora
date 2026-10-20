#import "/template/manual.typ": *

= 迁移现有动画程序 <sec-migration>

MosaicKit 与 utility-viz 过去各自带有小型动画工具。弃用入口会保留一个版本周期；新的动画程序应直接创建 KineticKit 场景与动作。

== 从参数扫描迁移

1. 为每个来源图层设置稳定标识符。
2. 编写转换函数，把图层转换成 KineticKit 节点。
3. 把相邻快照转成 `SceneTransition`，再用 `then()` 接起各段动作。
4. 通过 `Animation.save()` 导出。

KineticKit 特意不提供 MosaicKit 兼容导入。适配器应放在使用方的软件包内，因为只有那里清楚特定用途对象的含义。

== 从工厂式 Animator 迁移

用 `adapt(objects, depict)` 转换工厂返回的对象，再用 `node.animate.<property>.to(...)` 或 `SceneTransition.between()` 表达变化。文件路径、帧率、DPI 与各格式的备用方案都交给导出器。

== 字体处理

把渲染器专用的字体路径改为由调用方持有的 `FontSource` 与 `FontLibrary`，再通过 `GlyphKitTypography` 转换排版结果。不要让场景模型或可选渲染器自行搜索字体。

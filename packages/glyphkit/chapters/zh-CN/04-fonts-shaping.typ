#import "/template/manual.typ": *

= 字体与字形处理 <sec-fonts-shaping>

== 配对与后备字体

#api(("FontQuery",))[描述字体匹配时偏好的字体族、字重、字宽、斜体与可变字体坐标。]
#api(("FontMatch",))[记录一次查询的结果，包括选中的字体面与最终采用的可变字体坐标。]
#api(("FontFace",))[一个可用字体面的快照，包含稳定标识、名称、度量、字符覆盖范围与字体表。]

```python
from glyphkit import FontLibrary, FontSource, Paragraph, TextSpan, TextStyle

library = FontLibrary.from_sources(
    (
        FontSource.path("fonts/SourceSans3-Regular.ttf"),
        FontSource.path("fonts/NotoSansTC-Regular.otf"),
    ),
    generic_families={"sans-serif": ("Source Sans 3", "Noto Sans TC")},
)
layout = library.layout(
    Paragraph((TextSpan("效用 U(x)", TextStyle(("sans-serif",), 18)),))
)
```

示例使用 Google Fonts 提供的开源字体 Source Sans 3 与 Noto Sans TC；数学公式章节则使用采用开放许可证的 STIX Two Math。

字体标识来自字体内容的 SHA-256 摘要与字体集合索引，与文件名无关。`FontManifest` 记录重现排版所需的来源与字体。字形选择、定位与可变字体数据采用 OpenType 规范定义的结构 #citep(<opentype2025>)。

== Unicode 字形处理

#api(("ShapingStyle",))[字形处理时采用的书写系统、方向、语言、OpenType 功能与间距选项。]
#api(("GlyphRun",))[共享同一字体面与处理条件的一段视觉顺序字形，并保留原文范围。]
#api(("PositionedGlyph",))[一个字形编号及其字符簇、前进宽度、位移与字体面标识。]
#api(("shape_text",))[根据明确的回退规则处理 Unicode 文本，返回不绑定渲染器的字形编号与位置。]

左右方向混排时，即使视觉顺序经过重排，原文范围仍保持逻辑顺序；这里采用 Unicode 双向算法对逻辑顺序与视觉顺序的区分 #citep(<unicode-bidi2026>)。找不到字形时会抛出 `MissingGlyphError`；GlyphKit 不会自行换成未设置的系统字体。

== 系统字体

#api(("discover_system_fonts",))[
  主动搜索操作系统已经安装的字体。需要可重现的构建时，请优先传入明确的文件或字节，并保存字体清单。
]

#import "/template/manual.typ": *

= 快速開始 <sec-quickstart>

這個範例明確指定字型檔。GlyphKit 建立字型庫時會留下內容快照，因此檔案路徑之後發生變化，也不會改變既有排版。

#example(```python
from glyphkit import FontLibrary, FontSource, Paragraph, TextSpan, TextStyle

library = FontLibrary.from_sources(
    (FontSource.path("fonts/SourceSans3-Regular.ttf"),)
)
family = library.faces[0].family
paragraph = Paragraph(
    (TextSpan("效用 U(x₁, x₂)", TextStyle((family,), 18)),),
    max_width=360,
)
layout = library.layout(paragraph)

print(layout.logical_bounds)
print(layout.lines[0].runs[0].glyphs[0])
```)

#api(("FontSource",), syntax: [#raw("FontSource") \
  #raw("FontSource.path(path)") \
  #raw("FontSource.bytes(data, label=...)")])[
  由呼叫端持有的字型來源。建立 `FontLibrary` 時會讀取路徑與資料流；位元組來源則保留傳入的資料。
]

#api(("FontLibrary",), syntax: [#raw("FontLibrary") \
  #raw("FontLibrary.from_sources(sources, *, generic_families={})")])[
  主要的字型排版引擎。建立完成後，字型目錄、配對規則與來源識別都不再改變。
]

#api(("Paragraph",))[由帶有樣式的文字片段組成，也可設定寬度、高度、對齊、縮排與行距。]
#api(("TextSpan",))[一段原始文字及其對應的 `TextStyle`。]
#api(("TextStyle",))[設定文字片段使用的字族、字級、字重、字寬、斜體、語言、方向、間距與 OpenType 功能。]
#api(("TextLayout",))[段落排版的不可變結果，包括行、字形處理結果、定位字形、原文範圍、基線、溢位與實際使用的字型。]

GlyphKit 使用邏輯單位，不會綁定特定 DPI 的像素。如何把單位映射到畫布，由使用端決定。

#fig("/figures/layout/metrics-zh-TW.svg", width: 92%, floating: false, caption: [
  字型的基準線、寬度與高度度量
]) <fig-glyph-metrics>

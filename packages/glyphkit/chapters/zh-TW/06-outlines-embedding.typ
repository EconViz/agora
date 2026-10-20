#import "/template/manual.typ": *

= 字形輪廓、字型子集與可攜式資料 <sec-outlines-embedding>

== 字形幾何

#api(("GlyphOutline",))[精確的字形輪廓，包含依序排列的路徑命令、範圍與每 em 單位數。]
#api(("MoveTo",))[把目前位置移到指定的字型座標，開始一條新輪廓。]
#api(("LineTo",))[從目前位置畫一條直線到指定端點。]
#api(("QuadraticTo",))[加入一段具有一個控制點與一個端點的二次 Bézier 曲線。]
#api(("CubicTo",))[加入一段具有兩個控制點與一個端點的三次 Bézier 曲線。]
#api(("ClosePath",))[把目前輪廓連回起點並封閉。]

#api(("flatten",))[依呼叫端指定的容許誤差，以線段近似輪廓中的曲線命令。]
#api(("Polyline",))[曲線細分後得到的一條開放或封閉折線。]

```python
glyph = layout.lines[0].runs[0].glyphs[0]
outline = library.outline(glyph)
```

== 檢查權限的字體子集

#api(("EmbeddingUse",))[宣告字型子集的嵌入用途，讓 GlyphKit 能依該用途檢查字型權限。]
#api(("FontContainer",))[選擇回傳的字型容器，例如 OpenType 或 WOFF2。]
#api(("FontSubsetBundle",))[完整的字型子集結果，包括可攜式字型、來源對應、警告與中繼資料。]
#api(("PortableFont",))[一份已檢查權限的字型資料，包含字族、格式、位元組、涵蓋字形與嵌入資訊。]

```python
from glyphkit.embedding import EmbeddingUse, FontContainer

bundle = library.subset(
    layout,
    embedding_use=EmbeddingUse.WEB,
    container=FontContainer.WOFF2,
)
```

禁止嵌入的字型會直接遭到拒絕。權限不明時也會拒絕，除非呼叫端明確覆寫並自行記錄這項決定。GlyphKit 只回傳位元組與中繼資料；是否寫檔、寫到哪裡，都由使用端決定。

== 序列化

#api(("to_data",))[把支援的公開不可變物件轉成帶有版本、適合 JSON 類儲存方式的一般資料。]
#api(("from_data",))[驗證帶版本的資料，並在設定限制內還原成對應的公開物件。]

#fig("/figures/outlines/glyph-g.svg", width: 30%, caption: [
  完成字形處理後的精確 Bézier 輪廓與部分控制多邊形
]) <fig-glyph-outline>

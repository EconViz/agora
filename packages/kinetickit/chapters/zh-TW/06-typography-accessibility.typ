#import "/template/manual.typ": *

= 字型與無障礙資訊 <sec-typography-accessibility>

== 整合 GlyphKit

#example(```python
from glyphkit import FontLibrary, FontSource
from kinetickit import Animation, Bounds2D, Scene2D, Text2D, Vec2
from kinetickit.integrations.glyphkit import GlyphKitTypography

library = FontLibrary.from_sources(
    (FontSource.path("fonts/SourceSans3-Regular.ttf"),)
)
typography = GlyphKitTypography(
    library,
    families=(library.faces[0].family,),
    size=48,
)
title = Text2D(
    id="title",
    asset=typography.asset("HELLO"),
    position=Vec2(1, 1),
    scale=0.05,
)
scene = Scene2D(title).bind(
    {"camera.view": Bounds2D(Vec2(0, 0), Vec2(10, 6))}
)
motion = title.animate.position.to(Vec2(4, 3), duration=1.5)
Animation(scene, motion).save("text.svg")
```)

#api(("GlyphKitTypography",))[已設定好的轉接器，可把一般文字或數學式轉成不綁定特定繪圖端的 KineticKit `TextAsset`。]
#api(("text_asset_from_layout",))[把既有的 GlyphKit `TextLayout` 轉成定位路徑、度量與選用的可攜式字型資料。]
#api(("text_asset_from_math",))[把 GlyphKit `MathBox` 樹中的字形與線條轉成 KineticKit 文字資產。]

安裝 KineticKit 時會一併安裝相容的 GlyphKit。KineticKit 核心仍延後載入；只有 `kinetickit.integrations.glyphkit` 會匯入字型套件。

#fig("/figures/typography/glyphkit-text.svg", width: 92%, caption: [
  內嵌在 KineticKit 動態 SVG 裡的 GlyphKit 精確字形輪廓
]) <fig-kinetic-type>

== 語意與減少動態效果

#api(("Semantics",))[節點層級的無障礙資料，包括角色、標籤、說明、閱讀順序與裝飾性標記。]
#api(("AccessibilityInfo",))[整段動畫的標題、說明、語言與有順序的語意資訊。]
#api(("ReducedMotion",))[使用者要求減少動態效果時，指定靜態代表畫面與自動播放行為。]

`ReducedMotion` 對應網頁平台的 `prefers-reduced-motion` 使用者偏好 #citep(<mediaqueries5>)；它是作者明確提供的替代呈現，不是自動降低影格率。

SVG 與 HTML 會保留標題、說明、穩定物件識別碼與個別節點語意。HTML 另有鍵盤可操作的控制項和依序排列的物件清單。GIF 無法攜帶這些執行期語意，因此啟用無障礙輸出時需要文字說明，也可附上代表畫面的 PNG。

== 互動

#api(("Event",))[可攜式的互動觸發條件，例如游標停留、點擊、焦點或播放進度。]
#api(("Binding",))[把一個事件接到純資料動作，並標示這項互動是否為必要功能。]
#api(("InteractionSpec",))[附加到動畫上的綁定集合，建立時會檢查內容是否合法。]

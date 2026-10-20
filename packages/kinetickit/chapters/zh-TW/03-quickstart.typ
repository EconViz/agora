#import "/template/manual.typ": *

= 快速開始 <sec-quickstart>

#example(```python
from kinetickit import Animation, Bounds2D, Point2D, Scene2D, Vec2, ease

dot = Point2D(id="dot", position=Vec2(1, 1), size=8, color="#e4572e")
scene = Scene2D(dot)
scene = scene.bind(
    {scene.camera.ref("view"): Bounds2D(Vec2(0, 0), Vec2(10, 10))}
)

motion = dot.animate.position.to(
    Vec2(9, 9),
    duration=1.5,
    easing=ease.out_cubic,
)
animation = Animation(scene, motion)

animation.save("dot.svg", width=400, height=400)
animation.save("dot.gif", width=400, height=400, fps=30)
animation.save("dot.html", width=400, height=440)
```)

#api(("Animation",), syntax: [#raw("Animation(scene, motion=None, *, interactions=None, accessibility=None)")])[
  把不可變場景和動作接在一起的主要介面。`frames()` 會逐一產生快照；`save()` 依目的檔副檔名選擇匯出器，並回傳 `ExportManifest`。
]

#api(("Scene2D",))[包含 2D 節點與相機的不可變場景。`bind()` 會回傳綁定初始屬性的新場景，不會修改原物件。]
#api(("Point2D",))[帶有穩定識別碼的圓形標記；位置、大小、顏色與不透明度都能製作動畫。]
#api(("Bounds2D",))[軸對齊矩形，用來表示相機可見範圍、裁切區域、版面與幾何範圍。]
#api(("Vec2",))[不可變的二維向量，用於位置、方向、尺寸與 2D 幾何計算。]

GIF 與 HTML 兩行需要對應的選用依賴。KineticKit 會在寫入目的地之前檢查能力；不支援的組合會拋出 `CapabilityError`，也不會留下寫到一半的檔案。

#api(("ease",))[
  頂層的緩動函式命名空間，包含線性、多項式、正弦、指數、圓形、回拉、彈性、彈跳與三次 Bézier 緩動函式。
]

#fig("/figures/motion/easing.svg", width: 92%, caption: [
  三次緩動的完整路徑、等時間取樣位置與移動點
]) <fig-kinetic-motion>

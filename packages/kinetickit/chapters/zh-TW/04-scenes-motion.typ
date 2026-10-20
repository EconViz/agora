#import "/template/manual.typ": *

= 場景與動作 <sec-scenes-motion>

== 2D 與 3D 場景

#api(("Line2D",))[兩點之間的線段；端點、顏色、線寬、虛線樣式與繪製進度都能製作動畫。]
#api(("PathNode2D",))[開放或閉合的描邊 `Path2D`，會保留直線與 Bézier 命令，也支援路徑變形。]
#api(("Shape2D",))[填色路徑，可另外加上描邊；適合表示區域、封閉輪廓與複合形狀。]
#api(("Group2D",))[依序容納多個子節點，並對它們套用共同的變換、不透明度與裁切。]
#api(("Text2D",))[放置在場景中的 `TextAsset`；縮放、變換與不透明度都能製作動畫。]
#api(("Camera2D",))[定義可見的 2D 世界座標範圍，以及它如何映射到輸出畫布。]

#api(("Scene3D",))[包含幾何物件、光源、群組與一部相機的不可變 3D 場景。]
#api(("Point3D",))[三維空間中的點標記；位置、大小、顏色與不透明度都能製作動畫。]
#api(("Line3D",))[由目前相機投影到畫布上的單一 3D 線段。]
#api(("Polyline3D",))[依序連接一組 3D 點所形成的折線。]
#api(("Mesh3D",))[由頂點索引與面組成的網格，會驗證拓撲，也可設定各面的顏色與材質。]
#api(("Surface3D",))[從 $x,y$ 規則網格及其高度值建立的高度場曲面。]
#api(("Group3D",))[依序容納多個 3D 節點，並套用共同的變換與不透明度。]
#api(("Camera3D",))[透視或正交相機，包含位置、觀察目標、裁切平面與投影設定。]

== 組合時間

#api(("Motion",))[不可變的時間變化描述；可以依序、同時、延遲、重複、反轉或裁切多段動作。]
#api(("Timeline",))[動作樹編譯後的形式，可以直接求出任意有效時間的屬性值。]
#api(("Keyframe",))[某個時間點的屬性值，也可指定通往下一個關鍵影格的緩動規則。]
#api(("Keyframes",))[同一屬性的關鍵影格序列，會檢查時間順序與端點是否合法。]

```python
motion = (
    a.animate.position.to(Vec2(5, 5), duration=1.0)
    .then(b.animate.opacity.to(1.0, duration=0.5))
    .with_(c.animate.size.to(9, duration=0.5), offset=1.0)
    .mark("settled")
)
```

#api(("SceneTransition",))[依穩定識別碼配對兩個場景的節點，並為相容屬性建立插補動作。]
#api(("TransitionPolicy",))[決定沒有配對或結構不相容的節點要如何進場、退場、交叉淡化或報錯。]

路徑、網格與曲面都有專用變形工具。系統無法自動統一路徑結構或判斷預期拓撲時，請明確提供對應方式。

#fig("/figures/projection/surface.svg", width: 88%, caption: [
  由 KineticKit 向量繪圖端投影並排序深度的 3D 曲面
]) <fig-kinetic-surface>

#import "/template/manual.typ": *

= Bézier 字形輪廓 <sec-glyph-bezier>

== 保留原始路徑命令

`GlyphOutline` 保留移動、直線、二次、三次曲線與閉合命令，不會偷偷把曲線取樣成折線。@fig-glyph-outline 的控制多邊形直接來自這些命令。

== 二次與三次曲線

二次與三次 Bézier 分別為
$ Q(t)=(1-t)^2 P_0+2(1-t)t P_1+t^2 P_2, $
$ C(t)=(1-t)^3 P_0+3(1-t)^2 t P_1+3(1-t) t^2 P_2+t^3 P_3, quad 0<=t<=1. $
兩者都精確通過端點，端點切線由相鄰控制點決定。

#api(("GlyphOutline",))[以字型座標保存精確且不綁定繪圖端的輪廓；擷取時會展開複合字形。]
#api(("MoveTo",))[移到新輪廓的第一個點，不會畫出線段。]
#api(("LineTo",))[畫一條直線到指定端點。]
#api(("QuadraticTo",))[使用一個控制點畫出二次 Bézier 曲線。]
#api(("CubicTo",))[使用兩個控制點畫出三次 Bézier 曲線。]
#api(("ClosePath",))[封閉目前輪廓，並明確加入最後一條邊。]

== 將曲線自動細分為折線

#api(("flatten",))[
  曲線扁平化（curve flattening）會遞迴細分曲線，直到控制點到弦的距離都不超過容許誤差，再回傳開放或閉合的 `Polyline`。
]

== 誤差與細分

二次曲線以 $d(P_1, overline(P_0 P_2)) <= epsilon$ 為停止條件；三次曲線同時檢查兩個內部控制點。未達條件時以 de Casteljau 法在 $t = 1 / 2$ 細分。誤差單位是字型單位；若呼叫端以像素指定誤差，必須先換算回字型單位。

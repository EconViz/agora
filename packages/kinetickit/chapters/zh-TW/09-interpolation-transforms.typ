#import "/template/manual.typ": *

= 插補與座標變換 <sec-kinetic-interpolation>

== 純量、向量、顏色與離散值

實數使用保留精確端點的線性插補 $L(a, b, u) = (1 - u) a + u b$；向量與顏色逐分量套用，離散值則在指定門檻切換。

== 角度與仿射變換

角度採最短有號差
$ Delta=((b-a+pi) mod 2pi)-pi, quad theta(u)=a+u Delta. $
2D 變換把平移、旋轉、縮放與剪切組成 $3 times 3$ 齊次矩陣。矩陣乘法的次序有意義，先平移再旋轉並不等於先旋轉再平移。

== 四元數旋轉

單位軸 $v$ 與角度 $theta$ 轉成 $q=(cos(theta/2),v sin(theta/2))$。若 $q_0 dot q_1<0$，先反轉 $q_1$ 以走短弧。令 $theta=arccos(q_0 dot q_1)$，則
$ "slerp"(q_0,q_1,u)=(sin((1-u)theta)/sin theta) q_0+(sin(u theta)/sin theta) q_1. $
兩端幾乎平行時改用正規化線性插補，避免數值不穩定。

== 幾何值與驗證

#api(("Quaternion",))[用於 3D 旋轉的單位四元數；建立時會驗證並正規化有限、非零的分量。]
#api(("Transform2D",))[不可變的 2D 仿射變換，組合平移、旋轉、縮放與剪切。]
#api(("Transform3D",))[不可變的 3D 齊次變換，用於平移、旋轉、縮放與變換組合。]

== 自訂插補器

自訂屬性型別可向登錄表（registry）註冊插補器。KineticKit 在編譯動作時解析型別與插補器；缺少實作會在輸出任何影格之前失敗，不會等動畫跑到一半才出錯。

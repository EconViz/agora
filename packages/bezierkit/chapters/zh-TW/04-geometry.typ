#import "/template/manual.typ": *

= 幾何數值物件 <sec-geometry>

所有數值物件都不可變，運算會回傳新物件。座標必須為有限值；建立物件時遇到 NaN 或無窮大會拋出 `ValueError`。

== 點與向量

#api(("Point", "Vector"), syntax: [
  #raw("Point(")#meta("float")#raw(", ...)") \
  #raw("Vector(")#meta("float")#raw(", ...)")
])[
  $RR^d$ 中的點或向量，由 $d >= 1$ 個座標給定。點與向量依仿射幾何的規則運算：
]

#param("point - point")[`Vector`。]
#param("point + vector, point - vector")[`Point`。]
#param("vector + vector, vector * scalar")[`Vector`；也可寫成 `scalar * vector`。]
#param("coords, dimension")[座標 tuple 與 $d$。]
#param("x, y, z")[前三個座標（存在時）。]
#param("dot(other), norm(), normalized()")[向量內積、歐氏長度與單位向量（零向量無法正規化）。]

維度不同時拋出 `DimensionMismatch`。`point + point` 不會被拒絕：它把座標相加並回傳 `Point`，只有在權重總和為一的組合中才有意義，例如 de Casteljau 演算法中的平均。

```python
from bezierkit import Point, Vector

p = Point(1, 2)
q = p + Vector(3, -1) * 2      # Point(coords=(7.0, 0.0))
v = q - p                      # Vector(coords=(6.0, -2.0))
print(v.norm())                # 6.324555320336759
```

== 點集合

#api(("PointSet",), syntax: [#raw("PointSet(")#meta("points")#raw(")")])[
  一批不可變的點，背後是唯讀的 $("count", d)$ NumPy 陣列，批次求值與取樣都回傳此物件。提供 `count`、`dimension`、`array`（唯讀副本）、各欄 `x`、`y`、`z`，可逐一取出 `Point`，也可用索引存取。
]

== 參數

#api(("Interval", "ParameterValues"))[
  `Interval(start, end)` 是閉區間，提供 `contains()`、`clamp()` 與 `linspace()`。`ParameterValues` 依定義域檢查單一參數或一維參數陣列；每條曲線都使用它，因此對定義域為 $[0, 1]$ 的曲線呼叫 `at(1.2)` 會拋出 `ParameterOutOfDomain`。
]

== 例外

#tbl(caption: [例外類別])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([例外], [拋出時機]),
    [`BezierKitError`], [下列例外的基礎類別],
    [`DimensionMismatch`], [組合不同維度的點、向量或線段],
    [`DegreeError`], [曲線次數不適用於某項運算，或沒有控制點],
    [`ParameterOutOfDomain`], [參數超出曲線定義域 $[0, 1]$],
    [`ToleranceNotMet`], [自適應擬合在限制內無法達到容許誤差（詳見#ref(<sec-fitting>)）],
  )
]

不屬於幾何的無效參數（例如負的容許誤差）拋出 `ValueError`。

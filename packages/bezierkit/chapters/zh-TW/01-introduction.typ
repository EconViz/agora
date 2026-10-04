#import "/template/manual.typ": *

= 簡介 <sec-intro>

#changed("0.5.0rc1")[首次發布到 PyPI：任意次數的 Bézier 曲線、三次線段與路徑、建構、Hermite 插值、擬合、等值線描繪、取樣、匯出器與命令列介面]
#changed("1.0.0")[第一個正式版；公開 API 依語意化版本管理]

#pkg("bezierkit") 是處理 Bézier 曲線的小型數學工具套件。它可由控制點或端點條件建構曲線，計算曲線值與導數，分割與截取曲線，將曲線擬合到函數、取樣點與等值線，並輸出為 JSON、SVG 路徑資料或 TikZ。套件本身不繪圖，繪圖交給 Matplotlib、#pkg("mosaickit") 或 #LaTeX 文件等繪圖端，它們收到的是精確的三次控制點。

== 符號

點與向量位於某個維度 $d >= 1$ 的 $RR^d$ 中；多數圖使用 $d = 2$。$n$ 次 Bézier 曲線有 $n + 1$ 個控制點 $P_0, dots, P_n$，定義為映射
$ B(t) = sum_(i=0)^n b_(i,n)(t) P_i, quad t in [0, 1], $
其中 $b_(i,n)(t) = binom(n, i) t^i (1-t)^(n-i)$ 為 Bernstein 多項式（詳見#ref(<sec-curves>)）。依序連接控制點即為控制多邊形。套件中每條曲線的參數範圍都是 $[0, 1]$；超出範圍的參數會拋出 `ParameterOutOfDomain`。

== 數學與證明

各章以編號定理陳述演算法所依據的性質：Bernstein 基底的保證、de Casteljau 演算法為何能計算並分割曲線、Hermite 插值最多偏離多少、匯出器因四捨五入損失多少精度。證明集中在#ref(<app-proofs>)，只想了解 API 時可略過。標準參考書為 #citet(<farin2002>) 與 #citet(<prautzsch2002>)。

== 閱讀指引

#tbl(caption: [章節主題])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([主題], [內容], [章節]),
    table.cell(rowspan: 3)[基礎],
    [點、向量、參數、例外], [#ref(<sec-geometry>)],
    [Bernstein 基底、曲線、求值], [#ref(<sec-curves>)],
    [導數、分割、反轉], [#ref(<sec-operations>)],
    table.cell(rowspan: 2)[三次曲線],
    [三次線段與分段路徑], [#ref(<sec-paths>)],
    [建構與 Hermite 插值], [#ref(<sec-construction>)],
    table.cell(rowspan: 2)[近似],
    [擬合函數與折線], [#ref(<sec-fitting>)],
    [描繪等值線], [#ref(<sec-implicit>)],
    table.cell(rowspan: 2)[輸出],
    [取樣、JSON、SVG、TikZ、Matplotlib], [#ref(<sec-export>)],
    [命令列], [#ref(<sec-cli>)],
  )
] <tab-guide>

初次使用時，先讀#ref(<sec-quickstart>)與#ref(<sec-curves>)。本手冊的圖本身就是 #pkg("bezierkit") 的輸出：每條曲線都由#ref(<sec-export>)的 TikZ 匯出器寫出，再以 #LaTeX 編譯。

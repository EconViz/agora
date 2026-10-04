#import "/template/manual.typ": *

= 主題與設定 <sec-themes>

`Theme` 定義圖形的預設外觀；`Config` 從 TOML 檔案載入主題覆寫與字型設定。`Canvas`、`Figure`、`DemandDiagram`、價格效果分解及 `EdgeworthBox` 共用這些樣式物件。

== 內建主題

#changed("1.6.0", label: "themes.default")[預設配色改為色盲友善，並提供 `COLORBLIND_CYCLE_RGB` 與 `COLORBLIND_CYCLE_HEX`]
#changed("1.11.0", label: "Theme")[完成主題系統，新增背景色、標籤比例及所有經濟圖層的預設樣式]
#changed("1.11.0", label: "themes")[新增 `paper`、`monochrome`、`presentation` 與 `dark`]
#changed("1.12.0", label: "Theme")[新增次要無異曲線的顏色、線寬與透明度設定]

#api(("themes",), updated: "v1.11.0", syntax: [
  #modify[```python
  from utility_viz import Canvas, themes

  cvs = Canvas(theme=themes.paper)
  ```]
])[
  Python API 提供下列主題。主題物件不可變；需要調整欄位時，可建立新的 `Theme`，或以 `Config` 覆寫指定欄位。

  #tbl(caption: [內建主題])[
    #booktabs(
      columns: (auto, 1fr),
      header: ([名稱], [特性]),
      [`default`], [色盲友善的預設配色],
      [`colorblind`], [與 `default` 相同的配色別名],
      [`nord`], [採用 Nord 色盤的冷色系主題],
      [`paper`], [透明背景與出版用細線條],
      [`monochrome`], [以線型與標記區分圖層的黑白主題],
      [`presentation`], [放大標籤、線條與標記，供投影使用],
      [`dark`], [深色背景與相應的前景色],
    )
  ] <tab-themes>

  Python API 與設定檔的 `base` 可使用全部七個名稱#footnote[命令列直接傳入 `--theme` 時，只接受 `colorblind` 別名以外的六個主題。]。

  預設主題的顏色取自一組色盲友善的配色 #citep(<thriveth2014>)。

  `themes.COLORBLIND_CYCLE_HEX` 與 `themes.COLORBLIND_CYCLE_RGB` 提供這組配色的十六進位與 RGB 值。經濟學教學大量依賴圖形，因此不應只靠顏色傳達意義，以免視覺障礙的學生無法辨識 #citep(<kugler1996>)。
]

== 自訂主題

#api(("Theme",), updated: "v1.12.0", syntax: [
  #modify[```python
  from utility_viz import Theme

  my_theme = Theme(
      name="custom",
      background_color="white",
      label_scale=1.0,
      axis_color="#333333",
      label_color="#333333",
      ic_color="#2563eb",
      secondary_ic_color="#93c5fd",
      secondary_ic_opacity=0.45,
      budget_color="#dc2626",
      eq_color="#16a34a",
  )
  ```]
])[
  `Theme` 保存圖形元素的顏色、線寬與樣式預設值。未指定的欄位使用類別預設值；繪圖方法明確收到的樣式參數優先於主題。
]

#param("name", type: "str")[主題識別名稱。]
#param("background_color", type: "str | None", default: "None")[圖形與座標區域的背景色；`None` 保持透明。]
#param("label_scale", type: "float", default: "1.0")[一般標籤字級的倍率。]
#param("axis_color", type: "str", default: "\"#222222\"")[座標軸顏色。]
#param("label_color", type: "str", default: "\"#222222\"")[座標標籤與原點文字顏色。]
#param("ic_color", type: "str", default: "\"#377EB8\"")[無異曲線顏色。]
#param("ic_linewidth", type: "float", default: "1.8")[無異曲線線寬。]
#param("secondary_ic_color", type: "str | None", default: "None")[非焦點無異曲線顏色；`None` 沿用 `ic_color`。]
#param("secondary_ic_linewidth", type: "float", default: "1.0")[非焦點無異曲線線寬。]
#param("secondary_ic_opacity", type: "float", default: "0.45")[非焦點無異曲線透明度。]
#param("path_color", type: "str", default: "\"#4DAF4A\"")[PCC 與 ICC 路徑顏色。]
#param("budget_color", type: "str", default: "\"#984EA3\"")[預算線顏色。]
#param("budget_fill_alpha", type: "float", default: "0.08")[預算集合陰影透明度。]
#param("eq_color", type: "str", default: "\"#E41A1C\"")[均衡點與投影線顏色。]
#param("eq_markersize", type: "float", default: "4.0")[均衡點標記大小。]

`Theme` 也包含射線、拗折點、補償預算線與價格效果箭頭的顏色和線寬。`axis_stroke`、`drop_stroke`、`projection_stroke`、`guide_stroke` 與 `box_stroke` 保存其他線條的預設值；標記、標籤、填色及圖例則由 `Marker`、`Label`、`Fill` 與 `Legend` 屬性提供（詳見#ref(<sec-styles>)）。

== 設定檔

#changed("1.10.0", label: "Config")[新增 `Config`、`econ-viz.toml`、`econ-viz init` 與 `plot --config`]
#changed("1.11.0", label: "Config")[設定檔可選用所有內建主題，並在各種圖形間保留相同的視覺語意]
#changed("2.0.0b1", label: "Config")[#modify[預設設定檔更名為 `utility-viz.toml`；舊的 `econ-viz.toml` 仍可讀取，但會發出警告]]
#changed("2.0.0b1", label: "Config.discover")[#modify[新增 `Config.discover()`，找不到檔案時改用內建預設值]]

#api(("Config.load", "Config.use", "Config.reset"), added: "v1.10.0", syntax: [
  #modify[```python
  from utility_viz import Config

  Config.load("utility-viz.toml").use()
  # 此後建立的圖形使用該設定

  Config.reset()
  # 恢復內建預設值
  ```]
])[
  `Config.load()` 讀取 TOML 檔案並回傳 `Config`。`use()` 將其設為後續圖形的預設設定；`reset()` 恢復內建預設值。
]

=== 教學：以設定檔統一圖形樣式

同一份講義或論文的圖形，通常要共用相同的顏色與線條。與其在每個 `Canvas` 重複傳入參數，不如把樣式寫在專案根目錄的 #modify[`utility-viz.toml`]，讓 Python 與命令列讀取同一份設定。

+ *建立範本。*在專案根目錄執行下列指令，會產生含註解的 #modify[`utility-viz.toml`]，列出每個區段可用的名稱與欄位：

  #modify[```bash
  utility-viz init
  ```]

  範本中的設定預設都是註解；只保留需要修改的項目即可，其餘可以刪除。

+ *選擇基底主題。*`base` 指定起始的內建主題（#ref(<tab-themes>)），其餘設定都在它之上覆寫：

  ```toml
  base = "paper"
  ```

+ *覆寫顏色與樣式。*只寫出要改的欄位：

  ```toml
  [color]
  ic = "#1B4F72"
  eq = "#C0392B"

  [stroke.budget]
  width = 1.6
  style = "dashed"

  [marker.eq]
  size = 5

  [label.point]
  fontsize = 11
  position = "right"
  ```

  區段名稱對應主題屬性：`[color]` 的 `ic` 對應 `ic_color`，`[stroke.budget]` 對應 `theme.budget_stroke`；區段內的欄位就是 `Stroke`、`Marker`、`Label`、`Fill`、`Legend` 的參數（詳見#ref(<sec-styles>)）。字型寫在 `[font]` 的 `text` 與 `math`。省略的欄位保留基底主題的值。

+ *在 Python 中套用。*在建立任何圖形之前載入一次：

  #modify[```python
  from utility_viz import Config

  Config.load().use()   # 預設讀取目前目錄的 utility-viz.toml
  ```]

  此後建立的 `Canvas`、`Figure`、`DemandDiagram` 與 `EdgeworthBox` 都使用這組設定；呼叫 `Config.reset()` 可恢復內建預設值。

+ *在命令列套用。*#modify[`utility-viz plot` 會自動讀取目前目錄的 `utility-viz.toml`；要使用其他檔案時，]以 `--config` 指定設定檔：

  #modify[```bash
  utility-viz plot --config utility-viz.toml --model cobb-douglas \
    --px 2 --py 3 --income 30 --output figure.png
  ```]

設定的優先順序由高到低為：直接傳入 `Canvas` 或繪圖方法的參數、設定檔、基底主題。例如 `Canvas(theme=themes.default)` 會略過設定檔中的主題。

設定檔寫錯時，`Config.load()` 會拋出 `InvalidParameterError`，並列出可用的名稱。例如把 `[stroke.budget]` 誤寫成 `[stroke.budgt]`：

#modify[```text
utility-viz.toml: [stroke.budgt]: no such setting (choose: axis, box, budget, ...)
```]

#modify[
=== 設定檔的查找順序 <sec-config-lookup>

#api(("Config.discover",), added: "v2.0.0b1", syntax: [
  #raw("Config.discover(")#oarg("path")#raw(", directory=None)")
])[
  尋找並讀取設定檔；找不到時不會出錯。
]

`Config.load()`、`Config.discover()` 與 `utility-viz plot` 依下列順序決定設定檔：

+ 明確指定的路徑（`Config.load("file.toml")` 或 `--config`）：檔案必須存在，且只讀取該檔；
+ 目前目錄（或 `directory=`）中的 `utility-viz.toml`；
+ 舊的 `econ-viz.toml`，並發出棄用警告；
+ 內建預設值。

兩個檔案同時存在時，以 `utility-viz.toml` 為準，舊檔會被略過並發出警告。兩個函式只在找不到檔案時有差異：`Config.load()` 與 1.x 相同，拋出 `InvalidParameterError`（"config file not found"）；`Config.discover()` 則回傳內建預設值。`utility-viz init --migrate` 可將舊檔轉為 `utility-viz.toml`（詳見#ref(<sec-cli-init>)）。
]

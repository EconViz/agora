#import "/template/manual.typ": *

= 命令列工具 <sec-cli>

#changed("1.7.0", label: "econ-viz")[新增 `econ-viz --version`，顯示已安裝的套件版本]
#changed("1.3.1", label: "econ-viz")[命令列錯誤改為拋出 `CliConfigError`，結束處理集中在 `cli.main`]
#changed("1.2.3", label: "econ-viz models")[命令列工具支援 `QuasiLinear`、`StoneGeary` 與 `Translog`]
#changed("1.10.0", label: "econ-viz init")[新增設定檔範本指令與 `plot --config`]
#changed("1.11.0", label: "econ-viz plot")[`--theme` 支援所有命令列內建主題]
#changed("2.0.0b1", label: "utility-viz")[指令改為 `utility-viz`；`econ-viz` 會印出棄用警告並轉交給新指令]
#changed("2.0.0b1", label: "utility-viz plot")[未指定 `--config` 時，讀取目前目錄的 `utility-viz.toml`（或舊的 `econ-viz.toml`）]
#changed("2.0.0b1", label: "utility-viz init")[新增 `--migrate` 選項]

命令列工具可繪圖、批次處理及輸出需求公式。以 `uv tool install utility-viz` 安裝為獨立工具，或在 #pkg("uv") 專案中於指令前加上 `uv run`（詳見#ref(<sec-install-cli>)）。由 #pkg("econ-viz") 相容套件安裝的 1.x 指令 `econ-viz` 在 2.x 仍可使用：它會發出棄用警告，再以相同參數執行 `utility-viz`（詳見#ref(<sec-migrate>)）。

#tbl(caption: [命令列指令])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([指令], [說明]),
    [#raw("utility-viz help [")#meta("command")#raw("]")],
    [顯示命令列工具或特定指令的說明],
    [`utility-viz models`],
    [列出所有支援的效用模型],
    [`utility-viz plot ...`],
    [產生並匯出圖形],
    [`utility-viz solve-tex ...`],
    [以 TeX 格式輸出 Marshall 需求的閉式解],
    [`utility-viz init [path]`],
    [建立 `utility-viz.toml` 設定範本],
  )
]

== 說明與模型

#api(("utility-viz help",), syntax: [#raw("utility-viz help [")#meta("command")#raw("]")])[
  未指定參數時列出所有指令；指定指令名稱時顯示該指令的選項。

  ```bash
  utility-viz help          # 所有指令
  utility-viz help plot     # plot 選項
  utility-viz help models   # models 選項
  ```
]

#api(("utility-viz models",))[
  列出命令列介面支援的模型名稱與參數。`--model` 使用 kebab-case 名稱，與 Python 類別名稱不同（參見#ref(<tab-models>)）。參數選項詳見#ref(<sec-cli-plot>)。

  #tbl(caption: [命令列模型])[
    #booktabs(
      columns: (auto, auto, auto, 1fr),
      header: ([模型], [`--model` 值], [必要參數], [選用參數]),
      [Cobb-Douglas], [`cobb-douglas`], [`alpha`、`beta`], [--],
      [CES], [`ces`], [`rho`], [`alpha`、`beta`],
      [完全互補], [`leontief`], [`a`、`b`], [--],
      [完全替代], [`perfect-substitutes`], [`a`、`b`], [--],
      [飽和偏好], [`satiation`], [`bliss-x`、`bliss-y`], [`a`、`b`],
      [準線性], [`quasi-linear`], [--], [`v-func`、`linear-in`],
      [Stone-Geary], [`stone-geary`], [--], [`alpha`、`beta`、`bar-x`、`bar-y`],
      [Translog], [`translog`], [--], [`alpha-0`、`alpha-x`、`alpha-y`、`beta-xx`、`beta-yy`、`beta-xy`],
    )
  ] <tab-models>
]

== 繪圖 <sec-cli-plot>

#api(("utility-viz plot",), syntax: [
  #raw("utility-viz plot --model ")#meta("name")#raw(" ")#meta("options") \
  #raw("utility-viz plot --latex ")#meta("expression")#raw(" ")#meta("options")
])[
  使用 `--model` 指定模型，或使用 `--latex` 輸入效用函數，兩者擇一。指定 `--output` 時匯出檔案，省略時開啟互動視窗。

  預算線與均衡點需要完整的價格與所得。`--no-budget`、`--no-equilibrium`、`--no-curves` 可分別省略對應圖層，且可併用（參見#ref(<tab-plot-flags>)）。

  #tbl(caption: [圖層控制選項])[
    #booktabs(
      columns: (auto, 1fr),
      header: ([情況], [結果]),
      [提供完整 `--px`、`--py`、`--income`], [繪製預算線並求解均衡],
      [省略任一價格或所得], [僅繪製無異曲線，不畫預算線與均衡點],
      [加上 `--no-equilibrium`], [略過求解與均衡標示，即使提供了價格與所得],
      [加上 `--no-budget`], [隱藏預算線，即使提供了價格與所得],
      [`--no-curves` 搭配完整價格與所得], [只呈現預算線與均衡點，不畫無異曲線],
    )
  ] <tab-plot-flags>

  ```bash
  # 指定模型名稱
  utility-viz plot --model cobb-douglas --alpha 0.5 --beta 0.5 ...

  # LaTeX 算式
  utility-viz plot --latex "x^{0.4} y^{0.6}" ...
  ```
]

#example([```bash
# Cobb-Douglas，可行集合加陰影
utility-viz plot --model cobb-douglas --alpha 0.5 --beta 0.5 \
              --px 2 --py 3 --income 30 \
              --fill --output cobb_douglas.png

# LaTeX 輸入，Nord 主題，擴張路徑
utility-viz plot --latex "x^{0.4} y^{0.6}" \
              --px 2 --py 3 --income 30 \
              --theme nord --show-ray \
              --output cd_latex.png

# 完全互補，加大畫布
utility-viz plot --model leontief --a 1 --b 2 \
              --px 2 --py 3 --income 30 \
              --x-max 20 --y-max 15 \
              --output leontief.png

# CES，只畫無異曲線
utility-viz plot --model ces --rho -0.5 \
              --x-max 20 --y-max 15 --n-curves 6 \
              --no-budget --no-equilibrium \
              --output ces.png

# 飽和（極樂點）
utility-viz plot --model satiation --bliss-x 6 --bliss-y 4 \
              --x-max 12 --y-max 10 \
              --no-budget --no-equilibrium \
              --output satiation.png

# 不加 --output：開啟視窗
utility-viz plot --model cobb-douglas --px 2 --py 3 --income 30
```])

=== 選擇模型

#param("--model, -m")[
  模型名稱，完整清單可用 `utility-viz models` 查詢。
]
#param("--latex, -l")[
  #LaTeX 算式，支援 Cobb-Douglas、完全互補、完全替代與 CES（詳見#ref(<sec-latex>)）。
]

=== 價格與所得

#param("--px")[商品 $x$ 的價格。]
#param("--py")[商品 $y$ 的價格。]
#param("--income")[消費者的所得。]

=== 模型參數

#param("--alpha", default: "0.5")[alpha 參數（Cobb-Douglas、CES）。]
#param("--beta", default: "0.5")[beta 參數（Cobb-Douglas、CES）。]
#param("--a", default: "1.0")[參數 $a$（完全互補、完全替代、飽和）。]
#param("--b", default: "1.0")[參數 $b$（完全互補、完全替代、飽和）。]
#param("--rho", default: "0.5")[替代參數（CES）。]
#param("--bliss-x", default: "5.0")[極樂點的 $x$ 座標（飽和）。]
#param("--bliss-y", default: "5.0")[極樂點的 $y$ 座標（飽和）。]

準線性、Stone-Geary 與 Translog 另有下列選項，可依模型使用：

#param("--v-func", default: "log")[準線性的非線性函數，接受 `log` 或 `sqrt`。]
#param("--linear-in", default: "y")[準線性的線性商品，接受 `x` 或 `y`。]
#param("--bar-x", default: "1.0")[Stone-Geary 的最低消費量 $overline(x)$。]
#param("--bar-y", default: "1.0")[Stone-Geary 的最低消費量 $overline(y)$。]
#param("--alpha-0", default: "0.0")[Translog 的截距。]
#param("--alpha-x", default: "0.5")[Translog 中 $ln x$ 的一次項權重。]
#param("--alpha-y", default: "0.5")[Translog 中 $ln y$ 的一次項權重。]
#param("--beta-xx", default: "0.0")[Translog 中 $x$ 方向的曲率。]
#param("--beta-yy", default: "0.0")[Translog 中 $y$ 方向的曲率。]
#param("--beta-xy", default: "0.0")[Translog 中 $x$ 與 $y$ 的交叉項。]

```bash
utility-viz plot --model stone-geary --bar-x 2 --bar-y 2 \
              --px 2 --py 3 --income 30 \
              --x-max 20 --y-max 15 --output stone_geary.png
```

此例的最低消費支出為 $2 times 2 + 3 times 2 = 10$，所得 $30$ 高於此限制。若將所得改為 $10$ 或更低，求解會因不符合模型定義域而失敗。

=== 畫布與圖層

#param("--x-max", default: "10")[橫軸上限。]
#param("--y-max", default: "10")[縱軸上限。]
#param("--x-label", default: "x")[橫軸標籤。]
#param("--y-label", default: "y")[縱軸標籤。]
#param("--title")[圖形標題。]
#param("--theme", default: "default")[主題名稱：`default`、`nord`、`paper`、`monochrome`、`presentation` 或 `dark`（詳見#ref(<sec-themes>)）。]
#param("--config")[TOML 設定檔路徑。命令列參數的優先順序高於設定檔。省略時，若目前目錄有 `utility-viz.toml`（或舊的 `econ-viz.toml`）則自動使用（詳見#ref(<sec-config-lookup>)）。]
#param("--n-curves", default: "5")[無異曲線的條數。]
#param("--dpi", default: "300")[點陣圖輸出解析度。]
#param("--fill")[為預算線下方的可行集合加上陰影。]
#param("--show-ray")[畫出通過最適點的擴張路徑射線。]
#param("--no-budget")[不畫預算線。]
#param("--no-equilibrium")[不畫均衡點。]
#param("--no-curves")[不畫無異曲線。]
#param("--output, -o")[
  輸出檔案（`.png`、`.pdf`、`.svg`、`.tex`）；省略時開啟互動視窗。
]

批次產圖時，為每組參數指定不同檔名，並先建立輸出目錄。`--x-max` 與 `--y-max` 不會隨價格自動調整；軸截距或最適點超出範圍時，應同步增大畫布上限。

== 建立設定檔 <sec-cli-init>

#api(("utility-viz init",), added: "v1.10.0", syntax: [
  #raw("utility-viz init [")#meta("path")#raw("] [--force]")#raw(" [--migrate]")
])[
  建立含註解的 `utility-viz.toml` 範本。省略路徑時寫入目前目錄；檔案已存在時，必須使用 `--force` 才會覆寫。`--migrate` 則改為從同一目錄中舊的 `econ-viz.toml` 建立 `utility-viz.toml`，並保留舊檔。

  ```bash
  utility-viz init
  utility-viz init config/figures.toml
  utility-viz init --migrate
  utility-viz plot --config utility-viz.toml --model cobb-douglas \
                --px 2 --py 3 --income 30 --output figure.png
  ```
]

== 需求公式

#api(("utility-viz solve-tex",), syntax: [
  #raw("utility-viz solve-tex --model ")#meta("name")#raw(" ")#meta("options")
])[
  以 TeX 格式輸出 Marshall 需求的閉式解，可用於支援 TeX 數學式的文件。

  ```bash
  # 數值參數
  utility-viz solve-tex --model cobb-douglas --alpha 0.4 --beta 0.6

  # 符號參數
  utility-viz solve-tex --model cobb-douglas --symbolic-params

  # 自訂價格與所得符號
  utility-viz solve-tex --model leontief --a 2 --b 3 \
                     --px-symbol p_1 --py-symbol p_2 --income-symbol M
  ```

  支援 `cobb-douglas`、`leontief`、`perfect-substitutes` 及其 #LaTeX 表示式。此指令只輸出公式文字，不產生圖檔。
]

#param("--symbolic-params")[保留模型參數符號，例如 $alpha$、$beta$；未使用時代入指定的參數值。]
#param("--px-symbol", default: "p_x")[商品 $x$ 價格的符號。]
#param("--py-symbol", default: "p_y")[商品 $y$ 價格的符號。]
#param("--income-symbol", default: "I")[所得的符號。]

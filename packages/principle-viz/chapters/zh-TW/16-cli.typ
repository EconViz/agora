#import "/template/manual.typ": *

= 命令列介面 <sec-cli>

#changed("0.1.0", label: "principle-viz")[命令列介面，輸出 JSON]

`principle-viz` 指令在命令列執行本手冊中的計算，並以 JSON 印出結果；`--output` 會另外寫成檔案。此指令不繪圖。可將其安裝為工具（詳見#ref(<sec-install-cli>)），或在專案中於指令前加上 `uv run`。

```bash
principle-viz equilibrium \
  --demand-intercept 10 --demand-slope -1 \
  --supply-intercept 2 --supply-slope 1
```

```text
{
  "q_star": 4.0,
  "p_star": 6.0,
  "is_valid_market": true,
  "notes": []
}
```

== 市場參數

多數指令以反函數形式 $p = a + b Q$ 的兩條直線描述市場：

#param("--demand-intercept")[需求的價格截距 $a$。]
#param("--demand-slope")[需求的斜率 $b$。]
#param("--supply-intercept")[供給的價格截距 $a$。]
#param("--supply-slope")[供給的斜率 $b$。]
#param("--output")[另將 JSON 寫入此檔案，並建立所需目錄。]

== 指令

各指令對應的計算與選項如#ref(<tab-cli>)；每個指令的計算說明見對應章節。

#tbl(caption: [命令列指令])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([指令], [計算與其他選項], [章節]),
    [`equilibrium`], [線性均衡], [#ref(<sec-markets>)],
    [`shift`], [比較靜態：#box[`--demand-delta-intercept`]、#box[`--demand-delta-slope`]、#box[`--supply-delta-intercept`]、#box[`--supply-delta-slope`]], [#ref(<sec-shifts>)],
    [`discrete`], [離散市場：#box[`--demand-values`]、#box[`--supply-values`]、#box[`--price-rule {midpoint,lower,upper}`]], [#ref(<sec-discrete>)],
    [`elasticity`], [點彈性：#box[`--intercept`]、#box[`--slope`]、#box[`--quantity`]；加上 #box[`--q1`]、#box[`--p1`] 計算弧彈性], [#ref(<sec-elasticity>)],
    [`revenue`], [彈性與總收益表：#box[`--samples`]], [#ref(<sec-elasticity>)],
    [`welfare`], [剩餘：#box[`--policy {baseline,tax,subsidy,control}`] 與該政策的選項], [#ref(<sec-welfare>)],
    [`report-dwl`], [單列無謂損失報表：#box[`--policy {tax,subsidy,control}`]、#box[`--csv`]], [#ref(<sec-welfare>)],
    [`tax`], [#box[`--tax-type {fixed,per_unit,ad_valorem}`]、#box[`--amount`]、#box[`--tax-on {consumer,producer}`]], [#ref(<sec-taxes>)],
    [`subsidy`], [#box[`--amount`]、#box[`--subsidy-to {consumer,producer}`]], [#ref(<sec-taxes>)],
    [`controls`], [#box[`--control-type {ceiling,floor}`]、#box[`--control-price`]], [#ref(<sec-controls>)],
    [`trade`], [#box[`--world-price`]、#box[`--tariff`]、#box[`--import-quota`]、#box[`--quota-rent-recipient`]], [#ref(<sec-trade>)],
    [`externality`], [#box[`--external-cost`]、#box[`--external-benefit`]], [#ref(<sec-failures>)],
    [`common-resource`], [#box[`--congestion-cost`]], [#ref(<sec-failures>)],
    [`public-good`], [#box[`--benefit-intercepts`]、#box[`--benefit-slopes`]、#box[`--cost-intercept`]、#box[`--cost-slope`]、#box[`--samples`]], [#ref(<sec-failures>)],
    [`minimum-wage`], [#box[`--labor-demand-*`]、#box[`--labor-supply-*`]、#box[`--minimum-wage`]], [#ref(<sec-factor>)],
    [`loanable-funds`], [#box[`--savings-*`]、#box[`--investment-*`]、#box[`--savings-shift`]、#box[`--investment-shift`]、#box[`--government-borrowing`]], [#ref(<sec-factor>)],
    [`ppf`], [#box[`--x-intercept`]、#box[`--y-intercept`]、#box[`--curvature`]、#box[`--x-good`]、#box[`--y-good`]、#box[`--x-growth`]、#box[`--y-growth`]、#box[`--samples`]], [#ref(<sec-ppf>)],
  )
] <tab-cli>

`principle-viz <command> --help` 列出指令的所有選項。

```bash
principle-viz tax \
  --demand-intercept 10 --demand-slope -1 \
  --supply-intercept 2 --supply-slope 1 \
  --tax-type per_unit --amount 1 --tax-on producer
```

輸出包含未課稅的均衡（`baseline_equilibrium`）、課稅後的均衡（`post_tax`）與各項變動，與 `compare_tax_scenario()` 的回傳值相同：本例數量為 3.5，消費者價格 6.5，生產者價格 5.5。

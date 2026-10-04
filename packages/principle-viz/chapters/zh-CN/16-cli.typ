#import "/template/manual.typ": *

= 命令行界面 <sec-cli>

#changed("0.1.0", label: "principle-viz")[命令行界面，输出 JSON]

`principle-viz` 命令在命令行运行本手册中的计算，并以 JSON 打印结果；`--output` 会另外写成文件。此命令不绘图。可将其安装为工具（详见#ref(<sec-install-cli>)），或在项目中于命令前加上 `uv run`。

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

== 市场参数

多数命令以反函数形式 $p = a + b Q$ 的两条直线描述市场：

#param("--demand-intercept")[需求的价格截距 $a$。]
#param("--demand-slope")[需求的斜率 $b$。]
#param("--supply-intercept")[供给的价格截距 $a$。]
#param("--supply-slope")[供给的斜率 $b$。]
#param("--output")[另将 JSON 写入此文件，并创建所需目录。]

== 命令

#tbl(caption: [命令行命令])[
  #booktabs(
    columns: (auto, 1fr, auto),
    header: ([命令], [计算与其他选项], [章节]),
    [`equilibrium`], [线性均衡], [#ref(<sec-markets>)],
    [`shift`], [比较静态：#box[`--demand-delta-intercept`]、#box[`--demand-delta-slope`]、#box[`--supply-delta-intercept`]、#box[`--supply-delta-slope`]], [#ref(<sec-shifts>)],
    [`discrete`], [离散市场：#box[`--demand-values`]、#box[`--supply-values`]、#box[`--price-rule {midpoint,lower,upper}`]], [#ref(<sec-discrete>)],
    [`elasticity`], [点弹性：#box[`--intercept`]、#box[`--slope`]、#box[`--quantity`]；加上 #box[`--q1`]、#box[`--p1`] 计算弧弹性], [#ref(<sec-elasticity>)],
    [`revenue`], [弹性与总收益表：#box[`--samples`]], [#ref(<sec-elasticity>)],
    [`welfare`], [剩余：#box[`--policy {baseline,tax,subsidy,control}`] 与该政策的选项], [#ref(<sec-welfare>)],
    [`report-dwl`], [单行无谓损失报表：#box[`--policy {tax,subsidy,control}`]、#box[`--csv`]], [#ref(<sec-welfare>)],
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

`principle-viz <command> --help` 列出命令的所有选项。

```bash
principle-viz tax \
  --demand-intercept 10 --demand-slope -1 \
  --supply-intercept 2 --supply-slope 1 \
  --tax-type per_unit --amount 1 --tax-on producer
```

输出包含未征税的均衡（`baseline_equilibrium`）、征税后的均衡（`post_tax`）与各项变动，与 `compare_tax_scenario()` 的返回值相同：本例数量为 3.5，消费者价格 6.5，生产者价格 5.5。

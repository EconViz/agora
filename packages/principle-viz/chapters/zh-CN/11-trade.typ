#import "/template/manual.typ": *

= 国际贸易 <sec-trade>

#changed("0.10.0", label: "MarketFigure.add_trade")[标出 $Q_s$ / $Q_d$，并在数量轴下方以括号标示 "Imports" / "Exports"；政策价格标为 $p_w + t$ 或 $p_q$]

小型开放经济体接受既定的世界价格 $p_w$。世界价格低于自给自足价格时，进口国内需求与供给的差额；高于自给自足价格时则出口。关税或进口配额会提高国内价格并减少进口。

#api(("TradeScenario",), syntax: [
  #raw("TradeScenario(world_price, tariff=0.0, import_quota=None, quota_rent_recipient=QuotaRentRecipient.DOMESTIC)")
])[
  世界价格与至多一项政策：每单位 `tariff` 或 `import_quota`，两者不可同时设置（`PolicyError`）。
]

#param("quota_rent_recipient", type: "QuotaRentRecipient")[配额租的归属：国内进口商（`DOMESTIC`）或政府（`GOVERNMENT`），两者都计入国民剩余，政府获得的部分列为收入；或外国出口商（`FOREIGN`），配额租流出国外。]

#api(("analyze_trade",), syntax: [
  #raw("analyze_trade(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  比较自给自足、自由贸易与政策三种情况。`TradeComparisonResult` 包含三个 `TradeOutcome`（`autarky`、`free_trade`、`policy`），以及政策相对于自由贸易的 `deadweight_loss`。
]

#param("domestic_price")[国内市场价格。]
#param("quantity_demanded")[该价格下的国内需求量。]
#param("quantity_supplied")[该价格下的国内供给量。]
#param("imports")[进口量。]
#param("exports")[出口量。]
#param("direction")[`TradeDirection`：`IMPORT`、`EXPORT` 或 `AUTARKY`。]
#param("consumer_surplus")[消费者剩余。]
#param("producer_surplus")[生产者剩余。]
#param("government_revenue")[政府收入。]
#param("quota_rent")[配额产生的租。]
#param("national_quota_rent")[配额租中留在国内的部分。]
#param("total_surplus")[国民剩余。]
#param("gains_from_trade")[相对于自给自足的增加。]
#param("is_policy_binding")[关税或配额是否改变价格。]

```python
from principle_viz import TradeScenario, analyze_trade

demand = line_from_inverse(12.0, -1.0)   # autarky price 7
scenario = TradeScenario(world_price=4, tariff=2)
result = analyze_trade(demand, supply, scenario)
print(result.free_trade.imports, result.policy.imports)
# 6.0 2.0
print(result.policy.government_revenue, result.deadweight_loss)
# 4.0 4.0
```

关税 2 时，国内价格为 6，政府收入为 $2 times 2 = 4$。配额 2 单位时价格同为 6，配额租 4 归 `quota_rent_recipient` 指定的一方。

#api(("MarketFigure.add_trade",), syntax: [
  #raw("add_trade(")#meta("result")#raw(")")
])[
  画出世界价格线并命名为 $p_w$，标出政策价格（$p_w + t$ 或 $p_q$），在数量轴上标 $Q_s$ 与 $Q_d$ 并于下方加上 "Imports" 或 "Exports" 括号，再以命名的矩形表示关税收入或配额租（参见#ref(<fig-free-trade>)、#ref(<fig-tariff>)、#ref(<fig-quota>)）。
]

#fig("/figures/trade/free_trade_import.svg", width: 46%, caption: [
  自由贸易下的进口。
]) <fig-free-trade>

#fig("/figures/trade/tariff.svg", width: 46%, caption: [
  进口关税。
]) <fig-tariff>

#fig("/figures/trade/quota.svg", width: 46%, caption: [
  有约束的进口配额。
]) <fig-quota>

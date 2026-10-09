#import "/template/manual.typ": *

= 國際貿易 <sec-trade>

#changed("0.10.0", label: "MarketFigure.add_trade")[標出 $Q_s$ / $Q_d$，並在數量軸下方以括號標示 "Imports" / "Exports"；政策價格標為 $p_w + t$ 或 $p_q$]

小型開放經濟體接受既定的世界價格 $p_w$。世界價格低於自給自足價格時，進口國內需求與供給的差額；高於自給自足價格時則出口。關稅或進口配額會提高國內價格並減少進口。

#api(("TradeScenario",), syntax: [
  #raw("TradeScenario(world_price, tariff=0.0, import_quota=None, quota_rent_recipient=QuotaRentRecipient.DOMESTIC)")
])[
  世界價格與至多一項政策：每單位 `tariff` 或 `import_quota`，兩者不可同時設定（`PolicyError`）。
]

#param("quota_rent_recipient", type: "QuotaRentRecipient")[配額租的歸屬：國內進口商（`DOMESTIC`）或政府（`GOVERNMENT`），兩者都計入國民剩餘，政府取得的部分列為收入；或外國出口商（`FOREIGN`），配額租流出國外。]

#api(("analyze_trade",), syntax: [
  #raw("analyze_trade(")#meta("demand")#raw(", ")#meta("supply")#raw(", ")#meta("scenario")#raw(")")
])[
  比較自給自足、自由貿易與政策三種情況。`TradeComparisonResult` 包含三個 `TradeOutcome`（`autarky`、`free_trade`、`policy`），以及政策相對於自由貿易的 `deadweight_loss`。
]

#param("domestic_price")[國內市場價格。]
#param("quantity_demanded")[該價格下的國內需求量。]
#param("quantity_supplied")[該價格下的國內供給量。]
#param("imports")[進口量。]
#param("exports")[出口量。]
#param("direction")[`TradeDirection`：`IMPORT`、`EXPORT` 或 `AUTARKY`。]
#param("consumer_surplus")[消費者剩餘。]
#param("producer_surplus")[生產者剩餘。]
#param("government_revenue")[政府收入。]
#param("quota_rent")[配額產生的租。]
#param("national_quota_rent")[配額租中留在國內的部分。]
#param("total_surplus")[國民剩餘。]
#param("gains_from_trade")[相對於自給自足的增加。]
#param("is_policy_binding")[關稅或配額是否改變價格。]

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

關稅 2 時，國內價格為 6，政府收入為 $2 times 2 = 4$。配額 2 單位時價格同為 6，配額租 4 歸 `quota_rent_recipient` 指定的一方。

#api(("MarketFigure.add_trade",), syntax: [
  #raw("add_trade(")#meta("result")#raw(")")
])[
  畫出世界價格線並命名為 $p_w$，標出政策價格（$p_w + t$ 或 $p_q$），在數量軸上標 $Q_s$ 與 $Q_d$ 並於下方加上 "Imports" 或 "Exports" 括號，再以命名的矩形表示關稅收入或配額租（參見#ref(<fig-free-trade>)、#ref(<fig-tariff>)、#ref(<fig-quota>)）。
]

#fig("/figures/trade/free_trade_import.svg", width: 46%, caption: [
  自由貿易下的進口。
]) <fig-free-trade>

#fig("/figures/trade/tariff.svg", width: 46%, caption: [
  進口關稅。
]) <fig-tariff>

#fig("/figures/trade/quota.svg", width: 46%, caption: [
  有約束的進口配額。
]) <fig-quota>

#import "/template/manual.typ": *

= 命令列介面 <sec-cli>

安裝 `cli` 選用依賴後即可使用 `bezierkit` 指令，在命令列計算、取樣與建構曲線。預設輸出表格，也可輸出 JSON 或 CSV 給其他程式使用。

```bash
bezierkit evaluate --points "0,0" --points "1,2" --points "3,2" --points "4,0" \
                   --t 0.5 --order 1 --json
# [{"t":0.5,"value":[4.5,0.0]}]
```

== 控制點

需要曲線的指令以重複的 `--points` 選項接收控制點，每個是以逗號分隔的座標（`"1,2"`，三維則為 `"1,2,3"`）。省略 `--points` 時，指令從標準輸入讀取含 `control_points` 陣列的 JSON 物件，也就是 `construct` 的輸出，因此指令之間可以用管線串接。

== 指令

#api(("evaluate",), syntax: [
  #raw("bezierkit evaluate --t ")#meta("values")#raw(" [--points ...] [--order ")#meta("int")#raw("] [--json]")
])[
  在每個 `--t` 計算曲線值，或其 `--order` 階導數（預設 0）。每個值可為數字或含端點的範圍 `start:stop:step`，例如 `0:1:0.25`；`--t` 可重複。
]

#api(("sample",), syntax: [
  #raw("bezierkit sample [--points ...] [--count ")#meta("int")#raw("] [--format table|csv|json] [--output ")#meta("path")#raw("]")
])[
  以 `--count` 個（預設 50）等距參數取樣，含兩端，每列為 `t`、`x`、`y`（三維另有 `z`，更高維為 `c3`、`c4`……）。`--output` 寫入檔案而非標準輸出。
]

#api(("construct slopes", "construct tangents"), syntax: [
  #raw("bezierkit construct slopes --start ")#meta("point")#raw(" --end ")#meta("point")#raw(" --start-slope ")#meta("float")#raw(" --end-slope ")#meta("float")#raw(" [--start-handle --end-handle]") \
  #raw("bezierkit construct tangents --start ... --end ... --start-direction ")#meta("vector")#raw(" --end-direction ")#meta("vector")#raw(" [...]")
])[
  以 `PlanarSlopes` 或 `TangentDirections`（詳見#ref(<sec-construction>)）建構三次曲線，並以 JSON 印出控制點。
]

```bash
bezierkit construct slopes --start "0,5" --end "5,0" \
                           --start-slope -2 --end-slope -0.3 \
| bezierkit sample --count 3 --format csv
# t,x,y
# 0.0,0.0,5.0
# 0.5,2.3085202413545525,2.272345260462411
# 1.0,5.0,0.0
```

== 錯誤

無效輸入（例如格式錯誤的點，或超出 $[0, 1]$ 的參數）會在標準錯誤輸出印出 `Error: ...`，結束狀態為 1，不顯示 traceback。在指令前加上全域選項 `--debug` 可改為顯示 Python traceback。

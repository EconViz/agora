#import "/template/manual.typ": *

= 命令行界面 <sec-cli>

安装 `cli` 可选依赖后即可使用 `bezierkit` 命令，在命令行计算、采样与构造曲线。默认输出表格，也可输出 JSON 或 CSV 给其他程序使用。

```bash
bezierkit evaluate --points "0,0" --points "1,2" --points "3,2" --points "4,0" \
                   --t 0.5 --order 1 --json
# [{"t":0.5,"value":[4.5,0.0]}]
```

== 控制点

需要曲线的命令以重复的 `--points` 选项接收控制点，每个是以逗号分隔的坐标（`"1,2"`，三维则为 `"1,2,3"`）。省略 `--points` 时，命令从标准输入读取含 `control_points` 数组的 JSON 对象，也就是 `construct` 的输出，因此命令之间可以用管道串接。

== 命令

#api(("bezierkit evaluate",), syntax: [
  #raw("bezierkit evaluate --t ")#meta("values")#raw(" [--points ...] [--order ")#meta("int")#raw("] [--json]")
])[
  在每个 `--t` 计算曲线值，或其 `--order` 阶导数（默认 0）。每个值可为数字或含端点的范围 `start:stop:step`，例如 `0:1:0.25`；`--t` 可重复。
]

#api(("bezierkit sample",), syntax: [
  #raw("bezierkit sample [--points ...] [--count ")#meta("int")#raw("] [--format table|csv|json] [--output ")#meta("path")#raw("]")
])[
  以 `--count` 个（默认 50）等距参数采样，含两端，每列为 `t`、`x`、`y`（三维另有 `z`，更高维为 `c3`、`c4`……）。`--output` 写入文件而非标准输出。
]

#api(("bezierkit construct slopes", "bezierkit construct tangents"), syntax: [
  #raw("bezierkit construct slopes --start ")#meta("point")#raw(" --end ")#meta("point")#raw(" --start-slope ")#meta("float")#raw(" --end-slope ")#meta("float")#raw(" [--start-handle --end-handle]") \
  #raw("bezierkit construct tangents --start ... --end ... --start-direction ")#meta("vector")#raw(" --end-direction ")#meta("vector")#raw(" [...]")
])[
  以 `PlanarSlopes` 或 `TangentDirections`（详见#ref(<sec-construction>)）构造三次曲线，并以 JSON 打印控制点。
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

== 错误

无效输入（例如格式错误的点，或超出 $[0, 1]$ 的参数）会在标准错误输出打印 `Error: ...`，退出状态为 1，不显示 traceback。在命令前加上全域选项 `--debug` 可改为显示 Python traceback。

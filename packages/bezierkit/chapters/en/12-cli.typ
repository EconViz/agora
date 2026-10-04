#import "/template/manual.typ": *

= Command-line interface <sec-cli>

The `bezierkit` command, installed with the `cli` extra, evaluates, samples
and constructs curves from the shell. Its output is a table by default, or
JSON or CSV for other programs.

```bash
bezierkit evaluate --points "0,0" --points "1,2" --points "3,2" --points "4,0" \
                   --t 0.5 --order 1 --json
# [{"t":0.5,"value":[4.5,0.0]}]
```

== Control points

Commands that take a curve accept its control points as repeated `--points`
options, each a comma-separated list of coordinates (`"1,2"`, or `"1,2,3"` in
three dimensions). Without `--points`, they read a JSON object with a
`control_points` array from standard input, which is what `construct`
writes, so commands can be piped together.

== Commands

#api(("bezierkit evaluate",), syntax: [
  #raw("bezierkit evaluate --t ")#meta("values")#raw(" [--points ...] [--order ")#meta("int")#raw("] [--json]")
])[
  Evaluate the curve, or its derivative of order `--order` (default 0), at
  each `--t`. A value is a number or an inclusive range `start:stop:step`,
  such as `0:1:0.25`; `--t` may be repeated.
]

#api(("bezierkit sample",), syntax: [
  #raw("bezierkit sample [--points ...] [--count ")#meta("int")#raw("] [--format table|csv|json] [--output ")#meta("path")#raw("]")
])[
  Sample the curve at `--count` (default 50) equally spaced parameters,
  ends included, as rows of `t`, `x`, `y` (and `z`, or `c3`, `c4`, ... in
  higher dimensions). `--output` writes to a file instead of standard
  output.
]

#api(("bezierkit construct slopes", "bezierkit construct tangents"), syntax: [
  #raw("bezierkit construct slopes --start ")#meta("point")#raw(" --end ")#meta("point")#raw(" --start-slope ")#meta("float")#raw(" --end-slope ")#meta("float")#raw(" [--start-handle --end-handle]") \
  #raw("bezierkit construct tangents --start ... --end ... --start-direction ")#meta("vector")#raw(" --end-direction ")#meta("vector")#raw(" [...]")
])[
  Build a cubic with `PlanarSlopes` or `TangentDirections`
  (@sec-construction) and print its control points as JSON.
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

== Errors

Invalid input, such as a malformed point or a parameter outside $[0, 1]$, is
reported on standard error as `Error: ...` with exit status 1 and no
traceback. Put the global option `--debug` before the command to see the
Python traceback instead.

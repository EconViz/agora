#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

dry_run() {
  make --no-print-directory -n "$@" TEXMFDIST=/tmp/texmf KAITI_DIR=
}

default_output=$(dry_run)
[[ "$default_output" == *"packages/utility-viz/main.typ build/utility-viz/utility-viz-en.pdf"* ]] ||
  fail "the default build must select utility-viz/en"

package_output=$(dry_run PACKAGE=bezierkit EDITION=zh-TW)
[[ "$package_output" == *"packages/bezierkit/main.typ build/bezierkit/bezierkit-zh-TW.pdf"* ]] ||
  fail "PACKAGE=bezierkit must select the BezierKit Traditional Chinese manual"
[[ "$package_output" == *"--ignore-system-fonts --input edition=zh-TW"* ]] ||
  fail "Typst flags and --input must be separate arguments"

manual_output=$(dry_run MANUAL=principle-viz EDITION=zh-CN)
[[ "$manual_output" == *"packages/principle-viz/main.typ build/principle-viz/principle-viz-zh-CN.pdf"* ]] ||
  fail "MANUAL must remain a compatibility alias for PACKAGE"

shortcut_output=$(dry_run bezierkit-zh-TW)
[[ "$shortcut_output" == *"packages/bezierkit/main.typ build/bezierkit/bezierkit-zh-TW.pdf"* ]] ||
  fail "bezierkit-zh-TW must build the requested package-edition pair"

tmp_out=$(mktemp -d)
trap 'rm -rf "$tmp_out"' EXIT

if make --no-print-directory pdf PACKAGE=missing EDITION=en TYPST=true OUT="$tmp_out" >/dev/null 2>&1; then
  fail "an unknown package must fail"
fi

if make --no-print-directory pdf PACKAGE=utility-viz EDITION=xx TYPST=true OUT="$tmp_out" >/dev/null 2>&1; then
  fail "an unknown edition must fail"
fi

printf 'PASS: Make selects and validates package-edition builds\n'

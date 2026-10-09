#!/usr/bin/env bash
# The mosaickit manual's figures are mosaickit canvases and grids saved as
# one-page PDFs by its own Matplotlib renderer, with text at the caption size
# so they are placed in the manual unscaled.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
package="$root/packages/mosaickit"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

expected=(
  quickstart/diagram
  annotations/gutter
  annotations/span
  labels/regions
  labels/points
  grids/sweep
  geometry/polylabel
  geometry/brace
  geometry/spread
  geometry/candidates
)

cd "$package"
list_output=$(uv run --frozen python scripts/make_figures.py --list)
for stem in "${expected[@]}"; do
  grep -qx "$stem" <<<"$list_output" || fail "--list omitted $stem"
done

grep -q '^size = 8 ' config/figures.toml || fail "figure text is not set at the 8 pt caption size"

uv run --frozen python scripts/make_figures.py >/dev/null 2>&1

for stem in "${expected[@]}"; do
  pdf="figures/$stem.pdf"
  [[ -s "$pdf" ]] || fail "$pdf was not generated"
  [[ $(pdfinfo "$pdf" | sed -n 's/^Pages:[[:space:]]*//p') == 1 ]] || fail "$pdf is not one page"
  pdfinfo "$pdf" | grep -q '^Producer:.*Matplotlib' || fail "$pdf was not written by Matplotlib"
done

# Figures are placed at their natural size, so the text size above is the
# size on the page.
if grep -n '#fig("/figures/' chapters/*/*.typ | grep -v 'width: auto'; then
  fail "a figure is scaled; place mosaickit figures with width: auto"
fi

stale=$(find figures -type f ! -name '*.pdf')
[[ -z "$stale" ]] || fail "unexpected files in figures/: $stale"

printf 'PASS: ten mosaickit PDF figures, 8 pt text, placed unscaled\n'

#!/usr/bin/env bash
# The bezierkit manual's figures are standalone TikZ pictures whose curves
# come from bezierkit's own exporter, compiled to one-page PDFs, with labels
# set at the caption size so they are placed in the manual unscaled.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
package="$root/packages/bezierkit"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

expected=(
  curves/basis
  curves/cubic
  curves/casteljau
  curves/split
  paths/bbox
  construction/hermite
  fitting/adaptive
  fitting/polyline
  implicit/contours
  implicit/saddle
)

cd "$package"
list_output=$(uv run --frozen python scripts/make_figures.py --list)
for group in curves paths construction fitting implicit; do
  [[ "$list_output" == *"$group:"* ]] || fail "--list omitted $group"
done

uv run --frozen python scripts/make_figures.py --no-pdf >/dev/null
uv run --frozen python scripts/make_figures.py >/dev/null

for stem in "${expected[@]}"; do
  tex="figures/$stem.tex"
  pdf="figures/$stem.pdf"
  [[ -s "$tex" ]] || fail "$tex was not generated"
  [[ -s "$pdf" ]] || fail "$pdf was not generated"
  grep -Eq '\.\. controls .* and .* \.\.' "$tex" || fail "$tex has no native TikZ cubic path"
  grep -q 'font=\\footnotesize' "$tex" || fail "$tex does not set labels at the caption size"
  [[ $(pdfinfo "$pdf" | sed -n 's/^Pages:[[:space:]]*//p') == 1 ]] || fail "$pdf is not one page"
done

# Figures are placed at their natural size, so the label size above is the
# size on the page.
if grep -n '#fig("/figures/' chapters/*/*.typ | grep -v 'width: auto'; then
  fail "a figure is scaled; place bezierkit figures with width: auto"
fi

[[ -z $(find figures -name '*.svg') ]] || fail "stale SVG figures remain"

printf 'PASS: ten standalone TikZ/PDF figures, 8 pt labels, placed unscaled\n'

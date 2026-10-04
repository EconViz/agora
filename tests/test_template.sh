#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

texmf=$(kpsewhich -var-value TEXMFDIST)
font_args=(
  --font-path fonts
  --font-path "$texmf/fonts/opentype/public/tex-gyre"
  --font-path "$texmf/fonts/opentype/public/tex-gyre-math"
  --font-path "$texmf/fonts/opentype/public/cm-unicode"
  --font-path "$texmf/fonts/opentype/public/newcomputermodern"
  --font-path "$texmf/fonts/opentype/public/newpx"
)

kaiti=$(find /System/Library/AssetsV2 -path '*/AssetData/Kaiti.ttc' -print -quit 2>/dev/null || true)
if [[ -n "$kaiti" ]]; then
  font_args+=(--font-path "$(dirname "$kaiti")")
fi

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for edition in en zh-TW zh-CN; do
  pdf="$tmp_dir/$edition.pdf"
  text="$tmp_dir/$edition.txt"
  typst compile --root . "${font_args[@]}" --ignore-system-fonts \
    --input "edition=$edition" tests/fixtures/theorem-proof.typ "$pdf"
  pdftotext -layout "$pdf" "$text"

  case "$edition" in
    en)
      rg -q 'Theorem 1.*Identity' "$text" || fail "English theorem label is missing"
      rg -q 'Proof of Theorem 1' "$text" || fail "English named proof label is missing"
      rg -q 'Appendix A.*Details' "$text" || fail "English appendix label is missing"
      ;;
    zh-TW)
      rg -q '定理 1.*Identity' "$text" || fail "Traditional Chinese theorem label is missing"
      rg -q '定理 1.*的證明' "$text" || fail "Traditional Chinese named proof label is missing"
      rg -q '附錄 A.*Details' "$text" || fail "Traditional Chinese appendix label is missing"
      ;;
    zh-CN)
      rg -q '定理 1.*Identity' "$text" || fail "Simplified Chinese theorem label is missing"
      rg -q '定理 1.*的证明' "$text" || fail "Simplified Chinese named proof label is missing"
      rg -q '附录 A.*Details' "$text" || fail "Simplified Chinese appendix label is missing"
      ;;
  esac

  qed_count=$(rg -o '□' "$text" | wc -l | tr -d ' ')
  [[ "$qed_count" == 2 ]] || fail "$edition must render one QED square per proof"
done

printf 'PASS: theorem, proof, appendix, and QED output in all editions\n'

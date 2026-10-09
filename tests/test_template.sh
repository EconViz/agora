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
      rg -q 'Definition 2.*Square' "$text" || fail "English definition shares the statement counter"
      rg -q 'Lemma 3' "$text" || fail "English lemma label is missing"
      rg -q 'Proposition 4' "$text" || fail "English proposition label is missing"
      rg -q 'Corollary 5' "$text" || fail "English corollary label is missing"
      rg -q 'Definition 2, Lemma 3, Proposition 4, Corollary 5' "$text" || fail "English references do not name their kinds"
      ;;
    zh-TW)
      rg -q '定理 1.*Identity' "$text" || fail "Traditional Chinese theorem label is missing"
      rg -q '定理 1.*的證明' "$text" || fail "Traditional Chinese named proof label is missing"
      rg -q '附錄 A.*Details' "$text" || fail "Traditional Chinese appendix label is missing"
      rg -q '定義 2.*Square' "$text" || fail "Traditional Chinese definition label is missing"
      rg -q '引理 3' "$text" || fail "Traditional Chinese lemma label is missing"
      rg -q '命題 4' "$text" || fail "Traditional Chinese proposition label is missing"
      rg -q '推論 5' "$text" || fail "Traditional Chinese corollary label is missing"
      ;;
    zh-CN)
      rg -q '定理 1.*Identity' "$text" || fail "Simplified Chinese theorem label is missing"
      rg -q '定理 1.*的证明' "$text" || fail "Simplified Chinese named proof label is missing"
      rg -q '附录 A.*Details' "$text" || fail "Simplified Chinese appendix label is missing"
      rg -q '定义 2.*Square' "$text" || fail "Simplified Chinese definition label is missing"
      rg -q '引理 3' "$text" || fail "Simplified Chinese lemma label is missing"
      rg -q '命题 4' "$text" || fail "Simplified Chinese proposition label is missing"
      rg -q '推论 5' "$text" || fail "Simplified Chinese corollary label is missing"
      ;;
  esac

  qed_count=$(rg -o '□' "$text" | wc -l | tr -d ' ')
  [[ "$qed_count" == 2 ]] || fail "$edition must render one QED square per proof"
done

printf 'PASS: statements, proofs, appendix, and QED output in all editions\n'

# Build the EconViz package manuals.
#
# Every directory under packages/ with a manual.toml is a manual
# (packages/utility-viz/, packages/principle-viz/, ...).
#
#   make                          utility-viz, English edition (default)
#   make utility-viz EDITION=zh-TW
#   make pdf MANUAL=utility-viz EDITION=zh-CN
#   make all                      every edition of every manual
#   make watch MANUAL=utility-viz EDITION=zh-TW
#   make figures MANUAL=utility-viz    regenerate packages/<manual>/figures/ (uv)
#   make publish MANUAL=utility-viz    build every edition, copy to econ-viz-docs
#
# Output: build/<manual>/<manual>-<edition>.pdf.
#
# Fonts: CJK fonts from fonts/ (Kaiti.ttc is not in the repository; see
# README), Latin fonts follow ctxdoc: TeX Gyre Pagella, TeX Gyre Heros,
# CMU Typewriter Text and TeX Gyre Pagella Math. Their TeX Live directories
# are passed separately because Typst does not recursively scan --font-path.
# TeXGyrePagellaX (newpx) is only a build fallback when Pagella OTF is absent.
# CMU comes from the cm-unicode package (tlmgr install cm-unicode).
# System fonts are ignored, so every machine builds deterministically.

TYPST     ?= typst
PACKAGES  := packages
MANUALS   := $(patsubst $(PACKAGES)/%/manual.toml,%,$(wildcard $(PACKAGES)/*/manual.toml))
MANUAL    ?= utility-viz
DIR        = $(PACKAGES)/$(MANUAL)
EDITION   ?= en
OUT       ?= build
TEXMFDIST ?= $(shell kpsewhich -var-value TEXMFDIST 2>/dev/null)
TEX_GYRE_FONTS ?= $(TEXMFDIST)/fonts/opentype/public/tex-gyre
TEX_MATH_FONTS ?= $(TEXMFDIST)/fonts/opentype/public/tex-gyre-math
CMU_FONTS      ?= $(TEXMFDIST)/fonts/opentype/public/cm-unicode
NCM_FONTS      ?= $(TEXMFDIST)/fonts/opentype/public/newcomputermodern
NEWPX_FONTS    ?= $(TEXMFDIST)/fonts/opentype/public/newpx
# Kaiti (emphasis in the Chinese editions): fonts/Kaiti.ttc if present,
# otherwise the copy macOS downloads through Font Book.
KAITI_DIR      ?= $(patsubst %/,%,$(dir $(firstword $(wildcard /System/Library/AssetsV2/com_apple_MobileAsset_Font*/*/AssetData/Kaiti.ttc))))

# A manual's editions and published file name, read from its manual.toml
# (`editions = [...]` and `[publish] name = "..."`).
editions-of = $(shell sed -n 's/^editions *= *\[\(.*\)\]/\1/p' $(PACKAGES)/$(1)/manual.toml | tr -d '",')
publish-name-of = $(shell sed -n '/^\[publish\]/,/^\[/s/^name *= *"\(.*\)"/\1/p' $(PACKAGES)/$(1)/manual.toml)

# `make publish` copies the PDFs to econ-viz-docs, which serves them at
# econ-viz.org/assets/manual/<publish name>-<edition>.pdf.
DOCS           ?= ../econ-viz-docs
MANUAL_DIR      = $(DOCS)/docs/assets/manual

TYPST_FLAGS = --root . --font-path fonts \
	--font-path "$(TEX_GYRE_FONTS)" \
	--font-path "$(TEX_MATH_FONTS)" \
	--font-path "$(CMU_FONTS)" \
	--font-path "$(NCM_FONTS)" \
	--font-path "$(NEWPX_FONTS)" \
	$(if $(KAITI_DIR),--font-path "$(KAITI_DIR)") \
	--ignore-system-fonts

.PHONY: pdf all editions watch figures publish clean $(MANUALS)

pdf:
	@test -f $(DIR)/manual.toml || { echo "no manual at $(DIR)/ (choose: $(MANUALS))" >&2; exit 1; }
	@mkdir -p $(OUT)/$(MANUAL)
	$(TYPST) compile $(TYPST_FLAGS) --input edition=$(EDITION) $(DIR)/main.typ $(OUT)/$(MANUAL)/$(MANUAL)-$(EDITION).pdf

$(MANUALS):
	@$(MAKE) --no-print-directory pdf MANUAL=$@

# Every edition of $(MANUAL).
editions:
	@for e in $(call editions-of,$(MANUAL)); do \
		$(MAKE) --no-print-directory pdf MANUAL=$(MANUAL) EDITION=$$e || exit 1; \
	done

all:
	@for m in $(MANUALS); do \
		$(MAKE) --no-print-directory editions MANUAL=$$m || exit 1; \
	done

watch:
	$(TYPST) watch $(TYPST_FLAGS) --input edition=$(EDITION) $(DIR)/main.typ $(OUT)/$(MANUAL)/$(MANUAL)-$(EDITION).pdf

figures:
	cd $(DIR) && uv run python scripts/make_figures.py

# The published PDFs must use the same fonts as a local build, so refuse to
# publish without Kaiti.
publish:
	@test -f fonts/Kaiti.ttc -o -n "$(KAITI_DIR)" || \
		{ echo "Kaiti not found; see README (Fonts)." >&2; exit 1; }
	@test -d "$(DOCS)/docs" || { echo "econ-viz-docs not found at $(DOCS); pass DOCS=..." >&2; exit 1; }
	@test -n "$(call publish-name-of,$(MANUAL))" || { echo "$(DIR)/manual.toml has no [publish] name" >&2; exit 1; }
	@$(MAKE) --no-print-directory editions MANUAL=$(MANUAL)
	@mkdir -p "$(MANUAL_DIR)"
	@for e in $(call editions-of,$(MANUAL)); do \
		cp $(OUT)/$(MANUAL)/$(MANUAL)-$$e.pdf "$(MANUAL_DIR)/$(call publish-name-of,$(MANUAL))-$$e.pdf"; \
		echo "published $(MANUAL_DIR)/$(call publish-name-of,$(MANUAL))-$$e.pdf"; \
	done

clean:
	rm -rf $(OUT)

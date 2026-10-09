# Build the EconViz package manuals.
#
# Every directory under packages/ with a manual.toml is a manual
# (packages/utility-viz/, packages/principle-viz/, ...).
#
#   make                          utility-viz, English edition (default)
#   make utility-viz EDITION=zh-TW
#   make PACKAGE=bezierkit EDITION=zh-CN
#   make bezierkit-zh-TW
#   make all                      every edition of every manual
#   make watch PACKAGE=utility-viz EDITION=zh-TW
#   make figures PACKAGE=utility-viz    regenerate packages/<package>/figures/ (uv)
#   make publish PACKAGE=utility-viz    build every edition, copy to econ-viz-docs
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

TYPST        ?= typst
.DEFAULT_GOAL := pdf
PACKAGES_DIR := packages
PACKAGE_NAMES := $(patsubst $(PACKAGES_DIR)/%/manual.toml,%,$(wildcard $(PACKAGES_DIR)/*/manual.toml))
# PACKAGE is the public name. MANUAL remains accepted by older commands.
ifeq ($(origin PACKAGE), undefined)
PACKAGE      := $(if $(MANUAL),$(MANUAL),utility-viz)
endif
MANUAL       ?= $(PACKAGE)
DIR           = $(PACKAGES_DIR)/$(PACKAGE)
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
editions-of = $(shell sed -n 's/^editions *= *\[\(.*\)\]/\1/p' $(PACKAGES_DIR)/$(1)/manual.toml 2>/dev/null | tr -d '",')
publish-name-of = $(shell sed -n '/^\[publish\]/,/^\[/s/^name *= *"\(.*\)"/\1/p' $(PACKAGES_DIR)/$(1)/manual.toml 2>/dev/null)

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

.PHONY: pdf all editions watch figures publish clean validate-package validate-edition $(PACKAGE_NAMES)

validate-package:
	@test -f "$(DIR)/manual.toml" || \
		{ echo "unknown package '$(PACKAGE)' (choose: $(PACKAGE_NAMES))" >&2; exit 1; }

validate-edition: validate-package
	@case " $(call editions-of,$(PACKAGE)) " in \
		*" $(EDITION) "*) ;; \
		*) echo "unknown edition '$(EDITION)' for $(PACKAGE) (choose: $(call editions-of,$(PACKAGE)))" >&2; exit 1 ;; \
	esac

pdf: validate-edition
	@mkdir -p $(OUT)/$(PACKAGE)
	$(TYPST) compile $(strip $(TYPST_FLAGS)) --input edition=$(EDITION) $(DIR)/main.typ $(OUT)/$(PACKAGE)/$(PACKAGE)-$(EDITION).pdf

$(PACKAGE_NAMES):
	@$(MAKE) --no-print-directory pdf PACKAGE=$@

define package-edition-rule
$(1)-$(2):
	@$$(MAKE) --no-print-directory pdf PACKAGE=$(1) EDITION=$(2)
endef

$(foreach package,$(PACKAGE_NAMES),$(foreach edition,$(call editions-of,$(package)),$(eval $(call package-edition-rule,$(package),$(edition)))))

# Every edition of $(PACKAGE).
editions: validate-package
	@for e in $(call editions-of,$(PACKAGE)); do \
		$(MAKE) --no-print-directory pdf PACKAGE=$(PACKAGE) EDITION=$$e || exit 1; \
	done

all:
	@for package in $(PACKAGE_NAMES); do \
		$(MAKE) --no-print-directory editions PACKAGE=$$package || exit 1; \
	done

watch: validate-edition
	@mkdir -p $(OUT)/$(PACKAGE)
	$(TYPST) watch $(strip $(TYPST_FLAGS)) --input edition=$(EDITION) $(DIR)/main.typ $(OUT)/$(PACKAGE)/$(PACKAGE)-$(EDITION).pdf

figures: validate-package
	cd $(DIR) && uv run python scripts/make_figures.py

# The published PDFs must use the same fonts as a local build, so refuse to
# publish without Kaiti.
publish: validate-package
	@test -f fonts/Kaiti.ttc -o -n "$(KAITI_DIR)" || \
		{ echo "Kaiti not found; see README (Fonts)." >&2; exit 1; }
	@test -d "$(DOCS)/docs" || { echo "econ-viz-docs not found at $(DOCS); pass DOCS=..." >&2; exit 1; }
	@test -n "$(call publish-name-of,$(PACKAGE))" || { echo "$(DIR)/manual.toml has no [publish] name" >&2; exit 1; }
	@$(MAKE) --no-print-directory editions PACKAGE=$(PACKAGE)
	@mkdir -p "$(MANUAL_DIR)"
	@for e in $(call editions-of,$(PACKAGE)); do \
		cp $(OUT)/$(PACKAGE)/$(PACKAGE)-$$e.pdf "$(MANUAL_DIR)/$(call publish-name-of,$(PACKAGE))-$$e.pdf"; \
		echo "published $(MANUAL_DIR)/$(call publish-name-of,$(PACKAGE))-$$e.pdf"; \
	done

clean:
	rm -rf $(OUT)

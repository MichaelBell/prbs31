MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

RUN_TAG = $(shell ls librelane/runs/ | tail -n 1)
TOP = prbs31

PDK_ROOT ?= $(MAKEFILE_DIR)/gf180mcu
PDK ?= gf180mcuD
PDK_COMMIT ?= 9233c19260cd813c3fa67dd4594fe4cc67016832

# Available SCL libraries:
# gf180mcu_as_sc_mcu7t3v3
# gf180mcu_fd_sc_mcu7t5v0
# gf180mcu_fd_sc_mcu9t5v0
# gf180mcu_osu_sc_gp9t3v3 (broken)
# gf180mcu_osu_sc_gp12t3v3 (broken)

SCL ?= gf180mcu_as_sc_mcu7t3v3

LIBRELANE_OPTS = --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --scl ${SCL}
LIBRELANE_CONFIGS = librelane/config.yaml

.DEFAULT_GOAL := help

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
.PHONY: help

all: librelane ## Build the project (runs LibreLane)
.PHONY: all

$(PDK_ROOT)/ciel/gf180mcu/versions/$(PDK_COMMIT)/$(PDK):
	ciel enable $(PDK_COMMIT) --pdk-root $(PDK_ROOT) --pdk-family $(PDK) --include-libraries all

clone-pdk: $(PDK_ROOT)/ciel/gf180mcu/versions/$(PDK_COMMIT)/$(PDK) ## Clone the gf180mcu PDK
.PHONY: clone-pdk

librelane: clone-pdk ## Run LibreLane flow (synthesis, PnR, verification)
	SRAM_DEFINE=${SRAM_DEFINE} librelane ${LIBRELANE_CONFIGS} ${LIBRELANE_OPTS} --save-views-to $(MAKEFILE_DIR)/final
.PHONY: librelane

librelane-condensed: clone-pdk ## Run LibreLane flow (synthesis, PnR, verification)
	SRAM_DEFINE=${SRAM_DEFINE} librelane --condensed ${LIBRELANE_CONFIGS} ${LIBRELANE_OPTS} --save-views-to $(MAKEFILE_DIR)/final
.PHONY: librelane-condensed

librelane-nodrc: clone-pdk ## Run LibreLane flow without DRC checks
	SRAM_DEFINE=${SRAM_DEFINE} librelane ${LIBRELANE_CONFIGS} ${LIBRELANE_OPTS} --save-views-to $(MAKEFILE_DIR)/final --skip KLayout.Antenna --skip KLayout.DRC --skip Magic.DRC
.PHONY: librelane-nodrc

librelane-openroad: clone-pdk ## Open the last run in OpenROAD
	SRAM_DEFINE=${SRAM_DEFINE} librelane ${LIBRELANE_CONFIGS} ${LIBRELANE_OPTS} --last-run --flow OpenInOpenROAD
.PHONY: librelane-openroad

librelane-klayout: clone-pdk ## Open the last run in KLayout
	SRAM_DEFINE=${SRAM_DEFINE} librelane ${LIBRELANE_CONFIGS} ${LIBRELANE_OPTS} --last-run --flow OpenInKLayout
.PHONY: librelane-klayout

sim: clone-pdk defines ## Run RTL simulation with cocotb
	cd cocotb; PDK_ROOT=${PDK_ROOT} PDK=${PDK} SLOT=${SLOT} PAD=${PAD} SCL=${SCL} SRAM=${SRAM} python3 chip_top_tb.py
.PHONY: sim

sim-gl: clone-pdk defines ## Run gate-level simulation with cocotb (after copy-final)
	cd cocotb; GL=1 PDK_ROOT=${PDK_ROOT} PDK=${PDK} SLOT=${SLOT} PAD=${PAD} SCL=${SCL} SRAM=${SRAM} python3 chip_top_tb.py
.PHONY: sim-gl

sim-view: ## View simulation waveforms in GTKWave
	gtkwave cocotb/sim_build/chip_top.fst
.PHONY: sim-view

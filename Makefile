TOP := $(shell git rev-parse --show-toplevel)

WORK_DIR := $(TOP)/work

apply_patches:
	mkdir -p $(WORK_DIR)/riscv-dbg
	cd $(TOP)/zynq/import/riscv-dbg; \
		git submodule update --init --recursive .; \
		git apply --reverse --check $(TOP)/patches/zynq/import/riscv-dbg/* \
			|| git apply $(TOP)/patches/zynq/import/riscv-dbg/*
	mkdir -p $(WORK_DIR)/opentitan
	mkdir -p $(TOP)/zynq/import/opentitan/hw/dv
	cd $(WORK_DIR)/opentitan; \
		git clone --single-branch https://github.com/lowrisc/opentitan opentitan || echo "Already cloned"; \
		cd opentitan; git checkout 33c4b71
	cd $(TOP)/zynq/import/opentitan; \
		cp -r $(WORK_DIR)/opentitan/opentitan/hw/dv/dpi hw/dv/; \
		git init; git add .; git commit -m "Initial commit"; \
		git apply --reverse --check $(TOP)/patches/zynq/import/opentitan/* \
			|| git apply $(TOP)/patches/zynq/import/opentitan/*;
		

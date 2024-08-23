TOP := $(shell git rev-parse --show-toplevel)

apply_patches:
	cd zynq/import/riscv-dbg; \
		git submodule update --init --recursive .; \
		git apply --reverse --check $(TOP)/patches/zynq/import/riscv-dbg/* \
		|| git apply $(TOP)/patches/zynq/import/riscv-dbg/*
	cd zynq/import/riscv-dbg; \
		git init; git commit -am "Initial commit"; \
		git apply --reverse --check $(TOP)/patches/zynq/import/opentitan/* \
		|| git apply $(TOP)/patches/zynq/import/opentitan/*; \
		rm -rf .git/
		



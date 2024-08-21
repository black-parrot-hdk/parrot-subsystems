TOP := $(shell git rev-parse --show-toplevel)

apply_patches:
	cd zynq/import/riscv-dbg; \
		git apply --reverse --check $(TOP)/patches/zynq/import/riscv-dbg/* \
		|| git apply $(TOP)/patches/zynq/import/riscv-dbg/*


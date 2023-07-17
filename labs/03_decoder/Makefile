# Author: Nikolai Ternovoi
.PHONY: build sim version clean

# Include directory
INCLUDE_DIR = ../common
# Verilator flags
VFLAGS = --trace-fst --cc --binary -Wno-style -Wno-fatal --compiler clang -o $(BIN) -O0
BIN=Vtop

build:
	verilator $(VFLAGS) -I$(INCLUDE_DIR) --top-module tb tb.sv top.sv ../common/config.svh
sim:
	./obj_dir/$(BIN)

version:
	verilator --version

clean:
	rm -rf obj_dir
	rm -r testbench.vcd

.PHONY: build run version clean

BIN=Vtop

build:
	verilator --trace-fst --cc --binary -Wno-style -Wno-fatal --compiler clang -o $(BIN) -O0 --top-module tb tb.sv top.sv
run:
	./obj_dir/$(BIN)

version:
	verilator --version

clean:
	rm -rf obj_dir
	rm -r testbench.vcd

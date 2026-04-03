# Makefile for AXI-Lite SRAM Controller UVM Verification

# Tool options
XRUN  = xrun
IMC   = imc
FLAGS = -f run.f

# Default test
TEST = base_test

all: clean run cov

run:
	$(XRUN) $(FLAGS) +UVM_TESTNAME=$(TEST)

cov:
	$(IMC) -exec imc_cmd.tcl

clean:
	rm -rf xcelium.d xrun.log xrun.history waves.shm dump.vcd cov_work cov_html

VERILOG_SRC=$(wildcard ../rtl/*.v) ../testbench/testbench.sv
GOLDEN_SRC=$(wildcard ../golden_model/*.*v) ../testbench/testbench.sv

vlog-v:
	rm -rf ./work
	/bin/bash -c "vlog $(VERILOG_SRC)"	

vlog-golden:
	rm -rf ./work
	/bin/bash -c "vlog -sv $(GOLDEN_SRC)"	

verify-564:
	/bin/bash -c "vsim -c tb_top +CLASS=564 +ROUNDS=2 +TIMEOUT=1000000 -do \"run -all\" "	

verify-464:
	/bin/bash -c "vsim -c tb_top +CLASS=464 +ROUNDS=2 +TIMEOUT=1000000 -do \"run -all\" "	

debug-564:
	/bin/bash -c "vsim -voptargs=+acc tb_top +CLASS=564 +TIMEOUT=1000000 +ROUNDS=2 "	

debug-464:
	/bin/bash -c "vsim -voptargs=+acc tb_top +CLASS=464 +TIMEOUT=1000000 +ROUNDS=2 "	

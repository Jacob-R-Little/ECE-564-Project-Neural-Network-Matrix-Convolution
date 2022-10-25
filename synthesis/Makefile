export RTL_FILES=$(wildcard ../rtl/*.v) 
export CLOCK_PER := 10


all: logs reports gl sdf 
	dc_shell -no_gui -x "source run_all.tcl"

logs:
	mkdir -p logs

reports:
	mkdir -p reports

gl:
	mkdir -p gl
	
sdf:
	mkdir -p sdf
svf:
	mkdir -p svf

clean:
	rm -rf  sdf logs reports gl sdf svf alib-52 command.log


SOURCES := scope_test.sv scope_test_tb.sv lfsr.sv
TOP := scope_test_tb

all: ${TOP}.vvp

${TOP}.vvp: ${SOURCES}
	iverilog -g2012 -o $@ $^

run: ${TOP}.vvp
	vvp -n $< | racket ../virtual-scope.rkt

clean:
	rm ${TOP}.vvp

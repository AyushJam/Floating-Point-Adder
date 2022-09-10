# Steps for compiling and running the tests

# default target
all: vtest

# Compile the C program - use implicit rules
fpAdd: fpAdd.c 

# Generating the Verilog test cases - just run the executable
vtest.dat: fpAdd
	./fpAdd 

# Compile the Verilog code to generate executable
fpadd_tb: fpadd_tb.v fpadd.v 
	iverilog -o fpadd_tb fpadd_tb.v fpadd.v 

# Run the C test - depends on executable
ctest: fpAdd
	./fpAdd

# Run the Verilog test
vtest: ctest fpadd_tb
	./fpadd_tb

clean:
	rm -f *.o fpAdd fpadd_tb vtest.dat 

.phony: all ctest vtest clean 

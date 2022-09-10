// Filename        : fpadd_tb.v
// Description     : Sequential multiplier test bench
// Author          : Nitin Chandrachoodan <nitin@ee.iitm.ac.in>

// Automatic test bench
// Uses tasks to keep test code clean

`timescale 1ns/1ns
// The number of tests should ideally be obtained from the file
`define NUMTEST 4
`define TIMEOUT 100

module fpadd_tb () ;
	reg [31:0]	testinputs[0:`NUMTEST*3-1];
	reg [31:0] 	a, b, sumexp;
	reg 		clk, reset, start;
	integer     tot, err;
	integer     timer, i;
	reg         timedout;

	wire [31:0]	sum;
	wire 	   	done;

	fpadd dut( .clk(clk),
		.reset(reset),
		.start(start),
		.a(a),
		.b(b),
		.sum(sum),
		.done(done));

	// Generate a 10ns clock 
	always #5 clk = !clk;
	
	task start_and_crank_dut;
		begin
			tot += 1;
			timer = 0;   
			// start the DUT for one clock cycle
			start = 1;
			@(posedge clk);
			// Remove start 
			#1 start = 0;
	 
			// Loop until the DUT indicates 'done'
			while ((done == 0) && (timer < `TIMEOUT)) begin
				@(posedge clk); // Wait for one clock cycle
				timer += 1;
			end
			if (timer == `TIMEOUT) begin
				$display("Timed out");
				timedout = 1;
			end else if (sum !== sumexp) begin
				err += 1;
				$display($time, " a = %X, b = %X, sum = %X, expected sum = %X", a, b, sum, sumexp);
			end
		end
	endtask // start_and_crank_dut
	
	initial begin
		// Initialize the clock
		clk = 1;
		tot = 0;
		err = 0;
		timedout = 0;
		// Apply reset for 100ns
		reset = 1;
		#100 reset = 0;

		// Bulk read the test cases into testinputs
		$readmemh("vtest.dat", testinputs);

		for (i=0; i<`NUMTEST; i=i+1) begin
			a = testinputs[i*3];
			b = testinputs[i*3+1];
			sumexp = testinputs[i*3+2];
			// $display($time, " a = %X, b = %X, expected sum = %X", a, b, sumexp);
			start_and_crank_dut;
		end

		if (err > 0) begin
			$display("FAILED %d out of %d", err, tot);
		end else if (timedout === 'b1) begin
			$display("FAILED due to TIMEOUT");
		end else begin
			$display("PASS");
		end

		$finish;
		
	end
	
endmodule // seq_mult_tb

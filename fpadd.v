/*
	EE2003: Computer Organization
	Floating Point Adder
	Author: Ayush Jamdar EE20B018
	Date started: Sept 10, 22
	
	Abstract: IEEE 754 format is used to store real numbers
			  in computer memory. Interpreting the 32 bits 
			  as real numbers and adding them is an interesting 
			  task by itself. The sum must be converted back to 
			  the known format and stored as a 'float'. 
*/


module fpadd (
    clk, reset, start,
    a, b,
    sum, 
    done
);
    input clk, reset, start;
    input [31:0] a, b;
    output [31:0] sum;
    output done;
	
	// 1. Extract relevant parts
	
	reg done;
	reg sum;
	reg sign_a, sign_b;			// 1 bit
	reg [7:0] exp_a, exp_b;		// 8 bits
	reg [24:0] mant_a, mant_b;	
	// 23 bits + 1 bit for the one of 1.xx + 1 for sign extension
	reg [7:0] ediff;
	reg sign_r;
	reg [7:0] exp_r;
	reg [24:0] mant_r;
	
	always @(posedge clk) begin
		if (start) begin 
			// 1. Extract relevant parts
			done 	<= 	0;
			sum  	<= 	32'b0;
			sign_a 	<= 	a[31];
			sign_b 	<= 	b[31];
			exp_a 	<= 	a[30:23];
			exp_b 	<= 	b[30:23];
			mant_a 	<= 	{2'b01, a[22:0]};   // add 1 to make 1.23 
			mant_b 	<= 	{2'b01, b[22:0]};
			end
		else if (reset) begin
			done 	<= 	0;
			sum  	<= 	32'b0;
			sign_a 	<= 	31'b0;
			sign_b 	<= 	31'b0;
			exp_a 	<= 	8'b0;
			exp_b 	<= 	8'b0;
			mant_a 	<= 	25'b0;
			mant_b 	<= 	25'b0;
			end
		else if (!done)
			// 2. Handle special cases
			if ((exp_a == 0) && (mant_a == 0)) begin
				sum 	<= b;
				done 	<= 1'b1;
				end
			else if ((exp_b == 0) && (mant_b == 0)) begin	
				sum 	<= a;
				done 	<= 1'b1;
				end
			else if (exp_a == 8'h0xFF) begin
				sum 	<= a;	// NaN or Inf
				done	<= 1'b1;
				end
			else if (exp_b == 8'h0xFF) begin
				sum 	<= b;
				done	<= 1'b1;
				end
			else begin
				// 3. Move on to actual computations
				// 3.2 Convert mantissas to two's complement
				//     mant_a was a 24 bit value.
				//     Considering a possibility of overflow, 
				//     extend sign bit to another bit 
				if (sign_a) begin
					mant_a <= -mant_a;
					end
				if (sign_b) begin
					mant_b <= -mant_b;
					end
				
				// 3.2 Equalize exponents
				if (exp_a > exp_b) begin
					ediff <= exp_a - exp_b;
					exp_r <= exp_a;
					mant_b <= mant_b >> ediff;
					end
				else if (exp_a < exp_b) begin
					ediff <= exp_b - exp_a;
					exp_r <= exp_b;
					mant_a <= mant_a >> ediff;
					end
				else // they are equal
					exp_r <= exp_a;
				
				// 3.3 Compute addition
				
				
				end
			
				
			 
				
			
				
			
	end
	
	
	
	
	
	// parsed data acquired.
	
	// 2. Handle special cases
	//	  MUX implementation
	

endmodule

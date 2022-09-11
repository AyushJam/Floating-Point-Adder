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
	reg [23:0] mant_a, mant_b;	
	// 23 bits + 1 bit for the one of 1.xx
	
	always @(posedge clk) begin
		if (start) begin 
			// 1. Extract relevant parts
			done 	<= 	0;
			sum  	<= 	32'b0;
			sign_a 	<= 	a[31];
			sign_b 	<= 	b[31];
			exp_a 	<= 	a[30:23];
			exp_b 	<= 	b[30:23];
			mant_a 	<= 	{1'b1, a[22:0]};   // add 1 to make 1.23 
			mant_b 	<= 	{1'b1, b[22:0]};
			end
		else if (reset) begin
			done 	<= 	0;
			sum  	<= 	32'b0;
			sign_a 	<= 	31'b0;
			sign_b 	<= 	31'b0;
			exp_a 	<= 	8'b0;
			exp_b 	<= 	8'b0;
			mant_a 	<= 	24'b0;
			mant_b 	<= 	24'b0;
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
				//     mant_a is a 24 bit value.
				//     Considering a possibility of overflow, 
				//     extend sign bit to another bit 
				if (sign_a) begin
					mant_a <= -mant_a;
				end
				if (sign_b) begin
					mant_b <= -mant_b;
				end
				
				end
			
				
			 
				
			
				
			
	end
	
	
	
	
	
	// parsed data acquired.
	
	// 2. Handle special cases
	//	  MUX implementation
	

endmodule

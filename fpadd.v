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

	An attempt to solve the problem using an FSM approach.
	Reference used: https://inst.eecs.berkeley.edu/~cs150/Documents/FSM
*/


module fpadd (
    clk, reset, start,
    a, b,
    sum, 
    done
);

//----------------------------------------------------------------------------
// Input - Output declaration
//----------------------------------------------------------------------------

    input wire 		clk, reset, start;
    input wire [31:0] 	a, b;
    output reg [31:0] 	sum;
    output reg	 	done;

//-----------------------------------------------------------------------------	
// State Encoding 
//-----------------------------------------------------------------------------
localparam STATE_Initial = 3'd0,
	   STATE_1 = 3'd1,
	   STATE_2 = 3'd2,
	   STATE_3 = 3'd3,
	   STATE_4 = 3'd4,
	   STATE_5 = 3'd5,
	   STATE_6 = 3'd6,
	   DONE = 3'd7;
	   // excess case handled
	   
// State regs declaration 
reg [2:0] CurrentState;
reg [2:0] NextState;

// Registers to parse the 32-bit data
	wire sign_a, sign_b;		// 1 bit
	reg [7:0] exp_a, exp_b;		// 8 bits
	reg signed [24:0] mant_a, mant_b;	
	// 23 bits + 1 bit for the one of 1.xx + 1 for sign extension
	// signed reg is used for the arithmetic shift operation later used. 
	reg [7:0] ediff;
	reg sign_r;
	reg [7:0] exp_r;
	reg [25:0] mant_r;
	reg b23, b24;
	reg [4:0] one_index;
	
	reg signed [24:0] mant_a_q, mant_b_q;
	reg [25:0] mant_r_q;
	reg [31:0] sum_q;
	reg [7:0] exp_a_q, exp_b_q, exp_r_q;
	reg sign_r_q;

	assign sign_a = a[31];
	assign sign_b = b[31];
	
// Synchronous State Transition
always @(posedge clk) begin
	if (reset) begin
		CurrentState <= STATE_Initial;
		mant_a_q 	 <= 0;
		mant_b_q 	 <= 0;
		sum_q        <= 0;
		exp_a_q 	 <= 0;
		exp_b_q		 <= 0;
		exp_r_q		 <= 0; 
		mant_r_q     <= 0;
		sign_r_q	 <= 0;
		
	end else begin
		CurrentState <= NextState;
		mant_a_q 	 <= mant_a;
		mant_b_q 	 <= mant_b;
		sum_q        <= sum;
		exp_a_q 	 <= exp_a;
		exp_b_q		 <= exp_b;
		exp_r_q		 <= exp_r;
		mant_r_q	 <= mant_r; 
		sign_r_q	 <= sign_r;
	end
end
// Important! Will have to press reset/start to go to start state.


// Conditional State Transition
always @(*) begin 
	NextState = CurrentState;
	done = 0;
	mant_a = mant_a_q;
	mant_b = mant_b_q;
	sum = sum_q;
	exp_a = exp_a_q;
	exp_b = exp_b_q;
	exp_r = exp_r_q;
	mant_r = mant_r_q;
	sign_r = sign_r_q;
	// default
	
	case (CurrentState)
		STATE_Initial: begin
				// 1. Start parsing input data
				//$display ("a = %d, b = %d\n", a, b);
				exp_a 	= 	a[30:23];
				exp_b 	= 	b[30:23];
				mant_a 	= 	{2'b00, a[22:0]};   
				mant_b 	= 	{2'b00, b[22:0]};
				sign_r = 0;
				mant_r = 0;
				// just the mantissa read for now, will update later
				
				// 2. Handle special cases
				if (start) begin	
					if ((exp_a_q == 0) && (mant_a_q == 0)) begin
						sum 	= b;  // a = 0
						done 	= 1'b1;
						NextState  = DONE;
					end
					else if ((exp_b_q == 0) && (mant_b_q == 0)) begin	
						sum 	= a;  // b = 0
						done 	= 1'b1;
						NextState  = DONE;
					end
					else if (exp_a_q == 8'hFF) begin
						sum 	= a;	// NaN or Inf
						done	= 1'b1;
						NextState  = DONE;
					end
					else if (exp_b_q == 8'hFF) begin
						sum 	= b;
						done	= 1'b1;
						NextState  = DONE;
					end
					else begin
						// 3. actual non-exceptional computation
						// $display ("No special case.");
						NextState = STATE_1;
					end
				end
				else NextState = STATE_Initial;
				
		end
		STATE_1: begin
			mant_a 	= 	{2'b01, a[22:0]};   // add 1 to make 1.xx
			mant_b 	= 	{2'b01, b[22:0]};   // a total 25-bit value
			
			// adjust mantissa sign, one bit used for sign extension
			if (sign_a) begin
				mant_a = -mant_a_q;
				// $display("arg A was negative\nchng from %b to %b\n", -mant_a, mant_a);
			end
			if (sign_b) begin
				mant_b = -mant_b_q;
				// $display("arg B was negative\n");
			end
			
			// 3.2 compare exponents
			if (exp_a_q > exp_b_q) begin
				// $display ("A had a bigger exponent.");
				NextState = STATE_2;	
			end
			else if (exp_a_q < exp_b_q) begin
				// $display ("B had a bigger exponent.n");
				NextState = STATE_3;
			end
			else begin // they are equal
				// $display ("Equal exponents.");
				exp_r = exp_a_q;
				NextState = STATE_4;
			end
		end
		STATE_2: begin
			ediff  = exp_a_q - exp_b_q;
			exp_r  = exp_a_q;
			mant_b = mant_b_q >>> ediff; // arithmetic shift to retain MSB
			NextState = STATE_4;
		end
		STATE_3: begin
			ediff 	= exp_b_q - exp_a_q;
			exp_r 	= exp_b_q;
			mant_a = mant_a_q >>> ediff;
			NextState = STATE_4;
		end
		STATE_4: begin
			// 3.3 Compute Addition
			mant_r = {mant_a_q[24] ,mant_a_q} + {mant_b_q[24] ,mant_b_q};
			// $display("mant_a = %b, mant_b = %b\nmant_r = %b\n", mant_a , mant_b, mant_r);
			// 3.4 Sign of the result
			if (mant_r_q[25]) begin
				// MSB indicates sign
				// negative
				// $display("result negative.");
				sign_r = 1;
				mant_r = -mant_r_q;
			end
			else begin
				// postitive
				// $display("result positive.");
				sign_r = 0;
			end
			NextState = STATE_5;
		end
		STATE_5: begin
			// 3.5 Normalize
			// mant_r is now unsigned
			b23 = mant_r_q[23];
			b24 = mant_r_q[24];
			if (!mant_r_q) begin
				// 3.5.1 numbers cancelled out
				exp_r = 0;
				NextState = STATE_6;
			end
			else if ((!b24) && (b23)) begin
				// 3.5.2 already normalized 
				// no need to normalize
				// $display("no need to normalize");
				NextState = STATE_6;
			end
			else if (b24) begin
				// 3.5.3 Overflow - renormalize
				// $display("normalize for overflow\n");
				mant_r = {1'b0, mant_r_q[25:1]};
				exp_r  = exp_r_q + 1'b1;
				NextState = STATE_6;
			end
			else begin 
				// 3.5.4 Search for leading one
				if(b23) begin
					// normalized
					// $display("normalized for small delta\n");
					NextState = STATE_6;
				end
				else begin 
					// keep looping until normalized
				
					// $display("normalize for small delta.");
					case (1)
						mant_r_q[22]: begin one_index = 22; end
						mant_r_q[21]: begin one_index = 21; end
						mant_r_q[20]: begin one_index = 20; end
						mant_r_q[19]: begin one_index = 19; end
						mant_r_q[18]: begin one_index = 18; end
						mant_r_q[17]: begin one_index = 17; end
						mant_r_q[16]: begin one_index = 16; end
						mant_r_q[15]: begin one_index = 15; end
						mant_r_q[14]: begin one_index = 14; end
						mant_r_q[13]: begin one_index = 13; end
						mant_r_q[12]: begin one_index = 12; end
						mant_r_q[11]: begin one_index = 11; end
						mant_r_q[10]: begin one_index = 10; end
						mant_r_q[9]: begin one_index = 9; end
						mant_r_q[8]: begin one_index = 8; end
						mant_r_q[7]: begin one_index = 7; end
						mant_r_q[6]: begin one_index = 6; end
						mant_r_q[5]: begin one_index = 5; end
						mant_r_q[4]: begin one_index = 4; end
						mant_r_q[3]: begin one_index = 3; end
						mant_r_q[2]: begin one_index = 2; end
						mant_r_q[1]: begin one_index = 1; end
						mant_r_q[0]: begin one_index = 0; end

					endcase
					// $display("one_index = %b", one_index);
					mant_r = mant_r_q << (23 - one_index);
					exp_r  =  exp_r_q - (23 - one_index);
					NextState = STATE_6;
				
				end
			end
		end
		STATE_6: begin
			// 4. Generate output
			// $display("sign = %b, exp = %b, mant = %b\n", sign_r, exp_r, mant_r);
			sum	= {sign_r_q, exp_r_q, mant_r_q[22:0]};
			done	= 1'b1;
			NextState = DONE;
		end
		DONE: begin
			done    = 1; // High only as long as we are in this state
			// wait here to ensure the start signal has gone low before going back to INIT
            if (start == 0) NextState = STATE_Initial;
            else NextState = DONE;	
            	
		end
	endcase				
end	
endmodule


#include <stdio.h>

// The below line is just for debugging - change to '#if 0' to stop printing
#if 1
#define debug(...) {printf(__VA_ARGS__);}
#else
#define debug(...) 
#endif

// Print an "nbits" bit value in binary (assume nbits <= 32)
void printBits(const char* name, size_t const nbits, unsigned int v)
{
	debug("%s: ", name);
    for (int i = nbits-1; i >= 0; i--) {
		char b = (v >> i) & 0x01; // extract i'th bit
		debug("%c", b==0 ? '0' : '1');
    }
    debug("\n");
}

/***
 * Implementation of a (mostly) complete floating point adder. 
 * This does not account for denormal values, and does not consider different
 * rounding modes.  However, this is to be taken as the reference implementation
 * and the Verilog code will be compared against what is described here.
 */
unsigned int fpAdd(unsigned int a, unsigned int b){
	printBits("a", 32, a);
	printBits("b", 32, b);

	// 1. Extract the relevant parts - note that signed or unsigned is irrelevant
	//    and must be handled properly by your hardware
	int sign_a = (a >> 31) & 0x01; // Extract the MSB as sign bit
	int sign_b = (b >> 31) & 0x01;
	int exp_a = (a >> 23) & 0xff; // Exponents - in HW use appropriate bit width
	int exp_b = (b >> 23) & 0xff;
	int mant_a = (a & 0x7fffff) | 0x800000;  // Mantissas - add 1 to make 1.23
	int mant_b = (b & 0x7fffff) | 0x800000;	 

	printBits("sign a", 1, sign_a);
	printBits("exp  a", 8, exp_a);
	printBits("mant a", 24, mant_a);

	// 2. Handle special cases: 0, inf, NaN
	if ((exp_a == 0) && (mant_a == 0)) return b;
	if ((exp_b == 0) && (mant_b == 0)) return a;
	if (exp_a == 0xff) return a; // NaN or inf same behaviour
	if (exp_b == 0xff) return b;
	debug("Not a special case.  Continue\n");

	// 3. Move on to the actual computations
	// 3.1 Convert mantissas to two's complement so signed is taken care of
	if (sign_a) {  // Take care of sign extending to 25 bits at least
		mant_a = -mant_a; 
		debug("arg A was negative\n");
	}
	if (sign_b) {
		mant_b = -mant_b;
		debug("arg B was negative\n");
	}
	// 3.2 Equalize exponents
	int ediff; 
	int sign_r, exp_r, mant_r;
	if (exp_a > exp_b) {
		ediff = exp_a - exp_b;
		exp_r = exp_a;
		mant_b = mant_b >> ediff;
		debug("A had bigger exponent\n");
	} else if (exp_a < exp_b) {
		ediff = exp_b - exp_a;
		exp_r = exp_b;
		mant_a = mant_a >> ediff;
		debug("B had bigger exponent\n");
	} else {
		exp_r = exp_a; // either one - they are the same
		debug("Same exponents\n");
	}
	// 3.3 Compute addition - mant_r at least 26 bits to avoid loss
	//     1 bit for 2's C, 1 bit for overflow, + 24b mantissa
	mant_r = mant_a + mant_b;
	// 3.4 Sign of result and two's C if needed
	if (mant_r < 0) {
		sign_r = 1; 
		mant_r = -mant_r;
		debug("Result negative\n");
	} else {
		sign_r = 0;
		debug("Result positive\n");
	}
	// printBits("mr", 26, mant_r);
	// 3.5 Normalize
	int b25 = (mant_r & 0x01000000) >> 24;
	int b24 = (mant_r & 0x00800000) >> 23;
	if (mant_r == 0) { 
		// 3.5.1 Only possible if numbers cancelled out!
		exp_r = 0;
		debug("Result was 0!!\n");
	} else if ((b25 == 0) && (b24 == 1)) {
		// 3.5.2 nothing to do everyone is happy
		debug("No need to normalize\n");
	} else if (b25 == 1) {
		// 3.5.3 Overflow - renormalize
		mant_r = mant_r >> 1;
		exp_r  += 1;
		debug("Normalize for overflow\n");
	} else {
		// 3.5.4 a-b small: search for leading one and renormalize - 
		// how do you do this in hardware?
		debug("Normalize for small delta\n");
		debug("Starting exponent = %d\n", exp_r);
		while (b24 != 1) {
			mant_r = mant_r << 1;
			exp_r  -= 1;
			b24 = (mant_r & 0x00800000) >> 23;
		}
		debug("Final exponent = %d\n", exp_r);
	}

	unsigned int res;
	res = 	(sign_r & 0x01) << 31 |
			(exp_r  & 0xff) << 23 |
			(mant_r & 0x7fffff);

	return res;
}

int main(){
	FILE *f = fopen("testcases.dat", "r");
	float a, b, ans, x, err;
	const float TOLERANCE = 0.000001; // arbitrary - should be LSB equivalent
	int numtests, numerr = 0;
	fscanf(f, "%d", &numtests);
	int t = 0;
	while (numtests){
		t++;
		debug("****************** TESTCASE %d ********************\n", t);
		fscanf(f, "%f %f", &a, &b);
		debug("a: %f\n", a);
		debug("b: %f\n", b);

		ans = a + b;

		// Take the 32-b value in memory and treat it as an unsigned int
		// through pointer casting - this is only interpretation of the value
		unsigned int int_a = *(unsigned int *)&a;
		unsigned int int_b = *(unsigned int *)&b;

		unsigned int int_x = fpAdd(int_a, int_b);

		// Cast the 32-b value in memory to float 
		x = *(float *)&int_x;
		debug("Expected result: %f\n", ans);
		debug("Actual result: %f\n", x);
		err = (ans - x) < 0 ? (x - ans) : (ans - x);
		if (err > TOLERANCE) {
			numerr ++;
		}
		numtests--;
		debug("**************************************************\n");
	}
	fclose(f);
	if (numerr > 0) {
		printf("FAIL: %d errors\n", numerr);
	} else {
		printf("PASS\n");
	}
	return numerr;
}
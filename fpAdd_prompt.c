#include <stdio.h>

/* function to print binary representation of any data type
 * Assumes little endian
 * example:
 	int a = 10;
 	printBits(sizeof(int), &a);
*/
void printBits(size_t const size, void const * const ptr)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte;
    int i, j;
    
    for (i = size-1; i >= 0; i--) {
        for (j = 7; j >= 0; j--) {
            byte = (b[i] >> j) & 1;
            printf("%u", byte);
        }
    }
    puts("");
}

unsigned int fpAdd(unsigned int a, unsigned int b){
	//Write your solution here
	return 0;
}

int main(){
	FILE *f = fopen("testcases.dat", "r");
	float a = 19.25;
	float b = 0.09375;
	int numtests = 0;
	fscanf(f, "%d", &numtests);
	int t = 0;
	while (numtests){
		t++;
		printf("****************** TESTCASE %d ********************\n", t);
		fscanf(f, "%f %f", &a, &b);
		printf("a: %f\n", a);
		printf("b: %f\n", b);

		float ans = a + b;

		unsigned int int_a = *(unsigned int *)&a;
		unsigned int int_b = *(unsigned int *)&b;

		unsigned int int_x = fpAdd(int_a, int_b);

		float x = *(float *)&int_x;
		printf("Expected: ");
		printBits(sizeof(float), &ans);
		printf("Actual:   ");
		printBits(sizeof(float), &x);
		printf("Expected result: %f\n", ans);
		printf("Actual result: %f\n", x);

		numtests--;
		printf("**************************************************\n");
	}
	fclose(f);
	return 0;
}

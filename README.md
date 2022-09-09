# Assignment - Floating Point Addition in Verilog
Implement the operations involved during Floating Point Addition in Verilog

## Goals 

Implement a floating point adder in Verilog to take 2 32-b values as input, interpret them as IEEE-754 floating point values, and add them.

## Details of the assignment

### Number Representation

<p align = "justify"> The most commonly used number representations in computer arthimetic are the fixed and the floating-point representations. The
name fixed-point is used because of the fact that, this involves a fixed number of digits after the radix point. While for the case of floating point 
the radix point can "float", which means it can be placed anywhere relative to the significant digits of the number. Therefore, the successive numbers
in the fixed-point representation are placed uniformly while in the case of floating-point representation the successive numbers are not uniformly spaced. </p>

#### Fixed-point Representation 

<p align = "justify"> 
Consider a 4-bit number with the radix point fixed after two bits. Hence any number in the representation is of the form: </p>



![e1](./figs/1.svg)


<p align = "justify">  The given representation can span the range of numbers from 0 - 3.75, with a separation of 0.25 between successive numbers. However, if we still want to represent something as small as 0.0625 and something as large as 12, still using 4-bits we need an alternate
  representation. Hence, the following floating point representation, tries to solve the purpose to represent a wider range of numbers. </p>
  
 #### Floating-point Representation 
 
<p align = "justify">  We use the same 4-bits in this representation, however, something similar to the scientific notation of decimal numbers is followed to represent the numbers. For say, the first bit represents the mantissa (m) and the remaining bits represent the exponent (e). Then in this notation the number is represented as: </p>

![e2](./figs/2.svg)

![e3](./figs/3.svg)

<p align = "justify">  Hence, in this representation 0000 means decimal 0.0625 and 1111 means 12. Using this representation, 4-bits covers a wider range of numbers. However, it is important to note the spacing between successive numbers as illustrated in the figure. Although, floating-point provides a wider range this comes with a larger spacing between large numbers and smaller spacing between small numbers.   </p>


<p align="center">
<img width="350" alt="Screenshot 2022-09-09 at 12 17 38 AM" src="https://user-images.githubusercontent.com/63749705/189201948-d110f1a1-cc27-4cae-a4e4-29ff68d7abe1.png"> </p>

<p align = "justify"> Further, this also requires additional arithmetic circuitry while the hardware for fixed-point is similar to that of integer arithmetic. Based on the application and range of data being accessed, the appropriate representation can be adopted since either of them have their own benefits. In most of the scientific applications today, where the data goes to as large as 1e40 and as low as 1e-40 the IEEE 754 floating point standard is adopted. </p>

### IEEE 754 Standard for Floating-Point Arithmetic 

<p align="justify"> A single-precision 32-bit floating point number is represented as illustrated in this standard and the same is used for the rest of the implementations. The MSB represents the sign bit with 0 being a positive number, while 1 means a negative number. The next 8-bits represent the exponent with a bias. To get the actual exponent, the value represented here is to be subtracted by 127. Since this is a binary representation, the base is 2. The last 23-bits represent the normalized mantissa (fraction). An implicit 1 is placed, followed by a decimal point and the 23-bit normalized mantissa to get the entire 24-bit mantissa. </p>


<img width="600" alt="float" src="https://user-images.githubusercontent.com/63749705/189207724-a014a41b-0caa-4852-ac4d-f0f7a9690bc6.png"> 


![e3](./figs/4.svg)

Further, certain combinations form a special case and are reserved for the following functions: 

* e = 255
    * mantissa = all zeros: +/- inf
    * mantissa = non-zero: NaN (Not-a-Number)
* e = 0, represents the case of denormal/subnormal numbers

For this assignment, the case of denormal numbers need not be handled. However, the case of e = 255 is to be considered.

### Floating-Point Addition 
The rough flow of addition for the case of floating-point numbers has been presented: 
<p align="center">
<img width="350" alt="chart" src="https://user-images.githubusercontent.com/63749705/189225579-1233a1bf-105a-4625-8930-e09552671413.png">
  </p>


## Given

The file `fpAdd.c` contains a reference implementation of the algorithm in C.  There are a few important points to note here:

- The test cases are provided in the file `testcases.dat` in regular floating point format that can be read by a C program.  However, the test cases for Verilog cannot be read in float format, and are in Hex format instead.
- The `main` function contains some pointer jugglery that is used to interpret the same 32-bit values in memory either as `int` or `float` depending on context.  This means we can directly obtain the binary representation, which is then being fed into the `fpAdd` function.
- The function shows most of the steps involved, namely extracting the relevant bit portions, shifting, aligning, normalizing etc.  The most important thing to understand here is that *how this is done in C may not be the best way to do it in Verilog*. 
- As you may notice, this will most likely not be possible in a single clock cycle, and will require some kind of finite state machine (FSM) to control the behaviour.  In particular, the normalization for small delta values is something that can take a large number of cycles if done naively, but there may be better ways to implement this.
  - Most importantly, unless you write the Verilog properly, it may pass the simulation test benches, but still not be synthesizable.  **This is NOT acceptable** - you will need to understand why and correct it. 

Along with this C code (given as reference) there is also a Verilog testbench (To be added).  You need to write your module in such a way that it is compatible with this test bench and passes all the test cases.  Note that we may run additional test cases separately, so obviously you need to implement the actual logic of addition, not just pass the given cases.

In general, the given C code will be taken as the *golden reference*, meaning that in case of doubt regarding rounding or accuracy of computation, the given `fpAdd` function will be taken to be correct, even if it does not agree with what is reported by C.

## More about the assignment

### Software emulation

The C code given here is an *emulation* of the expected behaviour, and is used as the *golden reference*.  In general creating this reference itself is a non-trivial part of the design process.  In order to focus on the aspects related to implementation, this part of the design is already done for you.

### Reading "floats" without "floats" in C?

<p align="justify"> A float datatype is a 32-bit datatype that follows the IEEE 754 standard. However, in the memory, any 32-bit data looks the same - the difference only lies in how it is interpreted. In this assignment, we initially store the testcases into memory as float datatype - this results in the number being stored in memory as per the IEEE 754 format. Once that is done, we read back from the same memory location in the form of an unsigned integer though another pointer. This ensures that we can now get the exact word (32-bits) representation of the floating-point number and we can use the same to perform the computations. The part of the code that deals with this is as shown below:
  
```
unsigned int int_a = *(unsigned int *)&a;
unsigned int int_b = *(unsigned int *)&b;
```

## Problem Requirements

You can clone or download this repository.  Obviously getting some familiarity with git is strongly recommended, but is not going to be enforced for this course.  On the other hand, if there is any problem in terms of suspicion of copying, if you can show that you have a git repository that has been getting regular updates that align with your design, then that will be taken into consideration as possible proof that you wrote the code yourself.  Otherwise copying will be taken as a violation of institute disciplinary norms and may attract appropriate punishment.

Once downloaded, you should be able to compile and run the C code using the following commands (assuming you are typing them at a Shell prompt - indicated by `$`).

```sh
$ make fpAdd   # to compile the C file
$ ./fpAdd      # to run the C executable against all test cases in testcases.dat
```

Additional commands for the Verilog tests will be added here shortly - please refresh the repository once these are announced.

### Grading

You need to first show (to your TA) a Verilog simulation of your code that passes the floating point add test cases.  Once this is done, you need to add VIO signals for each of the inputs (including the clock), synthesize, and demonstrate this functioning on the FPGA.

## References 

The following references could be useful, if you want to explore further about number representations: 

* [IEEE 754, Wikipedia](https://en.wikipedia.org/wiki/IEEE_754)
* [Fixed-Point vs. Floating-Point Digital Signal Processing, Analog Devices](https://www.analog.com/en/technical-articles/fixedpoint-vs-floatingpoint-dsp.html)
* Section 3.5, Floating Point, Computer Organisation and Design, Patterson and Hennessy

    



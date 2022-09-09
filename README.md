# Assignment - Floating Point Addition in C
Implement the operations involved during Floating Point Addition in C 

## Goals 

To design the floating point adder in C (without using the float data type) to understand the operations involved. 

## Details of the assignment

### Number Representation

<p align = "justify"> The most commonly used number representations in computer arthimetic are the fixed and the floating-point representations. The
name fixed-point is used because of the fact that, this invloves a fixed number of digits after the radix point. While for the case of floating point 
the radix point can "float", which means it can be placed anywhere relative to the significant digits of the number. Therefore, the succesive numbers
in the fixed-point represntation are placed uniformly while in the case of floating-point representation the succesive numbers are not uniformly spaced. </p>

#### Fixed-point Representation 

<p align = "justify"> 
Consider a 4-bit number with the radix point fixed after two bits. Hence any number in the representation is of the form: </p>



![e1](./figs/1.svg)


<p align = "justify">  The given representation can span the range of numbers from 0 - 3.75, with a separation of 0.25 between succesive numbers. However, if we still want to represent something as small as 0.0625 and something as large as 12, still using 4-bits we need an alternate
  representation. Hence, the following floating point representation, tries to solve the purpose to represent a wider range of numbers. </p>
  
 #### Floating-point Representation 
 
<p align = "justify">  We use the same 4-bits in this representation, however, something similar to the scientifc notation of decimal numbers is followed to represent the numbers. For say, the first bit represents the mantissa (m) and the remaining bits represent the exponent (e). Then in this notation the number is represented as: </p>

![e2](./figs/2.svg)

![e3](./figs/3.svg)

<p align = "justify">  Hence, in this representation 0000 means decimal 0.0625 and 1111 means 12. Using this representaion, 4-bits covers a wider range of numbers. However, it is important to note the spacing between succesive numbers as illustrated in the figure. Although, floating-point provides a wider range this comes with a larger spacing between large numbers and smaller spacing between small numbers.   </p>


<p align="center">
<img width="350" alt="Screenshot 2022-09-09 at 12 17 38 AM" src="https://user-images.githubusercontent.com/63749705/189201948-d110f1a1-cc27-4cae-a4e4-29ff68d7abe1.png"> </p>

<p align = "justify"> Further, this also requires additional arthimetic circuitry while the hardware for fixed-point is similar to that of integer arthimetic. Based on the application and range of data being accessed, the appropriate representation can be adopted since either of them have their own benefits. In most of the scientific applications today, where the data goes to as large as 1e40 and as low as 1e-40 the IEEE 754 floating point standard is adopted. </p>

### IEEE 754 Standard for Floating-Point Arithmetic 

<p align="justify"> A single-precision 32-bit floating point number is represented as illustrated in this standard and the same is used for the rest of the implementations. The MSB represents the sign bit with 0 being a positive number, while 1 means a negative number. The next 8-bits represent the exponent with a bias. To get the actual exponent, the value represented here is to be subtracted by 127. Since this is a binary representation, the base is 2. The last 23-bits represent the normalised mantissa (fraction). An implicit 1 is placed, followed by a decimal point and the 23-bit normalised mantissa to get the entire 24-bit mantissa. </p>


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

<p align ="justify"> You have been provided the code template to test the functional correctness. Fill in the code corresponding to fpAdd function in the C file, that implements the floating point adder. You are required to "emulate" the working of the floating point adder. This is not a test of functional correctness - that could as well be done by assigning float c = a + b. By the end of this assignment you should be able to clearly identify the different stages involved in the process, and emulate those step-by-step. </p> 

<p align ="justify">  As a rule of thumb, float variables should not be used anywhere in the C code, except in reading the test cases, as specified in the template. The code should be able to deal with +/- inf and NaNs as inputs. Denorms are beyond the scope of this assignment and need not be dealt with. Rounding the results is not required, and is optional - the test setup provided would account for this variation. </p>

## More about the assignment

### Software emulation

<p align="justify"> In the first part of the assignment, we try to “emulate” the working of a floating point adder hardware unit using C code. As you could guess, this would be sequential in nature, and would go through multiple stages described previously. This in some sense might represent how a processor would try to perform a floating point add operation in the absence of a dedicated floating point unit. On an integer ALU, this corresponds to multiple clock cycles before a single floating point result can be finally represented. As a result, designing efficient floating point hardware units that can achieve better throughput and/ or lower latency, has been an area of active interest, with several possible design choices. In the next part of the assignment, we would try to build a hardware unit that functions as a floating point adder using Verilog HDL.</p>

### Reading "floats" without "floats" in C?

<p align="justify"> A float datatype is a 32-bit datatype that follows the IEEE 754 standard. However, in the memory, any 32-bit data looks the same - the difference only lies in how it is interpreted. In this assignment, we initially store the testcases into memory as float datatype - this results in the number being stored in memory as per the IEEE 754 format. Once that is done, we read back from the same memory location in the form of an unsigned integer though another pointer. This ensures that we can now get the exact word (32-bits) representation of the floating-point number and we can use the same to perform the computations. The part of the code that deals with this is as shown below:
  
```
unsigned int int_a = *(unsigned int *)&a;
unsigned int int_b = *(unsigned int *)&b;
```

## Grading

<p align="justify"> Clone the repository to your system. You have to fill in the fpAdd function in the fpAdd_prompt.c file. The two arguments a, b  can be considered as the 32-bit representations of the two floating point numbers that are need to be added, as per the IEEE 754 standard. Compile the C file and run it to test the program against the provided testcases. Note that this just checks for functional correctness, and you could end-up using two float numbers to get the test cases passed. However, you should demonstrate in the lab session, how your code is actually “emulating” the working of hardware. </p>

## References 

The following references could be useful, if you want to explore further about number representations: 

* ![IEEE 754, Wikipedia](https://en.wikipedia.org/wiki/IEEE_754)
* ![Fixed-Point vs. Floating-Point Digital Signal Processing, Analog Devices](https://www.analog.com/en/technical-articles/fixedpoint-vs-floatingpoint-dsp.html)
* Section 3.5, Floating Point, Computer Organisation and Design, Patterson and Hennessy

    



# Sisyphus

![thumbnail]()

## Overview
Sisyphus is a hybrid accumulator/register-register architecture using 9-bit instructions and an 8-bit datapath. Operations primarily work around moving data from the accumulator register and saving/restoring registers using the stack.

## Instruction set reference
A comprehensive documentation on the instruction set is linked [here](isa).

## Hardware design
The microarchitecture implementation is built around the following core modules: 
1. [Instruction memory](instruction_memory)
2. [Instruction decoder](decoder)
3. [Register file](register_file)
4. [Program counter](pc)
5. [ALU](alu)
6. [Data memory](data_memory)
7. [Stack/stack controller](stack)

## Assembler
Assembler command `python3 assembler.py [-h] [-o OUTPUT] [-b] input`
`input` specifies what assembly file should be assembled (including the file extension). The `-b` flag outputs to a `.bin` file for memory initialization. By default the output machine code is saved a `.mif` file to support commentsand compactness.

## Programs and emulation
Three programs are included in the repository:
1. [Closest/farthest Hamming distance pairs](hamming)
2. [Closest/farthest absolute distance pairs](pairs)
3. [16-bit signed multiplication](multiplication)

Assembly files can be run through a software emulation of the processor's behavior using the emulator in `assembly/emulator.py`. Run the emulator with `python3 emulator.py [-h] name`
`name` specifies what assembly file should be simulated.

All three programs will have their expected values asserted at the end. Throughout execution, the emulator will track register values, the stack, and data memory. 

## Testbenches
Testbenches and simulations were run using [Verilator](https://verilator.org/guide/latest/install.html) v5.048. Versions v5.020-v5.046 do not run the combined testbench correctly. Older versions may work, but run signficantly slower. 

Run the testbenches by navigating to the `run` directory and selecting the shell script with the test to be run.

```
cd run
./test_combined.sh  # tests the three programs
```
# Register file

## Overview
The register file stores eight 8-bit registers and the current program's status flags. Up to two registers can be read and one register can be written at the same time.

## Inputs
1. 3-bit read address 1
2. 3-bit read address 2
3. 3-bit write address
4. 8-bit write data
5. 5-bit incoming ALU flags
6. 1-bit write enable signal

## Outputs
1. 8-bit read result 1
2. 8-bit read result 2
3. 8-bit status flags

## Behavior
Register reads are handled combinationally with the two read addresses determining what values are passed to the output. Register writes are performed at the rising edge of the clock with the `write_en` signal blocking the write if the signal is zero. 

## ALU Flags
ALU flags are written at the rising edge of the clock if the `write_flags_en` signal is 1. The ALU flags are the four comparison flags: less than, greater than, and their signed counterparts along with the carry flag. When one ALU flag is written, all flags are reset. For example, an addition operation that updates the carry flag will reset the comparison flags even if no comparison takes place. ALU operations that do not touch flags, like `copy` will not change flags. Note that although memory operations use the ALU to perform addition and calculate addresses, these additions will not update the ALU flags.

## Non-ALU flags
There are three non-ALU flags that are also stored in the register file: zero, nonzero, and positive. These are updated combinationally based on the current value in the register `r0`. The positive flag interprets the value stored in the register as an 8-bit two's complement value. 
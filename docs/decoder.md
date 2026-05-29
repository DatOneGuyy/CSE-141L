# Decoder

## Overview
The decoder produces control signals for the other modules in the processor based on the current instruction. 

## Inputs
1. 9-bit instruction

## Output
1. 6-bit label address
2. 3-bit opcode
3. 3-bit function code
4. 3-bit immediate value
5. 1-bit data memory write enable
6. 1-bit program counter write enable
7. 1-bit register file write enable
8. 3-bit register read address 1
9. 3-bit register read address 2
10. 3-bit register write address
11. 1-bit stack controller push/pop indicator
12. 2-bit stack controller read/write mask
13. 2-bit register write MUX control signal
14. 1-bit stack operation flag

## Behavior
The decoder is purely a combinational module that assigns signals based only on the current instruction.
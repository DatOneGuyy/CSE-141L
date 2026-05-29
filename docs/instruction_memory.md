# Instruction memory

## Overview
The instruction memory has a 1024 9-bit entries and is divided into two sections: The lower 896 entries are used to store instructions, while the upper 128 entries contain 64 jump targets each representing a label in the currently loaded program.

## Inputs
1. 10-bit program counter
2. 6-bit label address

## Outputs
1. 9-bit instruction
2. 18-bit jump target

# Jump targets
The upper 128 entries (indices 896-1023) are divided into 64 larger entries each representing a label in the original assembly. Each label has 18 bits, subdivided into a 10-bit program counter representing the location of the label and an 8-bit flag encoding.

The flag encoding is `{unconditional, zero, nonzero, positive, less than, greater than, signed}`. If a field's bit is set to 1, then the associated condition is used when jumping to this label. The signed field only acts as a modifier for the less than and greater than fields. When it is zero, an unsigned comparison is used to determine if the branch should be taken.

# Behavior
Instruction memory should be initialized by the testbench as follows:
```
initial $readmemb("program.bin", D1.instruction_memory_inst.mem);
```

The module is purely combinational and reads the instruction and jump target based on the current program counter and label address signals.
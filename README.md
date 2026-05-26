# CSE 141L Project Repository

## Assembler and interpreter
Assembler command `python3 assembler.py [-h] [-o OUTPUT] [-b] input`
`input` specifies what assembly file should be assembled. The `-b` flag outputs to a `.bin` file for memory initialization. By default the output machine code is in a `.mif` file for comments and compactness.

Interpreter command `python3 interpreter.py [-h] name`
`name` specifies what assembly file should be simulated. All three programs will have their expected values asserted at the end. 

## Running tests
Run all tests from the `/run` directory. Tested with Verilator v5.048, does not work on v5.046.

## Viewing waveforms
The waveforms in `/dump` are associated with a settings file for [VaporView](https://marketplace.visualstudio.com/items?itemName=lramseyer.vaporview). 
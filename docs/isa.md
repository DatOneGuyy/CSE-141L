# Sisyphus ISA Reference

**Architecture:** Sisyphus
**Instruction width:** 9 bits
**Class:** Load–store accumulator machine

## Register Model

- **8 general-purpose registers** (`r0`–`r7`), each **8 bits** wide.
- **`r0`** is the default destination ("accumulator") for most operations and
  is an implicit operand for the single-operand instructions.
- **`r1`–`r7`** are general purpose. Registers `r4`–`r7` are always restored
  from the stack on a pop; whether `r1`–`r3` are restored is configurable per
  stack frame.
- **Flags** (8 total): four comparison flags, one carry flag (set by the ALU),
  plus zero / nonzero / positive status derived from `r0`. The comparison flag
  set by `cmp` is **persistent** — it changes only on a machine reset or the
  next `cmp`.

## Instruction Formats

| Type | Instructions | Description |
|------|--------------|-------------|
| J | `jump`, `jumplt`, `jumpgt`, `jumplts`, `jumpgts`, `jumpz`, `jumpnz`, `jumppos`, `call`, `return` | Modify the program counter |
| R | `add`, `imm`, `copy`, `lshift`, `rshift` | Basic register operations |
| Z | `popcnt`, `not`, `xor`, `and`, `addc`, `sub`, `lshiftc` | Register operations using `r0` as one operand |
| M | `load`, `store` | Interact with data memory |
| S | `push`, `pop` | Interact with the stack |
| C | `cmp` | Comparison |
| H | `halt` | Stop the current program |

### Opcode map

| Opcode | Used by |
|--------|---------|
| `000` | `imm`, `push`, `pop` |
| `001` | `jump`, all conditional jumps, `call`, `return` |
| `010` | `copy` |
| `011` | `popcnt`, `not`, `and`, `xor`, `addc`, `sub`, `lshiftc`, `halt` |
| `100` | `cmp` |
| `101` | `lshift`, `rshift` |
| `110` | `add` |
| `111` | `load`, `store` |

> **Note:** Every jump (conditional or not), `call`, and `return` share the
> same machine encoding — opcode `001` plus a 6-bit label address. The jump
> *condition* is not encoded in the instruction; it is stored alongside the
> target in label memory (see [Branch Addressing](#branch-addressing)).

---

## Control Flow Instructions

All targets reference one of 63 label slots in program memory (1 of the 64 is
reserved for function-call returns).

### `jump <target>`
Unconditional jump to the target.

```
#start
    jump #new-position
...
    #new-position    // jumps here
```

`| 001 | Address (6 bits) |`

### `jumplt <target>`
Jump if the **unsigned less-than** flag was set by the previous `cmp`.

```
imm r1 4
imm r0 3
cmp r0 r1        // less_than becomes TRUE since r0 < r1
jumplt #new-position
```

`| 001 | Address (6 bits) |`

### `jumpgt <target>`
Jump if the **unsigned greater-than** flag was set by the previous `cmp`.

```
imm r1 3
imm r0 4
cmp r0 r1        // greater_than becomes TRUE since r0 > r1
jumpgt #new-position
```

`| 001 | Address (6 bits) |`

### `jumplts <target>`
Jump if the **signed less-than** flag was set by the previous `cmp`.

```
imm r1 1
imm r0 -1
cmp r0 r1        // less_than (signed) becomes TRUE since r0 < r1
jumplts #new-position
```

`| 001 | Address (6 bits) |`

### `jumpgts <target>`
Jump if the **signed greater-than** flag was set by the previous `cmp`.

```
imm r1 -1
imm r0 1
cmp r0 r1        // greater_than (signed) becomes TRUE since r0 > r1
jumpgts #new-position
```

`| 001 | Address (6 bits) |`

### `jumpz <target>`
Jump if the current value in `r0` is **zero**.

```
imm r1 -1
imm r2 1
add r1 r2        // r0 = 0
jumpz #new-position
```

`| 001 | Address (6 bits) |`

### `jumpnz <target>`
Jump if the current value in `r0` is **nonzero**.

```
imm r1 3
imm r2 1
add r1 r2        // r0 != 0
jumpnz #new-position
```

`| 001 | Address (6 bits) |`

### `jumppos <target>`
Jump if the current value in `r0` is **positive**.

```
imm r1 3
imm r2 -1
add r1 r2        // r0 > 0
jumppos #new-position
```

`| 001 | Address (6 bits) |`

### `call <function>`
Jump to the first instruction of a function. `call` performs **only the
jump** — the matching stack frame (including the return address) must be
created by a `push` executed immediately beforehand.

```
#start
...
    push r4+
    call #my-function
    pop
...
#my-function         // jumps here
    ...
    return
```

`| 001 | Address (6 bits) |`

### `return`
Read the stored return address from the top of the stack and jump there. This
instruction does **not** modify the stack.

```
    push            // address 10: stores return address (12) on the stack
    call #my-function   // address 11
    pop             // address 12

#my-function
    ...
    return          // jumps to the pop at address 12
```

`| 001 | 000000 |`

Uses the reserved address `000000`, which tells the program counter to read
the next PC from the stack instead of from instruction memory.

---

## Register Operations

### `imm <destination> <immediate>`
Load an immediate into the destination register. Valid immediates are `1`–`6`
or `-1`. Use `xor`/`copy` to produce zero.

```
imm r1 1
imm r2 2
imm r3 3
imm r4 4
imm r5 5
imm r6 6
imm r7 -1
```

`| 000 | Destination (3 bits) | Immediate (3 bits) |`

- Immediate encoding: `0b001`–`0b110` for 1–6, `0b111` for −1.

### `copy <destination> [source]`
Copy the source register into the destination. Source defaults to `r0` if
omitted.

```
imm r5 3
copy r4 r5       // r4 and r5 both hold 3
lshift r4 1      // r0 = 6
copy r7          // r7 = 6  (source defaults to r0)
```

`| 010 | Destination (3 bits) | Source (3 bits) |`

### `add <operand1> <operand2>`
Add two registers; result goes to `r0`. Sets the carry flag on overflow.

```
imm r2 3
imm r3 5
add r2 r3        // r0 = 8
copy r2
add r2 r3        // r0 = 13
```

`| 110 | Operand1 (3 bits) | Operand2 (3 bits) |`

### `lshift <operand1> <immediate>`
Logical left shift by the immediate (`1`–`4`). The last bit shifted out becomes
the new carry flag.

```
imm r1 2
lshift r1 4      // r0 = 32
lshift r0 2      // r0 = 128
```

`| 101 | Operand1 (3 bits) | 0 | Immediate (2 bits) |`

- Shift amount encoding: `0b01`–`0b11` for 1–3, `0b00` for 4.

### `rshift <operand1> <immediate>`
Logical right shift by the immediate (`1`–`4`).

```
imm r1 6
rshift r1 2      // r0 = 1
```

`| 101 | Operand1 (3 bits) | 1 | Immediate (2 bits) |`

- Shift amount encoding: `0b01`–`0b11` for 1–3, `0b00` for 4.

---

## Accumulator Operations (`r0`-implicit)

These instructions take one explicit register operand, combine it with `r0`,
and write the result back to `r0`. All share opcode `011` and differ by their
3-bit function field.

### `popcnt <operand1>` — funct `000`
Population count of the operand; result in `r0`.

```
imm r3 3         // 0b011
popcnt r3
copy r5          // r5 = 2

imm r4 -1        // 0b...1111 1111
popcnt r4
copy r6          // r6 = 8
```

`| 011 | Operand1 (3 bits) | 000 |`

### `not <operand1>` — funct `001`
Bitwise NOT of the operand; result in `r0`.

```
imm r4 3
not r4           // r0 = 0xFC
```

`| 011 | Operand1 (3 bits) | 001 |`

### `and <operand1>` — funct `010`
Bitwise AND of the operand with `r0`; result in `r0`.

```
imm r1 3
imm r0 2
and r1           // r0 = 0x02
```

`| 011 | Operand1 (3 bits) | 010 |`

### `xor <operand1>` — funct `011`
Bitwise XOR of the operand with `r0`; result in `r0`.

```
// classic XOR swap of r1 and r2
copy r0 r1
xor r2
copy r1          // r1 = r1 ^ r2
copy r0 r2
xor r1
copy r2          // r2 = original r1
copy r0 r1
xor r2
copy r1          // r1 = original r2
```

`| 011 | Operand1 (3 bits) | 011 |`

### `addc <operand1>` — funct `100`
Add the operand, `r0`, and the current carry flag. Updates the carry flag on
overflow.

```
imm r0 -1
lshift r0 2      // r0 = 252
imm r1 6
add r0 r1        // r0 = 4, carry set
imm r2 5
addc r2          // r0 = 4 + 5 + 1 = 10
```

`| 011 | Operand1 (3 bits) | 100 |`

### `sub <operand1>` — funct `101`
Subtract the operand from `r0`; result in `r0`.

```
imm r0 3
imm r1 2
sub r1           // r0 = 1
sub r1           // r0 = -1
sub r1           // r0 = -3
```

`| 011 | Operand1 (3 bits) | 101 |`

### `lshiftc <operand1>` — funct `110`
Left-shift the operand by one, shifting the current carry flag into the LSB.
The bit shifted out of the MSB becomes the new carry flag.

```
imm r0 -1
lshift r0 2      // r0 = 252
imm r1 6
add r0 r1        // r0 = 4, carry set
lshiftc r0       // r0 = 9
```

`| 011 | Operand1 (3 bits) | 110 |`

---

## Memory Operations

Only indirect addressing is supported. The effective address is a base
register plus a 0–3 byte immediate offset, allowing a 4-byte word to be read
without recomputing the base address.

### `store <address> [offset]`
Store `r0` to the address held in the given register, plus optional offset
(`0`–`3`, default `0`).

```
imm r1 1
lshift r1 4      // r1 = 16
imm r3 6
imm r4 5
add r3 r4        // r0 = 11
store r1         // mem[16] = 11
add r1 r0        // r0 = 27
store r1 1       // mem[17] = 27
```

`| 111 | Address (3 bits) | 0 | Immediate (2 bits) |`

### `load <address> [offset]`
Load into `r0` from the address held in the given register, plus optional
offset (`0`–`3`, default `0`).

```
imm r1 1
lshift r1 4      // r1 = 16
imm r0 6
store r1         // mem[16] = 6
...
load r7 1        // r0 = mem[base + 1]
```

`| 111 | Address (3 bits) | 1 | Immediate (2 bits) |`

**Word-access example** (assume `r3 = 132`, and bytes 132–135 hold
`0xABCDEF55`):

```
load r3
copy r4          // 0xAB
load r3 1
copy r5          // 0xCD
load r3 2
copy r6          // 0xEF
load r3 3
copy r7          // 0x55
```

---

## Stack Operations

### `push [registers]`
Push a new stack frame: the selected register group, a record of which
registers to restore on the next `pop`, and the return address `pc + 2`.
Because the return address is saved here (and not by `call`), a `push` is
**required immediately before every `call`**.

Register groups save register `rN` through `r7` inclusive:

| Group | Encoding | Registers saved |
|-------|----------|-----------------|
| `r2+` | `00` | `r2`–`r7` |
| `r4+` | `01` | `r4`–`r7` |
| `r5+` | `10` | `r5`–`r7` |
| `r6+` | `11` | `r6`–`r7` |

```
imm r3 5
imm r4 6
imm r5 2
push r4+         // saves r4-r7 and the return address
call #my-function
pop              // restores r4-r7
```

`| 000 | 0 | Registers (2 bits) | 000 |`

### `pop`
Restore the register values from the top stack frame and remove that frame.
The register group recorded at push time determines which registers are
restored.

```
imm r4 6
imm r5 2
imm r6 3
imm r7 4
push r5+         // save r5-r7
imm r5 1
imm r6 2
add r5 r6
pop              // r5-r7 restored
```

`| 000 | 1 | XX | 000 |`

**Timing:** pushing *n* registers takes ⌈n/2⌉ cycles; popping *n* registers
takes *n* cycles (the register file reads two and writes one register per
cycle).

---

## Comparison

### `cmp <operand1> <operand2>`
Compare two registers and set the comparison flags. The flag is set when
`operand1 < operand2` (the architecture provides both signed and unsigned
forms; signedness is selected by the jump that consumes the flag). The
comparison flag is **persistent** — it only changes on a machine reset or the
next `cmp`.

```
// equality check via two comparisons
cmp r0 r1
jumplt #not-equal
cmp r1 r0
jumplt #not-equal
push
call #run-if-equal
pop
#not-equal
...
#run-if-equal
...
return
```

`| 100 | Operand1 (3 bits) | Operand2 (3 bits) |`

---

## System

### `halt`
Halt execution, raise the processor's `done` signal, and wait until the
`start` signal is lowered. New operands can be loaded into memory between
halted programs so that programs can be chained.

```
#program-1
...
halt             // wait for new operands

#program-2
...
#end
```

`| 011 | 000111 |`

---

## Branch Addressing

Branches use absolute target addresses stored in a dedicated **label memory**
section, separate from the instruction stream.

- A single program supports up to **63 branch locations** (1 of 64 is reserved
  for function-call returns).
- The maximum branch distance equals the instruction-memory size: 896 entries,
  so up to 895 instructions.

### Label memory layout

Label memory lives in instruction-memory addresses **896–1023**. Since
instruction memory is 9 bits wide, each 18-bit label entry spans two
consecutive addresses:

- **Even address:** the 9 most-significant bits of the target address.
- **Odd address:** the least-significant bit of the target address (in the
  MSB), followed by 8 condition bits, ordered MSB→LSB as:

  `{ call, return, jumpz, jumpnz, jumppos, less_than, greater_than, signed }`

  The `signed` bit selects signed vs. unsigned comparison flags. If all 8
  condition bits are zero, the jump is **unconditional**.

A label at machine-code address *N* occupies label-memory addresses
`896 + N·2` and `896 + N·2 + 1`.

**Example.** A signed conditional less-than jump to target `0b1010101010` from
machine-code address 25 (`0b011001`) uses label-memory addresses 946 and 947:

- Address 946 = `0b101010101` (top 9 bits of the target)
- Address 947 = `0b00000101` (target LSB in the MSB, then the condition bits)

### Constraints

- Label-memory addresses **896–897** are reserved for the `return` instruction
  and are the only entry with the `return` bit set.
- A given label may use **only one** jump condition. To jump to the same
  instruction with two different conditions, define a second label on an
  adjacent line; both assemble into jumps pointing at the same instruction.

### Worked machine-code example

The equality check above assembles to:

```
...                              // (#start)
[5]  001 000 001    // cmp r0 r1
[6]  001 000001     // jumplt  #not-equal-lt
[7]  001 000 001    // cmp r0 r1
[8]  001 000001     // jumpgt  #not-equal-gt  (separate label per jump type)
[9]  011 0 11 000   // push r4+
[10] 001 000010     // call #run-if-equal
[11] 000 1 00 000   // pop
[12] ...                         // (#not-equal-lt) / (#not-equal-gt)
[30] 001 000000     // return

// Label memory
[896] 000000000 001000000   // (return)
[898] 000000000 000000000   // (#start)
[900] 000001100 000000100   // (#not-equal-lt) conditional branch
[902] 000001100 000000010   // (#not-equal-gt) conditional branch
```
// ===============================================
// CPU ARITHMETIC & LOGIC VALIDATION SUITE
// Tests: add, sub, addc, and, or, xor, not, lshift, rshift, rlc
// Outputs: mem[0] through mem[9]
// ===============================================

#hardware-test-start
    // -------------------------------------------
    // INITIALIZATION
    // -------------------------------------------
    // Use the RISC-style zeroing: r0 = r0 ^ r0
    xor r0        
    copy r7       // r7 = 0 (Used as the memory pointer)

    // -------------------------------------------
    // TEST 1: Addition (add)
    // Goal: 2 + 3 = 5
    // -------------------------------------------
    imm r1 2
    imm r2 3
    add r1 r2     // r0 = r1 + r2
    store r7      // mem[0] = 5

    // -------------------------------------------
    // TEST 2: Subtraction (sub)
    // Goal: 4 - 1 = 3
    // -------------------------------------------
    imm r1 4
    copy r0 r1    // Load 4 into the accumulator
    imm r2 1
    sub r2        // r0 = r0 - r2
    store r7 1    // mem[1] = 3

    // -------------------------------------------
    // TEST 3: Add with Carry (addc)
    // Goal: 3 + 1 + 1 (Carry) = 5
    // -------------------------------------------
    // Step A: Force a carry overflow (255 + 2 = 1, Carry = 1)
    imm r1 -1     // -1 is 0xFF (255)
    imm r2 2
    add r1 r2     // Carry Flag is now 1

    // Step B: Execute addc
    imm r3 3
    copy r0 r3    // Load 3 into accumulator
    imm r4 1
    addc r4       // r0 = 3 + 1 + 1 (Carry)
    store r7 2    // mem[2] = 5

    // -------------------------------------------
    // TEST 4: Bitwise AND (and)
    // Goal: 0b011 (3) & 0b010 (2) = 0b010 (2)
    // -------------------------------------------
    imm r1 3
    copy r0 r1
    imm r2 2
    and r2        // r0 = r0 & r2
    store r7 3    // mem[3] = 2

    // --- Advance Memory Pointer by 4 ---
    imm r6 4
    add r7 r6
    copy r7       // r7 is now 4

    // -------------------------------------------
    // TEST 5: Population count (popcnt)
    // Goal: 0b001 (1) | 0b010 (2) = 0b011 (3)
    // -------------------------------------------
    imm r5 -1
    popcnt r5
    store r7      // mem[4] = 8

    // -------------------------------------------
    // TEST 6: Bitwise XOR (xor)
    // Goal: 0b011 (3) ^ 0b001 (1) = 0b010 (2)
    // -------------------------------------------
    imm r1 3
    copy r0 r1
    imm r2 1
    xor r2        // r0 = r0 ^ r2
    store r7 1    // mem[5] = 2

    // -------------------------------------------
    // TEST 7: Bitwise NOT (not)
    // Goal: ~0x00 = 0xFF (255)
    // -------------------------------------------
    xor r0        // r0 = 0
    copy r1       // r1 = 0
    not r1        // r0 = ~r1
    store r7 2    // mem[6] = 255

    // -------------------------------------------
    // TEST 8: Logical Shift Left (lshift)
    // Goal: 1 << 2 = 4
    // -------------------------------------------
    imm r1 1
    lshift r1 2   // r0 = r1 << 2
    store r7 3    // mem[7] = 4

    // --- Advance Memory Pointer by 4 ---
    imm r6 4
    add r7 r6
    copy r7       // r7 is now 8

    // -------------------------------------------
    // TEST 9: Logical Shift Right (rshift)
    // Goal: 4 >> 1 = 2
    // -------------------------------------------
    imm r1 4
    rshift r1 1   // r0 = r1 >> 1
    store r7      // mem[8] = 2

    // -------------------------------------------
    // TEST 10: Left shift with carry (clshift)
    // Goal: (0 << 1) | Carry = 1
    // ------------------------------------------
    // Step A: Generate carry flag using a left shift
    imm r1 -1     // 0xFF (255)
    lshift r1 1   // r0 = 0xFE, Carry = 1

    // Step B: Execute lshiftc
    xor r0        // Safely load 0 into accumulator without touching carry
    copy r2       // r2 = 0
    lshiftc r2        // r0 = (r2 << 1) | Carry Flag
    store r7 1    // mem[9] = 1

    halt
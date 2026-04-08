//main function 3
#program-3-multiply

    jump #end

// Multiplies two unsigned 16-bit numbers
// Args: (r4: Mult MSB, r5: Mult LSB, r6: Mcand MSB, r7: Mcand LSB) 
// Returns: Product in (r2: MSB, r3: LSB)
#multiply-16
    
    // 1. Store Multiplicand to memory to free r6 and r7
    dist r0       // r0 = 0
    copy r2       // r2 = 0 (temporarily use r2 as the memory pointer)
    
    copy r0 r6    // r0 = Mcand MSB
    store r2      // mem[0] = Mcand MSB
    copy r0 r7    // r0 = Mcand LSB
    store r2 1    // mem[1] = Mcand LSB

    // 2. Initialize Product to 0
    dist r0
    copy r2       // Product MSB = 0
    copy r3       // Product LSB = 0
    
    // 3. Initialize Constants
    dist r0
    copy r6       // r6 = 0 (Used as memory pointer and for comparisons)
    imm r7 1      // r7 = 1 (Used for decrements and bit masking)
    
    // 4. Initialize Loop Counter to 16
    imm r1 4
    lshift r1 2   // r0 = 4 << 2 (16)
    copy r1       // r1 = 16

#multiply-loop
    
    // STEP 1: Shift Product Left by 1
    lshift r3 1   // r0 = LSB << 1 (MSB falls into Carry Flag)
    copy r3       // r3 = r0
    rlc r2        // r0 = (r2 << 1) | Carry Flag 
    copy r2       // r2 = r0

    // STEP 2: Extract MSB of Multiplier (r4)
    rshift r4 4   // r0 = r4 >> 4
    rshift r0 3   // r0 = r0 >> 3 (r0 is now perfectly 0x00 or 0x01)
    
    // STEP 3: Conditional Addition
    cmp r0 r7     // Is MSB < 1? (i.e., is it 0?)
    jumplt #skip-add 
        
        // If MSB == 1, add Multiplicand to Product
        load r6 1     // r0 = mem[1] (Multiplicand LSB)
        add r3 r0     // r0 = r3 + r0 (Sets Carry Flag)
        copy r3

        load r6       // r0 = mem[0] (Multiplicand MSB)
        addc r2       // r0 = r0 + r2 + Carry Flag! (Single operand addc)
        copy r2

    #skip-add
    
    // STEP 4: Shift Multiplier Left by 1
    lshift r5 1   // r0 = LSB << 1 (MSB falls into Carry Flag)
    copy r5
    rlc r4        // r0 = (r4 << 1) | Carry Flag
    copy r4
    
    // STEP 5: Decrement Counter (8-bit sub)
    copy r0 r1    // r0 = Loop Counter
    sub r7        // r0 = r0 - 1 (Subtracts r7)
    copy r1       // Loop Counter = r0
    
    // STEP 6: Loop Check
    cmp r6 r1     // Is 0 < r1? (Will evaluate to false when r1 hits 0)
    jumplt #multiply-loop

    // Loop finished. Final 16-bit product is safely sitting in r2 and r3.
    return
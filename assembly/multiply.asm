//main function 3
#program-3-multiply
    //initialize loop counter in r7
    dist r0
    copy r7
    copy r6 //memory read address for function output

    //max count in r4 - address 64
    imm r0 4
    lshift r0 4
    copy r4

    //write address in r5 - begins at 64
    copy r5 r4

    #main-loop-start
        push r4+ //save r5-r7 for use at end of loop body
        
        //get multiplier sign
        load r7        //Load MSB 1
        rshift r0 4
        rshift r0 3
        copy r5        //r5 = multiplier sign (0 or 1)

        //get multiplicand sign
        load r7 2      //Load MSB 2
        rshift r0 4
        rshift r0 3

        xor r5         
        copy r5        //save result sign

        //negate multplier if needed
        load r7 1
        copy r2
        load r7
        copy r1

        //check sign
        rshift r0 4
        rshift r0 3
        imm r3 1
        cmp r0 r3
        jumplt #store-multiplier //if sign bit < 1, is positive

        //negate
        not r1
        copy r1
        not r2
        copy r2

        imm r0 1
        add r2 r0
        copy r2

        dist r0
        addc r1
        copy r1

        #store-multiplier

        //store multiplier to mem[0-1]
        copy r0 r2
        store r6 1 
        copy r0 r1
        store r6

        //negate multiplicand if needed
        load r7 3
        copy r2
        load r7 2
        copy r1

        //check sign
        rshift r0 4
        rshift r0 3
        imm r3 1
        cmp r0 r3
        jumplt #store-multiplicand //if sign bit < 1, is positive

        //negate
        not r1
        copy r1
        not r2
        copy r2

        imm r0 1
        add r2 r0
        copy r2

        dist r0
        addc r1
        copy r1

        #store-multiplicand

        //store multiplicand to mem[2-3]
        copy r0 r2
        store r6 3
        copy r0 r1
        store r6 2

        //call multiplication
        push r1+
        call #multiply-32
        pop

        imm r0 1
        cmp r5 r0
        jumplt #positive-result //skip negation step if result is positive
            //negate smallest byte
            load r6 3
            not r0
            imm r7 1
            add r0 r7
            store r6 3

            //next smallest byte and propagate carry
            load r6 2
            not r0
            copy r7
            dist r0
            addc r7 //r7 + 0 + carry
            store r6 2
            
            //next smallest byte and propagate carry
            load r6 1
            not r0
            copy r7
            dist r0
            addc r7 //r7 + 0 + carry
            store r6 1

            //negate msb
            load r6
            not r0
            copy r7
            dist r0
            addc r7 //r7 + 0 + carry
            store r6

        #positive-result

        pop //restore r4-7

        //store result
        load r6 3
        store r5 3
        load r6 2
        store r5 2
        load r6 1
        store r5 1
        load r6
        store r5

        //increment write address
        imm r0 4
        add r5 r0
        copy r5

    //increment counter, then jump
    imm r0 4
    add r7 r0
    copy r7
    cmp r7 r4
    jumplt #main-loop-start

    jump #end

// Multiplies two unsigned 16-bit numbers to produce a 32-bit product
// Inputs: mem[0-1]: Multiplier (MSB, LSB)
//         mem[2-3]: Multiplicand (MSB, LSB)
// Output: mem[0-3]: 32-bit Product (MSB to LSB)
#multiply-32
    flag
    // 1. Initialize 32-bit Product to 0 in registers
    dist r0       // r0 = 0
    copy r2       // Product Byte 0 = 0
    copy r3       // Product Byte 1 = 0
    copy r4       // Product Byte 2 = 0
    copy r5       // Product Byte 3 = 0
    
    // 2. Initialize Constants
    dist r0
    copy r6       // r6 = 0 (Memory pointer and for loop comparison)
    imm r7 1      // r7 = 1 (Used for decrements and bit masking)
    
    // 3. Initialize Loop Counter to 16
    imm r1 4
    lshift r1 2   // r0 = 4 << 2 (16)
    copy r1       // r1 = 16

    #multiply-loop
        
        // STEP 1: Shift the 32-bit Product Left by 1
        lshift r5 1   // r0 = r5 << 1 (MSB falls into Carry Flag)
        copy r5
        clshift r4        // r0 = (r4 << 1) | Carry Flag
        copy r4
        clshift r3        // r0 = (r3 << 1) | Carry Flag
        copy r3
        clshift r2        // r0 = (r2 << 1) | Carry Flag
        copy r2

        // STEP 2: Extract MSB of Multiplier from Memory
        load r6       // r0 = mem[0] (Multiplier MSB)
        rshift r0 4   // r0 = r0 >> 4
        rshift r0 3   // r0 = r0 >> 3 (r0 is now exactly 0x00 or 0x01)
        
        // STEP 3: Conditional Addition
        cmp r0 r7     // Is MSB < 1? (i.e., is it 0?)
        jumplt #skip-add 
            
            // Add LSBs
            load r6 3     // r0 = mem[3] (Multiplicand LSB)
            add r5 r0     // r0 = r5 + r0 (Sets Carry Flag)
            copy r5

            // Add MSBs
            load r6 2     // r0 = mem[2] (Multiplicand MSB)
            addc r4       // r0 = r0 + r4 + Carry Flag
            copy r4

            // Propagate Carry to upper 16 bits of Product
            dist r0       // r0 = 0
            addc r3       // r0 = r0 + r3 + Carry Flag
            copy r3

            dist r0       // r0 = 0
            addc r2       // r0 = r0 + r2 + Carry Flag
            copy r2

        #skip-add
        
        // STEP 4: Shift Multiplier Left by 1 in Memory
        load r6 1     // r0 = mem[1] (Multiplier LSB)
        lshift r0 1   // r0 = r0 << 1 (MSB to Carry)
        store r6 1    // mem[1] = r0
        
        load r6       // r0 = mem[0] (Multiplier MSB)
        clshift r0        // r0 = (r0 << 1) | Carry
        store r6      // mem[0] = r0
    
    // STEP 5: Decrement Counter
    copy r0 r1    // r0 = Loop Counter
    sub r7        // r0 = r0 - 1
    copy r1       // Loop Counter = r0
    
    // STEP 6: Loop Check
    cmp r6 r1     // Is 0 < r1?
    jumplt #multiply-loop

    // ----------------------------------------------------
    // STEP 7: Copy 32-bit Product back to memory
    // ----------------------------------------------------
    
    copy r0 r2    // Move Product Byte 0 to accumulator
    store r6      // mem[0] = Product MSB
    
    copy r0 r3
    store r6 1    // mem[1] = Product Byte 1
    
    copy r0 r4
    store r6 2    // mem[2] = Product Byte 2
    
    copy r0 r5
    store r6 3    // mem[3] = Product LSB

    return

#end
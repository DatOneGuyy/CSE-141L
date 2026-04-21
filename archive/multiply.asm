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
        jumppos #store-multiplier

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
        jumppos #store-multiplicand

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

    jump #end-3

// multiplies two unsigned 16-bit numbers to produce a 32-bit product
// inputs: mem[0-1]: multiplier
//         mem[2-3]: multiplicand
// output: mem[0-3]: 32-bit product
#multiply-32
    //initialize product to zero
    dist r0
    copy r2
    copy r3
    copy r4
    copy r5
    
    //initialize constants
    dist r0
    copy r6       // r6 = 0 (memory pointer and loop comparison)
    imm r7 1      // r7 = 1 (decrement and bit masking)
    
    //initialize loop counter in r1 to 16
    imm r1 4
    lshift r1 2
    copy r1

    #multiply-loop
        
        //shift product left by 1
        lshift r5 1       // r0 = r5 << 1 and MSB sets carry flag
        copy r5
        lshiftc r4        // r0 = (r4 << 1) | carry
        copy r4
        lshiftc r3        // r0 = (r3 << 1) | carry
        copy r3
        lshiftc r2        // r0 = (r2 << 1) | carry
        copy r2

        //load multiplier from memory
        load r6       // r0 = mem[0]
        rshift r0 4   // r0 = r0 >> 4
        rshift r0 3   // r0 = r0 >> 3 (r0 is 0x00 or 0x01)
        
        //add only if MSB is 1
        cmp r0 r7
        jumplt #skip-add 
            
            //add LSBs
            load r6 3     // r0 = mem[3] (multiplicand MSB)
            add r5 r0     // r0 = r5 + r0 and set carry
            copy r5

            //add MSBs
            load r6 2     //r0 = mem[2]
            addc r4       //r0 = r0 + r4 + carry
            copy r4

            // propagate carry
            dist r0       //r0 = 0
            addc r3       //r0 = r0 + r3 + carry
            copy r3

            dist r0       //r0 = 0
            addc r2       //r0 = r0 + r2 + carry
            copy r2

        #skip-add
        
        //shift multiplier left by 1
        load r6 1
        lshift r0 1
        store r6 1
        
        //shift in lost bit
        load r6
        lshiftc r0
        store r6
    
    //loop decrement and comparison
    copy r0 r1
    sub r7
    copy r1
    cmp r6 r1
    jumplt #multiply-loop

    //copy product back into memory
    copy r0 r2    // Move Product Byte 0 to accumulator
    store r6      // mem[0] = Product MSB
    
    copy r0 r3
    store r6 1    // mem[1] = Product Byte 1
    
    copy r0 r4
    store r6 2    // mem[2] = Product Byte 2
    
    copy r0 r5
    store r6 3    // mem[3] = Product LSB

    return

#end-3
halt
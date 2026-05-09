//main function 1
#program-1-hamming
    //registers
    //r0    - return result
    //r1    - immediate 2 for increment
    //r2-r3 - loop counters
    //r4    - max array address 1 (62)
    //r5    - max array address 2 (64), also write address of solution
    //r6    - current min distance
    //r7    - current max distance

    //set max addresses
    imm r1 -1
    imm r0 4
    lshift r0 4
    copy r5 //64
    add r1 r5
    add r0 r1
    copy r4 //62

    //initialize min
    imm r0 4
    lshift r0 2
    copy r6
    
    //initialize outer loop counter, increment value, and max
    xor r0
    copy r7
    copy r2
    imm r1 2

    #outer-loop-start
        //initialize inner loop counter to outer + 2
        add r2 r1
        copy r3

        #inner-loop-start
            //inner loop body

            push r4+
            call #calculate-distance
            pop

            //if min < dist don't store dist
            cmp r6 r0
            jumplt #skip-min
            copy r6

            #skip-min
            //if dist < max don't store dist
            cmp r0 r7
            jumplt #skip-max
            copy r7

            #skip-max
        add r3 r1
        copy r3
        cmp r3 r5
        jumplt #inner-loop-start
    add r2 r1
    copy r2
    cmp r2 r4
    jumplt #outer-loop-start

    //write min and max to memory
    copy r0 r6
    store r5
    copy r0 r7
    store r5 1

    jump #end-1

//calculates hamming distance between two 16-bit numbers
//argument positions set to minimize copying
//args (r2: address1, r3: address2) => (r0: distance)
#calculate-distance
    //load MSBs
    load r2
    copy r4
    load r3

    //calculate distance
    xor r4
    popcnt r0
    copy r5

    //load LSBs
    load r2 1
    copy r4
    load r3 1

    //calculate distance
    xor r4
    popcnt r0
    add r0 r5

    return

#end-1
halt

//main function 2
#program-2-pairs
    //sort numbers before processing

    //pass start index 0, size 32
    imm r1 4
    lshift r1 4
    copy r1
    xor r0

    push r6+
    call #merge-sort
    pop
    
    //calculate difference between highest/lowest
    imm r0 4
    lshift r0 3 //32
    imm r1 -1   
    add r0 r1   //31
    lshift r0 1 //62
    copy r3 //stores address 62

    //load largest into r4/r5
    load r3
    copy r4
    load r3 1
    copy r5

    xor r0
    copy r1 //stores address 0
    
    //load smallest into r6/r7
    load r1
    copy r6
    load r1 1
    copy r7

    push r2+
    call #subtract
    pop

    //move r0 to r2
    copy r2
    imm r0 4
    add r3 r0 
    copy r3 //stores address 66

    //write subtraction result to mem[66-67]
    copy r0 r2
    store r3
    copy r0 r1
    store r3 1

    //loop to find the smallest difference
    //register used:
    //r0-r1 - shared data between frames
    //r2    - loop counter
    //r3    - loop limit
    //r6-r7 - smallest difference seen so far

    //initialize loop counter
    xor r0
    copy r2

    //set loop limit at 62
    imm r0 4
    lshift r0 3
    imm r1 -1
    add r0 r1
    lshift r0 1 
    copy r3

    //set smallest difference to 65535
    imm r6 -1
    imm r7 -1

    #difference-loop-start
        push r4+

        //calculate subtraction first
        //load adjacent array elements
        load r2
        copy r6
        load r2 1
        copy r7
        load r2 2
        copy r4
        load r2 3
        copy r5

        //subtraction call
        push r2+
        call #subtract
        pop

        pop //pass up new difference

        //compare current difference with minimum difference
        
        //subtraction here produces an unsigned result so compare msb first
        cmp r0 r6 //if r0 < r6, current difference is smaller
        jumplt #smaller-current
        jumpgt #larger-current

        //msbs are equal so compare lsbs
        cmp r1 r7 //if r5 < r7, current difference is smaller
        jumplt #smaller-current
        jump #larger-current-always //skip storing otherwise
        
        #smaller-current
        //replace stored minimum
        copy r6
        copy r7 r1

        #larger-current
        #larger-current-always
    
    //increment read address
    imm r0 2
    add r0 r2
    copy r2
    cmp r2 r3
    jumplt #difference-loop-start

    //write to addresses 68-69
    imm r1 4
    lshift r1 4
    add r0 r1
    copy r1
    copy r0 r6
    store r1
    copy r0 r7
    store r1 1

    jump #end-2

//subtracts two double-precision numbers (n1 - n2)
//args: (r4: MSB 1, r5: LSB 1, r6: MSB 2, r7: LSB 2) => (r0: MSB, r1: LSB)
#subtract
    //set constants
    xor r0
    copy r3
    imm r2 1

    //negate n2
    not r7
    add r0 r2
    copy r7

    not r6
    addc r3 //propagate carry
    copy r6

    //add LSBs
    add r5 r7
    copy r1

    //add MSBs
    copy r0 r4
    addc r6 //propagate carry
    
    return

//sorts the array in the memory locations 0-63
//args: (r0: index, r1: size) => (r0: index, r1: size)
#merge-sort
    //return early if subarray is size 1
    imm r2 4
    cmp r1 r2
    jumplt #merge-sort-return

        //save first index to r7
        copy r7

        //split array and store new length in r6
        rshift r1 1
        copy r6

        //setup left recursive call
        copy r0 r7 //copy index
        copy r1 r6 //copy size
        push r6+   //keep return values in r0/r1
        call #merge-sort
        pop

        //setup right recursive call
        add r6 r7  // calculate right start index
        copy r1 r6 // restore the split size to r1
        push r6+   
        call #merge-sort
        pop

        //setup merge function call
        copy r0 r7 // restore left start index
        copy r1 r6 // restore the split size to r1
        push r4+
        call #merge
        pop

    #merge-sort-return
    return //last #merge call already placed correct index in r0 and size in r1 for return

//merges two sorted arrays with the same size placed continguously in memory and returns the index of the first element of the new array and the new array's size
//args: (r0: index, r1: size) => (r0: index, r1: size)
#merge
    //set up for the merge loop
    //registers used here:
    //r0, r1 - output from inner stack
    //r2, r3 - array counters
    //r4     - right array start index
    //r5     - write output index
    //r6     - subarray size
    //r7     - left array start index

    copy r7    //set up r7
    copy r6 r1 //set up r6
    imm r5 4
    lshift r5 4
    add r0 r7
    copy r5    //set up r5
    add r7 r6
    copy r4    //set up r4

    //initialize counters
    xor r0
    copy r2
    copy r3

    #merge-loop-start
        //merge loop body
        push r2+  //save to stack to use more registers

        //load upper right into r1
        add r3 r4 //right index + right array start
        copy r3
        load r3
        copy r1

        //load upper left into r0
        add r2 r7 //left index + left array start
        copy r2
        load r2

        pop       //restore registers

        //compare MSBs
        //start with sign comparison
        push r6+

        //save right, then left
        copy r7 r1 
        copy r6

        cmp r6 r7
        jumplts #smaller-left-msb
        jumpgts #smaller-right-msb

            //MSBs are equal so load the LSBs
            pop
            push r2+

            //load lower right into r1
            add r3 r4 //right index + right array start
            copy r3
            load r3 1
            copy r1

            //load lower left into r0
            add r2 r7 //left index + left array start
            copy r2
            load r2 1

            pop

        //compare LSBs in r0 and r1
        //if r0 < r1, left is smaller
        cmp r0 r1
        jumplt #smaller-left-lsb
        
        //right must be smaller or equal at this point
        jump #smaller-right-lsb

        #merge-body-end
        //increment write output index
        imm r0 2
        add r5 r0
        copy r5

    //if one counter finishes, exit loop
    cmp r2 r6
    jumplt #check-1-pass
    jump #merge-loop-end

    #check-1-pass
    cmp r3 r6
    jumplt #merge-loop-start

    #merge-loop-end

    //copy remaining items
    
    //check if left finished first
    cmp r2 r6
    jumplt #left-unfinished-loop

    #right-unfinished-loop
        push r6+
        
        //load bytes
        add r3 r4 //right index + right array start
        copy r7
        load r7   //MSBs
        copy r6
        load r7 1 //LSBs

        //store bytes
        store r5 1
        copy r0 r6
        store r5 

        pop

    imm r0 2

    //increment write index
    add r5 r0
    copy r5

    //increment right index
    imm r0 2
    add r3 r0
    copy r3
    cmp r3 r6
    jumplt #right-unfinished-loop

    jump #copy-back 

    #left-unfinished-loop
        push r6+
        
        //load bytes
        add r2 r7 //left index + left array start
        copy r7
        load r7   //MSBs
        copy r6
        load r7 1 //LSBs

        //store bytes
        store r5 1
        copy r0 r6
        store r5 

        pop

    imm r0 2

    //increment write index
    add r5 r0
    copy r5

    //increment left index
    imm r0 2
    add r2 r0
    copy r2
    cmp r2 r6
    jumplt #left-unfinished-loop

    #copy-back

    push r2+
    //use r7 as the loop counter
    lshift r6 1
    add r0 r7
    copy r6

    //temporary array offset is 32 elements
    imm r0 4
    lshift r0 4
    copy r1

    #copy-back-loop
        //calculate temporary array address
        add r7 r1
        copy r2

        load r2 1  //load LSBs
        copy r5
        load r2    //load MSBs

        store r7   //store MSBs
        copy r0 r5
        store r7 1 //store LSBs

    imm r0 2
    add r7 r0
    copy r7
    cmp r7 r6
    jumplt #copy-back-loop

    pop

    lshift r6 1
    copy r1    //new array size in r1
    copy r0 r7 //start index in r0

    return

//for msb cases, upper byte is stored in r6 or r7
#smaller-left-msb
    //pass up upper left
    copy r1 r6
    pop //pop frame pushed at the start of loop body

    push r2+

    //calculate write position

    //write upper byte
    copy r0 r1
    store r5

    //pass up write position
    copy r1 r5
    pop

    //load lower byte
    add r2 r7 //left index + left array start
    load r0 1

    //write lower byte
    store r1 1

    //increment left index
    imm r0 2
    add r0 r2
    copy r2
    jump #merge-body-end

#smaller-right-msb
    //pass up upper right
    copy r1 r7
    pop

    push r2+

    //write upper byte
    copy r0 r1
    store r5

    //pass up write position
    copy r1 r5
    pop

    //load lower byte
    add r3 r4 //right index + right array start
    load r0 1

    //write lower byte
    store r1 1

    //increment right index
    imm r0 2
    add r0 r3
    copy r3
    jump #merge-body-end

//for lsb cases, lower byte is stored in r0 and r1
#smaller-left-lsb
    push r2+

    //save lower left
    copy r6

    //write lower byte
    copy r0 r6
    store r5 1

    //pass up write position
    copy r1 r5
    pop

    //load upper byte
    add r2 r7 //left index + left array start
    load r0

    //write upper byte
    store r1

    //increment left index
    imm r0 2
    add r0 r2
    copy r2
    jump #merge-body-end

#smaller-right-lsb
    push r2+

    //save lower right
    copy r6 r1
    
    //write lower byte
    copy r0 r6
    store r5 1

    //pass up write position
    copy r1 r5
    pop

    //load upper byte
    add r3 r4 //right index + right array start
    load r0

    //write upper byte
    store r1

    //increment right index
    imm r0 2
    add r0 r3
    copy r3
    jump #merge-body-end

#end-2
halt

//main function 3
#program-3-multiply
    //initialize loop counter in r7
    xor r0
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
        
        load r7        //load MSB 1
        copy r1

        load r7 2      //load MSB 2
        xor r1
        rshift r0 4
        rshift r0 3
        copy r5        //save sign bit of result

        //negate multplier if needed
        load r7 1
        copy r2
        copy r0 r1

        //check sign
        jumppos #store-multiplier //skip negation if positive

        //negate
        not r1
        copy r1
        not r2
        copy r2

        imm r0 1
        add r2 r0
        copy r2

        xor r0
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
        jumppos #store-multiplicand //if sign bit < 1, is positive

        //negate
        not r1
        copy r1
        not r2
        copy r2

        imm r0 1
        add r2 r0
        copy r2

        xor r0
        addc r1
        copy r1

        #store-multiplicand

        //store multiplicand to mem[2-3]
        copy r0 r2
        store r6 3
        copy r0 r1
        store r6 2

        //call multiplication
        push r5+
        call #multiply-32
        pop

        copy r0 r5
        jumpz #positive-result //skip negation step if result is positive
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
            xor r0
            addc r7 //r7 + 0 + carry
            store r6 2
            
            //next smallest byte and propagate carry
            load r6 1
            not r0
            copy r7
            xor r0
            addc r7 //r7 + 0 + carry
            store r6 1

            //negate msb
            load r6
            not r0
            copy r7
            xor r0
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
    xor r0
    copy r2
    copy r3
    copy r4
    copy r5
    
    //initialize constants
    xor r0
    copy r6       // r6 = 0 (memory pointer and loop comparison)
    imm r7 1      // r7 = 1 (decrement and bit masking)
    
    //initialize loop counter in r1 to 16
    imm r1 4
    lshift r1 2
    copy r1

    #multiply-loop
        
        //shift product left by 1
        lshift r5 1       //r0 = r5 << 1 and MSB sets carry flag
        copy r5
        lshiftc r4        //r0 = (r4 << 1) | carry
        copy r4
        lshiftc r3        //r0 = (r3 << 1) | carry
        copy r3
        lshiftc r2        //r0 = (r2 << 1) | carry
        copy r2

        //load multiplier from memory
        load r6

        jumppos #skip-add //skip addition if MSB is 0
            
            //add LSBs
            load r6 3     //r0 = mem[3] (multiplicand MSB)
            add r5 r0     //r0 = r5 + r0 and set carry
            copy r5

            //add MSBs
            load r6 2     //r0 = mem[2]
            addc r4       //r0 = r0 + r4 + carry
            copy r4

            // propagate carry
            xor r0       //r0 = 0
            addc r3       //r0 = r0 + r3 + carry
            copy r3

            xor r0       //r0 = 0
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
    jumpnz #multiply-loop

    //copy product back into memory
    copy r0 r2    //move product byte 0 to r0
    store r6      //mem[0] = product MSB
    
    copy r0 r3
    store r6 1    //mem[1] = product byte 1
    
    copy r0 r4
    store r6 2    //mem[2] = product byte 2
    
    copy r0 r5
    store r6 3    //mem[3] = product LSB

    return

#end-3
halt
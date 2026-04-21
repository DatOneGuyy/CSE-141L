//main function 1
#program-1-hamming
    //initialize minimum of 16 at mem[64]
    //store 32 in r2 and r7
    imm r1 1
    lshift r1 3
    lshift r0 2
    copy r2
    copy r7

    //store 16 in r0
    lshift r1 4
    store r2 lower //store with mask 10

    //set max - 1 at 31 in r5
    imm r0 -1
    add r0 r2
    copy r5

    //store increment in r6
    imm r6 1

    //first item loop index => r3
    //second item loop index => r4

    #outer-loop-start
        add r3 r6 //initialize r4 to r3 + 1
        copy r4

        #inner-loop-start
            //nested loop body

            //address of first: r3
            copy r1 r3

            //address of second: r4
            copy r2 r4

            stack push r4+
            call #dist-from-mem
            stack pop

        pause

        add r4 r6 //increment inner loop
        copy r4
        cmp r4 r7 //compare and jump
        jumplt #inner-loop-start

    add r3 r6 //increment outer loop
    copy r3
    cmp r3 r5 //compare and jump
    jumplt #outer-loop-start

    jump #end

//(r1, r2) => r0
//modifies r0, r1, r2, r6, r7
#dist-from-mem
    //load half-words
    load r1      //load from address in r1
    copy r1      //move loaded value to r3
    load r2      //load from address in r2

    //find distances
    dist r1 r0   //store distance in r7
    copy r7

    //store 32 in r0 and r6
    imm r1 1
    lshift r1 3
    lshift r0 2
    copy r6

    //compare minimum to replace
    load r0 lower
    cmp r0 r7 //skip if min < current
    jumplt #skip-minimum
        copy r0 r7
        store r6 lower
    #skip-minimum

    //compare maximum to replace
    load r6 upper //get upper bits at 32 (65)
    //shift right by 8 for comparison
    rshift r0 4
    rshift r0 4
    cmp r7 r0 //skip if current < max
    jumplt #skip-maximum
        lshift r7 4
        lshift r0 4
        store r6 upper
    #skip-maximum

    return

#end
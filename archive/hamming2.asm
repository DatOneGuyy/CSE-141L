//main function 1
#program-1-hamming
    //initialize minimum of 16 at mem[64]
    //store 64 in r2
    imm r1 1
    lshift r1 4
    lshift r0 2
    copy r2

    //store 16 in r0
    lshift r1 4
    store r2

    //store 32 (max) in r7 and 31 (max - 1) in r5
    rshift r2 1
    copy r7

    imm r0 -1
    add r0 r7
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

            //calculate addresses from indices
            lshift r3 1
            copy r1
            lshift r4 1
            copy r2

            //function call
            push r4+ //save registers r4-r7
            call #calculate-distance
            pop

        //pause (only for debugging with interpreter/simulator)

        add r4 r6 //increment inner loop
        copy r4
        cmp r4 r7
        jumplt #inner-loop-start

    add r3 r6 //increment outer loop
    copy r3
    cmp r3 r5
    jumplt #outer-loop-start

    jump #end

//calculates distances and whether they are the maximum or minimum. if they are a max or min, stores the new distance in memory
// args (r1: address1, r2: address2) => none
//modifies r0, r1, r5, r7
#calculate-distance
    //load lower bytes
    load r1
    copy r7
    load r2

    //find lower distance
    dist r7
    copy r7

    //load upper bytes using offset
    load r1 1
    copy r1
    load r2 1
    
    //find upper distance and combine
    dist r1
    add r0 r7
    copy r7 //store total dist in r7

    //load from address 64
    lshift r6 4
    lshift r0 2
    copy r5 //store 64 in r5
    load r5
    cmp r0 r7 //skip if min < current
    jumplt #skip-minimum
        copy r0 r7
        store r5
    #skip-minimum

    //load from address 65
    load r5 1
    cmp r7 r0 //skip if current < max
    jumplt #skip-maximum
        copy r0 r7
        store r5 1
    #skip-maximum

    return

#end

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
    dist r0
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
    dist r4
    copy r5

    //load LSBs
    load r2 1
    copy r4
    load r3 1

    //calculate distance
    dist r4
    add r0 r5

    return

#end-1
halt
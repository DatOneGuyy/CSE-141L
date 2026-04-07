//main function 3
#program-3-multiply

    jump #end

//multiplies two 8-bit numbers
//args: (r6: a, r7: b) => (r0: a * b)
#mult8x8

    //r5 accumulator
    dist r0
    copy r5
    
    //right bit initialized to zero
    copy r1 

    //r2 loop counter
    copy r2

    //loop limit in r3
    imm r0 2
    lshift r0 2
    copy r3

    //increment in r4
    imm r4 1

    //booth's algorithm:
    //bits in r1
    //left bit == right bit   => shift
    //left bit 1, right bit 0 => subtract then shift
    //left bit 0, right bit 1 => add then shift

    #accumulation-loop
        //accumulation loop body
        push r2+

        //store bits in r5
        //update left bit
        imm r0 1
        and r7
        lshift 1  //move to position then add
        add r0 r1
        copy r1   //restore in r1

        //compare left and right bits
        //if both are the same, only shift
        push r1+
        
        //put left bit in r5
        imm r0 1
        lshift r0 1
        and r1      
        copy r5

        //put right bit in r0
        imm r0 1
        and r1

        //if both bits are the same, dist = 0
        dist r5

        imm r5 1
        cmp r0 r1
        pop //restore r5 to accumulator, r1 still holds left/right bits
        jumplt #shift

        #shift
        //left bit moves into right bit
        rshift r1 1
        copy r1

        //shift accumulator LSB into multiplier MSB
        //shift multiplier
        lshift r7 1
        copy r7

        //extract accumulator LSB
        imm r0 1
        and r5
        
        //replace multiplier MSB
        or r7
        copy r7

        //shift accumulator and sign extend
        //get accumulator sign
        imm r0 4
        lshift r0 4
        lshift r0 1
        or r5

        

        lshift r5 1
        copy r5

    //increment
    add r2 r4
    copy r2
    cmp r2 r3
    jumplt #accumulation-loop

#end
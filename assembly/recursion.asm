#recursion-test
    //case 0
    xor r0
    copy r2
    copy r3
    push r6+
    call #add
    pop

    xor r0
    copy r7
    copy r0 r3
    store r7

    //case 1
    imm r2 1
    xor r0
    copy r3
    push r6+
    call #add
    pop

    imm r1 1
    add r7 r1
    copy r7
    copy r0 r3
    store r7

    //case 2
    imm r2 2
    xor r0
    copy r3
    push r6+
    call #add
    pop

    imm r1 1
    add r7 r1
    copy r7
    copy r0 r3
    store r7

    //case 3
    imm r2 3
    xor r0
    copy r3
    push r6+
    call #add
    pop

    imm r1 1
    add r7 r1
    copy r7
    copy r0 r3
    store r7

    //case 4
    imm r2 4
    xor r0
    copy r3
    push r6+
    call #add
    pop

    imm r1 1
    add r7 r1
    copy r7
    copy r0 r3
    store r7

    //case 5
    imm r2 5
    xor r0
    copy r3
    push r6+
    call #add
    pop

    imm r1 1
    add r7 r1
    copy r7
    copy r0 r3
    store r7

    //case 6
    imm r2 6
    xor r0
    copy r3
    push r6+
    call #add
    pop

    imm r1 1
    add r7 r1
    copy r7
    copy r0 r3
    store r7

    //case 7
    imm r2 4
    imm r3 3
    add r2 r3
    copy r2
    xor r0
    copy r3
    push r6+
    call #add
    pop

    imm r1 1
    add r7 r1
    copy r7
    copy r0 r3
    store r7

    halt

#add //pass in argument in r2, return in r3
    add r2 r3
    copy r3

    imm r0 1
    cmp r2 r0
    jumplt #return-point

    imm r7 -1
    add r2 r7
    copy r2

    push r6+
    call #add
    pop

    #return-point

    return

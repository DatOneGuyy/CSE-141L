#stack-test
    imm r1 1
    imm r2 2
    imm r3 3
    imm r4 4
    imm r5 5
    imm r6 6
    imm r7 -1
    xor r0

    push r4+

    imm r4 1
    imm r5 1
    imm r6 1
    imm r7 1

    pop

    imm r4 2
    imm r5 2

    halt
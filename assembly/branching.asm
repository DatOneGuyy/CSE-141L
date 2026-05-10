// ===============================================
// CPU BRANCH INSTRUCTION VALIDATION SUITE
// Tests: jump, jumpz, jumpnz, jumplt, jumplts, jumpgt, jumpgts, jumppos
// Expected Output: mem[0] to mem[7] should all be 0x01 (Success)
// ===============================================

#hardware-test-start
    // Initialize Memory Pointer to 0
    xor r0        
    copy r7       // r7 = 0

// -----------------------------------------------
// TEST 1: jump (Unconditional)
// -----------------------------------------------
#test1-jump
    jump #t1-pass
    
#t1-fail
    xor r0        // r0 = 0
    store r7      // mem[0] = 0
    jump #test2-jumpz
    
#t1-pass
    imm r1 1
    copy r0 r1
    store r7      // mem[0] = 1
    jump #test2-jumpz

// -----------------------------------------------
// TEST 2: jumpz (Jump if Zero)
// -----------------------------------------------
#test2-jumpz
    // True Case (5 - 5 = 0)
    xor r0
    jumpz #t2-false-case
    jump #t2-fail
    
#t2-false-case
    // False Case (5 - 3 = 2)
    imm r2 3
    copy r0 r2
    jumpz #t2-fail-z
    
#t2-pass
    imm r1 1
    copy r0 r1
    store r7 1    // mem[1] = 1
    jump #test3-jumpnz
    
#t2-fail
#t2-fail-z
    xor r0
    store r7 1
    jump #test3-jumpnz

// -----------------------------------------------
// TEST 3: jumpnz (Jump if Not Zero)
// -----------------------------------------------
#test3-jumpnz
    // True Case (5 - 3 = 2)
    imm r1 5
    imm r2 3
    cmp r1 r2
    jumpnz #t3-false-case
    jump #t3-fail
    
#t3-false-case
    // False Case (5 - 5 = 0)
    cmp r1 r1
    jumpnz #t3-fail-nz
    
#t3-pass
    imm r1 1
    copy r0 r1
    store r7 2    // mem[2] = 1
    jump #test4-jumplt
    
#t3-fail
#t3-fail-nz
    xor r0
    store r7 2
    jump #test4-jumplt

// -----------------------------------------------
// TEST 4: jumplt (Unsigned Less Than)
// -----------------------------------------------
#test4-jumplt
    // True Case (3 < 5)
    imm r1 3
    imm r2 5
    cmp r1 r2
    jumplt #t4-false-case
    jump #t4-fail
    
#t4-false-case
    // False Case A: (5 < 3)
    cmp r2 r1
    jumplt #t4-fail-lt
    // False Case B: (5 < 5) Ensures Z=1 doesn't trigger it!
    cmp r2 r2
    jumplt #t4-fail-lt
    
#t4-pass
    imm r1 1
    copy r0 r1
    store r7 3    // mem[3] = 1
    jump #advance-ptr
    
#t4-fail
#t4-fail-lt
    xor r0
    store r7 3
    jump #advance-ptr

// -----------------------------------------------
// Advance Memory Pointer
// -----------------------------------------------
#advance-ptr
    imm r6 4
    add r7 r6
    copy r7       // r7 is now 4
    jump #test5-jumpgt

// -----------------------------------------------
// TEST 5: jumpgt (Unsigned Greater Than)
// -----------------------------------------------
#test5-jumpgt
    // True Case (5 > 3)
    imm r1 5
    imm r2 3
    cmp r1 r2
    jumpgt #t5-false-case
    jump #t5-fail
    
#t5-false-case
    // False Case A: (3 > 5)
    cmp r2 r1
    jumpgt #t5-fail-gt
    // False Case B: (5 > 5) Ensures Z=1 prevents the jump!
    cmp r1 r1
    jumpgt #t5-fail-gt
    
#t5-pass
    imm r1 1
    copy r0 r1
    store r7      // mem[4] = 1
    jump #test6-jumplts
    
#t5-fail
#t5-fail-gt
    xor r0
    store r7
    jump #test6-jumplts

// -----------------------------------------------
// TEST 6: jumplts (Signed Less Than)
// -----------------------------------------------
#test6-jumplts
    // True Case: -1 < 3. 
    imm r1 -1
    imm r2 3
    cmp r1 r2
    jumplts #t6-false-case
    jump #t6-fail
    
#t6-false-case
    // False Case A: (3 < -1)
    cmp r2 r1
    jumplts #t6-fail-lts
    // False Case B: (-1 < -1)
    cmp r1 r1
    jumplts #t6-fail-lts
    
#t6-pass
    imm r1 1
    copy r0 r1
    store r7 1    // mem[5] = 1
    jump #test7-jumpgts
    
#t6-fail
#t6-fail-lts
    xor r0
    store r7 1
    jump #test7-jumpgts

// -----------------------------------------------
// TEST 7: jumpgts (Signed Greater Than)
// -----------------------------------------------
#test7-jumpgts
    // True Case: 3 > -1
    imm r1 3
    imm r2 -1
    cmp r1 r2
    jumpgts #t7-false-case
    jump #t7-fail
    
#t7-false-case
    // False Case A: (-1 > 3)
    cmp r2 r1
    jumpgts #t7-fail-gts
    // False Case B: (3 > 3) Ensures Z=1 prevents the jump!
    cmp r1 r1
    jumpgts #t7-fail-gts
    
#t7-pass
    imm r1 1
    copy r0 r1
    store r7 2    // mem[6] = 1
    jump #test8-jumppos
    
#t7-fail
#t7-fail-gts
    xor r0
    store r7 2
    jump #test8-jumppos

// -----------------------------------------------
// TEST 8: jumppos (Jump if Positive)
// -----------------------------------------------
#test8-jumppos
    // True Case (Positive Number -> MSB = 0)
    imm r1 5
    xor r0        // r0 = 0
    add r0 r1     // ALU puts 5 in r0, updates Negative Flag
    jumppos #t8-false-case
    jump #t8-fail
    
#t8-false-case
    // False Case (Negative Number -> MSB = 1)
    imm r2 -1
    xor r0
    add r0 r2     // ALU puts -1 (0xFF) in r0, updates Negative Flag
    jumppos #t8-fail-pos
    
#t8-pass
    imm r1 1
    copy r0 r1
    store r7 3    // mem[7] = 1
    jump #end
    
#t8-fail
#t8-fail-pos
    xor r0
    store r7 3
    jump #end

#end
    halt
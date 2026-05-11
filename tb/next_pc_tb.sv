module next_pc_tb;

logic [9:0] current_pc;
logic [6:0] flags;
logic [17:0] jump_target;
logic [9:0] top_address;
logic pc_write_en;

logic [9:0] new_pc;

next_pc dut (
    .current_pc(current_pc),
    .flags(flags),
    .jump_target(jump_target),
    .top_address(top_address),
    .pc_write_en(pc_write_en),
    .new_pc(new_pc)
);

initial begin
    $dumpfile("next_pc_dump.vcd");
    $dumpvars(0, tb_next_pc);

    //initialize
    current_pc  = 10'd100;
    flags       = 7'b0;
    jump_target = 18'b0;
    top_address = 10'h3FF;
    pc_write_en = 1'b0;

    #10;
    $display("--- Starting next_pc Tests ---");

    // ---------------------------------------------------------
    // Test 1: Standard PC Increment (pc_write_en = 0)
    // Expected: new_pc = current_pc + 1 (101)
    // ---------------------------------------------------------
    pc_write_en = 1'b0;
    #10;
    $display("T1 - Standard Increment: current_pc=%d, new_pc=%d (Expected: 101)", current_pc, new_pc);

    // ---------------------------------------------------------
    // Test 2: Unconditional Jump
    // Expected: new_pc = jump_address (0x0AA)
    // ---------------------------------------------------------
    // one_hot_code[7] maps to jump_target[15]. extended_flags[7] is hardcoded to 1'b1.
    // jump_address maps to {jump_target[8:0], jump_target[17]}
    pc_write_en = 1'b1;
    jump_target = 18'b0;
    jump_target[15] = 1'b1;   // Trigger one_hot_code[7]
    jump_target[8:0] = 9'h055; 
    jump_target[17]  = 1'b0;  // jump_address = {9'h055, 1'b0} = 10'h0AA (170)
    #10;
    $display("T2 - Unconditional Jump: new_pc=%d (Expected: 170)", new_pc);

    // ---------------------------------------------------------
    // Test 3: Conditional Branch (Less Than Unsigned - ltu)
    // Expected: new_pc = jump_address (0x0CC)
    // ---------------------------------------------------------
    // ltu is jump_target[11] & ~jump_target[9]. It maps to one_hot_code[3].
    // This requires extended_flags[3] (flags[3]) to be 1.
    jump_target = 18'b0;
    jump_target[11] = 1'b1;
    jump_target[9]  = 1'b0;
    jump_target[8:0] = 9'h066;
    jump_target[17]  = 1'b0;  // jump_address = {9'h066, 1'b0} = 10'h0CC (204)
    
    flags[3] = 1'b1;          // Set the required flag condition
    #10;
    $display("T3 - Conditional Branch (ltu=1, flag=1): new_pc=%d (Expected: 204)", new_pc);

    // ---------------------------------------------------------
    // Test 4: Conditional Branch Failed (Condition not met)
    // Expected: new_pc = current_pc + 1 (101)
    // ---------------------------------------------------------
    flags[3] = 1'b0;          // Clear the flag
    #10;
    $display("T4 - Conditional Branch (ltu=1, flag=0): new_pc=%d (Expected: 101)", new_pc);

    // ---------------------------------------------------------
    // Test 5: Stack Return / Pop
    // Expected: new_pc = top_address (1023 / 0x3FF)
    // ---------------------------------------------------------
    // one_hot_code[8] maps to jump_target[16]
    jump_target = 18'b0;
    jump_target[16] = 1'b1;
    #10;
    $display("T5 - Stack Return: new_pc=%d (Expected: 1023)", new_pc);

    // ---------------------------------------------------------
    // Test 6: pc_write_en override
    // Expected: new_pc = current_pc + 1 (101) despite jump_target calling for return
    // ---------------------------------------------------------
    pc_write_en = 1'b0;
    #10;
    $display("T6 - pc_write_en=0 with branch pending: new_pc=%d (Expected: 101)", new_pc);

    $display("--- Tests Complete ---");
    $finish;
end

endmodule
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

task test_branch(input string test_name, input int flag_idx, input logic [17:0] target_cmd);
    begin
        $display("--- Testing %s ---", test_name);
        jump_target = target_cmd;
        
        // 1. Test FALSE Condition (Flag is 0)
        flags = 7'b0;
        #10;
        if (new_pc === (current_pc + 10'b1))
            $display("PASS: %s (False) correctly fell through to PC+1: %3h", test_name, new_pc);
        else
            $error("FAIL: %s (False). Expected %3h, got %3h", test_name, (current_pc + 1), new_pc);
        
        // 2. Test TRUE Condition (Flag is 1)
        flags = (7'b1 << flag_idx);
        #10;
        // Expected target: 10'h2AA (Jump Address)
        if (new_pc === 10'h2AA)
            $display("PASS: %s (True) correctly jumped to target: %3h", test_name, new_pc);
        else
            $error("FAIL: %s (True). Expected 2AA, got %3h", test_name, new_pc);
            
        $display("");
    end
endtask

initial begin
    // Output configuration specified by requirements
    $dumpfile("../dump/next_pc_dump.vcd");
    $dumpvars(0, tb_next_pc);

    $display("starting next_pc validation");

    // Initialize default state
    current_pc = 10'h100;
    flags = 7'b0;
    top_address = 10'h0FA; // Example stack return address
    
    // Construct standard jump_address: 10'h2AA (10_1010_1010)
    // jump_address = {jump_target[8:0], jump_target[17]}
    // jump_target[17] = 0
    // jump_target[8:0] = 9'h155 (1_0101_0101)
    // Base payload = 18'h00155

    // Disabled write
    pc_write_en = 1'b0;
    jump_target = 18'h08155; // Unconditional jump command
    #10;
    $display("--- Testing PC Write Disable ---");
    if (new_pc === 10'h101) $display("PASS: new_pc incremented normally while disabled.");
    else $error("FAIL: Jump executed while pc_write_en was 0.");
    $display("");

    // Enable pc writing for the remaining tests
    pc_write_en = 1'b1;

    // Return
    // Set bit 16 for top_address mapping
    jump_target = 18'h00155 | (1 << 16); 
    #10;
    $display("--- Testing Return / Pop ---");
    if (new_pc === top_address) $display("PASS: Returned to top_address successfully: %3h", new_pc);
    else $error("FAIL: Did not return to top_address.");
    $display("");

    // Unconditional
    // Set bit 15. Maps to extended_flags[7] which is always 1.
    jump_target = 18'h00155 | (1 << 15); 
    #10;
    $display("--- Testing Unconditional Jump ---");
    if (new_pc === 10'h2AA) $display("PASS: Unconditional Jump executed successfully: %3h", new_pc);
    else $error("FAIL: Unconditional jump missed.");
    $display("");

    // Index 0: gts -> jump_target[10]=1, [9]=1
    test_branch("gts (Idx 0)", 0, (18'h00155 | (1<<10) | (1<<9)));
    
    // Index 1: lts -> jump_target[11]=1, [9]=1
    test_branch("lts (Idx 1)", 1, (18'h00155 | (1<<11) | (1<<9)));
    
    // Index 2: gtu -> jump_target[10]=1, [9]=0
    test_branch("gtu (Idx 2)", 2, (18'h00155 | (1<<10)));
    
    // Index 3: ltu -> jump_target[11]=1, [9]=0
    test_branch("ltu (Idx 3)", 3, (18'h00155 | (1<<11)));

    // Index 4: jump_target[12]
    test_branch("Flag 4", 4, (18'h00155 | (1<<12)));

    // Index 5: jump_target[13]
    test_branch("Flag 5", 5, (18'h00155 | (1<<13)));

    // Index 6: jump_target[14]
    test_branch("Flag 6", 6, (18'h00155 | (1<<14)));

    $display("============================================");
    $display("   next_pc Module Validation Suite Finish   ");
    $display("============================================");

    $finish;
end

endmodule
module branching_tb;

bit clk;
logic start;
logic done;
top dut(.*);

function void display_info();
    $display("State at start of cycle:");
    $display("PC: %d", dut.pc);
    $display("Instruction: %b", dut.instruction);
    $display("Registers: [%d, %d, %d, %d, %d, %d, %d, %d]", dut.register_file_inst.registers[0], dut.register_file_inst.registers[1], dut.register_file_inst.registers[2], dut.register_file_inst.registers[3], dut.register_file_inst.registers[4], dut.register_file_inst.registers[5], dut.register_file_inst.registers[6], dut.register_file_inst.registers[7]);
    $display("Memory contents: [%d, %d, %d, %d, %d, %d, %d, %d, %d, %d]", dut.data_memory_inst.core[0], dut.data_memory_inst.core[1], dut.data_memory_inst.core[2], dut.data_memory_inst.core[3], dut.data_memory_inst.core[4], dut.data_memory_inst.core[5], dut.data_memory_inst.core[6], dut.data_memory_inst.core[7], dut.data_memory_inst.core[8], dut.data_memory_inst.core[9], );
    $display();
endfunction

task automatic advance_clk();
    #5 clk = ~clk;
    #5 clk = ~clk;
endtask

logic [12:0] count = 0;
logic debug_pause = 0;

initial begin
    $readmemb("../rtl/programs/branching.bin", dut.instruction_memory_inst.mem);
end

logic [7:0] branch_results;
assign branch_results = {dut.data_memory_inst.core[0] == 8'b1, dut.data_memory_inst.core[1] == 8'b1, dut.data_memory_inst.core[2] == 8'b1, dut.data_memory_inst.core[3] == 8'b1, dut.data_memory_inst.core[4] == 8'b1, dut.data_memory_inst.core[5] == 8'b1, dut.data_memory_inst.core[6] == 8'b1, dut.data_memory_inst.core[7] == 8'b1};

initial begin 
    $dumpfile("../dump/top_dump.vcd");
    $dumpvars(0, top_tb);

    $display("Starting top-level testbench");
    start = 1'b1;
    advance_clk();

    #10 clk = ~clk;
    $display("Instruction number: %d", count++);
    display_info();

    forever begin
        advance_clk();

        if (count == 77 & debug_pause) begin
            $display("inspection: %b %b", dut.next_pc_inst.extended_flags, dut.next_pc_inst.one_hot_code);
        end

        $display("Instruction number: %d", count++);
        display_info();

        if (done) begin
            $display("Finished program");
            if (&branch_results) $display("Passed all branching tests");
            else $display("Failed branching tests. Results: %b", branch_results);
            $finish;
        end
    end
end

endmodule
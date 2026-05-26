module arithmetic_tb;

bit clk;
logic start;
logic done;
DUT dut(.*);

function void display_info();
    $display("State at start of cycle:");
    $display("PC: %d", dut.pc);
    $display("Instruction: %b", dut.instruction);
    $display("Registers: [%d, %d, %d, %d, %d, %d, %d, %d]", dut.register_file_inst.registers[0], dut.register_file_inst.registers[1], dut.register_file_inst.registers[2], dut.register_file_inst.registers[3], dut.register_file_inst.registers[4], dut.register_file_inst.registers[5], dut.register_file_inst.registers[6], dut.register_file_inst.registers[7]);
    $display("Memory contents: [%d, %d, %d, %d, %d, %d, %d, %d, %d, %d]", dut.dm.core[0], dut.dm.core[1], dut.dm.core[2], dut.dm.core[3], dut.dm.core[4], dut.dm.core[5], dut.dm.core[6], dut.dm.core[7], dut.dm.core[8], dut.dm.core[9], );
    $display();
endfunction

task automatic advance_clk();
    #5 clk = ~clk;
    #5 clk = ~clk;
endtask

logic [12:0] count = 0;
logic debug_pause = 0;

initial begin
    $readmemb("../rtl/programs/arithmetic.bin", dut.instruction_memory_inst.mem);
end

logic [9:0] arithmetic_results;
assign arithmetic_results = {dut.dm.core[0] == 8'd5, dut.dm.core[1] == 8'd3, dut.dm.core[2] == 8'd5, dut.dm.core[3] == 8'd2, dut.dm.core[4] == 8'd8, dut.dm.core[5] == 8'd2, dut.dm.core[6] == 8'd255, dut.dm.core[7] == 8'd4, dut.dm.core[8] == 8'd2, dut.dm.core[9] == 8'd1};

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

            if (&arithmetic_results) $display("Passed all arithmetic tests");
            else $display("Failed arithmetic tests. Results: %b", arithmetic_results);
            $finish;
        end
    end
end

endmodule
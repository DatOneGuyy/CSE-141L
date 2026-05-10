module top_tb;

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
logic debug_pause = 1;

initial begin 
    $dumpfile("../dump/top_dump.vcd");
    $dumpvars(0, top_tb);

    $display("Starting top-level testbench");
    start = 1'b1;
    advance_clk();

    #10 clk = ~clk;
    $display("Instruction number: %d", count++);
    display_info();

    repeat (16) begin
        advance_clk();

        if (count == 2 & debug_pause) begin
            $display("inspection: %b %b %b", dut.next_pc_inst.one_hot_code, dut.next_pc_inst.extended_flags, dut.next_pc_inst.jump_target);
        end

        $display("Instruction number: %d", count++);
        display_info();

        if (done) begin
            $display("Finished program");
            $finish;
        end
    end

    $finish;
end

endmodule
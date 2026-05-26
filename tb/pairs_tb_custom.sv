module stack_tb;

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
endfunction

function void display_stack();
    $display("Stack: [%d, %d, %d, %d, %d, %d], pc: %d, empty: %d, pointer: %d", dut.stack_inst.stack[0].r2, dut.stack_inst.stack[0].r3, dut.stack_inst.stack[0].r4, dut.stack_inst.stack[0].r5, dut.stack_inst.stack[0].r6, dut.stack_inst.stack[0].r7, dut.stack_inst.stack[0].pc, dut.stack_inst.empty, dut.stack_inst.pointer);
endfunction

task automatic advance_clk();
    #5 clk = ~clk;
    #5 clk = ~clk;
endtask

initial begin
    $readmemb("../rtl/programs/hamming.bin", dut.instruction_memory_inst.mem);
    $readmemb("../test_files/test9.txt",dut.dm.core);
end

logic [7:0] branch_results;
assign branch_results = {dut.dm.core[0] == 8'b1, dut.dm.core[1] == 8'b1, dut.dm.core[2] == 8'b1, dut.dm.core[3] == 8'b1, dut.dm.core[4] == 8'b1, dut.dm.core[5] == 8'b1, dut.dm.core[6] == 8'b1, dut.dm.core[7] == 8'b1};

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

    forever begin
        advance_clk();

        if (debug_pause) begin
            $display("top-level inspection: is_stack_op: %b, current_state: %d, new_state: %d, register_write_data: %d, mem_write_en: %b, mem_out: %d, alu_out: %d", dut.is_stack_op, dut.current_state, dut.new_state, dut.register_write_data, dut.mem_write_en, dut.mem_out, dut.alu_out);
            $display("controller inspection: start_stack: %b, opcode: %b, mask: %b, op_type: %b, stack_state: %d", dut.start_stack, dut.stack_opcode, dut.stack_controller_mask, dut.stack_controller_inst.op_type, dut.stack_controller_inst.state);
            $display("stack inspection: [r1, r2]: [%d, %d], empty: %b", dut.stack_inst.r1, dut.stack_inst.r2, dut.stack_inst.empty);
        end

        $display("Instruction number: %d", count++);
        display_info();
        display_stack();
        $display();

        if (done) begin
            $display("Finished program");
            $display("Memory contents: Min: %d, Max: %d", dut.dm.core[64], dut.dm.core[65]);
            $finish;
        end
    end
end

endmodule
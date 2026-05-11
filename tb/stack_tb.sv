module stack_tb;

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
endfunction

function void display_stack();
    $display("Stack: [%d, %d, %d, %d, %d, %d], pc: %d, empty: %d, pointer: %d", dut.stack_inst.stack[0].r2, dut.stack_inst.stack[0].r3, dut.stack_inst.stack[0].r4, dut.stack_inst.stack[0].r5, dut.stack_inst.stack[0].r6, dut.stack_inst.stack[0].r7, dut.stack_inst.stack[0].pc, dut.stack_inst.empty, dut.stack_inst.pointer);
endfunction

task automatic advance_clk();
    #5 clk = ~clk;
    #5 clk = ~clk;
endtask

initial begin
    $readmemb("../rtl/programs/stack.bin", dut.instruction_memory_inst.mem);
end

logic [7:0] branch_results;
assign branch_results = {dut.data_memory_inst.core[0] == 8'b1, dut.data_memory_inst.core[1] == 8'b1, dut.data_memory_inst.core[2] == 8'b1, dut.data_memory_inst.core[3] == 8'b1, dut.data_memory_inst.core[4] == 8'b1, dut.data_memory_inst.core[5] == 8'b1, dut.data_memory_inst.core[6] == 8'b1, dut.data_memory_inst.core[7] == 8'b1};

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
            $display("top-level inspection: is_stack_op: %b, current_state: %d, new_state: %d, register_write_data: %d", dut.is_stack_op, dut.current_state, dut.new_state, dut.register_write_data);
            $display("controller inspection: start_stack: %b, opcode: %b, mask: %b, op_type: %b, stack_state: %d", dut.start_stack, dut.stack_opcode, dut.stack_controller_mask, dut.stack_controller_inst.op_type, dut.stack_controller_inst.state);
            $display("stack inspection: [r1, r2]: [%d, %d], empty: %b", dut.stack_inst.r1, dut.stack_inst.r2, dut.stack_inst.empty);
        end

        $display("Instruction number: %d", count++);
        display_info();
        display_stack();
        $display();

        if (done) begin
            $display("Finished program");
            $finish;
        end
    end
end

endmodule
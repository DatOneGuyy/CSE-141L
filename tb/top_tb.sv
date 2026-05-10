module top_tb;

bit clk;
logic start;
logic done;
top dut(.*);

function void display_info();
    $display("State at start of cycle:");
    $display("Instruction: %b", dut.instruction);
    $display("Registers: [%d, %d, %d, %d, %d, %d, %d, %d]", dut.register_file_inst.registers[0], dut.register_file_inst.registers[1], dut.register_file_inst.registers[2], dut.register_file_inst.registers[3], dut.register_file_inst.registers[4], dut.register_file_inst.registers[5], dut.register_file_inst.registers[6], dut.register_file_inst.registers[7]);
    $display();
endfunction

initial begin 
    $dumpfile("dump/top_dump.vcd");
    $dumpvars(0, top_tb);

    $display("Starting top-level testbench");
    start = 1'b1;

    #10 clk = ~clk;
    display_info();

    #5 clk = ~clk;
    #5 clk = ~clk;
    display_info();

    #5 clk = ~clk;
    #5 clk = ~clk;
    display_info();

    #5 clk = ~clk;
    #5 clk = ~clk;
    display_info();

    $finish;
end

endmodule
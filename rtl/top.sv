module top(
    input logic clk,
    input logic start,

    output logic done
);

decoder decoder_inst();

instruction_memory imem_inst(
    .clk(clk),
);

endmodule
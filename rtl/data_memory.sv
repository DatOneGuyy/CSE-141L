module data_memory (
    input logic clk,

    //from ALU
    input logic [7:0] address,

    //from register file
    input logic [7:0] data_in,

    //from decoder
    input logic write_en

    output logic [7:0] data_out,
);

logic [7:0] core [0:255];

assign data_out = core[address];

always_ff @(posedge clk) begin
    if (write_en) core[address] <= data_in;
end

endmodule
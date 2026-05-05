module data_memory (
    input logic clk,

    input logic [7:0] address,
    output logic [7:0] data_out,

    input logic [7:0] data_in,
    input logic write_en,
);

logic [7:0] core [0:255];

$initial begin
    core = '{default: 0}
end

assign data_out = core[address];

always_ff @(posedge clk) begin
    if (write_en) core[address] <= data_in;
end

endmodule
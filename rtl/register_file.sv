import types::*;

module register_file(
    input clk,

    input logic [2:0] read1_src,
    input logic [2:0] read2_src,
    output logic [7:0] read1_result,
    output logic [7:0] read2_result

    input logic [7:0] write_data,
    input logic [7:0] write_dest,
    input logic [7:0] write_en,

    output logic [4:0] alu_flags,
    output logic [7:0] flags
);

logic [7:0] registers [0:7];

assign read1_result = registers[read1_src];
assign read2_result = registers[read2_src];

always_ff @(posedge clk) begin
    if (write_en)
        registers[write_dest] <= write_data;
end

always_ff @(posedge clk) begin
    
end

endmodule
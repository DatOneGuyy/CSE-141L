module register_file (
    input logic clk,

    //from decoder
    input logic [2:0] read1_src,
    input logic [2:0] read2_src,
    input logic [7:0] write_dest,
    input logic write_en,

    //to ALU
    output logic [7:0] read1_result,
    output logic [7:0] read2_result

    //from ALU/data memory/stack
    input logic [7:0] write_data,

    //from ALU
    input logic [4:0] alu_flags,
    input logic write_flags_en,
    
    output logic [7:0] flags
);

logic [7:0] registers [0:7];
logic [7:0] flag_registers;

assign read1_result = registers[read1_src];
assign read2_result = registers[read2_src];

assign flags = flag_registers;

always_ff @(posedge clk) begin
    if (write_en) registers[write_dest] <= write_data;
end

//lt, gt, lts, and gts flags written from ALU
always_ff @(posedge clk) begin
    if (write_flags_en) begin
        flags[7] <= alu_flags[4];
        flags[3:0] <= alu_flags[3:0];
    end
end

//z, nz, and pos flags set combinationally
assign flags[6] = ~|(registers[0]);
assign flags[5] = |(registers[0]);
assign flags[4] = registers[0][7];

endmodule
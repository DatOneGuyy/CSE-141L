module register_write_mux (
    input logic [7:0] alu_out,
    input logic [7:0] data_mem_out,
    input logic [7:0] stack_out,

    input logic [1:0] write_src,

    output logic [7:0] mux_out
);

always_comb begin
    unique case (write_src)
        2'b01: mux_out = data_mem_out;
        2'b10: mux_out = stack_out;
        default: mux_out = alu_out;
    endcase
end

endmodule
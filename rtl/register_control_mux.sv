module register_control_mux (
    input logic [2:0] read1_src_decoder,
    input logic [2:0] read2_src_decoder,
    input logic [2:0] write_dest_decoder,
    input logic reg_write_en_decoder,

    input logic [2:0] read1_src_stack,
    input logic [2:0] read2_src_stack,
    input logic [2:0] write_dest_stack,
    input logic reg_write_en_stack,

    input logic is_stack_op,

    output logic [2:0] read1_src,
    output logic [2:0] read2_src,
    output logic [2:0] write_dest,
    output logic reg_write_en
);

always_comb begin
    if (is_stack_op) begin
        read1_src = read1_src_stack;
        read2_src = read2_src_stack;
        write_dest = write_dest_stack;
        reg_write_en = reg_write_en_stack;
    end
    else begin
        read1_src = read1_src_decoder;
        read2_src = read2_src_decoder;
        write_dest = write_dest_decoder;
        reg_write_en = reg_write_en_decoder;
    end
end

endmodule
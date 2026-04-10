module decoder(
    input logic [8:0] instruction,

    output logic [2:0] reg_read1,
    output logic [2:0] reg_read2,
    output logic reg_write_en,

    output logic pc_write_en,
    output logic stack_write_en,

    output logic lt_flag_write_en,
    output logic carry_flag_write_en,

    output logic shift_direction,

    output logic use_immediate,
    output logic [2:0] immediate,

    output logic memory_en,
    output logic memory_rw_type
);

logic [2:0] opcode, field1, field2;
logic [1:0] subfield;
logic read_reg0, write_reg_nonzero;

assign opcode = instruction[8:6];
assign field1 = instruction[5:3];
assign field2 = instruction[2:0];
assign subfield = instruction[1:0];

assign read_reg0 = &(opcode[1:0]);
assign write_reg_nonzero = &(field2) & (~|opcode);

assign reg_read1 = field1;
assign reg_read2 = read_reg0 ? 1'b0 : field2;
assign reg_write = write_reg_nonzero ? field1 : 3'b0;

assign pc_write_en = (opcode == 3'b001);

assign stack_write_en = (~|{opcode, field2}) & field1[2];

assign lt_flag_write_en = (opcode == 3'b100);
assign carry_flag_write_en = (opcode == 3'b011 & subfield[0]) | (opcode == 3'b110);

assign shift_direction = field2[2];

assign use_immediate = (opcode[2] & opcode[0]) | write_reg_nonzero;
assign immediate = {(|field2) ? field2[2] : 1'b0, subfield};

assign memory_en = &(opcode);
assign memory_rw_type = field2[2];

endmodule
module decoder (
    //from instruction memory
    input logic [8:0] instruction

    //to ALU
    output logic [2:0] opcode,
    output logic [2:0] funct,
    output logic [1:0] imm,

    //to data memory
    output logic mem_write_en,

    //to pc
    output logic pc_write_en

    //to register file
    output logic [2:0] read1_src,
    output logic [2:0] read2_src,
    output logic [2:0] write_dest,
    output logic reg_write_en,

    //to stack controller
    output logic stack_controller_op_type,
    output logic [1:0] stack_controller_mask
);

assign opcode = instruction[8:6];
assign funct = instruction[2:0];
assign imm = instruction[2:0];

assign mem_write_en = &(instruction[8:6]);

assign pc_write_en = ~|(instruction[8:6]);

assign read1_src = instruction[5:3];
assign read2_src = (instruction[8] & ~instruction[6]) ? instruction[2:0] : 3'b0; //only read 2nd register for add/cmp
assign write_dest = (instruction[8] ~| instruction[6]) ? instruction[5:3] : 3'b0; //only write to other registers for imm/copy
assign reg_write_en = ~((instruction[8:6] == 3'b100) | ((~|instruction[8:6] | &instruction[8:6]) & ~instruction[2]) | (instruction[8:6] == 3'b001)); //disable register writing for cmp, push, store, jumps

assign stack_controller_op_type = instruction[5];
assign stack_controller_mask = instruction[4:3];

endmodule
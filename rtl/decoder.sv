module decoder (
    //from instruction memory
    input logic [8:0] instruction,

    //to instruction memory
    output logic [5:0] label_address,

    //to ALU
    output logic [2:0] opcode,
    output logic [2:0] funct,
    output logic [2:0] imm,

    //to data memory
    output logic mem_write_en,

    //to pc
    output logic pc_write_en,

    //to register file
    output logic [2:0] read1_src,
    output logic [2:0] read2_src,
    output logic [2:0] write_dest,
    output logic reg_write_en,

    //to stack controller
    output logic stack_controller_op_type,
    output logic [1:0] stack_controller_mask,

    //to register write MUX
    output logic [1:0] write_src,

    //to register control MUX
    output logic is_stack_op
);

assign label_address = instruction[5:0];

assign opcode = instruction[8:6];
assign funct = instruction[2:0];
assign imm = instruction[2:0];

assign mem_write_en = &(instruction[8:6]) & ~instruction[2];

assign pc_write_en = (instruction[8:6] == 3'b001);

assign read1_src = instruction[5:3];
assign read2_src = ((instruction[8] & ~instruction[6]) | (instruction[8:6] == 3'b010)) ? instruction[2:0] : 3'b0; //only read 2nd register for add/cmp/copy
assign write_dest = (~|{instruction[8], instruction[6]}) ? instruction[5:3] : 3'b0; //only write to other registers for imm/copy

logic is_cmp, is_push, is_pop, is_load, is_store, is_jump;
assign is_cmp = (instruction[8:6] == 3'b100);
assign is_push = (~|{instruction[8:5], instruction[2:0]});
assign is_pop = (~|{instruction[8:6], instruction[2:0]}) & instruction[5];
assign is_load = &instruction[8:6] & instruction[2];
assign is_store = &instruction[8:6] & ~instruction[2];
assign is_jump = (instruction[8:6] == 3'b001);

assign is_stack_op = is_push | is_pop;

assign reg_write_en = ~|{is_cmp, is_push, is_store, is_jump}; //disable register writing for cmp, push, store, jumps

assign stack_controller_op_type = instruction[5];
assign stack_controller_mask = instruction[4:3];

always_comb begin
    if (is_load) write_src = 2'b01;
    else if (is_pop) write_src = 2'b10;
    else write_src = 2'b00;
end

endmodule
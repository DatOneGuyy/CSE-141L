module pc_block (
    input logic current_pc [9:0],
    input logic flags [6:0], //carry flag unused in branching so only 7 bits passed
    input logic jump_target [17:0];
    input logic top_address [9:0];
    input logic pc_write_en;

    output logic new_pc [9:0];
);

logic pc_p1 [9:0];
assign pc_p1 = current_pc + 10'b1;

//1 appended for unconditional jumps
logic extended_flags [7:0];
assign extended_flags = {1'b1, flags};

logic unconditional, ret, z, nz, pos, ltu, gtu, lts, gts;

assign unconditional = jump_target[16];
assign ret = jump_target[15];
assign z = jump_target[14];
assign nz = jump_target[13];
assign pos = jump_target[12];
assign ltu = jump_target[11] & ~jump_target[9];
assign gtu = jump_target[10] & ~jump_target[9];
assign lts = jump_target[11] & jump_target[9];
assign gts = jump_target[10] & jump_target[9];

logic one_hot_code [8:0] = {ret, unconditional, z, nz, pos, ltu, gtu, lts, gts};
assign no_jump = ~|one_hot_code;

logic jump_address [9:0];
assign jump_address = {jump_target[17], jump_target[8:0]};

always_comb begin
    new_pc = pc_p1;

    for (int i = 0; i < 9; i++) begin
        unique if (one_hot_code[i]) begin
            if (i < 7 & extended_flags[i]) pc = jump_address;
            else new_pc = top_address;
        end
    end
end

endmodule
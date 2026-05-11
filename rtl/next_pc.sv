module next_pc (
    //from top-level module
    input logic [9:0] current_pc,

    //from register file
    input logic [6:0] flags , //carry flag unused in branching so only 7 bits passed

    //from instruction memory
    input logic [17:0] jump_target,
    
    //from stack
    input logic [9:0] top_address,

    //from decoder
    input logic pc_write_en,

    output logic [9:0] new_pc
);

logic [9:0] pc_p1;
assign pc_p1 = current_pc + 10'b1;

//1 appended for unconditional jumps
logic [7:0] extended_flags;
assign extended_flags = {1'b1, flags};

logic ltu, gtu, lts, gts;
assign ltu = jump_target[11] & ~jump_target[9];
assign gtu = jump_target[10] & ~jump_target[9];
assign lts = jump_target[11] & jump_target[9];
assign gts = jump_target[10] & jump_target[9];

logic [8:0] one_hot_code;
assign one_hot_code = {jump_target[16:12], ltu, gtu, lts, gts};

logic [9:0] jump_address;
assign jump_address = {jump_target[8:0], jump_target[17]};

always_comb begin
    new_pc = pc_p1;
    for (int i = 0; i < 9; i++) begin
        if (one_hot_code[i]) begin
            if (pc_write_en) begin
                if (i < 8) begin
                    if (extended_flags[i]) new_pc = jump_address;
                end 
                else if (i == 8) begin
                    new_pc = top_address;
                end
            end
        end
    end
end

endmodule
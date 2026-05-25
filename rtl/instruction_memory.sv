module instruction_memory (
    //from top
    input logic clk,

    //from pc
    input logic [9:0] pc,

    //from decoder
    input logic [5:0] label_address,
    
    output logic [8:0] instruction,
    output logic [17:0] jump_target
);

logic [8:0] mem [0:1023];
logic [8:0] label_mem [0:127];

assign label_mem = mem[896:1023];

always_ff @(posedge clk) begin
    instruction <= mem[pc];
end

assign jump_target = {label_mem[{label_address, 1'b1}], label_mem[{label_address, 1'b0}]};

endmodule
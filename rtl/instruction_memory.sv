module instruction_memory (
    //from pc
    input logic [9:0] pc,

    //from decoder
    input logic [5:0] label_address,
    
    output logic [8:0] instruction,
    output logic [17:0] jump_target
);

logic [8:0] mem [0:1023];
logic [8:0] instruction_mem [0:895];
logic [8:0] label_mem [0:127];

assign instruction_mem = mem[0:895];
assign label_mem = mem[896:1023];

initial begin
    $readmemb("../rtl/programs/simple.bin", mem);
end

assign instruction = mem[pc];
assign jump_target = {label_mem[{label_address, 1'b1}], label_mem[{label_address, 1'b0}]};

endmodule
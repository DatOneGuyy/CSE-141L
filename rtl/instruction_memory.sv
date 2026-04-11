module instruction_memory(
    input logic clk,
    input logic [9:0] pc,
    output logic [8:0] instruction
);

logic [8:0] mem [0:1023];

initial begin
    $readmemb("pairs.bin");
end

assign instruction = mem[pc];

endmodule
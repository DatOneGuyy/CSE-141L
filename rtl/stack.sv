import types::*;

module stack (
    input logic clk,
    
    //from top module
    input logic [9:0] pc,

    //from stack controller
    input logic [3:0] stack_opcode,
    input logic [1:0] mask,

    //from register file
    input logic [7:0] r1,
    input logic [7:0] r2,

    //to register file
    output logic [7:0] restore,

    //to pc
    output logic [9:0] top_address,

    //to stack controller
    output logic [1:0] top_mask
);

types::stack_frame stack [0:7];

logic empty;
logic [2:0] pointer;

initial empty = 1'b1;

assign top_address = stack[pointer].pc;
assign top_mask = stack[pointer].mask;

//write to stack synchronously
always_ff @(posedge clk) begin
    unique case (stack_opcode) inside
        4'b0000: begin
            if (empty) begin
                empty <= 1'b0;
                pointer <= 3'b0;

                stack[0].r6 <= r1;
                stack[0].r7 <= r2;
                stack[0].mask <= mask;
                stack[0].pc <= pc + 10'd2;
            end
            else begin
                pointer <= pointer + 'b1;

                stack[pointer + 'b1].r6 <= r1;
                stack[pointer + 'b1].r7 <= r2;
                stack[pointer + 'b1].mask <= mask;
                stack[pointer + 'b1].pc <= pc + 10'd2;
            end
        end
        4'b0001: begin
            stack[pointer].r4 <= r1;
            stack[pointer].r5 <= r2;
        end
        4'b0010: begin
            stack[pointer].r5 <= r1;
        end
        4'b0011: begin
            stack[pointer].r2 <= r1;
            stack[pointer].r3 <= r2;
        end

        [4'b1100:4'b1111]: begin
            if (pointer == 0) empty <= 1'b1;
            else pointer <= pointer - 'b1;
        end

        default: begin
            //no-op
        end
    endcase
end

//read restored register values combinationally
always_comb begin
    unique case (stack_opcode)
        4'b0100: restore = stack[pointer].r7;
        4'b0101, 4'b1100: restore = stack[pointer].r6;
        4'b0110, 4'b1101: restore = stack[pointer].r5;
        4'b0111, 4'b1110: restore = stack[pointer].r4;
        4'b1000, 4'b1111: restore = stack[pointer].r3;
        default: restore = 8'b0;
    endcase
end

endmodule
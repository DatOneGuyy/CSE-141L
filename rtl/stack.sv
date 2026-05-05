import types::*;

module stack_module (
    input logic clk,

    input logic [3:0] stack_opcode,
    input logic [1:0] mask,

    input logic [7:0] r1,
    input logic [7:0] r2,

    output logic [7:0] restore,
    output logic [9:0] top_address,
    output logic [1:0] top_mask
);

stack_frame stack [0:7];

logic empty;
logic [2:0] pointer;

assign top_address = stack[pointer].pc;
assign top_mask = stack[pointer].mask;

always_ff @(posedge clk) begin
    unique case (stack_opcode)
        4'b0000: begin
            if (empty) begin
                empty <= 1'b0;
                pointer <= 3'b0;

                stack[0].r6 <= r1;
                stack[0].r7 <= r2;
                stack[0].mask <= mask;
            end
            else begin
                pointer <= pointer + 'b1;

                stack[pointer + 'b1].r6 <= r1;
                stack[pointer + 'b1].r7 <= r2;
                stack[pointer + 'b1].mask <= mask;
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

        4'b0100: begin
            restore <= stack[pointer].r7;
        end
        4'b0101: begin
            restore <= stack[pointer].r6;
        end
        4'b0110: begin
            restore <= stack[pointer].r5;
        end
        4'b0111: begin
            restore <= stack[pointer].r4;
        end
        4'b1000: begin
            restore <= stack[pointer].r3;
        end

        4'b1100: begin
            restore <= stack[pointer].r6;

            pointer <= pointer - 'b1;
            if (pointer == 0) empty <= 1'b1;
        end
        4'b1101: begin
            restore <= stack[pointer].r5;
            
            pointer <= pointer - 'b1;
            if (pointer == 0) empty <= 1'b1;
        end
        4'b1110: begin
            restore <= stack[pointer].r4;

            pointer <= pointer - 'b1;
            if (pointer == 0) empty <= 1'b1;
        end
        4'b1111: begin
            restore <= stack[pointer].r2;
            
            pointer <= pointer - 'b1;
            if (pointer == 0) empty <= 1'b1;
        end

        default: begin
            //
        end
    endcase
end

endmodule
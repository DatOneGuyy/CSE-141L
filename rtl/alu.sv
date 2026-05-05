module alu (
    input logic [2:0] opcode,
    input logic [2:0] funct,

    input logic [7:0] r1,
    input logic [7:0] r2,
    input logic [2:0] imm,
    input logic carry,

    output logic [7:0] alu_out
    output logic [4:0] alu_flags
);

logic signed [7:0] r1_s = r1;
logic signed [7:0] r2_s = r2;
logic unsigned [7:0] r1_u = r1;
logic unsigned [7:0] r2_u = r2;

always_comb begin
    alu_flags = 5'b0;
    alu_out = 8'b0;

    unique case (opcode)
        3'b110: {alu_flags[4], alu_out} = r1 + r2;
        3'b100: alu_flags[3:0] = {r1_u < r2_u, r1_u > r2_u, r1_s < r2_s, r1_s > r2_s};
        3'b010: alu_out = r1;
        3'b101: begin
            if (imm[2]) begin
                unique case (imm[1:0])
                    2'b00: alu_out = r1 >> 1;
                    2'b01: alu_out = r1 >> 2;
                    2'b10: alu_out = r1 >> 3;
                    2'b11: alu_out = r1 >> 4;
                endcase
            end
            else begin
                unique case (imm[1:0])
                    2'b00: {alu_flags[4], alu_out} = r1 << 1;
                    2'b01: {alu_flags[4], alu_out} = r1 << 2;
                    2'b10: {alu_flags[4], alu_out} = r1 << 3;
                    2'b11: {alu_flags[4], alu_out} = r1 << 4;
                endcase
            end
        end
        3'b000: begin
            unique case (imm) inside
                [3'b001:3'b110]: alu_out = {5'b0, imm};
                3'b111: alu_out = 8'b11111111;
                default: alu_out = 8'b0;
            endcase
        end
        3'b111: {alu_flags[4], alu_out} = r1 + imm;
        3'b011: begin
            unique case (funct)
                3'b000: alu_out = $countones(r1 ^ r2);
                3'b001: alu_out = ~r1;
                3'b010: alu_out = r1 ^ r2;
                3'b011: alu_out = r1 & r2;
                3'b100: {alu_flags[4], alu_out} = r1 + r2 + {7'b0, carry};
                3'b101: sub = r1 - r2;
                3'b110: {alu_flags[4], alu_out} = {r1, carry};
                default: alu_out = 8'b0;
            endcase
        end
    endcase
end

endmodule
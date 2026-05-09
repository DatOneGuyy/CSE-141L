module alu_tb;

// Signals
logic [2:0] opcode;
logic [2:0] funct;
logic [7:0] r1;
logic [7:0] r2;
logic [2:0] imm;
logic carry_in;
logic [7:0] alu_out;
logic [4:0] alu_flags;
logic write_flags_en;

// Instantiate ALU
alu dut (
    .opcode(opcode),
    .funct(funct),
    .r1(r1),
    .r2(r2),
    .imm(imm),
    .carry_in(carry_in),
    .alu_out(alu_out),
    .alu_flags(alu_flags),
    .write_flags_en(write_flags_en)
);

initial begin
    $dumpfile("dump/alu_dump.vcd");
    $dumpvars(0, alu_tb);

    $display("Starting ALU Testbench");

    // Test ADD (opcode 110) - addition without carry input
    opcode = 3'b110;
    r1 = 8'd10; r2 = 8'd5; carry_in = 0;
    #1; $display("ADD (no carry_in): r1=%d, r2=%d, carry_in=%b, out=%d, carry_out=%b", r1, r2, carry_in, alu_out, alu_flags[4]);
    r1 = 8'd255; r2 = 8'd1; carry_in = 1; // carry_in ignored
    #1; $display("ADD (carry_in ignored): r1=%d, r2=%d, carry_in=%b, out=%d, carry_out=%b", r1, r2, carry_in, alu_out, alu_flags[4]);

    // Test CMP (opcode 100)
    opcode = 3'b100;
    r1 = 8'd10; r2 = 8'd5;
    #1; $display("CMP: r1=%d, r2=%d, flags=%b (u< u> s< s>)", r1, r2, alu_flags[3:0]);
    r1 = 8'd5; r2 = 8'd10;
    #1; $display("CMP: r1=%d, r2=%d, flags=%b", r1, r2, alu_flags[3:0]);
    r1 = 8'b10000000; r2 = 8'b00000001; // signed comparison
    #1; $display("CMP signed: r1=%d, r2=%d, flags=%b", r1, r2, alu_flags[3:0]);

    // Test MOV (opcode 010)
    opcode = 3'b010;
    r1 = 8'd42;
    #1; $display("MOV: r1=%d, out=%d", r1, alu_out);

    // Test Shifts (opcode 101)
    opcode = 3'b101;
    imm = 3'b100; // right shift 1
    r1 = 8'b10101010;
    #1; $display("RSH 1: r1=%b, out=%b", r1, alu_out);
    imm = 3'b101; // right shift 2
    #1; $display("RSH 2: r1=%b, out=%b", r1, alu_out);
    imm = 3'b000; // left shift 1
    #1; $display("LSH 1: r1=%b, out=%b, carry_out=%b", r1, alu_out, alu_flags[4]);
    imm = 3'b001; // left shift 2
    #1; $display("LSH 2: r1=%b, out=%b, carry_out=%b", r1, alu_out, alu_flags[4]);

    // Test IMM (opcode 000)
    opcode = 3'b000;
    imm = 3'b001;
    #1; $display("IMM 1: imm=%b, out=%b", imm, alu_out);
    imm = 3'b111;
    #1; $display("IMM 7: imm=%b, out=%b", imm, alu_out);

    // Test ADD IMM (opcode 111)
    opcode = 3'b111;
    r1 = 8'd10; imm = 3'd2;
    #1; $display("ADD IMM: r1=%d, imm=%d, out=%d, carry_out=%b", r1, imm, alu_out, alu_flags[4]);

    // Test other ops (opcode 011)
    opcode = 3'b011;
    funct = 3'b000; // countones(r1 ^ r2)
    r1 = 8'b10101010; r2 = 8'b01010101;
    #1; $display("POPCNT: r1=%b, out=%d", r1, alu_out);
    funct = 3'b001; // ~r1
    #1; $display("NOT: r1=%b, out=%b", r1, alu_out);
    funct = 3'b010; // r1 ^ r2
    #1; $display("XOR: r1=%b, r2=%b, out=%b", r1, r2, alu_out);
    funct = 3'b011; // r1 & r2
    #1; $display("AND: r1=%b, r2=%b, out=%b", r1, r2, alu_out);
    funct = 3'b100; // add with carry
    carry_in = 1;
    #1; $display("ADD CARRY: r1=%d, r2=%d, carry_in=%b, out=%d, carry_out=%b", r1, r2, carry_in, alu_out, alu_flags[4]);
    funct = 3'b101; // sub (assuming)
    #1; $display("SUB: r1=%d, r2=%d, out=%d", r1, r2, alu_out);
    funct = 3'b110; // lshiftc
    carry_in = 1;
    #1; $display("LSHIFTC: r1=%b, carry_in=%b, out=%b", r1, carry_in, alu_out);

    $display("ALU Testbench Complete");
    $finish;
end

endmodule
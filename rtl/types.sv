package types;

typedef struct packed {
    logic [7:0] r2;
    logic [7:0] r3;
    logic [7:0] r4;
    logic [7:0] r5;
    logic [7:0] r6;
    logic [7:0] r7;

    logic [1:0] mask;
    
    logic [9:0] pc;
} stack_frame;

typedef struct packed {
    logic selector;
    logic [1:0] imm;
} inst_field;

typedef struct packed {
    inst_field opcode;
    inst_field field1;
    inst_field field2;
} instruction;

endpackage
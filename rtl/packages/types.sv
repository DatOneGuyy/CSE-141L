package types;

typedef enum logic [1:0] {
    exec, stack, halted, waiting
} states;

typedef enum logic [3:0] {
    idle,
    save_67, save_45,
    push_67, push_45, push_5, push_23,
    restore_7, restore_6, restore_5, restore_4, restore_3,
    pop_6, pop_5, pop_4, pop_2
} stack_state;

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

endpackage
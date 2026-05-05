module stack_controller (
    input logic clk,

    input logic start,
    input logic [2:0] field,

    output logic [3:0] stack_opcode;
);

typedef enum {
    idle,
    push_67, push_45, push_5, push_23,
    restore_7, restore_6, restore_5, restore_4, restore_3,
    pop_6, pop_5, pop_4, pop_2
} stack_state;

stack_state state;

initial begin
    state = idle;
end

logic [2:0] field_latch;
always_ff @(posedge clk) begin
    unique case (state)
        idle: begin
            if (start) begin
                field_latch <= field;

                if (op_type) begin
                    state <= restore_7;
                end
                else begin
                    state <= push_67;
                end
            end
        end

        push_67: begin
            unique case (field_latch[1:0])
                2'b11: state <= idle;
                2'b10: state <= push_5;
                default: state <= push_45;
            endcase
        end

        push_45: begin
            if (field_latch[1:0] == 2'b00) state <= push_23;
            else state <= idle;
        end

        restore_7: begin
            if (field_latch[1:0] == 2'b11) begin
                state <= pop_6;
            end
            else begin
                state <= restore_6;
            end
        end

        restore_6: begin
            if (field_latch[1:0] == 2'b10) begin
                state <= pop_5;
            end
            else begin
                state <= restore_5;
            end
        end

        restore_5: begin
            if (field_latch[1:0] == 2'b01) begin
                state <= pop_4;
            end
            else begin
                state <= restore_4;
            end
        end

        restore_4: state <= restore_3;
        restore_3: state <= pop_2;
        
        //covers push_5, push_23, pop_6, pop_5, pop_4, and pop_2
        default: state <= idle;
    endcase
end

//moore machine output
always_comb begin
    unique case (state)
        push_67: stack_opcode = 4'b0000;
        push_45: stack_opcode = 4'b0001;
        push_5:  stack_opcode = 4'b0010;
        push_23: stack_opcode = 4'b0011;

        restore_7: stack_opcode = 4'b0100;
        restore_6: stack_opcode = 4'b0101;
        restore_5: stack_opcode = 4'b0110;
        restore_4: stack_opcode = 4'b0111;
        restore_3: stack_opcode = 4'b1000;

        pop_6: stack_opcode = 4'b1100;
        pop_5: stack_opcode = 4'b1101;
        pop_4: stack_opcode = 4'b1110;
        pop_2: stack_opcode = 4'b1111;

        default: stack_opcode = 4'b1001;
    endcase
end

endmodule
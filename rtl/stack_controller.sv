module stack_controller (
    input logic clk,

    //from top-level module
    input logic start,

    //from decoder
    input logic op_type,
    input logic [1:0] inst_mask,

    //from stack
    input logic [1:0] stack_mask,

    //to stack
    output logic [3:0] stack_opcode,
    output logic [1:0] mask_out,

    //to register file
    output logic [2:0] read1_src,
    output logic [2:0] read2_src
    output logic [2:0] write_dest,
    output logic reg_write_en,

    //to top-level module
    output logic stack_override
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
assign mask_out = field_latch[1:0];

always_ff @(posedge clk) begin
    unique case (state)
        idle: begin
            if (start) begin
                stack_override <= 1'b1;

                //field latch determines what operations to cycle through
                //mask is chosen from stack for pops, from instruction for pushes
                //op type always comes from instruction
                if (op_type) begin
                    state <= restore_7;
                    field_latch <= {op_type, stack_mask};
                end
                else begin
                    state <= push_67;
                    field_latch <= {op_type, inst_mask};
                end
            end
        end

        push_67: begin
            unique case (field_latch[1:0])
                2'b11: begin
                    state <= idle;
                    stack_override <= 1'b0;
                end
                2'b10: state <= push_5;
                default: state <= push_45;
            endcase
        end

        push_45: begin
            if (field_latch[1:0] == 2'b00) state <= push_23;
            else begin
                state <= idle;
                stack_override <= 1'b0;
            end
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
        default: begin
            state <= idle;
            stack_override <= 1'b0;
        end
    endcase
end

//set stack opcodes
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

//set register file control signals
always_comb begin
    read1_src = 3'b000;
    read2_src = 3'b000;
    write_dest = 3'b000;
    reg_write_en = 1'b0;

    unique case (state)
        push_67: begin
            read1_src = 3'b110;
            read2_src = 3'b111;
        end
        push_45: begin
            read1_src = 3'b100;
            read2_src = 3'b101;
        end
        push_5: begin
            read1_src = 3'b101;
            read2_src = 3'b101;
        end
        push_23: begin
            read1_src = 3'b010;
            read2_src = 3'b011;
        end

        restore_7: begin
            write_dest = 3'b111;
            reg_write_en = 1'b1;
        end
        restore_6: begin
            write_dest = 3'b110;
            reg_write_en = 1'b1;
        end
        restore_5: begin
            write_dest = 3'b101;
            reg_write_en = 1'b1;
        end
        restore_4: begin
            write_dest = 3'b100;
            reg_write_en = 1'b1;
        end
        restore_3: begin
            write_dest = 3'b011;
            reg_write_en = 1'b1;
        end

        pop_6: begin
            write_dest = 3'b110;
            reg_write_en = 1'b1;
        end
        pop_5: begin
            write_dest = 3'b101;
            reg_write_en = 1'b1;
        end
        pop_4: begin
            write_dest = 3'b100;
            reg_write_en = 1'b1;
        end
        pop_2: begin
            write_dest = 3'b010;
            reg_write_en = 1'b1;
        end

        default: begin
            read1_src = 3'b000;
            read2_src = 3'b000;
            write_dest = 3'b000;
            reg_write_en = 1'b0;
        end
    endcase
end

endmodule
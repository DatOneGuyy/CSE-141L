import types::*;

module top (
    input logic clk,
    input logic start,

    output logic done
);

//instruction memory signals
logic [9:0] pc;

logic [5:0] label_address;

logic [8:0] instruction;
logic [17:0] jump_target;
instruction_memory instruction_memory_inst(
    .pc(pc),
    
    .label_address(label_address),

    .instruction(instruction),
    .jump_target(jump_target)
);

//decoder signals
logic [2:0] opcode;
logic [2:0] funct;
logic [2:0] imm;

logic mem_write_en;

logic pc_write_en;

logic [2:0] read1_src;
logic [2:0] read2_src;
logic [2:0] write_dest;
logic reg_write_en;

logic [2:0] read1_src_decoder;
logic [2:0] read2_src_decoder;
logic [2:0] write_dest_decoder;
logic reg_write_en_decoder;

logic stack_controller_op_type;
logic [1:0] stack_controller_mask;

logic [1:0] write_src;
logic is_stack_op;
decoder decoder_inst(
    .instruction(instruction),
    
    .label_address(label_address),
    
    .opcode(opcode),
    .funct(funct),
    .imm(imm),

    .mem_write_en(mem_write_en),

    .pc_write_en(pc_write_en),

    .read1_src(read1_src_decoder),
    .read2_src(read2_src_decoder),
    .write_dest(write_dest_decoder),
    .reg_write_en(reg_write_en_decoder),

    .stack_controller_op_type(stack_controller_op_type),
    .stack_controller_mask(stack_controller_mask),

    .write_src(write_src),

    .is_stack_op(is_stack_op)
);

//register file signals
logic [7:0] read1_result;
logic [7:0] read2_result;

logic [7:0] register_write_data;

logic [4:0] alu_flags;
logic write_flags_en;
logic [7:0] flags;
register_file register_file_inst(
    .clk(clk),

    .read1_src(read1_src),
    .read2_src(read2_src),
    .write_dest(write_dest),
    .write_en(reg_write_en), 

    .write_data(register_write_data),

    .alu_flags(alu_flags),
    .write_flags_en(write_flags_en),

    .read1_result(read1_result),
    .read2_result(read2_result),

    .flags(flags)
);

//ALU signals
logic [7:0] alu_out;
alu alu_inst(
    .opcode(opcode),
    .funct(funct),
    .imm(imm),

    .r1(read1_result),
    .r2(read2_result),
    .carry_in(flags[7]),

    .alu_out(alu_out),
    .alu_flags(alu_flags),
    .write_flags_en(write_flags_en)
);

//data memory signals
logic [7:0] mem_out;
data_memory data_memory_inst(
    .clk(clk),
    .address(alu_out),
    .data_in(read2_result),
    .write_en(mem_write_en),
    .data_out(mem_out)
);

//register write MUX signals
logic [7:0] restore;
register_write_mux register_write_mux_inst(
    .alu_out(alu_out),
    .data_mem_out(mem_out),
    .stack_out(restore),
    .write_src(write_src),
    .mux_out(register_write_data)
);

//next pc signals
logic [9:0] new_pc;
logic [9:0] top_address;
next_pc next_pc_inst(
    .current_pc(pc),
    .flags(flags[6:0]),
    .jump_target(jump_target),
    .top_address(top_address),
    .pc_write_en(pc_write_en),
    .new_pc(new_pc)
);

//stack controller signals
logic start_stack;
logic [1:0] top_mask;

logic [3:0] stack_opcode;
logic [1:0] mask_out;

logic [2:0] read1_src_stack;
logic [2:0] read2_src_stack;
logic [2:0] write_dest_stack;
logic reg_write_en_stack;

logic stack_override;
logic [9:0] new_pc_stack;
types::states new_state;
stack_controller stack_controller_inst(
    .clk(clk),
    .start(start_stack),
    .pc(pc),
    .op_type(stack_controller_op_type),
    .inst_mask(stack_controller_mask),
    .stack_mask(top_mask),
    .stack_opcode(stack_opcode),
    .mask_out(mask_out),
    .read1_src(read1_src_stack),
    .read2_src(read2_src_stack),
    .write_dest(write_dest_stack),
    .reg_write_en(reg_write_en_stack),
    .stack_override(stack_override),
    .new_pc(new_pc_stack),
    .new_state(new_state)
);

//stack signals
stack stack_inst(
    .clk(clk),
    .pc(pc),
    .stack_opcode(stack_opcode),
    .mask(mask_out),
    .r1(read1_result),
    .r2(read2_result),
    .restore(restore),
    .top_address(top_address),
    .top_mask(top_mask)
);

//register control MUX signals
register_control_mux register_control_mux_inst(
    .read1_src_decoder(read1_src_decoder),
    .read2_src_decoder(read2_src_decoder),
    .write_dest_decoder(write_dest_decoder),
    .reg_write_en_decoder(reg_write_en_decoder),

    .read1_src_stack(read1_src_stack),
    .read2_src_stack(read2_src_stack),
    .write_dest_stack(write_dest_stack),
    .reg_write_en_stack(reg_write_en_stack),

    .is_stack_op(is_stack_op),

    .read1_src(read1_src),
    .read2_src(read2_src),
    .write_dest(write_dest),
    .reg_write_en(reg_write_en)
);

types::states current_state;
initial begin
    current_state = halted;
end

always_ff @(posedge clk) begin
    unique case (current_state)
        exec: begin
            if (instruction == 9'b011000111) begin
                current_state <= halted;
            end
            else if (is_stack_op) begin
                current_state <= stack;
            end
            else begin
                pc <= new_pc;
            end
        end

        stack: begin
            pc <= new_pc_stack;
            current_state <= new_state;
        end

        halted: begin
            if (start) current_state <= exec;
        end

        default: current_state <= halted;
    endcase
end

assign done = (current_state == halted);
assign start_stack = is_stack_op;

endmodule
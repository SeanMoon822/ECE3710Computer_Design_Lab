`include "alu_opcodes.v"

module decode (
    input [15:0] inst,
    output reg [7:0] inst_imm,
    output reg [3:0] reg_a,
    output reg [3:0] reg_b,
    output reg [3:0] reg_dst,
    output reg [1:0] inst_type,
    output reg [3:0] cond,
    output reg pc_disp_abs,
    output reg alu_b_imm_extend,
    output reg [1:0] alu_b_sel,
    output reg [3:0] alu_opcode,
    output reg update_flags,
    output reg update_regfile
);

    localparam [1:0] TYPE_REGISTER = 0;
    localparam [1:0] TYPE_LOAD = 1;
    localparam [1:0] TYPE_STORE = 2;

    localparam [3:0] COND_NEVER = 4'b1111;

    reg reg_a_zero;

    always @(*) begin
        inst_imm = inst[7:0];
        reg_a = reg_a_zero ? 0 : inst[11:8];
        reg_b = inst[3:0];
        reg_dst = inst[11:8];
    end

    always @(*) begin
        casex ({inst[15:12],inst[7:4]})
            // ADD
            8'b0000_0101: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `ADD;
                update_flags = 1;
                update_regfile = 1;
            end
            // ADDI
            8'b0101_xxxx: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 1;
                alu_b_sel = 1;
                alu_opcode = `ADD;
                update_flags = 1;
                update_regfile = 1;
            end
            // ADDC
            8'b0000_0111: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `ADDC;
                update_flags = 1;
                update_regfile = 1;
            end
            // ADDCI
            8'b0111_xxxx: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 1;
                alu_b_sel = 1;
                alu_opcode = `ADDC;
                update_flags = 1;
                update_regfile = 1;
            end
            // SUB
            8'b0000_1001: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `SUB;
                update_flags = 1;
                update_regfile = 1;
            end
            // SUBI
            8'b1001_xxxx: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 1;
                alu_b_sel = 1;
                alu_opcode = `SUB;
                update_flags = 1;
                update_regfile = 1;
            end
            // CMP
            8'b0000_1011: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `CMP;
                update_flags = 1;
                update_regfile = 0;
            end
            // CMPI
            8'b1011_xxxx: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 1;
                alu_b_sel = 1;
                alu_opcode = `CMP;
                update_flags = 1;
                update_regfile = 0;
            end
            // AND
            8'b0000_0001: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `AND;
                update_flags = 1;
                update_regfile = 1;
            end
            // ANDI
            8'b0001_xxxx: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 1;
                alu_opcode = `AND;
                update_flags = 1;
                update_regfile = 1;
            end
            // OR
            8'b0000_0010: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `OR;
                update_flags = 1;
                update_regfile = 1;
            end
            // ORI
            8'b0010_xxxx: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 1;
                alu_opcode = `OR;
                update_flags = 1;
                update_regfile = 1;
            end
            // XOR
            8'b0000_0011: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `XOR;
                update_flags = 1;
                update_regfile = 1;
            end
            // XORI
            8'b0011_xxxx: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 1;
                alu_opcode = `XOR;
                update_flags = 1;
                update_regfile = 1;
            end
            // MOV
            8'b0000_1101: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 1;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `ADD;
                update_flags = 0;
                update_regfile = 1;
            end
            /*
            // MOVLI
            8'b1101_xxxx: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 1;
                alu_opcode = `NOP;
                update_flags = 0;
                update_regfile = 1;
            end
            // MOVUI
            8'b1111_xxxx: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 1;
                alu_opcode = `NOP;
                update_flags = 0;
                update_regfile = 1;
            end
            */
            // LSHI
            8'b1000_000x: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 1;
                alu_opcode = inst[4] ? `RSHL : `LSH;
                update_flags = 1;
                update_regfile = 1;
            end
            // ASHI
            8'b1000_001x: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 1;
                alu_opcode = inst[4] ? `RSHA : `LSH;
                update_flags = 1;
                update_regfile = 1;
            end
            // LOAD
            8'b0100_0000: begin
                inst_type = TYPE_LOAD;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 1;
                alu_b_imm_extend = 0;
                alu_b_sel = 3;
                alu_opcode = `ADD;
                update_flags = 0;
                update_regfile = 1;
            end
            // STOR
            8'b0100_0100: begin
                inst_type = TYPE_STORE;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `NOP;
                update_flags = 0;
                update_regfile = 0;
            end
            /*
            // Scond
            8'b0100_1101: begin
                inst_type = TYPE_REGISTER;
                cond = inst[3:0];
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `NOP;
                update_flags = 0;
                update_regfile = 1;
            end
            */
            // Bcond
            8'b1100_xxxx: begin
                inst_type = TYPE_REGISTER;
                cond = inst[11:8];
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `NOP;
                update_flags = 0;
                update_regfile = 0;
            end
            // Jcond
            8'b0100_1100: begin
                inst_type = TYPE_REGISTER;
                cond = inst[11:8];
                pc_disp_abs = 1;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `NOP;
                update_flags = 0;
                update_regfile = 0;
            end
            // WAIT
            8'b0000_0000: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `NOP;
                update_flags = 0;
                update_regfile = 0;
            end
            default: begin
                inst_type = TYPE_REGISTER;
                cond = COND_NEVER;
                pc_disp_abs = 0;
                reg_a_zero = 0;
                alu_b_imm_extend = 0;
                alu_b_sel = 0;
                alu_opcode = `NOP;
                update_flags = 0;
                update_regfile = 0;
            end
        endcase
    end

endmodule

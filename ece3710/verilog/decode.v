`include "alu_opcodes.v"

module decode (
    input wire [15:0] inst,
    output reg [1:0] inst_type,
    output reg set_flags,
    output reg set_dst,
    output reg pc_next_sel,
    output reg pc_load_sel,
    output reg pre_decr_sel,
    output reg post_incr_sel,
    output reg imm_ex_sel,
    output reg [1:0] alu_b_sel,
    output reg dst_wdata_sel,
    output reg [7:0] imm,
    output reg [3:0] cond,
    output reg [3:0] src_a_sel,
    output reg [3:0] src_b_sel,
    output reg [3:0] alu_opcode
);

    localparam [3:0] COND_ALWAYS = 4'b1110;
    localparam [3:0] COND_NEVER = 4'b1111;

    always @(*) begin
        imm = inst[7:0];
        src_a_sel = inst[11:8];
        src_b_sel = inst[3:0];
    end

    always @(*) casex ({inst[15:12], inst[7:4]})
        // ADD
        8'b0000_0101: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `ADD;
        end
        // ADDI
        8'b0101_xxxx: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 1;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `ADD;
        end
        // ADDC
        8'b0000_0111: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `ADDC;
        end
        // ADDCI
        8'b0111_xxxx: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 1;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `ADDC;
        end
        // SUB
        8'b0000_1001: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `SUB;
        end
        // SUBI
        8'b1001_xxxx: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 1;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `SUB;
        end
        // CMP
        8'b0000_1011: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 0;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `CMP;
        end
        // CMPI
        8'b1011_xxxx: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 0;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 1;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `CMP;
        end
        // AND
        8'b0000_0001: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `AND;
        end
        // ANDI
        8'b0001_xxxx: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `AND;
        end
        // OR
        8'b0000_0010: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `OR;
        end
        // ORI
        8'b0010_xxxx: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `OR;
        end
        // XOR
        8'b0000_0011: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `XOR;
        end
        // XORI
        8'b0011_xxxx: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `XOR;
        end
        // MOV
        8'b0000_1101: begin
            inst_type = 0;
            set_flags = 0;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `PASSB;
        end
        // MOVZI
        8'b1101_xxxx: begin
            inst_type = 0;
            set_flags = 0;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `PASSB;
        end
        // MOVSI
        8'b1110_xxxx: begin
            inst_type = 0;
            set_flags = 0;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 1;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `PASSB;
        end
        // MOVUI
        8'b1111_xxxx: begin
            inst_type = 0;
            set_flags = 0;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `SETU;
        end
        // LSHI
        8'b1000_000x: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `LSH;
        end
        // ASHI
        8'b1000_001x: begin
            inst_type = 0;
            set_flags = 1;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 1;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `ASH;
        end
        // LOAD
        8'b0100_00xx: begin
            inst_type = 1;
            set_flags = 0;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = inst[5] && !inst[4];
            post_incr_sel = inst[5] && inst[4];
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `PASSB;
        end
        // STOR
        8'b0100_01xx: begin
            inst_type = 2;
            set_flags = 0;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = inst[5] && !inst[4];
            post_incr_sel = inst[5] && inst[4];
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `PASSB;
        end
        // Scond
        8'b0100_1101: begin
            inst_type = 0;
            set_flags = 0;
            set_dst = 1;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 3;
            dst_wdata_sel = 0;
            cond = inst[3:0];
            alu_opcode = `PASSB;
        end
        // Bcond
        8'b1100_xxxx: begin
            inst_type = 0;
            set_flags = 0;
            set_dst = 0;
            pc_next_sel = 1;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 1;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = inst[11:8];
            alu_opcode = `NOP;
        end
        // Jcond
        8'b0100_1100: begin
            inst_type = 0;
            set_flags = 0;
            set_dst = 0;
            pc_next_sel = 1;
            pc_load_sel = 1;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = inst[11:8];
            alu_opcode = `NOP;
        end
        // JAL
        8'b0100_1000: begin
            inst_type = 0;
            set_flags = 0;
            set_dst = 1;
            pc_next_sel = 1;
            pc_load_sel = 1;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 1;
            cond = COND_ALWAYS;
            alu_opcode = `NOP;
        end
        // WAIT
        8'b0000_0000: begin
            inst_type = 0;
            set_flags = 0;
            set_dst = 0;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `NOP;
        end
        default: begin
            inst_type = 0;
            set_flags = 0;
            set_dst = 0;
            pc_next_sel = 0;
            pc_load_sel = 0;
            pre_decr_sel = 0;
            post_incr_sel = 0;
            imm_ex_sel = 0;
            alu_b_sel = 0;
            dst_wdata_sel = 0;
            cond = COND_NEVER;
            alu_opcode = `NOP;
        end
    endcase

endmodule

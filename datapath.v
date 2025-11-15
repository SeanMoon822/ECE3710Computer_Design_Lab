`include "alu_flags.v"

module datapath (
    input clk,
    input rst,
    output reg [15:0] out,
    output reg [15:0] mem_addr,
    input [15:0] mem_rdata,
    output reg mem_we,
    output reg [15:0] mem_wdata
);

    wire [15:0] pc;
    reg [15:0] pc_incr;
    reg [15:0] pc_disp;
    reg [15:0] pc_abs;
    reg [15:0] pc_load;
    wire pc_disp_abs;
    reg [15:0] pc_next;
    wire pc_incr_load;

    reg [15:0] inst;
    wire [15:0] inst_reg;

    wire [7:0] inst_imm;
    wire [1:0] inst_type;
    wire [3:0] cond;
    wire update_flags;
    wire update_regfile;

    wire ctrl_pc_en;
    wire ctrl_ir_en;
    wire ctrl_ir_decode;
    wire ctrl_fr_en;
    wire ctrl_regfile_we;
    wire ctrl_mem_addr;
    wire ctrl_mem_we;

    reg [15:0] reg_en;
    wire [3:0] reg_a;
    wire [3:0] reg_b;
    wire [3:0] reg_dst;

    reg [15:0] alu_b_imm;
    wire alu_b_imm_extend;
    wire [15:0] alu_b_reg;
    wire [1:0] alu_b_sel;

    wire [15:0] alu_a;
    reg [15:0] alu_b;
    wire [3:0] alu_opcode;
    wire [15:0] alu_c;
    wire [4:0] alu_flags;

    wire [4:0] flag_reg;

    always @(*) begin
        out = alu_c;
        mem_addr = ctrl_mem_addr ? alu_b_reg : pc;
        mem_we = ctrl_mem_we;
        mem_wdata = alu_a;
    end

    always @(*) begin
        pc_incr = pc + 1;
        pc_disp = pc + {{8{inst_imm[7]}},inst_imm};
        pc_abs = alu_b_reg;
        pc_load = pc_disp_abs ? pc_abs : pc_disp;
        pc_next = pc_incr_load ? pc_load : pc_incr;
    end

    always @(*) begin
        inst = ctrl_ir_decode ? inst_reg : mem_rdata;
        reg_en = 0;
        reg_en[reg_dst] = 1;
    end

    always @(*) begin
        if (alu_b_imm_extend) begin
            alu_b_imm = {{8{inst_imm[7]}},inst_imm};
        end else begin
            alu_b_imm = {{8{1'b0}},inst_imm};
        end
        case (alu_b_sel)
            0: alu_b = alu_b_reg;
            1: alu_b = alu_b_imm;
            2: alu_b = flag_reg;
            3: alu_b = mem_rdata;
            default: alu_b = 0;
        endcase
    end

    register #(
        .WIDTH(16)
    ) register_pc (
        .clk(clk),
        .rst(rst),
        .en(ctrl_pc_en),
        .d(pc_next),
        .q(pc)
    );

    register #(
        .WIDTH(16)
    ) register_inst (
        .clk(clk),
        .rst(rst),
        .en(ctrl_ir_en),
        .d(mem_rdata),
        .q(inst_reg)
    );

    decode decode (
        .inst(inst),
        .inst_imm(inst_imm),
        .reg_a(reg_a),
        .reg_b(reg_b),
        .reg_dst(reg_dst),
        .inst_type(inst_type),
        .cond(cond),
        .pc_disp_abs(pc_disp_abs),
        .alu_b_imm_extend(alu_b_imm_extend),
        .alu_b_sel(alu_b_sel),
        .alu_opcode(alu_opcode),
        .update_flags(update_flags),
        .update_regfile(update_regfile)
    );

    control control (
        .clk(clk),
        .rst(rst),
        .inst_type(inst_type),
        .inst_update_flags(update_flags),
        .inst_update_regfile(update_regfile),
        .ctrl_pc_en(ctrl_pc_en),
        .ctrl_ir_en(ctrl_ir_en),
        .ctrl_ir_decode(ctrl_ir_decode),
        .ctrl_fr_en(ctrl_fr_en),
        .ctrl_regfile_we(ctrl_regfile_we),
        .ctrl_mem_addr(ctrl_mem_addr),
        .ctrl_mem_we(ctrl_mem_we)
    );

    condcheck condcheck (
        .cond(cond),
        .flags(flag_reg),
        .set(pc_incr_load)
    );

    regfile regfile (
        .clk(clk),
        .rst(rst),
        .we(ctrl_regfile_we),
        .en(reg_en),
        .wdata(alu_c),
        .raddr_a(reg_a),
        .rdata_a(alu_a),
        .raddr_b(reg_b),
        .rdata_b(alu_b_reg)
    );

    alu alu (
        .a(alu_a),
        .b(alu_b),
        .opcode(alu_opcode),
        .c_in(flag_reg[`C]),
        .c(alu_c),
        .flags(alu_flags)
    );

    register #(
        .WIDTH(5)
    ) register_flag (
        .clk(clk),
        .rst(rst),
        .en(ctrl_fr_en),
        .d(alu_flags),
        .q(flag_reg)
    );

endmodule

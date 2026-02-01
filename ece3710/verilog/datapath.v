`include "alu_flags.v"

module datapath (
    input wire clk,
    input wire rst,
    input wire en,
    output wire mem_re,
    output wire mem_we,
    output wire [15:0] mem_addr,
    input wire [15:0] mem_rdata,
    output wire [15:0] mem_wdata,
	 
	 output wire [15:0] regfpu1,
	 output wire [15:0] regfpu2
);

    //FPU additions
	 //reg [15:0] regfpu1, regfpu2, regfpu_res;

    wire mem_addr_sel;
    wire pc_next_sel;
    wire pc_load_sel;
    wire inst_sel;
    wire dst_sel_sel;
    wire pre_decr_sel;
    wire post_incr_sel;
    wire imm_ex_sel;
    wire [1:0] alu_b_sel;
    wire dst_data_sel;
    wire dst_wdata_sel;

    wire pc_reg_en;
    wire [15:0] pc_reg;
    wire inst_reg_en;
    wire [15:0] inst_reg;
    wire flag_reg_en;
    wire [4:0] flag_reg;

    wire [15:0] pc_next;
    wire [15:0] pc_incr;
    wire [15:0] pc_load;
    wire [15:0] pc_disp;

    wire [15:0] inst;
    wire [1:0] inst_type;
    wire set_flags;
    wire set_dst;
    wire [7:0] imm;
    wire [15:0] imm_ex;
    wire [3:0] cond;
    wire cond_pass;

    wire [3:0] src_a_sel;
    wire [3:0] src_b_sel;
    wire [15:0] src_b;
    wire [15:0] src_b_decr;
    wire [3:0] dst_sel;
    wire dst_we;
    wire [15:0] dst_wdata;
    wire [15:0] dst_data;

    wire [15:0] alu_b;
    wire [3:0] alu_opcode;
    wire [15:0] alu_c;
    wire [15:0] alu_c_incr;
    wire [4:0] alu_flags;

    mux_2_to_1 #(
        .WIDTH(16)
    ) sel_mem_addr (
        .sel(mem_addr_sel),
        .i0(pc_reg),
        .i1(src_b_decr),
        .o(mem_addr)
    );

    mux_2_to_1 #(
        .WIDTH(16)
    ) sel_pc_next (
        .sel(pc_next_sel && cond_pass),
        .i0(pc_incr),
        .i1(pc_load),
        .o(pc_next)
    );

    mux_2_to_1 #(
        .WIDTH(16)
    ) sel_pc_load (
        .sel(pc_load_sel),
        .i0(pc_disp),
        .i1(src_b_decr),
        .o(pc_load)
    );

    mux_2_to_1 #(
        .WIDTH(16)
    ) sel_inst (
        .sel(inst_sel),
        .i0(mem_rdata),
        .i1(inst_reg),
        .o(inst)
    );

    mux_2_to_1 #(
        .WIDTH(4)
    ) sel_dst_sel (
        .sel(dst_sel_sel),
        .i0(src_a_sel),
        .i1(src_b_sel),
        .o(dst_sel)
    );

    mux_4_to_1 #(
        .WIDTH(16)
    ) sel_alu_b (
        .sel(alu_b_sel),
        .i0(src_b_decr),
        .i1(imm_ex),
        .i2({{11{1'b0}}, flag_reg}),
        .i3({{15{1'b0}}, cond_pass}),
        .o(alu_b)
    );

    mux_2_to_1 #(
        .WIDTH(16)
    ) sel_dst_wdata (
        .sel(dst_wdata_sel),
        .i0(dst_data),
        .i1(pc_incr),
        .o(dst_wdata)
    );

    mux_2_to_1 #(
        .WIDTH(16)
    ) sel_dst_data (
        .sel(dst_data_sel),
        .i0(alu_c_incr),
        .i1(mem_rdata),
        .o(dst_data)
    );

    register #(
        .WIDTH(16)
    ) reg_pc (
        .clk(clk),
        .rst(rst),
        .en(pc_reg_en),
        .d(pc_next),
        .q(pc_reg)
    );

    register #(
        .WIDTH(16)
    ) reg_inst (
        .clk(clk),
        .rst(rst),
        .en(inst_reg_en),
        .d(mem_rdata),
        .q(inst_reg)
    );

    register #(
        .WIDTH(5)
    ) reg_flag (
        .clk(clk),
        .rst(rst),
        .en(flag_reg_en),
        .d(alu_flags),
        .q(flag_reg)
    );

    pc_add #(
        .WIDTH(16)
    ) incr_pc (
        .a(pc_reg),
        .b(16'd1),
        .c(pc_incr)
    );

    pc_add #(
        .WIDTH(16)
    ) disp_pc (
        .a(pc_reg),
        .b(imm_ex),
        .c(pc_disp)
    );

    decode decode (
        .inst(inst),
        .inst_type(inst_type),
        .set_flags(set_flags),
        .set_dst(set_dst),
        .pc_next_sel(pc_next_sel),
        .pc_load_sel(pc_load_sel),
        .pre_decr_sel(pre_decr_sel),
        .post_incr_sel(post_incr_sel),
        .imm_ex_sel(imm_ex_sel),
        .alu_b_sel(alu_b_sel),
        .dst_wdata_sel(dst_wdata_sel),
        .imm(imm),
        .cond(cond),
        .src_a_sel(src_a_sel),
        .src_b_sel(src_b_sel),
        .alu_opcode(alu_opcode)
    );

    control control (
        .clk(clk),
        .rst(rst),
        .en(en),
        .inst_type(inst_type),
        .set_flags(set_flags),
        .set_dst(set_dst),
        .mem_re(mem_re),
        .mem_we(mem_we),
        .mem_addr_sel(mem_addr_sel),
        .inst_sel(inst_sel),
        .dst_sel_sel(dst_sel_sel),
        .dst_data_sel(dst_data_sel),
        .pc_reg_en(pc_reg_en),
        .inst_reg_en(inst_reg_en),
        .flag_reg_en(flag_reg_en),
        .dst_we(dst_we)
    );

    imm_extend #(
        .IWIDTH(8),
        .OWIDTH(16)
    ) extend_imm (
        .sel_zero_sign(imm_ex_sel),
        .i(imm),
        .o(imm_ex)
    );

    condcheck condcheck (
        .flags(flag_reg),
        .cond(cond),
        .set(cond_pass)
    );

    regfile regfile (
        .clk(clk),
        .rst(rst),
        .src_a_sel(src_a_sel),
        .src_a(mem_wdata),
        .src_b_sel(src_b_sel),
        .src_b(src_b),
        .dst_sel(dst_sel),
        .dst_we(dst_we),
        .dst_wdata(dst_wdata),
		  
		  .regfpu1(regfpu1),
	     .regfpu2(regfpu2)
    );

    decrement #(
        .WIDTH(16)
    ) pre_decrement (
        .en(pre_decr_sel),
        .i(src_b),
        .o(src_b_decr)
    );

    alu alu (
        .a(mem_wdata),
        .b(alu_b),
        .opcode(alu_opcode),
        .c_in(flag_reg[`C]),
        .c(alu_c),
        .flags(alu_flags)
    );

    increment #(
        .WIDTH(16)
    ) post_increment (
        .en(post_incr_sel),
        .i(alu_c),
        .o(alu_c_incr)
    );

endmodule

module test_datapath(
	input clk,
	input rst,
	output [15:0] out
);

wire [15:0] reg_en;
wire [3:0] reg_a;
wire [3:0] reg_b;
wire [15:0] imm;
wire [1:0] b_sel;
wire [3:0] opcode;
wire flag_en;

wire [15:0] alu_a;
wire [15:0] reg_alu_b;
reg [15:0] alu_b;

wire [4:0] flags_in;
wire [15:0] flags_out;

// multiplexing for B register
always @(*) begin
	case (b_sel)
		0: alu_b = reg_alu_b;	// Use register value
		1: alu_b = imm;		// Use Immediate Value
		2: alu_b = flags_out;	// Use flags register
		default: alu_b = 0;
	endcase
end

//test_datapath_alu test(
test_datapath_fibonacci test(
//test_datapath_flags test(
//test_datapath_signed test(
	.clk(clk),
	.rst(rst),
	.reg_en(reg_en),
	.reg_a(reg_a),
	.reg_b(reg_b),
	.imm(imm),
	.b_sel(b_sel),
	.opcode(opcode),
	.flag_en(flag_en)
);

regfile registers(
	.clk(clk),
	.rst(rst),
	.en(reg_en),
	.wdata(out),
	.raddr_a(reg_a),
	.raddr_b(reg_b),
	.rdata_a(alu_a),
	.rdata_b(reg_alu_b)
);

register flags(
	.clk(clk),
	.rst(rst),
	.en(flag_en),
	.d({11'b0, flags_in}),
	.q(flags_out)
);

alu alu(
	.a(alu_a),
	.b(alu_b),
	.opcode(opcode),
	.c_in(flags_out[0]),
	.c(out),
	.flags(flags_in)
);

endmodule

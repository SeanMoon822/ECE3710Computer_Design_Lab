module ece3710_testALU
(
	output [0:6] seg3,
	output [0:6] seg2,
	output [0:6] seg1,
	output [0:6] seg0,
	input [2:0] a,
	input [2:0] b,
	input [3:0] opcode,
	output [4:0] flags
);

wire [15:0] c;

alu alu
(
	.a({{14{a[2]}}, a[1:0]}),
	.b({{14{b[2]}}, b[1:0]}),
	.opcode(opcode),
	.c_in(1'b0),
	.c(c),
	.flags(flags)
);

hex_to_sev_seg to_seg3(.hex(c[15:12]), .seven_seg(seg3));
hex_to_sev_seg to_seg2(.hex(c[11:8]), .seven_seg(seg2));
hex_to_sev_seg to_seg1(.hex(c[7:4]), .seven_seg(seg1));
hex_to_sev_seg to_seg0(.hex(c[3:0]), .seven_seg(seg0));

endmodule

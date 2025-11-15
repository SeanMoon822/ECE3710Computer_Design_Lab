module ece3710_memtest(
	input clk,
	input rst,
	output [0:6] seg3,
	output [0:6] seg2,
	output [0:6] seg1,
	output [0:6] seg0
);

wire [15:0] out;

memtest test(
	.clk(clk),
	.rst(rst),
	.out(out)
);

hex_to_sev_seg to_seg3(.hex(out[15:12]), .seven_seg(seg3));
hex_to_sev_seg to_seg2(.hex(out[11:8]), .seven_seg(seg2));
hex_to_sev_seg to_seg1(.hex(out[7:4]), .seven_seg(seg1));
hex_to_sev_seg to_seg0(.hex(out[3:0]), .seven_seg(seg0));

endmodule

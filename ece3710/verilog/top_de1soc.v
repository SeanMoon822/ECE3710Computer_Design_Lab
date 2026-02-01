module top_de1soc
(
    input wire clk_50MHz,

    input wire [3:0] key,
    input wire [9:0] sw,
    output wire [9:0] led,
	 
    output wire [0:6] seg_0,
    output wire [0:6] seg_1,
    output wire [0:6] seg_2,
    output wire [0:6] seg_3,
    output wire [0:6] seg_4,
    output wire [0:6] seg_5,

    input wire [1:0] ps2_clk,
    input wire [1:0] ps2_dat,

    output wire [7:0] vga_r,
    output wire [7:0] vga_g,
    output wire [7:0] vga_b,
    output wire vga_clk,
    output wire vga_blank_n,
    output wire vga_hs,
    output wire vga_vs,
    output wire vga_sync_n
);

    wire [15:0] out_0;
    wire [15:0] out_1;
	 wire [15:0] fpu_result;

    top top (
        .clk_50MHz(clk_50MHz),
        .rst(~key[3]),
		  .mode(sw[1:0]),
        .out_0(out_0),
        .out_1(out_1),
        .ps2_clk(ps2_clk[0]),
        .ps2_dat(ps2_dat[0]),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .vga_clk(vga_clk),
        .vga_blank_n(vga_blank_n),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs),
        .vga_sync_n(vga_sync_n),
		  .fpu_result(fpu_result)
    );

    hex_to_sev_seg hex_0 (
        .hex(sw[2] ? fpu_result[3:0] : out_0[3:0]),
        .seven_seg(seg_0[0:6])
    );

    hex_to_sev_seg hex_1 (
        .hex(sw[2] ? fpu_result[7:4] : out_0[7:4]),
        .seven_seg(seg_1[0:6])
    );

    hex_to_sev_seg hex_2 (
        .hex(sw[2] ? fpu_result[11:8] : out_0[11:8]),
        .seven_seg(seg_2[0:6])
    );

    hex_to_sev_seg hex_3 (
        .hex(sw[2] ? fpu_result[15:12] : out_0[15:12]),
        .seven_seg(seg_3[0:6])
    );

    hex_to_sev_seg hex_4 (
        .hex(sw[2] ? 4'b0 : out_1[3:0]),
        .seven_seg(seg_4[0:6])
    );

    hex_to_sev_seg hex_5 (
        .hex(sw[2] ? 4'b0 : out_1[7:4]),
        .seven_seg(seg_5[0:6])
    );

endmodule

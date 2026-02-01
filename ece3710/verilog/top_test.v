`timescale 1ns / 1ps

module top_test;

    reg clk_50MHz;
    reg rst;
    wire [15:0] out_0;
    wire [15:0] out_1;
    reg ps2_clk;
    reg ps2_dat;
    wire [7:0] vga_r;
    wire [7:0] vga_g;
    wire [7:0] vga_b;
    wire vga_clk;
    wire vga_blank_n;
    wire vga_hs;
    wire vga_vs;
    wire vga_sync_n;

    top #(
        .PROGRAM_FILE("program.hex")
    ) top (
        .clk_50MHz(clk_50MHz),
        .rst(rst),
        .out_0(out_0),
        .out_1(out_1),
        .ps2_clk(ps2_clk),
        .ps2_dat(ps2_dat),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .vga_clk(vga_clk),
        .vga_blank_n(vga_blank_n),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs),
        .vga_sync_n(vga_sync_n)
    );

    initial begin
        clk_50MHz = 0;
        forever #10 clk_50MHz = ~clk_50MHz;
    end

    initial begin
        rst = 0;
        @(posedge clk_50MHz);
        rst = 1;
        @(posedge clk_50MHz);
        rst = 0;
    end

    initial begin
        ps2_clk = 0;
        ps2_dat = 0;
    end

    initial begin
        $monitor("time=%0t out_0=%4x out_1=%4x", $time, out_0, out_1);
    end

endmodule

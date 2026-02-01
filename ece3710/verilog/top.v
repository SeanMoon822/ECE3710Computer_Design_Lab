module top
#(
    parameter PROGRAM_FILE = "../program.hex"
)(
    input wire clk_50MHz,
    input wire rst,
	 
	 // for FPU mode selection
	 input wire [1:0] mode,

    output wire [15:0] out_0,
    output wire [15:0] out_1,

    input wire ps2_clk,
    input wire ps2_dat,

    output reg [7:0] vga_r,
    output reg [7:0] vga_g,
    output reg [7:0] vga_b,
    output reg vga_clk,
    output reg vga_blank_n,
    output wire vga_hs,
    output wire vga_vs,
    output reg vga_sync_n,
	 
	 // the result of the FPU
	 output wire [15:0] fpu_result
);

    wire [15:0] rdata_mem;
    wire [15:0] rdata_out_0;
    wire [15:0] rdata_out_1;
    wire [15:0] rdata_key;

    wire cpu_we;
    wire cpu_re;
    wire [15:0] cpu_addr;
    wire [15:0] cpu_wdata;
    reg [15:0] cpu_rdata;

    wire [11:0] vga_addr;
    wire [15:0] vga_data;

    wire [7:0] scan_code;
    wire new_scan_code;
    wire [7:0] ascii;
    wire ascii_ready;

    wire [9:0] h_count;
    wire [9:0] v_count;
    wire bright;
    wire pixel_on;
	 
	 reg [15:0] cursor_pos;

    always @(*) begin
        cpu_rdata = rdata_mem | rdata_out_0 | rdata_out_1 | rdata_key;
    end

    always @(posedge clk_50MHz) begin
        vga_clk <= ~vga_clk;
    end

    always @(*) begin
        vga_blank_n = 1;
        vga_sync_n = 1;
        vga_r = 8'd0;
        vga_g = pixel_on ? 8'd255 : 8'd0;
        vga_b = 8'd0;
    end

    mapped_bram #(
        .INIT_HEX_FILE(PROGRAM_FILE),
        .DATA_WIDTH(16),
        .ADDR_WIDTH(14),
        .ADDR_A_WIDTH(16),
        .ADDR_A_START(14'h0000),
        .ADDR_B_WIDTH(14),
        .ADDR_B_START(14'h0000)
    ) bram (
        .clk(clk_50MHz),
        .rst(rst),
        .we_a(cpu_we),
        .re_a(cpu_re),
        .addr_a(cpu_addr),
        .wdata_a(cpu_wdata),
        .rdata_a(rdata_mem),
        .we_b(1'b0),
        .re_b(1'b1),
        .addr_b({2'b11, vga_addr}),
        .wdata_b(16'b0),
        .rdata_b(vga_data)
    );

    mapped_register #(
        .WIDTH(16),
        .WADDR_WIDTH(16),
        .WADDR(16'h4000),
        .RADDR_WIDTH(16),
        .RADDR(16'h4000)
    ) out_reg_0 (
        .clk(clk_50MHz),
        .rst(rst),
        .data(out_0),
        .we(cpu_we),
        .waddr(cpu_addr),
        .wdata(cpu_wdata),
        .re(cpu_re),
        .raddr(cpu_addr),
        .rdata(rdata_out_0)
    );

    mapped_register #(
        .WIDTH(16),
        .WADDR_WIDTH(16),
        .WADDR(16'h4001),
        .RADDR_WIDTH(16),
        .RADDR(16'h4001)
    ) out_reg_1 (
        .clk(clk_50MHz),
        .rst(rst),
        .data(out_1),
        .we(cpu_we),
        .waddr(cpu_addr),
        .wdata(cpu_wdata),
        .re(cpu_re),
        .raddr(cpu_addr),
        .rdata(rdata_out_1)
    );

    mapped_register #(
        .WIDTH(16),
        .WADDR_WIDTH(1),
        .WADDR(0),
        .RADDR_WIDTH(16),
        .RADDR(16'h4002),
        .CLEAR_ON_READ(1)
    ) key_reg (
        .clk(clk_50MHz),
        .rst(rst),
        .we(ascii_ready),
        .waddr(1'b0),
        .wdata({{8{1'b0}}, ascii}),
        .re(cpu_re),
        .raddr(cpu_addr),
        .rdata(rdata_key)
    );
	 
	    /* mapped_register #(
        .WIDTH(16),
        .WADDR_WIDTH(16),
        .WADDR(16'h4003),   // CPU writes here
        .RADDR_WIDTH(1),
        .RADDR(1'b0)
    ) cursor_reg (
        .clk(clk_50MHz),
        .rst(rst),
        .data(cursor_pos),   // hardware reads cursor_pos
        .we(cpu_we),
        .waddr(cpu_addr),
        .wdata(cpu_wdata),
        .re(1'b0),
        .raddr(1'b0),
        .rdata()
    );*/
	 
	  always @(posedge clk_50MHz or posedge rst) begin
        if (rst) begin
            cursor_pos <= 16'd0;
        end else if (cpu_we && cpu_addr == 16'h4003) begin
            cursor_pos <= cpu_wdata;
        end
    end

    wire [15:0] regfpu1;
    wire [15:0] regfpu2;

    datapath cpu (
        .clk(clk_50MHz),
        .rst(rst),
        .en(1'b1),
        .mem_re(cpu_re),
        .mem_we(cpu_we),
        .mem_addr(cpu_addr),
        .mem_rdata(cpu_rdata),
        .mem_wdata(cpu_wdata),
		  
		  .regfpu1(regfpu1),
	     .regfpu2(regfpu2)
    );
	 
    FPU fpu (
       .arg1(regfpu1),
		  .arg2(regfpu2),
		  .mode(mode),
		  .fpu_result(fpu_result)
    );

    ps2_interface ps2 (
        .clk(clk_50MHz),
        .rst(rst),
        .ps2_clk(ps2_clk),
        .ps2_dat(ps2_dat),
        .scan_code(scan_code),
        .new_scan_code(new_scan_code)
    );

    ps2_scancode_decoder ps2_decoder (
        .clk(clk_50MHz),
        .rst(rst),
        .scan_code(scan_code),
        .scancode_ready(new_scan_code),
        .ascii(ascii),
        .ascii_ready(ascii_ready)
    );

    VGA_controller vga_controller (
        .clk(vga_clk),
        .rst(rst),
        .hSync(vga_hs),
        .vSync(vga_vs),
        .bright(bright),
        .hCount(h_count),
        .vCount(v_count)
    );

    char_grid char_grid (
        .clk(vga_clk),
        .rst(rst),
        .hCount(h_count),
        .vCount(v_count),
        .bright(bright),
        .pixel_on(pixel_on),
		  .cursor_pos(cursor_pos),
        .mem_addr(vga_addr),
        .mem_data(vga_data)
    );

endmodule

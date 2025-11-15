module ece3710 (
    input clk,
    input rst,
    output [0:6] seg3,
    output [0:6] seg2,
    output [0:6] seg1,
    output [0:6] seg0
);

    localparam PROGRAM_HEX_FILE = "datapath_branchjump.hex";

    wire [15:0] out;

	 // memory port A signals
    wire [15:0] addr_a;
    wire [15:0] rdata_a;
    wire we_a;
    wire [15:0] wdata_a;

	 // memory port B signals
    reg [15:0] addr_b;
    wire [15:0] rdata_b;
    reg we_b;
    reg [15:0] wdata_b;

    always @(*) begin
        addr_b = 0;
        we_b = 0;
        wdata_b = 0;
    end

    datapath cpu (
        .clk(clk),
        .rst(rst),
        .out(out),
        .mem_addr(addr_a),
        .mem_rdata(rdata_a),
        .mem_we(we_a),
        .mem_wdata(wdata_a)
    );

    bram #(
        .HEX_FILE(PROGRAM_HEX_FILE),
        .DATA_WIDTH(16),
        .ADDR_WIDTH(16)
    ) mem (
        .clk(clk),
        .addr_a(addr_a),
        .q_a(rdata_a),
        .we_a(we_a),
        .data_a(wdata_a),
        .addr_b(addr_b),
        .q_b(rdata_b),
        .we_b(we_b),
        .data_b(wdata_b)
    );

    hex_to_sev_seg to_seg3(.hex(out[15:12]), .seven_seg(seg3));
    hex_to_sev_seg to_seg2(.hex(out[11:8]), .seven_seg(seg2));
    hex_to_sev_seg to_seg1(.hex(out[7:4]), .seven_seg(seg1));
    hex_to_sev_seg to_seg0(.hex(out[3:0]), .seven_seg(seg0));

endmodule

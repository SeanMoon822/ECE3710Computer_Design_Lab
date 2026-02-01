module memtest (
    input clk,
    input rst,
    output [15:0] out
);

wire [15:0] q_a;
wire [15:0] q_b;
wire we_a;
wire we_b;
wire [15:0] data_a;
wire [15:0] data_b;
wire [9:0] addr_a;
wire [9:0] addr_b;
wire selectout;

assign out = selectout == 0 ? q_a : q_b;

memtest_fsm fsm (
    .clk(clk),
    .rst(rst),
    .q_a(q_a),
    .q_b(q_b),
    .we_a(we_a),
    .we_b(we_b),
    .data_a(data_a),
    .data_b(data_b),
    .addr_a(addr_a),
    .addr_b(addr_b),
    .selectout(selectout)
);

bram #(
    .HEX_FILE("memtest.hex"),
    .DATA_WIDTH(16),
    .ADDR_WIDTH(10)
) ram (
    .data_a(data_a),
    .data_b(data_b),
    .addr_a(addr_a),
    .addr_b(addr_b),
    .we_a(we_a),
    .we_b(we_b),
    .clk(clk),
    .q_a(q_a),
    .q_b(q_b)
);

endmodule

module imm_extend
#(
    parameter IWIDTH = 0,
    parameter OWIDTH = 0
)(
    input wire sel_zero_sign,
    input wire [IWIDTH-1:0] i,
    output reg [OWIDTH-1:0] o
);

    reg e;

    always @(*) begin
        e = (sel_zero_sign == 0) ? 1'b0 : i[IWIDTH-1];
        o = {{(OWIDTH-IWIDTH){e}}, i};
    end

endmodule

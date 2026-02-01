module mux_2_to_1
#(
    parameter WIDTH = 0
)(
    input wire sel,
    input wire [WIDTH-1:0] i0,
    input wire [WIDTH-1:0] i1,
    output reg [WIDTH-1:0] o
);

    always @(*) case (sel)
        0: o = i0;
        1: o = i1;
        default: o = 0;
    endcase

endmodule

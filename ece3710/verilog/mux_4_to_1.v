module mux_4_to_1
#(
    parameter WIDTH = 0
)(
    input wire [1:0] sel,
    input wire [WIDTH-1:0] i0,
    input wire [WIDTH-1:0] i1,
    input wire [WIDTH-1:0] i2,
    input wire [WIDTH-1:0] i3,
    output reg [WIDTH-1:0] o
);

    always @(*) case (sel)
        0: o = i0;
        1: o = i1;
        2: o = i2;
        3: o = i3;
        default: o = 0;
    endcase

endmodule

module increment
#(
    parameter WIDTH = 0
)(
    input wire en,
    input wire [WIDTH-1:0] i,
    output reg [WIDTH-1:0] o
);

    always @(*) begin
        o = (en == 1) ? (i + {{WIDTH-1{1'b0}}, 1'b1}) : i;
    end

endmodule

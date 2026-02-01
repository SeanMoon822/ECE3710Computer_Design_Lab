module pc_add
#(
    parameter WIDTH = 0
)(
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    output reg [WIDTH-1:0] c
);

    always @(*) begin
        c = a + b;
    end

endmodule

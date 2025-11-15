module register #(
    parameter WIDTH = 16
) (
    input clk,
    input rst,
    input en,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            q <= 0;
        end else if (en) begin
            q <= d;
        end
    end

endmodule

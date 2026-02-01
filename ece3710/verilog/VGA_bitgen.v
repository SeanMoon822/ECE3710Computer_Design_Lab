module VGA_bitgen (
    input wire bright,
    input wire [9:0] hcount,
    input wire [9:0] vcount,
    output reg [7:0] r,
    output reg [7:0] g,
    output reg [7:0] b
);

    always @(*) begin
        if (bright && hcount >= 160 && hcount < 480 && vcount >= 120 && vcount < 360) begin
            r = 255;
            g = 255;
            b = 255;
        end else begin
            r = 0;
            g = 0;
            b = 0;
        end
    end

endmodule

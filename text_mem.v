module text_mem(
    input [5:0] row,
    input [6:0] col,
    output reg [7:0] glyph_id
);
    always @(*) begin
        if (col < 7'd54)
            glyph_id = col[7:0]; // glyph 0-53
        else
            glyph_id = 8'd0; // rest = glyph 0
    end
endmodule
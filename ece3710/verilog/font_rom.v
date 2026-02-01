module font_rom(
    input [7:0] glyph_id,  // changed to ASCII code
    input [2:0] row,
    output reg [7:0] bits
);
    // font8x8.hex contains glyphs for ASCII 32 (' ') through ASCII 90 ('Z')
    localparam NUM_GLYPHS = 59;
    localparam DEPTH      = NUM_GLYPHS * 8;  // 59 * 8 = 472

    reg [7:0] rom [0:DEPTH-1];

    initial begin
        $readmemh("font8x8.hex", rom);
    end

    reg [7:0] idx;
	 
    always @(*) begin
        if (glyph_id >= 8'd32 && glyph_id <= 8'd90) begin
            //glyph_id 32-90
            idx = glyph_id - 8'd32;
        end else begin
            // space (glyph 0)
            idx = 8'd0;
        end
    end

    always @(*) begin
        bits = rom[idx*8 + row];
    end
endmodule

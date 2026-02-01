module char_grid(
    input wire clk,
    input wire rst,
    input wire [9:0] hCount,
    input wire [9:0] vCount,
    input wire bright,
    output reg pixel_on,
    output reg [11:0] mem_addr,
    input wire [15:0] mem_data,
    input wire [15:0] cursor_pos // cursor position in chars (0..4799)
);

    wire [6:0] char_x = hCount[9:3];  
    wire [5:0] char_y = vCount[8:3];  

    wire [2:0] glyph_x = hCount[2:0];
    wire [2:0] glyph_y = vCount[2:0];

    wire [12:0] char_index = char_y * 13'd80 + char_x;
    wire at_cursor = (char_index == cursor_pos[12:0]);

    reg [7:0] glyph_id;
    always @(*) begin
        glyph_id = (char_x[0] == 1'b0) ? mem_data[15:8] : mem_data[7:0];
    end

    wire [7:0] glyph_row_bits;
    font_rom u_font (
        .glyph_id(glyph_id),
        .row(glyph_y),
        .bits(glyph_row_bits)
    );

    wire glyph_bit = glyph_row_bits[7 - glyph_x];

    always @(*) begin
        pixel_on = bright && (at_cursor ? ~glyph_bit : glyph_bit);
        mem_addr = (char_y * 80 + char_x) >> 1;  
    end

endmodule

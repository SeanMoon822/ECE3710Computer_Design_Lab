module text_mem(
    input wire clk,

    // WRITE PORT (CPU / Forth)
    input wire we, // write enable
    input wire [5:0] wr_row,       // 0..59
    input wire [6:0] wr_col,       // 0..79
    input wire [7:0] wr_glyph,     // ASCII

    // READ PORT (VGA / char_grid)
    input wire [5:0] row,          // 0..59
    input wire [6:0] col,          // 0..79
    output reg [7:0] glyph_id      // ASCII stored at [row][col]
);

    // Text screen 
    localparam ROWS = 60;
    localparam COLS = 80;
    localparam MEM_SIZE = ROWS * COLS;   // 4800 entries

    // 4800 x 8-bit memory
    reg [7:0] mem [0:MEM_SIZE-1];

    integer i;
	 
    // Initialize all cells to space (ASCII 32)
    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1)
            mem[i] = i;
    end

    // Convert row/col
    function integer idx;
        input [5:0] r;
        input [6:0] c;
        begin
            idx = r * COLS + c;
        end
    endfunction

    // WRITE PORT (CPU / Forth controls this)
    always @(posedge clk) begin
        if (we)
            mem[idx(wr_row, wr_col)] <= wr_glyph;
    end

    // READ PORT (for VGA)
    always @(*) begin
        glyph_id = mem[idx(row, col)];
    end

endmodule

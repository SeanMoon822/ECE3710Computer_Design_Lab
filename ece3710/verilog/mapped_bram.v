module mapped_bram
#(
    parameter INIT_HEX_FILE = "",
    parameter DATA_WIDTH = 0,
    parameter ADDR_WIDTH = 0,
    parameter ADDR_A_WIDTH = 0,
    parameter ADDR_A_START = 0,
    parameter ADDR_B_WIDTH = 0,
    parameter ADDR_B_START = 0
)(
    input wire clk,
    input wire rst,

    input wire we_a,
    input wire re_a,
    input wire [ADDR_A_WIDTH-1:0] addr_a,
    input wire [DATA_WIDTH-1:0] wdata_a,
    output reg [DATA_WIDTH-1:0] rdata_a,

    input wire we_b,
    input wire re_b,
    input wire [ADDR_B_WIDTH-1:0] addr_b,
    input wire [DATA_WIDTH-1:0] wdata_b,
    output reg [DATA_WIDTH-1:0] rdata_b
);

    reg [DATA_WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];

    reg [DATA_WIDTH-1:0] data_a;
    reg valid_a;
    reg valid_a_reg;

    reg [DATA_WIDTH-1:0] data_b;
    reg valid_b;
    reg valid_b_reg;

    initial begin
        if (INIT_HEX_FILE) begin
            $readmemh(INIT_HEX_FILE, mem);
        end
    end

    always @(posedge clk) begin
        if (we_a && valid_a) begin
            mem[addr_a-ADDR_A_START] <= wdata_a;
            data_a <= wdata_a;
        end else begin
            data_a <= mem[addr_a-ADDR_A_START];
        end
    end

    always @(posedge clk) begin
        if (we_b && valid_b) begin
            mem[addr_b-ADDR_B_START] <= wdata_b;
            data_b <= wdata_b;
        end else begin
            data_b <= mem[addr_b-ADDR_B_START];
        end
    end

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            valid_a_reg <= 0;
            valid_b_reg <= 0;
        end else begin
            valid_a_reg <= valid_a;
            valid_b_reg <= valid_b;
        end
    end

    always @(*) begin
        valid_a = (addr_a >= ADDR_A_START) && (addr_a < ADDR_A_START+2**ADDR_WIDTH);
        rdata_a = (valid_a_reg) ? data_a : 0;
        valid_b = (addr_b >= ADDR_B_START) && (addr_b < ADDR_B_START+2**ADDR_WIDTH);
        rdata_b = (valid_b_reg) ? data_b : 0;
    end

endmodule

module regfile (
    input wire clk,
    input wire rst,
    input wire [3:0] src_a_sel,
    output reg [15:0] src_a,
    input wire [3:0] src_b_sel,
    output reg [15:0] src_b,
    input wire [3:0] dst_sel,
    input wire dst_we,
    input wire [15:0] dst_wdata,
	 
	 output reg [15:0] regfpu1,
	 output reg [15:0] regfpu2
);

    reg [15:0] r [0:15];

    always @(posedge clk, posedge rst) begin
        if (rst) begin : reset
            integer i;
            for (i = 0; i <= 15; i = i+1) begin
                r[i] <= 0;
            end
        end else if (dst_we) begin
            r[dst_sel] <= dst_wdata;
            r[0] <= 16'b0;
        end
    end

    always @(*) begin
        src_a = r[src_a_sel];
        src_b = r[src_b_sel];
		  // FPU hardcodes
		  regfpu1 = r[6];
		  regfpu2 = r[7];
    end

endmodule

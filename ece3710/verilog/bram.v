module bram #(
	parameter HEX_FILE = "",
	parameter DATA_WIDTH = 16,
	parameter ADDR_WIDTH = 10
) (
	input [DATA_WIDTH-1:0] data_a, data_b,
	input [ADDR_WIDTH-1:0] addr_a, addr_b,
	input we_a, we_b, clk,
	output reg [DATA_WIDTH-1:0] q_a, q_b
);

	reg [DATA_WIDTH-1:0] ram [0:2**ADDR_WIDTH-1];

	initial begin
		if (HEX_FILE) begin
			$readmemh(HEX_FILE, ram);
		end
	end

	// Port A
	always @(posedge clk) begin
		if (we_a) begin
			ram[addr_a] <= data_a;
			q_a <= data_a;
		end else begin
			q_a <= ram[addr_a];
		end
	end

	// Port B
	always @(posedge clk) begin
		if (we_b) begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end else begin
			q_b <= ram[addr_b];
		end
	end

endmodule

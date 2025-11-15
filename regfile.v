module regfile
(
	input clk, rst,
	input we,
	input [15:0] en,
	input [15:0] wdata,
	input [3:0] raddr_a,
	input [3:0] raddr_b,
	output reg [15:0] rdata_a,
	output reg [15:0] rdata_b
);
reg [15:0] r [0:15];
integer i;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		for (i=0; i<16; i=i+1) r[i] <= 16'h0000;
	end else if (we) begin
		r[0] <= 16'h0000;	// declare r[0] to be a zero register
								// (explicitly, to prevent latch inference)
	   for (i=1; i<16; i=i+1) begin
			if (en[i]) r[i] <= wdata;
	   end
	end
end

// asynchronous read (combinational read)
always @(*) begin
	rdata_a = r[raddr_a];
	rdata_b = r[raddr_b];
end
endmodule

module test_datapath_test;

reg clk;
reg rst;
wire [15:0] out;

test_datapath uut(
	.clk(clk),
	.rst(rst),
	.out(out)
);

initial begin
	clk = 0;
	rst = 0;
	#5 rst = 1;
	#5 rst = 0;
	repeat (50) begin
		$display("out:%h time:%0d", out, $time);
		clk = 0;
		#5 clk = 1;
		#5;
	end
end

endmodule

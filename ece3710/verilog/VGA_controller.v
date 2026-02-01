module VGA_controller(
	input clk,rst,
	output reg hSync, // active low
	output reg vSync, //active low
	output reg bright,
	output [9:0] hCount, //0 to 799
	output [9:0] vCount //0 to 524
);
	wire hDone, vDone;

	// 640x480 timing
	// Horizontal parameters
	localparam h_display = 640,
				  h_fp = 16,
				  h_sync = 96,
				  h_bp = 48,
	// Vertical Parameter
				  v_display = 480,
			     v_fp = 10,
				  v_sync = 2,
				  v_bp = 33;

	hori_counter hori_counter(
		.clk(clk),
		.en(1'b1), 
		.rst(rst),
		.hCount(hCount),
		.hdone(hDone)
		);
	vert_counter vert_counter(
		.clk(clk),
		.en(hDone),
		.rst(rst),
		.vCount(vCount),
		.vdone(vDone)
	);
	// Negative sync
	always @(*) begin
		//hsync low during sync pulse
		hSync = ~((hCount >= (h_display + h_fp)) && (hCount < (h_display + h_fp + h_sync)));
		//vsync low during sync pulse
		vSync = ~((vCount >= (v_display + v_fp)) && (vCount < (v_display + v_fp + v_sync)));
		// 1 only both are true
		bright = (hCount < h_display) && (vCount < v_display);
	end
endmodule

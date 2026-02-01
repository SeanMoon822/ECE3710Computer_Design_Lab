module vert_counter(
	input clk, en,rst,
	output [9:0] vCount,
	output vdone
);
	localparam last = 10'd524; // total-1
	reg [9:0] v_reg, v_next;
	
	always @(posedge clk or posedge rst) begin
		if(rst)
			v_reg <= 10'd0;
		else if (en)
			v_reg <= v_next; // update when enable is 1
		else 
			v_reg <= v_reg; // hold the value
	end
	
	always @(*) begin
	if (vdone)
		v_next = 10'd0;
	else 
		v_next = v_reg + 10'd1; // increment
	end
	
	// outputs
	assign vCount = v_reg;
	assign vdone = (v_reg == last); // when v_reg is 524 (end)
	
endmodule

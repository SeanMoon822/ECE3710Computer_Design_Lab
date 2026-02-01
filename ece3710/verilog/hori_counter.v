module hori_counter(
	input clk, en,rst,
	output [9:0] hCount,
	output hdone
);
	localparam last = 10'd799; // total-1
	reg [9:0] h_reg, h_next;
	
	always @(posedge clk or posedge rst) begin
		if(rst)
			h_reg <= 10'd0;
		else if (en)
			h_reg <= h_next; // update when en is 1
		else 
			h_reg <= h_reg; // hold the value
	end
	
	always @(*) begin
	if (hdone)
		h_next = 10'd0;
	else 
		h_next = h_reg + 10'd1; // increment
	end
	
	// outputs
	assign hCount = h_reg;
	assign hdone = (h_reg == last); // when h_reg is 799 
endmodule
	

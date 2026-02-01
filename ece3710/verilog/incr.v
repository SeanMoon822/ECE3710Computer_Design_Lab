module incr #(parameter WIDTH=10) (
	input [WIDTH-1:0] in,
	output reg [WIDTH-1:0] out);
	
	always @(*) begin
		out <= in + 1;
	end
	
endmodule
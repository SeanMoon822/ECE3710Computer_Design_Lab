module mux
(
	input[3:0] select,
	input [15:0] q0, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15,
	output reg [15:0] q
);

always @(select) begin
	case (select)
		4'b0000: q = q0;
		4'b0001: q = q1;
		4'b0010: q = q2;
		4'b0011: q = q3;
		4'b0100: q = q4;
		4'b0101: q = q5;
		4'b0110: q = q6;
		4'b0111: q = q7;
		4'b1000: q = q8;
		4'b1001: q = q9;
		4'b1010: q = q10;
		4'b1011: q = q11;
		4'b1100: q = q12;
		4'b1101: q = q13;
		4'b1110: q = q14;
		4'b1111: q = q15;
		// should never happen
		default: q = 4'b0000;
	endcase
end

endmodule
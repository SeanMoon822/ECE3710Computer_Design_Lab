// Top-level module for the FPU.
// Implements addition, subtraction, multiplication, division, reciprocal, and comparison
module FPU(
	input wire [15:0] arg1, arg2,
	input wire [1:0] mode,
	output wire fpu_comp,
	output reg [15:0] fpu_result
);

	// Regular addition and subtraction
	wire [31:0] norm_sum, norm_diff;

	// Intermediate wires for float conversion
	wire [31:0] log_val1, log_val2;
	wire special1, special2;

	// Wires for the calculated Logarithmic results
	wire [31:0] log_sum, log_diff;

	// Wires for the final reconstruction
	reg result_sign;
	wire out_special;

	FloatingCompare comp(
		.A({arg1, 16'b0}), 
		.B({arg2, 16'b0}),
		.result(fpu_comp)
	);

	// Convert 16-bit Takum input to 32-bit Logarithmic Float
	takum16_to_l toLongArg1(
		.takum16_in(arg1),
		.float_out(log_val1),
		.is_special(special1)
	);
	takum16_to_l toLongArg2(
		.takum16_in(arg2),
		.float_out(log_val2),
		.is_special(special2)
	);
	// We need the absolute values of the logs, 
	// as the converter outputs Signed Log values
	wire [31:0] log_abs_1 = {1'b0, log_val1[30:0]};
	wire [31:0] log_abs_2 = {1'b0, log_val2[30:0]};

	FloatingAddition takumAdder(
		.A({1'b0, log_val1[30:0]}),
		.B({1'b0, log_val2[30:0]}),
		.result(log_sum)
	);
	FloatingAddition takumSubtracter(
		.A({1'b0, log_val2[30:0]}),
		.B({1'b1, log_val2[30:0]}), // Negate B
		.result(log_diff)
	);

	FloatingAddition adder(
		.A(arg1),
		.B(arg2),
		.result(norm_sum)
	);
	FloatingAddition subtracter(
		.A(arg1),
		.B({~arg2[15], arg2[14:0]}), // Negate B
		.result(norm_diff)
	);


	always @(*) begin
		// reset regs
		fpu_result = 0;
		result_sign = 1'b0;
		
		case (mode)
			// Addition (IEEE754)
			2'b00: begin
				fpu_result = norm_sum;
			end
			
			// Subtraction (IEEE754)
			2'b01: begin
				fpu_result = norm_diff;
			end
			
			// Multiplicatiom
			2'b10: begin
				result_sign = arg1[15] ^ arg2[15];
				fpu_result = log_sum;
			end

			// Division
			2'b11: begin
				result_sign = arg1[15] ^ arg2[15];
				fpu_result = log_diff;
			end
		endcase
	end

endmodule


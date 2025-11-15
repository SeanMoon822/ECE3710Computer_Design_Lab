`include "alu_flags.v"
`include "alu_opcodes.v"

module alu
(
	input [15:0] a,
	input [15:0] b,
	input [3:0] opcode,
	input c_in,
	output reg [15:0] c,
	output reg [4:0] flags
);

reg [16:0] sum_ext;

always @(*) begin

	sum_ext = 17'b0;
	c = 16'b0;
	flags = 5'b0;

	case (opcode)

		`NOP: begin
		end

		`ADD: begin
			sum_ext = {1'b0,a} + {1'b0,b};
			c = sum_ext[15:0];
			flags[`C] = sum_ext[16];
			flags[`F] = (~(a[15]^b[15])) & (c[15]^a[15]);
			flags[`N] = c[15];
			flags[`Z] = (c == 16'b0);
		end

		`ADDC: begin
			sum_ext = {1'b0,a} + {1'b0,b} + {16'b0,c_in};
			c = sum_ext[15:0];
			flags[`C] = sum_ext[16];
			flags[`F] = (~(a[15]^b[15])) & (c[15]^a[15]);
			flags[`N] = c[15];
			flags[`Z] = (c == 16'b0);
		end

		`SUB: begin
			sum_ext = {1'b0,a} + {1'b0,~b} + 17'b1;
			c = sum_ext[15:0];
			flags[`C] = ~sum_ext[16];
			flags[`F] = (a[15]^b[15]) & (c[15]^a[15]);
			flags[`N] = c[15];
			flags[`Z] = (c == 16'b0);
		end

		`CMP: begin
			flags[`L] = (a < b);
			flags[`N] = ($signed(a) < $signed(b));
			flags[`Z] = (a == b);
		end

		`AND: begin
			c = a & b;
			flags[`N] = c[15];
			flags[`Z] = (c == 16'b0);
		end

		`OR: begin
			c = a | b;
			flags[`N] = c[15];
			flags[`Z] = (c == 16'b0);
		end

		`XOR: begin
			c = a ^ b;
			flags[`N] = c[15];
			flags[`Z] = (c == 16'b0);
		end

		`NOT: begin
			c = ~a;
			flags[`N] = c[15];
			flags[`Z] = (c == 16'b0);
		end

		`LSH: begin
			c = a << 1;
			flags[`C] = a[15];
			flags[`N] = c[15];
			flags[`Z] = (c == 16'b0);
		end

		`RSHL: begin
			c = a >> 1;
			flags[`C] = a[0];
			flags[`N] = c[15];
			flags[`Z] = (c == 16'b0);
		end

		`RSHA: begin
			c = {a[15], a[15:1]};
			flags[`C] = a[0];
			flags[`N] = c[15];
			flags[`Z] = (c == 16'b0);
		end

		default: begin
		end

	endcase
end

endmodule

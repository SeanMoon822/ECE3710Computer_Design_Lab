`include "alu_flags.v"
`include "alu_opcodes.v"

`timescale 1ns / 1ps

`define ERROR(m) $display("ERROR (%s) a:%x b:%x c_in:%b c:%x flags:%b time:%0d", (m), a, b, c_in, c, flags, $time); errors = errors + 1;
`define ASSERT(m, a) if (!(a)) begin `ERROR(m) end

module alu_test;

reg [15:0] a;
reg [15:0] b;
reg [3:0] opcode;
reg c_in;
wire [15:0] c;
wire [4:0] flags;

reg [16:0] sum;
reg [15:0] shift;

alu uut
(
	.a(a),
	.b(b),
	.opcode(opcode),
	.c_in(c_in),
	.c(c),
	.flags(flags)
);

task randomize(output[15:0] a, b, output c_in);
	begin
		a = $random;
		b = $random;
		c_in = $random;
	end
endtask

integer i;
integer errors = 0;
parameter n = 10;

initial begin

	a = 0;
	b = 0;
	opcode = 0;
	c_in = 0;
	#10;

	$display("Checking PASSB");
	opcode = `PASSB;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		`ASSERT("c", c == b)
		`ASSERT("flag c", (flags[`C] == 0))
		`ASSERT("flag f", (flags[`F] == 0))
		`ASSERT("flag l", (flags[`L] == 0))
		`ASSERT("flag n", (flags[`N] != 0) == (c[15] != 0))
		`ASSERT("flag z", (flags[`Z] != 0) == (c == 0))
	end

	$display("Checking ADD");
	opcode = `ADD;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		sum = a + b;
		`ASSERT("sum", c == sum[15:0])
		`ASSERT("flag c", (flags[`C] != 0) == (sum[16] != 0))
		`ASSERT("flag f", (flags[`F] != 0) == ((!a[15] && !b[15] && c[15]) || (a[15] && b[15] && !c[15])))
		`ASSERT("flag l", (flags[`L] == 0))
		`ASSERT("flag n", (flags[`N] != 0) == (c[15] != 0))
		`ASSERT("flag z", (flags[`Z] != 0) == (c == 0))
	end

	$display("Checking ADDC");
	opcode = `ADDC;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		sum = a + b + c_in;
		`ASSERT("sum", c == sum[15:0])
		`ASSERT("flag c", (flags[`C] != 0) == (sum[16] != 0))
		`ASSERT("flag f", (flags[`F] != 0) == ((!a[15] && !b[15] && c[15]) || (a[15] && b[15] && !c[15])))
		`ASSERT("flag l", (flags[`L] == 0))
		`ASSERT("flag n", (flags[`N] != 0) == (c[15] != 0))
		`ASSERT("flag z", (flags[`Z] != 0) == (c == 0))
	end

	$display("Checking SUB");
	opcode = `SUB;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		sum = a - b;
		`ASSERT("difference", c == sum[15:0])
		`ASSERT("flag c", (flags[`C] != 0) == (sum[16] != 0))
		`ASSERT("flag f", (flags[`F] != 0) == ((!a[15] && b[15] && c[15]) || (a[15] && !b[15] && !c[15])))
		`ASSERT("flag l", (flags[`L] == 0))
		`ASSERT("flag n", (flags[`N] != 0) == (c[15] != 0))
		`ASSERT("flag z", (flags[`Z] != 0) == (c == 0))
	end

	$display("Checking CMP");
	opcode = `CMP;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		`ASSERT("cmp", c == 0)
		`ASSERT("flag c", (flags[`C] == 0))
		`ASSERT("flag f", (flags[`F] == 0))
		`ASSERT("flag l", (flags[`L] != 0) == (a < b))
		`ASSERT("flag n", (flags[`N] != 0) == ($signed(a) < $signed(b)))
		`ASSERT("flag z", (flags[`Z] != 0) == (a == b))
	end

	$display("Checking AND");
	opcode = `AND;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		`ASSERT("and", c == (a & b))
		`ASSERT("flag c", (flags[`C] == 0))
		`ASSERT("flag f", (flags[`F] == 0))
		`ASSERT("flag l", (flags[`L] == 0))
		`ASSERT("flag n", (flags[`N] != 0) == (c[15] != 0))
		`ASSERT("flag z", (flags[`Z] != 0) == (c == 0))
	end

	$display("Checking OR");
	opcode = `OR;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		`ASSERT("or", c == (a | b))
		`ASSERT("flag c", (flags[`C] == 0))
		`ASSERT("flag f", (flags[`F] == 0))
		`ASSERT("flag l", (flags[`L] == 0))
		`ASSERT("flag n", (flags[`N] != 0) == (c[15] != 0))
		`ASSERT("flag z", (flags[`Z] != 0) == (c == 0))
	end

	$display("Checking XOR");
	opcode = `XOR;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		`ASSERT("xor", c == (a ^ b))
		`ASSERT("flag c", (flags[`C] == 0))
		`ASSERT("flag f", (flags[`F] == 0))
		`ASSERT("flag l", (flags[`L] == 0))
		`ASSERT("flag n", (flags[`N] != 0) == (c[15] != 0))
		`ASSERT("flag z", (flags[`Z] != 0) == (c == 0))
	end

	$display("Checking NOT");
	opcode = `NOT;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		`ASSERT("not", c == ~a)
		`ASSERT("flag c", (flags[`C] == 0))
		`ASSERT("flag f", (flags[`F] == 0))
		`ASSERT("flag l", (flags[`L] == 0))
		`ASSERT("flag n", (flags[`N] != 0) == (c[15] != 0))
		`ASSERT("flag z", (flags[`Z] != 0) == (c == 0))
	end

	$display("Checking LSH");
	opcode = `LSH;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		shift = (b[4] == 0) ? (a << b[3:0]) : (a >> b[3:0]);
		`ASSERT("shift", c == shift)
		`ASSERT("flag c", (flags[`C] != 0) == ((b[4] == 0) ? (a[15] != 0) : a[0] != 0))
		`ASSERT("flag f", (flags[`F] == 0))
		`ASSERT("flag l", (flags[`L] == 0))
		`ASSERT("flag n", (flags[`N] != 0) == (c[15] != 0))
		`ASSERT("flag z", (flags[`Z] != 0) == (c == 0))
	end

	$display("Checking ASH");
	opcode = `ASH;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		shift = (b[4] == 0) ? ($signed(a) <<< b[3:0]) : ($signed(a) >>> b[3:0]);
		`ASSERT("shift", c == shift)
		`ASSERT("flag c", (flags[`C] != 0) == ((b[4] == 0) ? (a[15] != 0) : a[0] != 0))
		`ASSERT("flag f", (flags[`F] == 0))
		`ASSERT("flag l", (flags[`L] == 0))
		`ASSERT("flag n", (flags[`N] != 0) == (c[15] != 0))
		`ASSERT("flag z", (flags[`Z] != 0) == (c == 0))
	end

	$display("Checking SETU");
	opcode = `SETU;
	for (i=0; i<n; i=i+1) begin
		randomize(a, b, c_in);
		#10;
		`ASSERT("result", c == {b[7:0], a[7:0]})
		`ASSERT("flag c", (flags[`C] == 0))
		`ASSERT("flag f", (flags[`F] == 0))
		`ASSERT("flag l", (flags[`L] == 0))
		`ASSERT("flag n", (flags[`N] != 0) == (c[15] != 0))
		`ASSERT("flag z", (flags[`Z] != 0) == (c == 0))
	end

	$display("Done (%0d errors)", errors);
end

endmodule

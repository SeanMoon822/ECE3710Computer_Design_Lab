`include "alu_opcodes.v"

module test_datapath_fibonacci(
	input clk,
	input rst,
	output reg [15:0] reg_en,
	output reg [3:0] reg_a,
	output reg [3:0] reg_b,
	output reg [15:0] imm,
	output reg [1:0] b_sel,
	output reg [3:0] opcode,
	output reg flag_en
);

reg [4:0] state;

//FSM 
always @(posedge clk, posedge rst) begin
	if (rst)
		state <= 0;
	else
		state <= (state == 5'd15) ? 5'd15 : state + 1;
end

//Output logic
always @(*) begin
	// defaults
	reg_en  = 0;
	reg_a   = 0;
	reg_b   = 0;
	imm	 = 0;
	b_sel   = 0;
	opcode  = `NOP;
	flag_en = 0;

	case (state)
		0: begin
			// r[1] <- 1
			reg_en[1] = 1;
			reg_a = 0;
			imm = 16'h0001;
			b_sel = 1;
			opcode = `ADD;
		end

		1: begin
			// r[2] <- r[0] + r[1]
			reg_en[2] = 1;
			reg_a = 0;
			reg_b = 1;
			opcode = `ADDC;
		end
		2: begin
			// r[3] <- r[1] + r[2]
			reg_en[3] = 1;
			reg_a = 1;
			reg_b = 2;
			opcode = `ADDC;
		end
		3: begin
			// r[4] <- r[2] + r[3]
			reg_en[4] = 1;
			reg_a = 2;
			reg_b = 3;
			opcode = `ADDC;
		end
		4: begin
			// r[5] <- r[3] + r[4]
			reg_en[5] = 1;
			reg_a = 3;
			reg_b = 4;
			opcode = `ADDC;
		end
		5: begin
			// r[6] <- r[4] + r[5]
			reg_en[6] = 1;
			reg_a = 4;
			reg_b = 5;
			opcode = `ADDC;
		end
		6: begin
			// r[7] <- r[5] + r[6]
			reg_en[7] = 1;
			reg_a = 5;
			reg_b = 6;
			opcode = `ADDC;
		end
		7: begin
			// r[8] <- r[6] + r[7]
			reg_en[8] = 1;
			reg_a = 6;
			reg_b = 7;
			opcode = `ADDC;
		end
		8: begin
			// r[9] <- r[7] + r[8]
			reg_en[9] = 1;
			reg_a = 7;
			reg_b = 8;
			opcode = `ADDC;
		end
		9: begin
			// r[10] <- r[8] + r[9]
			reg_en[10] = 1;
			reg_a = 8;
			reg_b = 9;
			opcode = `ADDC;
		end
		10: begin
			// r[11] <- r[9] + r[10]
			reg_en[11] = 1;
			reg_a = 9;
			reg_b = 10;
			opcode = `ADDC;
		end
		11: begin
			// r[12] <- r[10] + r[11]
			reg_en[12] = 1;
			reg_a = 10;
			reg_b = 11;
			opcode = `ADDC;
		end
		12: begin
			// r[13] <- r[11] + r[12]
			reg_en[13] = 1;
			reg_a = 11;
			reg_b = 12;
			opcode = `ADDC;
		end
		13: begin
			// r[14] <- r[12] + r[13]
			reg_en[14] = 1;
			reg_a = 12;
			reg_b = 13;
			opcode = `ADDC;
		end
		14: begin
			// r[15] <- r[13] + r[14]
			reg_en[15] = 1;
			reg_a = 13;
			reg_b = 14;
			opcode = `ADDC;
		end

		//15: default

		default: begin
		// register 15 should contain 'd610 at this stage
		// output register 15
			reg_a = 0;
			reg_b = 15;
			b_sel = 0;
			opcode  = `ADD;
		end
	endcase
end

// stub array that might be useful for further testing
reg [15:0] fib_expected [0:15];
initial begin
	fib_expected[0] = 16'd0;
	fib_expected[1] = 16'd1;
	fib_expected[2] = 16'd1;
	fib_expected[3] = 16'd2;
	fib_expected[4] = 16'd3;
	fib_expected[5] = 16'd5;
	fib_expected[6] = 16'd8;
	fib_expected[7] = 16'd13;
	fib_expected[8] = 16'd21;
	fib_expected[9] = 16'd34;
	fib_expected[10] = 16'd55;
	fib_expected[11] = 16'd89;
	fib_expected[12] = 16'd144;
	fib_expected[13] = 16'd233;
	fib_expected[14] = 16'd377;
	fib_expected[15] = 16'd610;
end

endmodule

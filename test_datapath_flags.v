`include "alu_opcodes.v"

module test_datapath_flags(
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

always @(posedge clk, posedge rst) begin
	if (rst) begin
		state <= 0;
	end else begin
		state <= (state == 5'd20) ? state : state+1;
	end
end

always @(state) begin

	reg_en = 0;
	reg_a = 0;
	reg_b = 0;
	imm = 0;
	b_sel = 0;
	opcode = 0;
	flag_en = 0;

	case (state)
		0: begin
			/* r[1] <- 0x7fff */
			reg_en[1] = 1;
			reg_a = 0;
			imm = 16'h7fff;
			b_sel = 1;
			opcode = `ADD;
		end
		1: begin
			/* r[2] <- 0xffff */
			reg_en[2] = 1;
			reg_a = 0;
			imm = 16'hffff;
			b_sel = 1;
			opcode = `ADD;
		end
		2: begin
			/* r[3] <- 0x8000 */
			reg_en[3] = 1;
			reg_a = 0;
			imm = 16'h8000;
			b_sel = 1;
			opcode = `ADD;
		end
		3: begin
			/* c flag */
			/* r[1] add r[2] */
			reg_a = 1;
			reg_b = 2;
			b_sel = 0;
			opcode = `ADD;
			flag_en = 1;
		end
		4: begin
			/* r[4] <- flags */
			reg_en[4] = 1;
			reg_a = 0;
			b_sel = 2;
			opcode = `ADD;
		end
		5: begin
			/* f flag */
			/* r[3] sub r[1] */
			reg_a = 3;
			reg_b = 1;
			b_sel = 0;
			opcode = `SUB;
			flag_en = 1;
		end
		6: begin
			/* r[5] <- flags */
			reg_en[5] = 1;
			reg_a = 0;
			b_sel = 2;
			opcode = `ADD;
		end
		7: begin
			/* l flag */
			/* r[3] cmp r[2] */
			reg_a = 3;
			reg_b = 2;
			b_sel = 0;
			opcode = `CMP;
			flag_en = 1;
		end
		8: begin
			/* r[6] <- flags */
			reg_en[6] = 1;
			reg_a = 0;
			b_sel = 2;
			opcode = `ADD;
		end
		9: begin
			/* n flag */
			/* r[0] add r[2] */
			reg_a = 0;
			reg_b = 2;
			b_sel = 0;
			opcode = `ADD;
			flag_en = 1;
		end
		10: begin
			/* r[7] <- flags */
			reg_en[7] = 1;
			reg_a = 0;
			b_sel = 2;
			opcode = `ADD;
		end
		11: begin
			/* z flag */
			/* r[2] sub r[2] */
			reg_a = 2;
			reg_b = 2;
			b_sel = 0;
			opcode = `SUB;
			flag_en = 1;
		end
		12: begin
			/* r[8] <- flags */
			reg_en[8] = 1;
			reg_a = 0;
			b_sel = 2;
			opcode = `ADD;
		end
		13: begin
			/* r[9] <- r[4] or r[5] */
			reg_en[9] = 1;
			reg_a = 4;
			reg_b = 5;
			b_sel = 0;
			opcode = `OR;
		end
		14: begin
			/* r[10] <- r[9] or r[6] */
			reg_en[10] = 1;
			reg_a = 9;
			reg_b = 6;
			b_sel = 0;
			opcode = `OR;
		end
		15: begin
			/* r[11] <- r[10] or r[7] */
			reg_en[11] = 1;
			reg_a = 10;
			reg_b = 7;
			b_sel = 0;
			opcode = `OR;
		end
		16: begin
			/* r[12] <- r[11] or r[8] */
			reg_en[12] = 1;
			reg_a = 11;
			reg_b = 8;
			b_sel = 0;
			opcode = `OR;
		end
		17: begin
			/* r[13] <- r[12] */
			reg_en[13] = 1;
			reg_a = 0;
			reg_b = 12;
			b_sel = 0;
			opcode = `ADD;
		end
		18: begin
			/* r[14] <- r[13] */
			reg_en[14] = 1;
			reg_a = 0;
			reg_b = 13;
			b_sel = 0;
			opcode = `ADD;
		end
		19: begin
			/* r[15] <- r[14] */
			reg_en[15] = 1;
			reg_a = 0;
			reg_b = 14;
			b_sel = 0;
			opcode = `ADD;
		end
		default: begin
			/* output r[15] */
			reg_a = 0;
			reg_b = 15;
			b_sel = 0;
			opcode = `ADD;
		end
	endcase
end

endmodule

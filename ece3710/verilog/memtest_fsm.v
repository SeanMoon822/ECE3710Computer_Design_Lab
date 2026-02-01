module memtest_fsm (
	input clk, rst,
	input [15:0] q_a, q_b,
	output reg we_a, we_b,
	output reg [15:0] data_a, data_b,
	output reg [9:0] addr_a, addr_b,
	// 0 selects output A, 1 selects output B
	output reg selectout
);

	reg [4:0] state;

	always @(posedge clk, posedge rst) begin
		if (rst) begin
			state <= 0;
		end else begin
			state <= (state == 23) ? state : state + 1;
		end
	end

	always @(*) begin

		we_a = 0;
		addr_a = 0;
		data_a = 0;
		we_b = 0;
		addr_b = 0;
		data_b = 0;
		selectout = 0;

		case (state)
			0: begin
				// Read address 0x000 on port a
				addr_a = 10'h000;
				selectout = 0;
			end
			1: begin
				// Add address to port a and write back to port a
				we_a = 1;
				addr_a = 10'h000;
				data_a = q_a + addr_a;
				selectout = 0;
			end
			2: begin
				// Read address 0x000 on port a
				addr_a = 10'h000;
				selectout = 0;
			end
			3: begin
				// Read address 0x001 on port b
				addr_b = 10'h001;
				selectout = 1;
			end
			4: begin
				// Add address to port b and write back to port b
				we_b = 1;
				addr_b = 10'h001;
				data_b = q_b + addr_b;
				selectout = 1;
			end
			5: begin
				// Read address 0x001 on port b
				addr_b = 10'h001;
				selectout = 1;
			end
			6: begin
				// Read address 0x1fe on port a
				addr_a = 10'h1fe;
				selectout = 0;
			end
			7: begin
				// Add address to port a and write back to port a
				we_a = 1;
				addr_a = 10'h1fe;
				data_a = q_a + addr_a;
				selectout = 0;
			end
			8: begin
				// Read address 0x1fe on port a
				addr_a = 10'h1fe;
				selectout = 0;
			end
			9: begin
				// Read address 0x1ff on port b
				addr_b = 10'h1ff;
				selectout = 1;
			end
			10: begin
				// Add address to port b and write back to port b
				we_b = 1;
				addr_b = 10'h1ff;
				data_b = q_b + addr_b;
				selectout = 1;
			end
			11: begin
				// Read address 0x1ff on port b
				addr_b = 10'h1ff;
				selectout = 1;
			end
			12: begin
				// Read address 0x200 on port a
				addr_a = 10'h200;
				selectout = 0;
			end
			13: begin
				// Add address to port a and write back to port a
				we_a = 1;
				addr_a = 10'h200;
				data_a = q_a + addr_a;
				selectout = 0;
			end
			14: begin
				// Read address 0x200 on port a
				addr_a = 10'h200;
				selectout = 0;
			end
			15: begin
				// Read address 0x201 on port b
				addr_b = 10'h201;
				selectout = 1;
			end
			16: begin
				// Add address to port b and write back to port b
				we_b = 1;
				addr_b = 10'h201;
				data_b = q_b + addr_b;
				selectout = 1;
			end
			17: begin
				// Read address 0x201 on port b
				addr_b = 10'h201;
				selectout = 1;
			end
			18: begin
				// Read address 0x3fe on port a
				addr_a = 10'h3fe;
				selectout = 0;
			end
			19: begin
				// Add address to port a and write back to port a
				we_a = 1;
				addr_a = 10'h3fe;
				data_a = q_a + addr_a;
				selectout = 0;
			end
			20: begin
				// Read address 0x3fe on port a
				addr_a = 10'h3fe;
				selectout = 0;
			end
			21: begin
				// Read address 0x3ff on port b
				addr_b = 10'h3ff;
				selectout = 1;
			end
			22: begin
				// Add address to port b and write back to port b
				we_b = 1;
				addr_b = 10'h3ff;
				data_b = q_b + addr_b;
				selectout = 1;
			end
			default: begin
				// Read address 0x3ff on port b
				addr_b = 10'h3ff;
				selectout = 1;
			end
		endcase
	end

endmodule

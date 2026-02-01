`include "alu_opcodes.v"

module test_datapath_signed(
  input clk,
  input rst,
  output reg [15:0] reg_en,
  output reg [3:0]  reg_a,
  output reg [3:0]  reg_b,
  output reg [15:0] imm,
  output reg [1:0]  b_sel,
  output reg [3:0]  opcode,
  output reg        flag_en
);

  reg [5:0] state;

  // state counter
  always @(posedge clk or posedge rst) begin
    if (rst) 
      state <= 0;
    else     
       state <= (state == 5'd15) ? 5'd15 : state + 1;
  end

  // output logic
  always @(*) begin
    // initialize as defaults
    reg_en  = 0;
    reg_a   = 0;
    reg_b   = 0;
    imm     = 0;
    b_sel   = 0;
    opcode  = `NOP;
    flag_en = 0;

    case (state)

      // preload randomly signed literals
      0: begin
        reg_en = 1 << 1;
        reg_a  = 4'd0;
        imm    = 16'hFFFF;
        b_sel  = 2'b01;
        opcode = `ADD;
      end 

      1: begin
        reg_en = 1 << 2;
        reg_a  = 4'd0;
        imm    = 16'h0002;
        b_sel  = 2'b01;
        opcode = `ADD;
      end 

      2: begin
        reg_en = 1 << 3;
        reg_a  = 4'd0;
        imm    = 16'hFFFC;
        b_sel  = 2'b01;
        opcode = `ADD;
      end 

      3: begin
        reg_en = 1 << 4;
        reg_a  = 4'd0;
        imm    = 16'hFFFD;
        b_sel  = 2'b01;
        opcode = `ADD;
      end 

      4: begin
        reg_en = 1 << 5;
        reg_a  = 4'd0;
        imm    = 16'd1000;
        b_sel  = 2'b01;
        opcode = `ADD;
      end

      5: begin
        reg_en = 1 << 6;
        reg_a  = 4'd0;
        imm    = 16'hF830;
        b_sel  = 2'b01;
        opcode = `ADD;
      end

      // ADD checks
      6: begin
        reg_en  = 1 << 7;
        reg_a   = 4'd1;
        reg_b   = 4'd2;
        opcode  = `ADD;
        flag_en = 1;
      end

      7: begin
        reg_en = 1 << 8;
        reg_a  = 4'd0;
        b_sel  = 2'b10;
        opcode = `ADD;
      end // saves flags

      8: begin
        reg_en  = 1 << 9;
        reg_a   = 4'd3;
        reg_b   = 4'd4;
        opcode  = `ADD;
        flag_en = 1;
      end 

      9: begin
        reg_en = 1 << 10;
        reg_a  = 4'd0;
        b_sel  = 2'b10;
        opcode = `ADD;
      end

      10: begin
        reg_en  = 1 << 11;
        reg_a   = 4'd5;
        reg_b   = 4'd6;
        opcode  = `ADD;
        flag_en = 1;
      end 

      11: begin
        reg_en = 1 << 12;
        reg_a  = 4'd0;
        b_sel  = 2'b10;
        opcode = `ADD;
      end

      // SUB check
      12: begin
        reg_en  = 1 << 13;
        reg_a   = 4'd1;
        reg_b   = 4'd2;
        opcode  = `SUB;
        flag_en = 1;
      end

      13: begin
        reg_en = 1 << 14;
        reg_a  = 4'd0;
        b_sel  = 2'b10;
        opcode = `ADD;
      end

      // overflow should happen
      14: begin
        reg_en = 1 << 0;
        reg_a  = 4'd0;
        imm    = 16'h7FFF;
        b_sel  = 2'b01;
        opcode = `ADD;
      end

      15: begin
        reg_en = 1 << 2;
        reg_a  = 4'd0;
        imm    = 16'h0001;
        b_sel  = 2'b01;
        opcode = `ADD;
      end

      16: begin
        reg_en  = 1 << 3;
        reg_a   = 4'd0;
        reg_b   = 4'd2;
        opcode  = `ADD;
        flag_en = 1;
      end

      17: begin
        reg_en = 1 << 4;
        reg_a  = 4'd0;
        b_sel  = 2'b10;
        opcode = `ADD;
      end

      // overflow should happen
      18: begin
        reg_en = 1 << 0;
        reg_a  = 4'd0;
        imm    = 16'h8000;
        b_sel  = 2'b01;
        opcode = `ADD;
      end

      19: begin
        reg_en = 1 << 2;
        reg_a  = 4'd0;
        imm    = 16'h0001;
        b_sel  = 2'b01;
        opcode = `ADD;
      end

      20: begin
        reg_en  = 1 << 3;
        reg_a   = 4'd0;
        reg_b   = 4'd2;
        opcode  = `SUB;
        flag_en = 1;
      end

      21: begin
        reg_en = 1 << 5;
        reg_a  = 4'd0;
        b_sel  = 2'b10;
        opcode = `ADD;
      end

      default: begin
        opcode = `NOP;
      end
    endcase
  end
endmodule

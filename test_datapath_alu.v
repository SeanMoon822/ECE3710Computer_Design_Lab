`include "alu_opcodes.v"

module test_datapath_alu(
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
        imm     = 0;
        b_sel   = 0;
        opcode  = `NOP;
        flag_en = 0;

        case (state)
            // preload R1 = 10
            5'd0: begin
                reg_en = (1 << 1); // enable write to R1
                reg_a  = 4'd0;
                imm    = 16'd10;
                b_sel  = 2'b01;    // select immediate
                opcode = `ADD;     // pass immediate
            end

            // preload R2 = 5
            5'd1: begin
                reg_en = (1 << 2); // R2
                reg_a  = 4'd0;
                imm    = 16'd5;
                b_sel  = 2'b01;
                opcode = `ADD;
            end

            // arithmetic: R3 = R1 + R2
            5'd2: begin
                reg_en = (1 << 3); // R3
                reg_a  = 4'd1;
                reg_b  = 4'd2;
                opcode = `ADD;
                flag_en= 1;
            end

            // arithmetic: R4 = R1 - R2
            5'd3: begin
                reg_en = (1 << 4); // R4
                reg_a  = 4'd1;
                reg_b  = 4'd2;
                opcode = `SUB;
                flag_en= 1;
            end

            // logic: R5 = R1 & R2
            5'd4: begin
                reg_en = (1 << 5); // R5
                reg_a  = 4'd1;
                reg_b  = 4'd2;
                opcode = `AND;
                flag_en= 1;
            end

            // logic: R6 = R1 | R2
            5'd5: begin
                reg_en = (1 << 6); // R6
                reg_a  = 4'd1;
                reg_b  = 4'd2;
                opcode = `OR;
                flag_en= 1;
            end

            // logic: R7 = R1 ^ R2
            5'd6: begin
                reg_en = (1 << 7); // R7
                reg_a  = 4'd1;
                reg_b  = 4'd2;
                opcode = `XOR;
                flag_en= 1;
            end

            // logic: R8 = ~R1
            5'd7: begin
                reg_en = (1 << 8); // R8
                reg_a  = 4'd1;
                opcode = `NOT;
                flag_en= 1;
            end

            // shift left: R9 = R1 << 1
            5'd8: begin
                reg_en = (1 << 9); // R9
                reg_a  = 4'd1;
                imm    = 16'd1;    // shift amount
                b_sel  = 2'b01;    // use imm
                opcode = `LSH;
                flag_en= 1;
            end

            // shift right logical: R10 = R1 >> 1
            5'd9: begin
                reg_en = (1 << 10); // R10
                reg_a  = 4'd1;
                imm    = 16'd1;
                b_sel  = 2'b01;
                opcode = `RSHL;
                flag_en= 1;
            end

            // shift right arithmetic: R11 = R1 >>> 1
            5'd10: begin
                reg_en = (1 << 11); // R11
                reg_a  = 4'd1;
                imm    = 16'd1;
                b_sel  = 2'b01;
                opcode = `RSHA;
                flag_en= 1;
            end

            default: begin
                reg_en  = 0;
                opcode  = `NOP;
                flag_en = 0;
            end
        endcase
    end
endmodule

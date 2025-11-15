`include "alu_flags.v"

module condcheck(
    input [4:0] flags,
    input [3:0] cond,
    output reg set // =1 if the condition was met
);

always @(*) begin
    case (cond)
        // EQUAL
        4'b0000: begin
            set = flags[`Z];
        end
        // NOT EQUAL
        4'b0001: begin
            set = !flags[`Z];
        end
        // CARRY SET
        4'b0010: begin
            set = flags[`C];
        end
        // CARRY CLEAR
        4'b0011: begin
            set = !flags[`C];
        end
        // HIGHER THAN
        4'b0100: begin
            set = !flags[`L];
        end
        // LOWER THAN OR SAME AS
        4'b0101: begin
            set = flags[`L] || flags[`Z];
        end
        // GREATER THAN
        4'b0110: begin
            set = !flags[`N];
        end
        // LESS THAN OR EQUAL
        4'b0111: begin
            set = flags[`N] || flags[`Z];
        end
        // FLAG SET
        4'b1000: begin
            set = flags[`F];
        end
        // FLAG CLEAR
        4'b1001: begin
            set = !flags[`F];
        end
        // LOWER THAN
        4'b1010: begin
            set = flags[`L];
        end
        // HIGHER THAN OR SAME AS
        4'b1011: begin
            set = !flags[`L] || flags[`Z];
        end
        // LESS THAN
        4'b1100: begin
            set = flags[`N];
        end
        // GREATER THAN OR EQUAL
        4'b1101: begin
            set = !flags[`N] || flags[`Z];
        end
        // UNCONDITIONAL
        4'b1110: begin
            set = 1;
        end
        // NEVER
        4'b1111: begin
            set = 0;
        end
        default: begin
            set = 0;
        end
    endcase
end

endmodule

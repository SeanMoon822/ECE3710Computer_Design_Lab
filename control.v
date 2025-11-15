module control (
    input clk,
    input rst,
    input [1:0] inst_type,
    input inst_update_flags,
    input inst_update_regfile,
    output reg ctrl_pc_en,
    output reg ctrl_ir_en,
    output reg ctrl_ir_decode,
    output reg ctrl_fr_en,
    output reg ctrl_regfile_we,
    output reg ctrl_mem_addr,
    output reg ctrl_mem_we
);

    localparam STATE_WIDTH = 3;
    localparam [STATE_WIDTH-1:0] S_FETCH = 0;
    localparam [STATE_WIDTH-1:0] S_DECODE = 1;
    localparam [STATE_WIDTH-1:0] S_REG = 2;
    localparam [STATE_WIDTH-1:0] S_LOAD1 = 3;
    localparam [STATE_WIDTH-1:0] S_LOAD2 = 4;
    localparam [STATE_WIDTH-1:0] S_STORE = 5;

    reg [STATE_WIDTH-1:0] state;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= S_FETCH;
        end else case (state)
            S_FETCH: begin
                state <= S_DECODE;
            end
            S_DECODE: begin
                case (inst_type)
                    0: state <= S_REG;
                    1: state <= S_LOAD1;
                    2: state <= S_STORE;
                    default: state <= S_FETCH;
                endcase
            end
            S_REG: begin
                state <= S_FETCH;
            end
            S_LOAD1: begin
                state <= S_LOAD2;
            end
            S_LOAD2: begin
                state <= S_FETCH;
            end
            S_STORE: begin
                state <= S_FETCH;
            end
            default: begin
                state <= S_FETCH;
            end
        endcase
    end

    always @(*) begin
        case (state)
            S_FETCH: begin
                ctrl_pc_en = 0;
                ctrl_ir_en = 0;
                ctrl_ir_decode = 0;
                ctrl_fr_en = 0;
                ctrl_regfile_we = 0;
                ctrl_mem_addr = 0;
                ctrl_mem_we = 0;
            end
            S_DECODE: begin
                ctrl_pc_en = 0;
                ctrl_ir_en = 1;
                ctrl_ir_decode = 0;
                ctrl_fr_en = 0;
                ctrl_regfile_we = 0;
                ctrl_mem_addr = 0;
                ctrl_mem_we = 0;
            end
            S_REG: begin
                ctrl_pc_en = 1;
                ctrl_ir_en = 0;
                ctrl_ir_decode = 0;
                ctrl_fr_en = inst_update_flags;
                ctrl_regfile_we = inst_update_regfile;
                ctrl_mem_addr = 0;
                ctrl_mem_we = 0;
            end
            S_LOAD1: begin
                ctrl_pc_en = 0;
                ctrl_ir_en = 0;
                ctrl_ir_decode = 0;
                ctrl_fr_en = 0;
                ctrl_regfile_we = 0;
                ctrl_mem_addr = 1;
                ctrl_mem_we = 0;
            end
            S_LOAD2: begin
                ctrl_pc_en = 1;
                ctrl_ir_en = 0;
                ctrl_ir_decode = 1;
                ctrl_fr_en = inst_update_flags;
                ctrl_regfile_we = inst_update_regfile;
                ctrl_mem_addr = 0;
                ctrl_mem_we = 0;
            end
            S_STORE: begin
                ctrl_pc_en = 1;
                ctrl_ir_en = 0;
                ctrl_ir_decode = 0;
                ctrl_fr_en = 0;
                ctrl_regfile_we = 0;
                ctrl_mem_addr = 1;
                ctrl_mem_we = 1;
            end
            default: begin
                ctrl_pc_en = 0;
                ctrl_ir_en = 0;
                ctrl_ir_decode = 0;
                ctrl_fr_en = 0;
                ctrl_regfile_we = 0;
                ctrl_mem_addr = 0;
                ctrl_mem_we = 0;
            end
        endcase
    end

endmodule

module control (
    input wire clk,
    input wire rst,
    input wire en,
    input wire [1:0] inst_type,
    input wire set_flags,
    input wire set_dst,
    output reg mem_re,
    output reg mem_we,
    output reg mem_addr_sel,
    output reg inst_sel,
    output reg dst_sel_sel,
    output reg dst_data_sel,
    output reg pc_reg_en,
    output reg inst_reg_en,
    output reg flag_reg_en,
    output reg dst_we
);

    localparam S_WIDTH = 3;
    localparam [S_WIDTH-1:0] S_FETCH = 0;
    localparam [S_WIDTH-1:0] S_DECODE = 1;
    localparam [S_WIDTH-1:0] S_RTYPE = 2;
    localparam [S_WIDTH-1:0] S_LOAD1 = 3;
    localparam [S_WIDTH-1:0] S_LOAD2 = 4;
    localparam [S_WIDTH-1:0] S_STORE = 5;

    reg [S_WIDTH-1:0] state;
    reg [S_WIDTH-1:0] inst_state;

    always @(*) case (inst_type)
        0: inst_state = S_RTYPE;
        1: inst_state = S_LOAD1;
        2: inst_state = S_STORE;
        default inst_state = S_FETCH;
    endcase

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= S_FETCH;
        end else case (state)
            S_FETCH: state <= (en == 0) ? S_FETCH : S_DECODE;
            S_DECODE: state <= inst_state;
            S_RTYPE: state <= S_FETCH;
            S_LOAD1: state <= S_LOAD2;
            S_LOAD2: state <= S_FETCH;
            S_STORE: state <= S_FETCH;
            default: state <= S_FETCH;
        endcase
    end

    always @(*) case (state)
        S_FETCH: begin
            mem_re = 1;
            mem_we = 0;
            mem_addr_sel = 0;
            inst_sel = 0;
            dst_sel_sel = 0;
            dst_data_sel = 0;
            pc_reg_en = 0;
            inst_reg_en = 0;
            flag_reg_en = 0;
            dst_we = 0;
        end
        S_DECODE: begin
            mem_re = 0;
            mem_we = 0;
            mem_addr_sel = 0;
            inst_sel = 0;
            dst_sel_sel = 0;
            dst_data_sel = 0;
            pc_reg_en = 0;
            inst_reg_en = 1;
            flag_reg_en = 0;
            dst_we = 0;
        end
        S_RTYPE: begin
            mem_re = 0;
            mem_we = 0;
            mem_addr_sel = 0;
            inst_sel = 0;
            dst_sel_sel = 0;
            dst_data_sel = 0;
            pc_reg_en = 1;
            inst_reg_en = 0;
            flag_reg_en = set_flags;
            dst_we = set_dst;
        end
        S_LOAD1: begin
            mem_re = 1;
            mem_we = 0;
            mem_addr_sel = 1;
            inst_sel = 0;
            dst_sel_sel = 1;
            dst_data_sel = 0;
            pc_reg_en = 0;
            inst_reg_en = 0;
            flag_reg_en = set_flags;
            dst_we = set_dst;
        end
        S_LOAD2: begin
            mem_re = 0;
            mem_we = 0;
            mem_addr_sel = 0;
            inst_sel = 1;
            dst_sel_sel = 0;
            dst_data_sel = 1;
            pc_reg_en = 1;
            inst_reg_en = 0;
            flag_reg_en = set_flags;
            dst_we = set_dst;
        end
        S_STORE: begin
            mem_re = 0;
            mem_we = 1;
            mem_addr_sel = 1;
            inst_sel = 0;
            dst_sel_sel = 1;
            dst_data_sel = 0;
            pc_reg_en = 1;
            inst_reg_en = 0;
            flag_reg_en = set_flags;
            dst_we = set_dst;
        end
        default: begin
            mem_re = 0;
            mem_we = 0;
            mem_addr_sel = 0;
            inst_sel = 0;
            dst_sel_sel = 0;
            dst_data_sel = 0;
            pc_reg_en = 0;
            inst_reg_en = 0;
            flag_reg_en = 0;
            dst_we = 0;
        end
    endcase

endmodule

module mapped_register
#(
    parameter WIDTH = 0,
    parameter WADDR_WIDTH = 0,
    parameter WADDR = 0,
    parameter RADDR_WIDTH = 0,
    parameter RADDR = 0,
    parameter CLEAR_ON_READ = 0
)(
    input wire clk,
    input wire rst,
    output reg [WIDTH-1:0] data,
    input wire we,
    input wire [WADDR_WIDTH-1:0] waddr,
    input wire [WIDTH-1:0] wdata,
    input wire re,
    input wire [RADDR_WIDTH-1:0] raddr,
    output reg [WIDTH-1:0] rdata
);

    reg wvalid;
    reg rvalid;

    always @(*) begin
        wvalid = waddr == WADDR;
        rvalid = raddr == RADDR;
    end

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            data <= 0;
            rdata <= 0;
        end else begin
            if (re && rvalid && CLEAR_ON_READ != 0) begin
                data <= 0;
            end
            if (re && rvalid) begin
                rdata <= data;
            end else if (re && !rvalid) begin
                rdata <= 0;
            end
            if (we && wvalid) begin
                data <= wdata;
            end
        end
    end

endmodule

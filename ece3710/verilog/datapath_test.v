module datapath_test;

    reg clk;
    reg rst;
    reg en;

    wire [15:0] addr_a;
    wire [15:0] q_a;
    wire we_a;
    wire [15:0] data_a;

    reg [15:0] addr_b;
    wire [15:0] q_b;
    reg we_b;
    reg [15:0] data_b;

    datapath test (
        .clk(clk),
        .rst(rst),
        .en(en),
        .mem_addr(addr_a),
        .mem_rdata(q_a),
        .mem_we(we_a),
        .mem_wdata(data_a)
    );

    bram #(
        .HEX_FILE("program.hex"),
        .DATA_WIDTH(16),
        .ADDR_WIDTH(16)
    ) mem (
        .clk(clk),
        .addr_a(addr_a),
        .we_a(we_a),
        .data_a(data_a),
        .q_a(q_a),
        .addr_b(addr_b),
        .we_b(we_b),
        .data_b(data_b),
        .q_b(q_b)
    );

    initial begin
        clk = 0;
        rst = 0;
        en = 1;
        addr_b = 0;
        we_b  = 0;
        data_b = 0;

        #5;
        rst = 1;
        #5;
        rst = 0;

        forever begin
            clk = 0;
            #5;
            clk = 1;
            #5;
        end

        /*
        // Read mem[0x8000]
        addr_b = 16'h8000;
        clk = 0;
        #5;
        clk = 1;
        #5;
        $display("mem[0x8000] = %h", q_b);

        // Read mem[0x8001]
        addr_b = 16'h8001;
        clk = 0;
        #5;
        clk = 1;
        #5;
        $display("mem[0x8001] = %h", q_b);

        // Read mem[0x8002]
        addr_b = 16'h8002;
        clk = 0;
        #5;
        clk = 1;
        #5;
        $display("mem[0x8002] = %h", q_b);

        // Read mem[0x8003]
        addr_b = 16'h8003;
        clk = 0;
        #5;
        clk = 1;
        #5;
        $display("mem[0x8003] = %h", q_b);
        */

        /*
        // Check expected results
        if (m40 === 16'h2000 &&
            m41 === 16'h3000 &&
            m42 === 16'h4000) begin
            $display("LOAD/STORE TEST: PASS");
        end else begin
            $display("LOAD/STORE TEST: FAIL");
        end
        */

        $stop;
    end


endmodule

module datapath_test;

    reg clk;
    reg rst;
    wire [15:0] out;

    wire [15:0] addr_a;
    wire [15:0] q_a;
    wire we_a;
    wire [15:0] data_a;

    reg [15:0] addr_b;
    wire [15:0] q_b;
    reg we_b;
    reg [15:0] data_b;
    /*
    reg [15:0] m40, m41, m42;
    */

    datapath test (
        .clk(clk),
        .rst(rst),
        .out(out),
        .mem_addr(addr_a),
        .mem_rdata(q_a),
        .mem_we(we_a),
        .mem_wdata(data_a)
    );

    bram #(
        .HEX_FILE("datapath_branchjump.hex"),
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
        addr_b = 0;
        we_b  = 0;
        data_b = 0;
        /*
        m40 = 0;
        m41 = 0;
        m42 = 0;
        */
		  
	#5;
	rst = 1;
	#5;
	rst = 0;
		  
        repeat (300) begin
            $display("out:%h time:%0d", out, $time);
            clk = 0;
            #5;
            clk = 1;
            #5;
        end

        /*
        // Read mem[0x40]
        addr_b = 16'h0040;
        we_b   = 0;
        clk = 0;
	#5;
        clk = 1; 
	#5;  
        m40 = q_b;
        $display("mem[0x40] = %h", m40);

        // Read mem[0x41]
        addr_b = 16'h0041;
        clk = 0; 
	#5;
        clk = 1; 
	#5;
        m41 = q_b;
        $display("mem[0x41] = %h", m41);

        // Read mem[0x42]
        addr_b = 16'h0042;
        clk = 0; 
	#5;
        clk = 1; 
	#5;
        m42 = q_b;
        $display("mem[0x42] = %h", m42);

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

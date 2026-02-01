module ps2_interface (
    input  wire clk,
    input  wire rst,
    input  wire ps2_clk,   // PS/2 Clock line
    input  wire ps2_dat,   // PS/2 Data line
    output reg  [7:0] scan_code,
    output reg  new_scan_code  // 1 clk pulse when a byte is ready
);

    // Synchronize PS/2 lines to system clock
    reg ps2_clk_sync0, ps2_clk_sync1;
    reg ps2_dat_sync0, ps2_dat_sync1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ps2_clk_sync0 <= 1'b1;
            ps2_clk_sync1 <= 1'b1;
            ps2_dat_sync0 <= 1'b1;
            ps2_dat_sync1 <= 1'b1;
        end else begin
            ps2_clk_sync0 <= ps2_clk;
            ps2_clk_sync1 <= ps2_clk_sync0;
            ps2_dat_sync0 <= ps2_dat;
            ps2_dat_sync1 <= ps2_dat_sync0;
        end
    end

    // Falling edge detect on PS/2 clock
    reg ps2_clk_prev;
    always @(posedge clk or posedge rst) begin
        if (rst)
            ps2_clk_prev <= 1'b1;
        else
            ps2_clk_prev <= ps2_clk_sync1;
    end

    wire ps2_falledge = (ps2_clk_prev == 1'b1) && (ps2_clk_sync1 == 1'b0);

    reg [3:0]  bit_count;         // Counts 0 to 9 (10 bits: 8 data + parity + stop)
    reg [10:0] received_packet;   // 11 bits: [0..7]=data, 8=parity, 9=stop, 10 unused

    localparam IDLE = 2'b00,
               RECEIVE = 2'b01,
               DONE = 2'b10;

    reg [1:0] state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            bit_count <= 4'd0;
            received_packet <= 11'd0;
            scan_code <= 8'd0;
            new_scan_code <= 1'b0;
        end else begin
            new_scan_code <= 1'b0; 

            case (state)
                IDLE: begin
                    // Wait for start bit: line goes low and then we see first falling edge
                    if (ps2_falledge && (ps2_dat_sync1 == 1'b0)) begin
                        bit_count <= 4'd0;
                        state <= RECEIVE;
                    end
                end

                RECEIVE: begin
                    if (ps2_falledge) begin
                        // Capture bits LSB first
                        received_packet[bit_count] <= ps2_dat_sync1;
                        bit_count <= bit_count + 1'b1;

                        if (bit_count == 4'd9) begin
                            state <= DONE;
                        end
                    end
                end

                DONE: begin
                    // Reorder from LSB-first to MSB-first
                    scan_code <= {
                        received_packet[7], received_packet[6],
                        received_packet[5], received_packet[4],
                        received_packet[3], received_packet[2],
                        received_packet[1], received_packet[0]
                    };

                    new_scan_code <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule

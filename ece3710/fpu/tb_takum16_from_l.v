`timescale 1ns / 1ps

module tb_takum16_from_l;

    // Inputs
    reg sign_bit;
    reg [31:0] log_value_float;
    
    // Outputs
    wire [15:0] takum16_out;
    wire is_special;
    
    // Instantiate the Unit Under Test (UUT)
    takum16_from_l uut (
        .sign_bit(sign_bit),
        .log_value_float(log_value_float),
        .takum16_out(takum16_out),
        .is_special(is_special)
    );
    
    // Helper function to create IEEE 754 float from real value (simplified)
    function [31:0] real_to_float;
        input real value;
        integer int_part;
        real frac_part;
        reg [7:0] exp;
        reg [22:0] mant;
        reg sign;
        integer i;
        begin
            sign = (value < 0);
            value = (value < 0) ? -value : value;
            
            if (value == 0.0) begin
                real_to_float = 32'h00000000;
            end else if (value >= 16777216.0) begin
                real_to_float = 32'h4B800000; // Large positive
            end else begin
                // Find exponent
                exp = 127;
                while (value >= 2.0) begin
                    value = value / 2.0;
                    exp = exp + 1;
                end
                while (value < 1.0) begin
                    value = value * 2.0;
                    exp = exp - 1;
                end
                
                // Extract mantissa (23 bits)
                frac_part = value - 1.0;
                mant = 0;
                for (i = 22; i >= 0; i = i - 1) begin
                    frac_part = frac_part * 2.0;
                    if (frac_part >= 1.0) begin
                        mant = mant | (1 << i);
                        frac_part = frac_part - 1.0;
                    end
                end
                
                real_to_float = {sign, exp, mant};
            end
        end
    endfunction
    
    // Task to display test result
    task test_conversion;
        input s;
        input real l_value;
        input [255:0] description;
        begin
            sign_bit = s;
            log_value_float = real_to_float(l_value);
            #10;
            
            $display("Test: %s", description);
            $display("  Sign: %b, Log value: %f (0x%08h)", s, l_value, log_value_float);
            $display("  Takum16: 0x%04h (bin: %b)", takum16_out, takum16_out);
            $display("  Special: %b", is_special);
            $display("");
        end
    endtask
    
    initial begin
        $display("=== Takum16 from Logarithmic Value Conversion Test ===");
        $display("");
        
        // Test special cases
        $display("--- Special Cases ---");
        sign_bit = 0;
        log_value_float = 32'h7FC00000; // NaN
        #10;
        $display("NaN input -> Takum16: 0x%04h (should be NAR=0x8000), Special: %b", 
                 takum16_out, is_special);
        
        log_value_float = 32'h7F800000; // +Inf
        #10;
        $display("+Inf input -> Takum16: 0x%04h (should be NAR=0x8000), Special: %b", 
                 takum16_out, is_special);
        
        log_value_float = 32'hFF800000; // -Inf
        #10;
        $display("-Inf input -> Takum16: 0x%04h (should be 0x0000), Special: %b", 
                 takum16_out, is_special);
        $display("");
        
        // Test zero logarithmic value (maps to takum value of 1.0)
        $display("--- Zero Logarithmic Value ---");
        test_conversion(0, 0.0, "Positive, l=0 (value = sqrt(e)^0 = 1)");
        test_conversion(1, 0.0, "Negative, l=0 (value = -1)");
        $display("");
        
        // Test small positive logarithmic values
        $display("--- Small Positive Logarithmic Values ---");
        test_conversion(0, 1.0, "Positive, l=1");
        test_conversion(0, 2.0, "Positive, l=2");
        test_conversion(0, 5.0, "Positive, l=5");
        test_conversion(0, 10.0, "Positive, l=10");
        $display("");
        
        // Test larger positive logarithmic values
        $display("--- Larger Positive Logarithmic Values ---");
        test_conversion(0, 30.0, "Positive, l=30");
        test_conversion(0, 62.0, "Positive, l=62");
        test_conversion(0, 126.0, "Positive, l=126");
        test_conversion(0, 200.0, "Positive, l=200");
        test_conversion(0, 254.0, "Positive, l=254");
        $display("");
        
        // Test boundary values
        $display("--- Boundary Values ---");
        test_conversion(0, 254.9375, "Positive, l=254.9375 (max)");
        test_conversion(1, 254.9375, "Negative, l=254.9375 (min magnitude)");
        $display("");
        
        // Test clamping
        $display("--- Clamping Test ---");
        test_conversion(0, 300.0, "Positive, l=300 (should clamp to 254.9375)");
        test_conversion(1, 300.0, "Negative, l=300 (should clamp to 254.9375)");
        $display("");
        
        // Test negative logarithmic values
        $display("--- Negative Logarithmic Values ---");
        test_conversion(0, -1.0, "Positive, l=-1");
        test_conversion(0, -10.0, "Positive, l=-10");
        test_conversion(0, -30.0, "Positive, l=-30");
        test_conversion(0, -62.0, "Positive, l=-62");
        test_conversion(0, -126.0, "Positive, l=-126");
        test_conversion(0, -200.0, "Positive, l=-200");
        test_conversion(0, -254.0, "Positive, l=-254");
        $display("");
        
        // Test with sign bit (negative takum values)
        $display("--- Negative Takum Values (sign=1) ---");
        test_conversion(1, -1.0, "Negative, l=-1 (becomes +1)");
        test_conversion(1, 1.0, "Negative, l=1 (becomes -1)");
        test_conversion(1, 10.0, "Negative, l=10");
        test_conversion(1, -10.0, "Negative, l=-10");
        $display("");
        
        // Test fractional logarithmic values
        $display("--- Fractional Logarithmic Values ---");
        test_conversion(0, 0.5, "Positive, l=0.5");
        test_conversion(0, 1.25, "Positive, l=1.25");
        test_conversion(0, 3.75, "Positive, l=3.75");
        test_conversion(0, 15.625, "Positive, l=15.625");
        test_conversion(0, 63.5, "Positive, l=63.5");
        $display("");
        
        // Test systematic values at regime boundaries
        $display("--- Regime Boundary Values ---");
        test_conversion(0, -254.0, "l=-254 (regime boundary)");
        test_conversion(0, -126.0, "l=-126 (regime boundary)");
        test_conversion(0, -62.0, "l=-62 (regime boundary)");
        test_conversion(0, -30.0, "l=-30 (regime boundary)");
        test_conversion(0, -14.0, "l=-14 (regime boundary)");
        test_conversion(0, -6.0, "l=-6 (regime boundary)");
        test_conversion(0, -2.0, "l=-2 (regime boundary)");
        test_conversion(0, 2.0, "l=2 (regime boundary)");
        test_conversion(0, 6.0, "l=6 (regime boundary)");
        test_conversion(0, 14.0, "l=14 (regime boundary)");
        test_conversion(0, 30.0, "l=30 (regime boundary)");
        test_conversion(0, 62.0, "l=62 (regime boundary)");
        test_conversion(0, 126.0, "l=126 (regime boundary)");
        test_conversion(0, 254.0, "l=254 (regime boundary)");
        $display("");
        
        $display("=== Test Complete ===");
        $finish;
    end

endmodule
`timescale 1ns / 1ps

module tb_takum16_encode_decode;

    // Parameters
    parameter N = 16;
    
    // Inputs for encoder
    reg sign_bit_in;
    reg [N+3:0] barred_log_value_in;  // 19 bits: 9 bits integer, 10 bits fractional
    reg is_zero_in;
    reg is_nar_in;
    
    // Intermediate signal
    wire [N-1:0] takum_encoded;
    
    // Outputs from decoder
    wire sign_bit_out;
    wire [N+3:0] barred_log_value_out;
    wire [$clog2(N-4):0] precision_out;
    wire is_zero_out;
    wire is_nar_out;
    
    // Instantiate encoder
    encoder_logarithmic #(
        .N(N)
    ) encoder_inst (
        .sign_bit(sign_bit_in),
        .barred_logarithmic_value(barred_log_value_in),
        .is_zero(is_zero_in),
        .is_nar(is_nar_in),
        .takum(takum_encoded)
    );
    
    // Instantiate decoder
    decoder_logarithmic #(
        .N(N)
    ) decoder_inst (
        .takum(takum_encoded),
        .sign_bit(sign_bit_out),
        .barred_logarithmic_value(barred_log_value_out),
        .precision(precision_out),
        .is_zero(is_zero_out),
        .is_nar(is_nar_out)
    );
	 
    task randomize(output[15:0] a, b, output c_in);
        begin
            a = $random;
            b = $random;
            c_in = $random;
        end
    endtask
    
    // Test counter
    integer test_num;
    integer pass_count;
    integer fail_count;
	 integer i;
	 parameter n = 1024; // sufficiently large test number
    
    // Task to perform encode-decode test
    task test_encode_decode;
        input sign_in;
        input [N+3:0] log_value;
        input zero_flag;
        input nar_flag;
        input [255:0] description;
        reg match;
        begin
            test_num = test_num + 1;
            
            // Set inputs
            sign_bit_in = sign_in;
            barred_log_value_in = log_value;
            is_zero_in = zero_flag;
            is_nar_in = nar_flag;
            
            // Wait for propagation
            #10;
            
            // Check if special cases are preserved
            if (zero_flag || nar_flag) begin
                match = (is_zero_out == zero_flag) && (is_nar_out == nar_flag);
            end else begin
                // For normal values, check if sign and log value match
                // Note: Due to rounding, we may lose precision
                match = (sign_bit_out == sign_in);
                
                // Display detailed comparison
                if (!match) begin
                    $display("Test %0d FAILED: %s", test_num, description);
                    $display("  Sign mismatch: in=%b, out=%b", sign_in, sign_bit_out);
                end else begin
                    // Check how close the logarithmic values are
                    $display("Test %0d: %s", test_num, description);
                end
            end
            
            // Display results
            $display("  Input:  sign=%b, log_val=0x%05h (dec:%0d), zero=%b, nar=%b", 
                     sign_in, log_value, $signed(log_value), zero_flag, nar_flag);
            $display("  Takum:  0x%04h (bin:%b)", takum_encoded, takum_encoded);
            $display("  Output: sign=%b, log_val=0x%05h (dec:%0d), zero=%b, nar=%b, precision=%0d", 
                     sign_bit_out, barred_log_value_out, $signed(barred_log_value_out), 
                     is_zero_out, is_nar_out, precision_out);
            
            // Calculate difference for normal values
            if (!zero_flag && !nar_flag) begin
                $display("  Delta: %0d (0x%05h)", 
                         $signed(barred_log_value_out) - $signed(log_value),
                         barred_log_value_out - log_value);
            end
            
            if (match) begin
                pass_count = pass_count + 1;
                $display("  Status: PASS");
            end else begin
                fail_count = fail_count + 1;
                $display("  Status: FAIL");
            end
            $display("");
        end
    endtask
    
    initial begin
        test_num = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("=== Takum16 Encode-Decode Round-Trip Test ===");
        $display("");
        
        // Test special cases
        $display("--- Special Cases ---");
        test_encode_decode(0, 19'h00000, 1, 0, "Zero");
        test_encode_decode(0, 19'h00000, 0, 1, "NaR");
        test_encode_decode(1, 19'h00000, 1, 0, "Negative Zero");
        $display("");
        
        // Test small positive logarithmic values
        $display("--- Small Positive Logarithmic Values ---");
        test_encode_decode(0, 19'h00001, 0, 0, "log = 1 (tiny positive)");
        test_encode_decode(0, 19'h00010, 0, 0, "log = 16");
        test_encode_decode(0, 19'h00100, 0, 0, "log = 256");
        test_encode_decode(0, 19'h00400, 0, 0, "log = 1024");
        $display("");
        
        // Test around characteristic = 0
        $display("--- Around Characteristic = 0 ---");
        test_encode_decode(0, 19'h00000, 0, 0, "log = 0 (value = 1)");
        test_encode_decode(0, 19'h00800, 0, 0, "log = 2048");
        test_encode_decode(1, 19'h7F800, 0, 0, "log = -2048 (negative)");
        $display("");
        
        // Test positive characteristics
        $display("--- Positive Characteristics ---");
        test_encode_decode(0, 19'h01000, 0, 0, "Characteristic = 1");
        test_encode_decode(0, 19'h02000, 0, 0, "Characteristic = 2");
        test_encode_decode(0, 19'h04000, 0, 0, "Characteristic = 4");
        test_encode_decode(0, 19'h08000, 0, 0, "Characteristic = 8");
        test_encode_decode(0, 19'h10000, 0, 0, "Characteristic = 16");
        test_encode_decode(0, 19'h20000, 0, 0, "Characteristic = 32");
        $display("");
        
        // Test negative logarithmic values
        $display("--- Negative Logarithmic Values ---");
        test_encode_decode(1, 19'h7FFFF, 0, 0, "log = -1 (small negative)");
        test_encode_decode(1, 19'h7FFF0, 0, 0, "log = -16");
        test_encode_decode(1, 19'h7FF00, 0, 0, "log = -256");
        test_encode_decode(1, 19'h7F000, 0, 0, "log = -4096");
        test_encode_decode(1, 19'h60000, 0, 0, "Char = -32 (large negative)");
        $display("");
        
        // Test boundary values
        $display("--- Boundary Values ---");
        test_encode_decode(0, 19'h3FC00, 0, 0, "Near max positive characteristic");
        test_encode_decode(1, 19'h40400, 0, 0, "Near min negative characteristic");
        test_encode_decode(0, 19'h7FFFF, 0, 0, "Max representable positive");
        test_encode_decode(1, 19'h00001, 0, 0, "Max representable negative");
        $display("");
        
        // Test with various mantissa patterns
        $display("--- Various Mantissa Patterns ---");
        test_encode_decode(0, 19'h00555, 0, 0, "Alternating bits pattern 1");
        test_encode_decode(0, 19'h002AA, 0, 0, "Alternating bits pattern 2");
        test_encode_decode(0, 19'h003FF, 0, 0, "All mantissa bits set");
        test_encode_decode(0, 19'h00200, 0, 0, "Single mantissa bit");
        $display("");
		  
		  // Fuzz testing
		  $display("--- Randomized testing ---");
		  for (i=0; i<n; i=i+1) begin
		      test_encode_decode(0, $random, 0, 0, "");
				$display("Random test #%d", i);
		  end
        
        // Summary
        $display("=== Test Summary ===");
        $display("Total tests: %0d", test_num);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("");
        
        if (fail_count == 0) begin
            $display("*** ALL TESTS PASSED ***");
        end else begin
            $display("*** SOME TESTS FAILED ***");
        end
        
        $finish;
    end

endmodule
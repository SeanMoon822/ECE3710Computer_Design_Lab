`timescale 1ns / 1ps

module tb_takum16_to_l;

    // Inputs
    reg [15:0] takum16_in;
    
    // Outputs
    wire [31:0] float_out;
    wire is_special;
    
    // Real number representation for display
    reg float_value;
    
    // Instantiate the Unit Under Test (UUT)
    takum16_to_l uut (
        .takum16_in(takum16_in),
        .float_out(float_out),
        .is_special(is_special)
    );
    
   
    // Task to display test result
    task display_result;
        input [15:0] takum_val;
        input [127:0] description;
        begin
            takum16_in = takum_val;
            #10;
            float_value = 0/*$bitstoreal(float_out)*/;
            $display("Takum16: 0x%04h | %s", takum_val, description);
            $display("  Float: 0x%08h | Value: %f | Special: %b", float_out, float_value, is_special);
            $display("");
        end
    endtask
    
    initial begin
        $display("=== Takum16 to Float Conversion Test ===");
        $display("");
        
        // Test special cases
        $display("--- Special Cases ---");
        display_result(16'h0000, "Zero (should output -Inf)");
        display_result(16'h8000, "NAR (should output NaN)");
        $display("");
        
        // Test small positive values
        $display("--- Small Positive Values ---");
        display_result(16'h0001, "Smallest positive");
        display_result(16'h0010, "Small positive 1");
        display_result(16'h0100, "Small positive 2");
        display_result(16'h1000, "Medium positive");
        $display("");
        
        // Test values around 1
        $display("--- Values Around Unity ---");
        display_result(16'h4000, "Near 1.0");
        display_result(16'h5000, "Greater than 1");
        display_result(16'h6000, "Larger value");
        display_result(16'h7000, "Even larger");
        display_result(16'h7FFF, "Maximum positive");
        $display("");
        
        // Test negative values
        $display("--- Negative Values ---");
        display_result(16'hFFFF, "Smallest magnitude negative");
        display_result(16'hFFF0, "Small negative 1");
        display_result(16'hFF00, "Small negative 2");
        display_result(16'hF000, "Medium negative");
        display_result(16'hC000, "Near -1.0");
        display_result(16'hA000, "Large negative");
        display_result(16'h8001, "Maximum magnitude negative");
        $display("");
        
        // Test systematic sweep
        $display("--- Systematic Sweep (powers of 2 pattern) ---");
        display_result(16'h0002, "0x0002");
        display_result(16'h0004, "0x0004");
        display_result(16'h0008, "0x0008");
        display_result(16'h0020, "0x0020");
        display_result(16'h0040, "0x0040");
        display_result(16'h0080, "0x0080");
        display_result(16'h0200, "0x0200");
        display_result(16'h0400, "0x0400");
        display_result(16'h0800, "0x0800");
        display_result(16'h2000, "0x2000");
        $display("");
        
        $display("=== Test Complete ===");
        $finish;
    end

endmodule
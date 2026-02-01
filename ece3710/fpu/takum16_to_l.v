// See LICENSE file for copyright and license details
// This module implements the following C function from libtakum:

//float codec_takum16_to_l(takum16 t)
//{
//	const union util_takum16_union in = {
//		.value = t,
//	};
//	int_fast16_t c;
//	uint16_t M;
//
//	/* Catch special cases */
//	if (t == 0) {
//		return -INFINITY;
//	} else if (t == TAKUM16_NAR) {
//		return NAN;
//	}
//
//	/*
//	 * Get mantissa bits by shifting so far
//	 *
//	 */
//	M = in.bits << get_c_and_return_shift(in.bits, &c);
//
//	/*
//	 * Convert c and M to floats and add them. The
//	 * conversions and the addition are lossless as
//	 * |c| is at most 8 bits, M is at most 11 bits,
//	 * which easily fits in the 23 bits provided by
//	 * float32.
//	 */
//	return (1 - 2 * (t < 0)) * ((float)c + ldexpf((float)M, -16));
//}

module takum16_to_l (
    input  wire [15:0] takum16_in,
    output reg  [31:0] float_out,      // IEEE 754 single precision
    output reg         is_special      // indicates NaN or -Inf output
);

    // Takum constants
    localparam [15:0] TAKUM16_ZERO = 0;
    localparam [15:0] TAKUM16_NAR  = 16'h8000; // #define TAKUM16_NAR (INT16_C(-32767) - INT16_C(1))
    
    // IEEE 754 constants
    localparam [31:0] IEEE_NEG_INF = 32'hFF800000;  // "negative infinity is represented with a sign bit of 1, a biased exponent of all 1 bits, and a fraction of all 0 bits."
    localparam [31:0] IEEE_NAN     = 32'h7FC00000; 
    
    // Internal signals
    wire sign_bit;
    wire signed [8:0] characteristic;
    wire [10:0] mantissa_bits;
    wire [3:0] precision;
    wire is_zero, is_nar;
    
    // Floating point conversion signals
    reg signed [8:0] c_adjusted;
    reg [15:0] M_shifted;
    reg [31:0] c_float;
    reg [31:0] M_float;
    reg [31:0] result_positive;
	 wire [31:0] result_positive_addition;
    
    // Instantiate the predecoder
    predecoder #(
        .N(16),
        .OUTPUT_EXPONENT(1'b0)  // We want characteristic, not exponent, so we can directly plug it in
    ) predec_inst (
        .takum(takum16_in),
        .sign_bit(sign_bit),
        .characteristic_or_exponent(characteristic),
        .mantissa_bits(mantissa_bits),
        .precision(precision),
        .is_zero(is_zero),
        .is_nar(is_nar)
    );
	 
	 // Intermediate addition
    FloatingAddition adder(
        .A(c_float),
        .B(M_float),
        .result(result_positive_addition)
    );
    
    always @(*) begin
	     // Prevent latches by assigning default value
		  c_float = 0;
		  M_float = 0;
		  result_positive = 0;
		  
        // Handle special cases
        if (is_zero) begin
            float_out = IEEE_NEG_INF;
            is_special = 1'b1;
        end else if (is_nar) begin
            float_out = IEEE_NAN;
            is_special = 1'b1;
        end else begin
            is_special = 1'b0;
            
            // The mantissa is already shifted by the predecoder
            // Convert characteristic to float
            c_float = int_to_float(characteristic);
            
            // Convert mantissa to float and scale by 2^-16 (ldexpf(M, -16))
            // M is a 16-bit integer representing a fractional value
            M_float = ldexpf({5'b0, mantissa_bits}, -16);
            
            // Add c and M: result = c + M * 2^-16
				result_positive = result_positive_addition;
            
            // Apply sign: (1 - 2 * (t < 0)) * result
            // If sign_bit is 0 (positive), multiply by 1
            // If sign_bit is 1 (negative), multiply by -1
            float_out = sign_bit ? float_negate(result_positive) : result_positive;
        end
    end
    
    // Helper function: Convert signed integer to IEEE 754 float
    function [31:0] int_to_float;
        input signed [8:0] value;
        reg [7:0] abs_value;
        reg sign;
        reg [7:0] exponent;
        reg [22:0] mantissa;
        integer shift;
        begin
            // Initialize all variables to prevent latches
            sign = 1'b0;
            abs_value = 8'b0;
            exponent = 8'b0;
            mantissa = 23'b0;            
				shift = 0;
				
            if (value == 0) begin
                int_to_float = 32'h00000000;
            end else begin
                sign = value[8];
                abs_value = sign ? -value[7:0] : value[7:0];
                
                // Find leading one position (normalize)
                if (abs_value[7]) shift = 7;
                else if (abs_value[6]) shift = 6;
                else if (abs_value[5]) shift = 5;
                else if (abs_value[4]) shift = 4;
                else if (abs_value[3]) shift = 3;
                else if (abs_value[2]) shift = 2;
                else if (abs_value[1]) shift = 1;
                else shift = 0;
                
                // IEEE 754: exponent = shift + 127 (bias)
                exponent = shift + 127;
                
                // Mantissa: normalized value with implicit leading 1 removed
                mantissa = (abs_value << (23 - shift)) & 23'h7FFFFF;
                
                int_to_float = {sign, exponent, mantissa};
            end
        end
    endfunction
    
    // Helper function: Convert unsigned integer to float and scale by 2^scale_exp
    function [31:0] ldexpf;
        input [15:0] value;
        input signed [7:0] scale_exp;
        reg [7:0] exponent;
        reg [22:0] mantissa;
        integer shift;
        begin
		      // Initialize all variables to prevent latches
            exponent = 8'b0;
            mantissa = 23'b0;            
				shift = 15;
				
            if (value == 0) begin
                ldexpf = 0;
            end else begin
                // priority encoder
                if (!value[15]) shift = 14;
                if (!value[15:14]) shift = 13;
                if (!value[15:13]) shift = 12;
                if (!value[15:12]) shift = 11;
                if (!value[15:11]) shift = 10;
                if (!value[15:10]) shift = 9;
                if (!value[15:9]) shift = 8;
                if (!value[15:8]) shift = 7;
                if (!value[15:7]) shift = 6;
                if (!value[15:6]) shift = 5;
                if (!value[15:5]) shift = 4;
                if (!value[15:4]) shift = 3;
                if (!value[15:3]) shift = 2;
                if (!value[15:2]) shift = 1;
                if (!value[15:1]) shift = 0;
                
                // Exponent includes normalization shift and scaling
                exponent = shift + scale_exp + 127;
                
                // Extract mantissa
                mantissa = (value << (23 - shift)) & 23'h7FFFFF;
                
                ldexpf = {1'b0, exponent, mantissa};
            end
        end
    endfunction
    
    // Helper function: Negate IEEE 754 float
    function [31:0] float_negate;
        input [31:0] value;
        begin
            float_negate = {~value[31], value[30:0]};
        end
    endfunction
	 
	 initial begin $display("got here!3"); end

endmodule
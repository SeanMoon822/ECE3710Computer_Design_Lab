// See LICENSE file for copyright and license details
// This module implements the following C function from libtakum:
//
// takum_log16
// codec_takum_log16_from_s_and_l(bool s, double l)
// {
// 	uint_fast8_t DR;
// 	uint8_t p;
// 	uint64_t M;
// 	int_fast16_t c;
// 	double cpm, m;
// 	const double bound = 254.9375;
// 
// 	if (isnan(l) || (isinf(l) && l > 0)) {
// 		return TAKUM_LOG16_NAR;
// 	} else if (isinf(l) && l < 0) {
// 		return 0;
// 	}
// 
// 	/*
// 	 * Clamp l to representable exponents,
// 	 * the maximum 0111111111111111 has l=254.9375
// 	 */
// 	l = (l < -bound) ? -bound : (l > bound) ? bound : l;
// 
// 	/* Apply sign to l to obtain c + m (cpm) */
// 	cpm = (1 - 2 * s) * l;
// 
// 	/* Obtain c and m from cpm */
// 	c = floor(cpm);
// 	m = cpm - c;
// 
// 	/* m could have overflowed to 1.0 */
// 	if (m == 1.0) {
// 		c += 1;
// 		m = 0.0;
// 	}
// 
// 	/* Determine DR */
// 	DR = get_DR_from_c(c);
// 
// 	/*
// 	 * Determine p, which is simple as p_lut is for a 16-bit
// 	 * takum.
// 	 */
// 	p = p_lut[DR];
// 
// 	/* Determine mantissa bits */
// 	M = float64_fraction_to_rounded_bits(m, p);
// 
// 	/*
// 	 * Assemble, optionally apply the carry to SDR which is guaranteed
// 	 * not to yield NaR as we bounded l earlier and return
// 	 */
// 	return ((((uint16_t)s) << (16 - 1)) | (((uint16_t)DR) << (16 - 5)) |
// 	        (((uint16_t)(c - c_bias_lut[DR])) << p)) +
// 	       (uint16_t)M;
// }

module takum16_from_l (
    input  wire        sign_bit,
    input  wire [31:0] log_value_float,  // IEEE 754 single precision
    output reg  [15:0] takum16_out,
    output reg         is_special         // indicates NaN or zero output
);

    // Takum constants
    localparam [15:0] TAKUM16_ZERO = 16'h0000;
    localparam [15:0] TAKUM16_NAR  = 16'h8000;
    
    // Bound for representable logarithmic values
    // Maximum takum16 0111111111111111 has l = 254 + 15/16 = 254.9375
    localparam [31:0] BOUND = 32'h437EF000; // 254.9375 in IEEE 754
    localparam [31:0] NEG_BOUND = 32'hC37EF000; // -254.9375
    
    // IEEE 754 special values
    localparam [31:0] IEEE_POS_INF = 32'h7F800000;
    localparam [31:0] IEEE_NEG_INF = 32'hFF800000;
    
    // Internal signals
    reg [31:0] l_clamped;
    reg [31:0] cpm;  // c + m (characteristic plus mantissa)
    reg signed [8:0] c;  // characteristic
    reg [31:0] m_float;  // mantissa as float
    reg [15:0] M_bits;   // mantissa as bits
    reg [3:0] DR;        // Direction-Regime (4 bits: 1 direction + 3 regime)
    reg [3:0] p;         // precision (number of mantissa bits)
    reg signed [10:0] c_biased;
    
    // LUT from original specification
    function [3:0] get_p_from_DR;
        input [3:0] DR_val;
        begin
            case (DR_val)
                4'h0: get_p_from_DR = 4;  // 0 000 → D=0, r=7
                4'h1: get_p_from_DR = 5;  // 0 001 → D=0, r=6
                4'h2: get_p_from_DR = 6;  // 0 010 → D=0, r=5
                4'h3: get_p_from_DR = 7;  // 0 011 → D=0, r=4
                4'h4: get_p_from_DR = 8;  // 0 100 → D=0, r=3
                4'h5: get_p_from_DR = 9;  // 0 101 → D=0, r=2
                4'h6: get_p_from_DR = 10; // 0 110 → D=0, r=1
                4'h7: get_p_from_DR = 11; // 0 111 → D=0, r=0
                4'h8: get_p_from_DR = 11; // 1 000 → D=1, r=0
                4'h9: get_p_from_DR = 10; // 1 001 → D=1, r=1
                4'hA: get_p_from_DR = 9;  // 1 010 → D=1, r=2
                4'hB: get_p_from_DR = 8;  // 1 011 → D=1, r=3
                4'hC: get_p_from_DR = 7;  // 1 100 → D=1, r=4
                4'hD: get_p_from_DR = 6;  // 1 101 → D=1, r=5
                4'hE: get_p_from_DR = 5;  // 1 110 → D=1, r=6
                4'hF: get_p_from_DR = 4;  // 1 111 → D=1, r=7
            endcase
        end
    endfunction
    
    // LUT from original specification
    function signed [9:0] get_c_bias_from_DR;
        input [3:0] DR_val;
        begin
            case (DR_val)
                4'h0: get_c_bias_from_DR = -10'sd255; // 0 000 → D=0, r=7, -2^(r+1)+1
                4'h1: get_c_bias_from_DR = -10'sd127; // 0 001 → D=0, r=6, -2^(r+1)+1
                4'h2: get_c_bias_from_DR = -10'sd63;  // 0 010 → D=0, r=5, -2^(r+1)+1
                4'h3: get_c_bias_from_DR = -10'sd31;  // 0 011 → D=0, r=4, -2^(r+1)+1
                4'h4: get_c_bias_from_DR = -10'sd15;  // 0 100 → D=0, r=3, -2^(r+1)+1
                4'h5: get_c_bias_from_DR = -10'sd7;   // 0 101 → D=0, r=2, -2^(r+1)+1
                4'h6: get_c_bias_from_DR = -10'sd3;   // 0 110 → D=0, r=1, -2^(r+1)+1
                4'h7: get_c_bias_from_DR = -10'sd1;   // 0 111 → D=0, r=0, -2^(r+1)+1
                4'h8: get_c_bias_from_DR = 10'sd0;    // 1 000 → D=1, r=0, 2^r-1
                4'h9: get_c_bias_from_DR = 10'sd1;    // 1 001 → D=1, r=1, 2^r-1
                4'hA: get_c_bias_from_DR = 10'sd3;    // 1 010 → D=1, r=2, 2^r-1
                4'hB: get_c_bias_from_DR = 10'sd7;    // 1 011 → D=1, r=3, 2^r-1
                4'hC: get_c_bias_from_DR = 10'sd15;   // 1 100 → D=1, r=4, 2^r-1
                4'hD: get_c_bias_from_DR = 10'sd31;   // 1 101 → D=1, r=5, 2^r-1
                4'hE: get_c_bias_from_DR = 10'sd63;   // 1 110 → D=1, r=6, 2^r-1
                4'hF: get_c_bias_from_DR = 10'sd127;  // 1 111 → D=1, r=7, 2^r-1
            endcase
        end
    endfunction
    
    // Determine DR from characteristic (implements get_DR_from_c)
    // Uses linear search through c_bias_lut
    function [3:0] get_DR_from_c;
        input signed [8:0] c_val;
        reg [3:0] DR;
        reg signed [9:0] next_bias;
        begin
            // Start at 0, or 8 if c is positive (skip first half)
            DR = (c_val >= 0) ? 4'd8 : 4'd0;
            
            // Linear search: find DR where c_bias_lut[DR] <= c < c_bias_lut[DR+1]
            if (DR == 4'd0) begin
                // Check DR 0-7 (negative c)
                if (c_val >= get_c_bias_from_DR(4'd1)) DR = 4'd1;
                if (c_val >= get_c_bias_from_DR(4'd2)) DR = 4'd2;
                if (c_val >= get_c_bias_from_DR(4'd3)) DR = 4'd3;
                if (c_val >= get_c_bias_from_DR(4'd4)) DR = 4'd4;
                if (c_val >= get_c_bias_from_DR(4'd5)) DR = 4'd5;
                if (c_val >= get_c_bias_from_DR(4'd6)) DR = 4'd6;
                if (c_val >= get_c_bias_from_DR(4'd7)) DR = 4'd7;
            end else begin
                // Check DR 8-15 (positive c)
                if (c_val >= get_c_bias_from_DR(4'd9)) DR = 4'd9;
                if (c_val >= get_c_bias_from_DR(4'd10)) DR = 4'd10;
                if (c_val >= get_c_bias_from_DR(4'd11)) DR = 4'd11;
                if (c_val >= get_c_bias_from_DR(4'd12)) DR = 4'd12;
                if (c_val >= get_c_bias_from_DR(4'd13)) DR = 4'd13;
                if (c_val >= get_c_bias_from_DR(4'd14)) DR = 4'd14;
                if (c_val >= get_c_bias_from_DR(4'd15)) DR = 4'd15;
            end
            
            get_DR_from_c = DR;
        end
    endfunction
    
    // Helper function to check if float is NaN
    function is_nan;
        input [31:0] f;
        begin
            is_nan = (f[30:23] == 8'hFF) && (f[22:0] != 0);
        end
    endfunction
	 
	 // Helper function: Negate IEEE 754 float
    function [31:0] float_negate;
        input [31:0] value;
        begin
            float_negate = {~value[31], value[30:0]};
        end
    endfunction
    
    // Helper function: floor of float (simplified for our use case)
    function [31:0] float_floor;
        input [31:0] f;
        reg [7:0] exp;
        reg [23:0] mant;
        reg sign;
        reg [4:0] shift;
        begin
            sign = f[31];
            exp = f[30:23];
            mant = {1'b1, f[22:0]};
				shift = 0;
            
            if (exp < 127) begin
                // Value is between -1 and 1
                float_floor = sign ? 32'hBF800000 : 32'h00000000; // -1 or 0
            end else if (exp >= 150) begin
                // No fractional part
                float_floor = f;
            end else begin
                // Shift to remove fractional bits
                shift = 150 - exp;
                mant = mant >> shift;
                mant = mant << shift;
                float_floor = {sign, exp, mant[22:0]};
            end
        end
    endfunction
	 
	 // Intermediate subtraction
	 wire sub_result;
    FloatingAddition subtracter(
        .A(cpm),
        .B(float_negate(c)),
        .result(sub_result)
    );
    
    always @(*) begin
        // Default assignments
        is_special = 1'b0;
		  l_clamped = 0;
		  cpm = 0;
		  c = 0;
		  m_float = 0;
		  DR = 0;
		  p = 0;
		  M_bits = 0;
		  c_biased = 0;
        takum16_out = TAKUM16_ZERO;
        
        // Check for special cases
        if (is_nan(log_value_float) || (log_value_float == IEEE_POS_INF)) begin
            takum16_out = TAKUM16_NAR;
            is_special = 1'b1;
        end else if (log_value_float == IEEE_NEG_INF) begin
            takum16_out = TAKUM16_ZERO;
            is_special = 1'b1;
        end else begin
            // Clamp l to representable range
            if ($signed(log_value_float) < $signed(NEG_BOUND)) begin
                l_clamped = NEG_BOUND;
            end else if ($signed(log_value_float) > $signed(BOUND)) begin
                l_clamped = BOUND;
            end else begin
                l_clamped = log_value_float;
            end
            
            // Apply sign to get c + m
            if (sign_bit) begin
                cpm = {~l_clamped[31], l_clamped[30:0]}; // Negate
            end else begin
                cpm = l_clamped;
            end
            
            // Extract characteristic and mantissa. done with subtracter unit
            c = float_to_int(float_floor(cpm));
            m_float = sub_result;
            
            // Handle m overflow to 1.0
            if (m_float == 32'h3F800000) begin // 1.0
                c = c + 1;
                m_float = 32'h00000000; // 0.0
            end
            
            // Determine DR
            DR = get_DR_from_c(c);
            
            // Determine precision
            p = get_p_from_DR(DR);
            
            // Convert mantissa to bits with rounding
            M_bits = float_fraction_to_rounded_bits(m_float, p);
            
            // Get characteristic bias
            c_biased = c - get_c_bias_from_DR(DR);
            
            // Assemble takum... We would like to do
            // takum16_out = ({sign_bit, DR[3], DR[2:0], c_biased[p-1:0]} << p) + M_bits;
				// but we cannot shift by a non-constant in Verilog.
				// We manually assemble takum based on DR (which determines p):
				
            // Format: S | D | RRR | characteristic_bits | mantissa_bits
				// the original is  ((s << (16 - 1)) | (DR << (16 - 5)) | (((c - c_bias_lut[DR])) << p)) + M;
            case (DR)
                4'h0: takum16_out = {sign_bit, DR[3:0], c_biased[3:0], 4'b0} + M_bits;    // p=4
                4'h1: takum16_out = {sign_bit, DR[3:0], c_biased[4:0], 5'b0} + M_bits;    // p=5
                4'h2: takum16_out = {sign_bit, DR[3:0], c_biased[5:0], 6'b0} + M_bits;    // p=6
                4'h3: takum16_out = {sign_bit, DR[3:0], c_biased[6:0], 7'b0} + M_bits;    // p=7
                4'h4: takum16_out = {sign_bit, DR[3:0], c_biased[7:0], 8'b0} + M_bits;    // p=8
                4'h5: takum16_out = {sign_bit, DR[3:0], c_biased[8:0], 9'b0} + M_bits;    // p=9
                4'h6: takum16_out = {sign_bit, DR[3:0], c_biased[9:0], 10'b0} + M_bits;   // p=10
                4'h7: takum16_out = {sign_bit, DR[3:0], c_biased[10:0], 11'b0} + M_bits;  // p=11
                4'h8: takum16_out = {sign_bit, DR[3:0], c_biased[10:0], 11'b0} + M_bits;  // p=11
                4'h9: takum16_out = {sign_bit, DR[3:0], c_biased[9:0], 10'b0} + M_bits;   // p=10
                4'hA: takum16_out = {sign_bit, DR[3:0], c_biased[8:0], 9'b0} + M_bits;    // p=9
                4'hB: takum16_out = {sign_bit, DR[3:0], c_biased[7:0], 8'b0} + M_bits;    // p=8
                4'hC: takum16_out = {sign_bit, DR[3:0], c_biased[6:0], 7'b0} + M_bits;    // p=7
                4'hD: takum16_out = {sign_bit, DR[3:0], c_biased[5:0], 6'b0} + M_bits;    // p=6
                4'hE: takum16_out = {sign_bit, DR[3:0], c_biased[4:0], 5'b0} + M_bits;    // p=5
                4'hF: takum16_out = {sign_bit, DR[3:0], c_biased[3:0], 4'b0} + M_bits;    // p=4
            endcase
        end
    end
    
    // Convert float to integer (extract integer part)
    function signed [8:0] float_to_int;
        input [31:0] f;
        reg [7:0] exp;
        reg [23:0] mant;
        reg sign;
        begin
            sign = f[31];
            exp = f[30:23];
            mant = {1'b1, f[22:0]};
            
            if (exp < 127) begin
                float_to_int = 0;
            end else if (exp >= 135) begin
                // Too large; saturate
                float_to_int = sign ? -9'd255 : 9'd254;
            end else begin
                float_to_int = mant >> (150 - exp);
                if (sign) float_to_int = -float_to_int;
            end
        end
    endfunction
    
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
    
    // Convert fractional float to rounded bits
    function [15:0] float_fraction_to_rounded_bits;
        input [31:0] frac;
        input [3:0] num_bits;
        reg [31:0] scaled;
        reg [15:0] result;
        begin
            // Scale by 2^16 and round
            scaled = float_mul_pow2(frac, 16);
            result = float_to_uint16(scaled);
            
            // Extract the requested number of bits
            float_fraction_to_rounded_bits = result >> (16 - num_bits);
        end
    endfunction
    
    // Multiply float by 2^exp
    function [31:0] float_mul_pow2;
        input [31:0] f;
        input signed [7:0] exp_add;
        begin
            if (f == 0) begin
                float_mul_pow2 = 0;
            end else begin
                float_mul_pow2 = {f[31], f[30:23] + exp_add, f[22:0]};
            end
        end
    endfunction
    
    // Convert float to uint16
    function [15:0] float_to_uint16;
        input [31:0] f;
        reg [7:0] exp;
        reg [23:0] mant;
        begin
            exp = f[30:23];
            mant = {1'b1, f[22:0]};
            
            if (exp < 127) begin
                float_to_uint16 = 0;
            end else if (exp >= 143) begin
                float_to_uint16 = 16'hFFFF;
            end else begin
                float_to_uint16 = mant >> (150 - exp);
            end
        end
    endfunction

endmodule
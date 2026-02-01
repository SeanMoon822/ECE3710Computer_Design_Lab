// See LICENSE file for copyright and license details
// Derived from standards at github.com/takum-arithmetic/

module decoder_logarithmic #(
    parameter N = 16  // range 2 to natural'high
) (
    input  wire [N-1:0]   takum,
    output wire           sign_bit,
    output wire [N+3:0]   barred_logarithmic_value,  // 9 bits integer, N-5 bits fractional
    output wire [$clog2(N-4):0] precision,            // range 0 to N-5
    output wire           is_zero,
    output wire           is_nar
);

    wire signed [8:0] characteristic;
    wire [N-6:0] mantissa_bits;

    predecoder #(
        .N(N),
        .OUTPUT_EXPONENT(1'b0)
    ) predecoder_inst (
        .takum(takum),
        .sign_bit(sign_bit),
        .characteristic_or_exponent(characteristic),
        .mantissa_bits(mantissa_bits),
        .precision(precision),
        .is_zero(is_zero),
        .is_nar(is_nar)
    );

    // The barred logarithmic value is just c + m, i.e. the concatenation
    // of the characteristic signed integer bits and the mantissa bits
    assign barred_logarithmic_value = {characteristic, mantissa_bits};

endmodule

module predecoder #(
    parameter N = 16,                // range 2 to natural'high
    parameter OUTPUT_EXPONENT = 1'b0
) (
    input  wire [N-1:0]   takum,
    output wire           sign_bit,
    output wire signed [8:0] characteristic_or_exponent,  // range -255 to 254
    output wire [N-6:0]   mantissa_bits,
    output wire [$clog2(N-5)-1:0] precision,                // range 0 to N-5
    output wire           is_zero,
    output wire           is_nar
);

    // Internal signals
    wire direction_bit;
    reg [9:0] regime_characteristic_segment;
    wire [2:0] regime_bits;
    reg  [2:0] regime;
    reg  [2:0] antiregime;
    wire [6:0] characteristic_raw_bits;
    
    // Characteristic calculation signals
    wire [6:0] characteristic_raw_normal_bits;
    wire signed [8:0] characteristic_precursor;
    wire signed [8:0] characteristic_normal;
    
    // Mantissa and precision signals
    wire [N-6:0] mantissa_bits_internal;
    wire [$clog2(N-4):0] precision_internal;
    
    // Special case constants
    localparam [N-1:0] TAKUM_ZERO = {N{1'b0}};
    localparam [N-1:0] TAKUM_NAR  = {{1'b1}, {(N-1){1'b0}}};

    // Directly output the sign bit
    assign sign_bit = takum[N-1];
    assign direction_bit = takum[N-2];

    // Get regime and characteristic segment (10 bits)
    always @(*) begin
        if (N >= 12) begin
            regime_characteristic_segment = takum[N-3:N-12];
        end else begin
            regime_characteristic_segment = {takum[N-3:0], {(12-N){1'b0}}};
        end
    end

    assign regime_bits = regime_characteristic_segment[9:7];

    // Determine regime and antiregime based on direction bit
    always @(*) begin
        if (direction_bit == 1'b0) begin
            regime = ~regime_bits;
            antiregime = regime_bits;
        end else begin
            regime = regime_bits;
            antiregime = ~regime_bits;
        end
    end

    assign characteristic_raw_bits = regime_characteristic_segment[6:0];

    // Determine characteristic or exponent
    assign characteristic_raw_normal_bits = (direction_bit == 1'b0) ? 
                                           characteristic_raw_bits : 
                                           ~characteristic_raw_bits;
    
    assign characteristic_precursor = $signed({2'b10, characteristic_raw_normal_bits}) >>> antiregime;
    assign characteristic_normal = {1'b1, characteristic_precursor[7:0] + 8'd1};

    // If OUTPUT_EXPONENT is zero, we just want the characteristic, which is obtained by conditional negation,
    // but if OUTPUT_EXPONENT is one, we want the exponent, and thus both cases are inverted.
    assign characteristic_or_exponent = (direction_bit == OUTPUT_EXPONENT) ? 
                                       $signed(characteristic_normal) : 
                                       $signed(~characteristic_normal);

    // Determine mantissa bits (left shift by regime)
    assign mantissa_bits_internal = takum[N-6:0] << regime;
    assign mantissa_bits = mantissa_bits_internal;

    // Determine precision
    assign precision_internal = (regime < (N - 5)) ? ((N - 5) - regime) : 0;
    assign precision = precision_internal;

    // Detect special cases
    assign is_zero = (takum == TAKUM_ZERO) ? 1'b1 : 1'b0;
    assign is_nar  = (takum == TAKUM_NAR)  ? 1'b1 : 1'b0;

endmodule

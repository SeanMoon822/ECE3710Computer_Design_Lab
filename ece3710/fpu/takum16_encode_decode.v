// Wrapper module that instantiates both encoder and decoder
module takum16_encode_decode (
    // Encoder
    input wire sign_bit_in,
    input wire [19:0] barred_logarithmic_value_in,  // N+3:0 where N=16
    input wire is_zero_in,
    input wire is_nar_in,
    
    // Decoder
    output wire sign_bit_out,
    output wire [19:0] barred_logarithmic_value_out,
    output wire [4:0] precision_out,  // $clog2(N-4):0 = $clog2(12):0 = 4:0
    output wire is_zero_out,
    output wire is_nar_out,
    
    // Intermediate takum signal (for debugging)
    output wire [15:0] takum
);

    parameter N = 16;

    // Instantiate encoder
    encoder_logarithmic #(
        .N(N)
    ) encoder_inst (
        .sign_bit(sign_bit_in),
        .barred_logarithmic_value(barred_logarithmic_value_in),
        .is_zero(is_zero_in),
        .is_nar(is_nar_in),
        .takum(takum)
    );
    
    // Instantiate decoder
    decoder_logarithmic #(
        .N(N)
    ) decoder_inst (
        .takum(takum),
        .sign_bit(sign_bit_out),
        .barred_logarithmic_value(barred_logarithmic_value_out),
        .precision(precision_out),
        .is_zero(is_zero_out),
        .is_nar(is_nar_out)
    );

endmodule
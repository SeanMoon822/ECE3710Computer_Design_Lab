// See LICENSE file for copyright and license details
// Derived from standards at github.com/takum-arithmetic/

module encoder_logarithmic #(
    parameter N = 16  // Must be >= 2
) (
    input wire sign_bit,
    input wire [N+3:0] barred_logarithmic_value,  // 9 bits integer, N-5 bits fractional
    input wire is_zero,
    input wire is_nar,
    output wire [N-1:0] takum
);

    wire [8:0] characteristic;
    wire [N-6:0] mantissa_bits;

    assign characteristic = barred_logarithmic_value[N+3:N-5];
    assign mantissa_bits = barred_logarithmic_value[N-6:0];

    postencoder #(
        .N(N)
    ) postencoder_inst (
        .sign_bit(sign_bit),
        .characteristic($signed(characteristic)),
        .mantissa_bits(mantissa_bits),
        .is_zero(is_zero),
        .is_nar(is_nar),
        .takum(takum)
    );

endmodule


module postencoder #(
    parameter N = 16
) (
    input wire sign_bit,
    input wire signed [8:0] characteristic,
    input wire [N-6:0] mantissa_bits,
    input wire is_zero,
    input wire is_nar,
    output wire [N-1:0] takum
);

    wire direction_bit;
    wire [7:0] characteristic_precursor;
    wire [2:0] regime;
    wire [N+6:0] extended_takum;
    wire [N-1:0] takum_rounded;
    wire round_up_overflows;
    wire round_down_underflows;

    // direction_bit is 1 when characteristic >= 0
    assign direction_bit = ~characteristic[8];

    // ========== Predict Underflow/Overflow ==========
    wire [N-12:0] mantissa_bits_crop;
    assign mantissa_bits_crop = mantissa_bits[N-6:6];

    reg round_up_overflows_reg;
    reg round_down_underflows_reg;

    assign round_up_overflows = round_up_overflows_reg;
    assign round_down_underflows = round_down_underflows_reg;

    always @(*) begin
        if (N <= 11) begin
            // For small N, use precomputed bounds
            case (N)
                2:  round_down_underflows_reg = (characteristic <= -1);
                3:  round_down_underflows_reg = (characteristic <= -16);
                4:  round_down_underflows_reg = (characteristic <= -64);
                5:  round_down_underflows_reg = (characteristic <= -128);
                6:  round_down_underflows_reg = (characteristic <= -192);
                7:  round_down_underflows_reg = (characteristic <= -224);
                8:  round_down_underflows_reg = (characteristic <= -240);
                9:  round_down_underflows_reg = (characteristic <= -248);
                10: round_down_underflows_reg = (characteristic <= -252);
                11: round_down_underflows_reg = (characteristic <= -254);
                default: round_down_underflows_reg = 1'b0;
            endcase

            case (N)
                2:  round_up_overflows_reg = (characteristic >= 0);
                3:  round_up_overflows_reg = (characteristic >= 15);
                4:  round_up_overflows_reg = (characteristic >= 63);
                5:  round_up_overflows_reg = (characteristic >= 127);
                6:  round_up_overflows_reg = (characteristic >= 191);
                7:  round_up_overflows_reg = (characteristic >= 223);
                8:  round_up_overflows_reg = (characteristic >= 239);
                9:  round_up_overflows_reg = (characteristic >= 247);
                10: round_up_overflows_reg = (characteristic >= 251);
                11: round_up_overflows_reg = (characteristic >= 253);
                default: round_up_overflows_reg = 1'b0;
            endcase
        end else begin
            // For larger N, check bounds only at extreme values
            if (mantissa_bits_crop == 0) begin
                round_down_underflows_reg = (characteristic == -255);
            end else begin
                round_down_underflows_reg = 1'b0;
            end

            if (mantissa_bits_crop == {(N-11){1'b1}}) begin
                round_up_overflows_reg = (characteristic == 254);
            end else begin
                round_up_overflows_reg = 1'b0;
            end
        end
    end

    // ========== Determine Characteristic Precursor ==========
    wire [7:0] characteristic_normal;
    assign characteristic_normal = (direction_bit == 1'b1) ? 
                                   characteristic[7:0] : 
                                   ~characteristic[7:0];
    assign characteristic_precursor = characteristic_normal + 1;

    // ========== Detect Leading One (8-bit) ==========
    wire [2:0] leading_one_offset;
    
    function [1:0] lod4(input [3:0] val);
        case (val)
            4'b0000: lod4 = 2'd0;
            4'b0001: lod4 = 2'd0;
            4'b0010: lod4 = 2'd1;
            4'b0011: lod4 = 2'd1;
            4'b0100: lod4 = 2'd2;
            4'b0101: lod4 = 2'd2;
            4'b0110: lod4 = 2'd2;
            4'b0111: lod4 = 2'd2;
            default: lod4 = 2'd3;  // 1xxx
        endcase
    endfunction

    wire [1:0] lod4_low, lod4_high;
    assign lod4_low = lod4(characteristic_precursor[3:0]);
    assign lod4_high = lod4(characteristic_precursor[7:4]);

    assign leading_one_offset = (characteristic_precursor[7:4] == 4'b0000) ? 
                                {1'b0, lod4_low} : 
                                {1'b1, lod4_high};
    assign regime = leading_one_offset;

    // ========== Generate Extended Takum ==========
    wire [2:0] regime_bits;
    wire [6:0] characteristic_bits;
    wire [N+8:0] characteristic_mantissa_bits;

    assign regime_bits = (direction_bit == 1'b0) ? 
                         ~regime : 
                         regime;
    assign characteristic_bits = (direction_bit == 1'b0) ? 
                                 ~characteristic_precursor[6:0] : 
                                 characteristic_precursor[6:0];

    // Shift right by regime amount
    assign characteristic_mantissa_bits = ({characteristic_bits, mantissa_bits, 7'b0} >> regime);
    
    assign extended_takum = {sign_bit, direction_bit, regime_bits, characteristic_mantissa_bits[N+1:0]};

    // ========== Rounding Logic ==========
    wire [N-1:0] takum_rounded_up, takum_rounded_down;
    wire is_rest_zero;

    assign takum_rounded_up = extended_takum[N+6:7] + 1;
    assign takum_rounded_down = extended_takum[N+6:7];
    assign is_rest_zero = (extended_takum[5:0] == 6'b0) ? 1'b1 : 1'b0;

    assign takum_rounded = ((round_down_underflows == 1'b1) || 
                            (round_up_overflows == 1'b0 && 
                             extended_takum[6] == 1'b1 && 
                             (is_rest_zero == 1'b0 || extended_takum[7] == 1'b1))) ? 
                           takum_rounded_up : 
                           takum_rounded_down;

    // ========== Drive Output ==========
    assign takum = (is_zero == 1'b1 || is_nar == 1'b1) ? 
                   {is_nar, {(N-1){1'b0}}} : 
                   takum_rounded;

endmodule

module ps2_scancode_decoder (
    input wire clk,
    input wire rst,

    // From PS/2 Interface
    input wire [7:0] scan_code,
    input wire scancode_ready,

    // Decode output
    output reg [7:0] ascii,
    output reg ascii_ready
);

    // State flags
    reg break_code;
    reg extended;    
    reg shift;    

    // Reset and state machine
	 always @(posedge clk or posedge rst) begin
    if (rst) begin
        break_code  <= 1'b0;
        extended    <= 1'b0;
        shift       <= 1'b0;
        ascii       <= 8'd0;
        ascii_ready <= 1'b0;

    end else begin
        ascii_ready <= 1'b0;  // default

        if (scancode_ready) begin
            // Prefix bytes
            if (scan_code == 8'hF0) begin
                // next byte is a key release
                break_code <= 1'b1;

            end else if (scan_code == 8'hE0) begin
                // next byte is an extended code
                extended <= 1'b1;

            end else begin
                // Actual key byte
                if (break_code) begin
                    // Key release
                    if (scan_code == 8'h12 || scan_code == 8'h59)
                        shift <= 1'b0;      // Shift released

                    // consume flags AFTER handling this byte
                    break_code <= 1'b0;
                    extended   <= 1'b0;

                end else begin
                    // Key press
                    if (scan_code == 8'h12 || scan_code == 8'h59) begin
                        shift <= 1'b1;      // Shift pressed
                    end else begin
                        // Normal key press
                        ascii <= translate_scancode(scan_code, shift);
                        if (translate_scancode(scan_code, shift) != 8'd0)
                            ascii_ready <= 1'b1;
                    end

                    // we currently ignore extended keys but still clear flag
                    extended <= 1'b0;
                end
            end
        end
    end
end


        //set function to translate_scancode  
    function [7:0] translate_scancode;
        input [7:0] code;
        input shift_key;
        begin
            // Default: no character
            translate_scancode = 8'd0;

            if (shift_key) begin

                // SHIFTED KEYS
                //  ! # $ % & * ( ) " +

                case (code)
                    // Number row: 1–0 with Shift
                    8'h16: translate_scancode = "!";   // 1
                    8'h1E: translate_scancode = "@";   // 2
                    8'h26: translate_scancode = "#";   // 3
                    8'h25: translate_scancode = "$";   // 4
                    8'h2E: translate_scancode = "%";   // 5
                    8'h3D: translate_scancode = "&";   // 7
                    8'h3E: translate_scancode = "*";   // 8
                    8'h46: translate_scancode = "(";   // 9
                    8'h45: translate_scancode = ")";   // 0

                    // Shifted apostrophe -> double quote (")
                    8'h52: translate_scancode = 8'd34; // "

                    8'h55: translate_scancode = "+";   // = key shifted

                    // Extra shifted punctuation that you have glyphs for
                    8'h4C: translate_scancode = ":";   // ; shifted
                    8'h41: translate_scancode = "<";   // , shifted
                    8'h49: translate_scancode = ">";   // . shifted
                    8'h4A: translate_scancode = "?";   // / shifted

                    default: begin end
                endcase

                // Letters A–Z (same whether shifted or not in your design)
                case (code)
                    8'h1C: translate_scancode = "A";
                    8'h32: translate_scancode = "B";
                    8'h21: translate_scancode = "C";
                    8'h23: translate_scancode = "D";
                    8'h24: translate_scancode = "E";
                    8'h2B: translate_scancode = "F";
                    8'h34: translate_scancode = "G";
                    8'h33: translate_scancode = "H";
                    8'h43: translate_scancode = "I";
                    8'h3B: translate_scancode = "J";
                    8'h42: translate_scancode = "K";
                    8'h4B: translate_scancode = "L";
                    8'h3A: translate_scancode = "M";
                    8'h31: translate_scancode = "N";
                    8'h44: translate_scancode = "O";
                    8'h4D: translate_scancode = "P";
                    8'h15: translate_scancode = "Q";
                    8'h2D: translate_scancode = "R";
                    8'h1B: translate_scancode = "S";
                    8'h2C: translate_scancode = "T";
                    8'h3C: translate_scancode = "U";
                    8'h2A: translate_scancode = "V";
                    8'h1D: translate_scancode = "W";
                    8'h22: translate_scancode = "X";
                    8'h35: translate_scancode = "Y";
                    8'h1A: translate_scancode = "Z";
                endcase
            end
            else begin
                // UNSHIFTED KEYS
                // Digits, letters, space, CR, tab,
                // and punctuation
                //  ' - , . /

                case (code)
                    // Letters A–Z
                    8'h1C: translate_scancode = "A";
                    8'h32: translate_scancode = "B";
                    8'h21: translate_scancode = "C";
                    8'h23: translate_scancode = "D";
                    8'h24: translate_scancode = "E";
                    8'h2B: translate_scancode = "F";
                    8'h34: translate_scancode = "G";
                    8'h33: translate_scancode = "H";
                    8'h43: translate_scancode = "I";
                    8'h3B: translate_scancode = "J";
                    8'h42: translate_scancode = "K";
                    8'h4B: translate_scancode = "L";
                    8'h3A: translate_scancode = "M";
                    8'h31: translate_scancode = "N";
                    8'h44: translate_scancode = "O";
                    8'h4D: translate_scancode = "P";
                    8'h15: translate_scancode = "Q";
                    8'h2D: translate_scancode = "R";
                    8'h1B: translate_scancode = "S";
                    8'h2C: translate_scancode = "T";
                    8'h3C: translate_scancode = "U";
                    8'h2A: translate_scancode = "V";
                    8'h1D: translate_scancode = "W";
                    8'h22: translate_scancode = "X";
                    8'h35: translate_scancode = "Y";
                    8'h1A: translate_scancode = "Z";

                    // Number row 0–9
                    8'h45: translate_scancode = "0";
                    8'h16: translate_scancode = "1";
                    8'h1E: translate_scancode = "2";
                    8'h26: translate_scancode = "3";
                    8'h25: translate_scancode = "4";
                    8'h2E: translate_scancode = "5";
                    8'h36: translate_scancode = "6";
                    8'h3D: translate_scancode = "7";
                    8'h3E: translate_scancode = "8";
                    8'h46: translate_scancode = "9";

                    // Space, Enter, Tab, Backspace
                    8'h29: translate_scancode = 8'd32; // space
                    8'h5A: translate_scancode = 8'd13; // carriage return
                    8'h0D: translate_scancode = 8'd9;  // tab
						  8'h66: translate_scancode = 8'd8;  // backspace

                    // Punctuation you have glyphs for
                    8'h4E: translate_scancode = "-";  
                    8'h52: translate_scancode = "'";  
                    8'h41: translate_scancode = ",";  
                    8'h49: translate_scancode = ".";  
                    8'h4A: translate_scancode = "/";  
                    8'h4C: translate_scancode = ";";
                    8'h55: translate_scancode = "=";   

                    default: begin end
                endcase
            end
        end
    endfunction
endmodule

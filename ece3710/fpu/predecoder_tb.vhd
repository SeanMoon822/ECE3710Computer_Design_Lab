-- See LICENSE file for copyright and license details
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity predecoder_tb is
	generic (
		n : natural range 2 to natural'high := 16
	);
end entity predecoder_tb;

architecture behave of predecoder_tb is
	signal clock                                : std_ulogic;
	signal takum                                : std_ulogic_vector(n - 1 downto 0) := (others => '0');
	signal sign_bit                             : std_ulogic;
	signal sign_bit_reference                   : std_ulogic;
	signal characteristic_or_exponent           : integer range -255 to 254;
	signal characteristic_or_exponent_reference : integer range -255 to 254;
	signal mantissa_bits                        : std_ulogic_vector(n - 6 downto 0);
	signal mantissa_bits_reference              : std_ulogic_vector(n - 6 downto 0);
	signal is_zero                              : std_ulogic;
	signal is_zero_reference                    : std_ulogic;
	signal is_nar                               : std_ulogic;
	signal is_nar_reference                     : std_ulogic;
	signal precision                            : natural range 0 to n - 5;
	signal precision_reference                  : natural range 0 to n - 5;

	constant takum_end : std_ulogic_vector(n - 1 downto 0) := (others => '1');
	function ulogic_vector_to_string (
		input: std_ulogic_vector
	) return string is
		variable output       : string (1 to input'length) := (others => NUL);
		variable output_index : integer                    := 1;
	begin
		for i in input'range loop
			output(output_index) := std_ulogic'image(input((i)))(2);
			output_index         := output_index + 1;
		end loop;

		return output;
	end function;

begin

	-- UUT instantiation
	decoder : entity REPLACEMEWITH VERILOG!
		generic map (
			n               => n,
			output_exponent => '0'
		)
		port map (
			takum                      => takum,
			sign_bit                   => sign_bit,
			characteristic_or_exponent => characteristic_or_exponent,
			mantissa_bits              => mantissa_bits,
			precision                  => precision,
			is_zero                    => is_zero,
			is_nar                     => is_nar
		);

	-- Reference unit instantiation
	decoder_reference : entity work.predecoder(rtl)
		generic map (
			n               => n,
			output_exponent => '0'
		)
		port map (
			takum                      => takum,
			sign_bit                   => sign_bit_reference,
			characteristic_or_exponent => characteristic_or_exponent_reference,
			mantissa_bits              => mantissa_bits_reference,
			precision                  => precision_reference,
			is_zero                    => is_zero_reference,
			is_nar                     => is_nar_reference
		);

	drive_clock : process is
	begin
		-- Allow initial signals to settle
		wait for 1 ns;

		while takum /= takum_end loop
			clock <= '0';
			wait for 10 ns;
			clock <= '1';
			wait for 10 ns;
		end loop;

		wait;
	end process drive_clock;

	check_results_and_increment_takum : process (clock) is
	begin
		if rising_edge(clock) then
			assert sign_bit = sign_bit_reference
				report ulogic_vector_to_string(takum) &
				       ": sign_bit mismatch (rtl sign_bit=" &
				       std_ulogic'image(sign_bit) &
				       ", behave sign_bit=" &
				       std_ulogic'image(sign_bit_reference) &
				       ")"
				severity error;
			assert characteristic_or_exponent = characteristic_or_exponent_reference
				report ulogic_vector_to_string(takum) &
				       ": characteristic_or_exponent mismatch (rtl characteristic_or_exponent=" &
				       integer'image(characteristic_or_exponent) &
				       ", behave characteristic_or_exponent=" &
				       integer'image(characteristic_or_exponent_reference) &
				       ")"
				severity error;
			assert mantissa_bits = mantissa_bits_reference
				report ulogic_vector_to_string(takum) &
				       ": mantissa bits mismatch (rtl mantissa_bits=" &
				       ulogic_vector_to_string(mantissa_bits) &
				       ", behave mantissa_bits=" &
				       ulogic_vector_to_string(mantissa_bits_reference) &
				       ")"
				severity error;
			assert is_zero = is_zero_reference
				report ulogic_vector_to_string(takum) &
				       ": is_zero mismatch (rtl is_zero=" &
				       std_ulogic'image(is_zero) &
				       ", behave is_zero=" &
				       std_ulogic'image(is_zero_reference) &
				       ")"
				severity error;
			assert is_nar = is_nar_reference
				report ulogic_vector_to_string(takum) &
				       ": is_nar mismatch (rtl is_nar=" &
				       std_ulogic'image(is_nar) &
				       ", behave is_nar=" &
				       std_ulogic'image(is_nar_reference) &
				       ")"
				severity error;
			assert precision = precision_reference
				report ulogic_vector_to_string(takum) &
				       ": precision mismatch (rtl precision=" &
				       natural'image(precision) &
				       ", behave precision=" &
				       natural'image(precision_reference) &
				       ")"
				severity error;

			takum <= std_ulogic_vector(unsigned(takum) + 1);
		end if;
	end process check_results_and_increment_takum;

end architecture behave;

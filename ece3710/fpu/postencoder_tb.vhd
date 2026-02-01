-- See LICENSE file for copyright and license details
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity postencoder_tb is
	generic (
		n : natural range 2 to natural'high := 16
	);
end entity postencoder_tb;

architecture behave of postencoder_tb is
	signal clock           : std_ulogic;
	signal takum           : std_ulogic_vector(n - 1 downto 0) := (others => '0');
	signal takum_reference : std_ulogic_vector(n - 1 downto 0) := (others => '0');
	signal sign_bit        : std_ulogic;
	signal characteristic  : integer range -255 to 254;
	signal mantissa_bits   : std_ulogic_vector(n - 6 downto 0);
	signal is_zero         : std_ulogic;
	signal is_nar          : std_ulogic;
	signal precision       : natural range 0 to n - 5;

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

	-- Reference decoder instantiation
	decoder_reference : entity work.predecoder(rtl)
		generic map (
			n               => n,
			output_exponent => '0'
		)
		port map (
			takum                      => takum_reference,
			sign_bit                   => sign_bit,
			characteristic_or_exponent => characteristic,
			mantissa_bits              => mantissa_bits,
			precision                  => precision,
			is_zero                    => is_zero,
			is_nar                     => is_nar
		);

	-- UUT instantiation
	encoder : entity REPLACE ME WITH VERILOG!
		generic map (
			n => n
		)
		port map (
			sign_bit       => sign_bit,
			characteristic => characteristic,
			mantissa_bits  => mantissa_bits,
			is_zero        => is_zero,
			is_nar         => is_nar,
			takum          => takum
		);

	drive_clock : process is
	begin
		while takum_reference /= takum_end loop
			clock <= '0';
			wait for 10 ns;
			clock <= '1';
			wait for 10 ns;
		end loop;

		wait;
	end process drive_clock;

	check_results_and_increment_takum_reference : process (clock) is
	begin
		if rising_edge(clock) then
			assert takum = takum_reference
				report ulogic_vector_to_string(takum) &
				       ": mismatch (reference takum=" &
				       ulogic_vector_to_string(takum_reference) &
				       ", rtl takum=" &
				       ulogic_vector_to_string(takum) &
				       ")"
				severity error;

			takum_reference <= std_ulogic_vector(unsigned(takum_reference) + 1);
		end if;
	end process check_results_and_increment_takum_reference;

end architecture behave;

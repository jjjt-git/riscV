library ieee;
use ieee.std_logic_1164.all;

entity tb_register_32bit is
end;

architecture test of tb_register_32bit is
	signal d0, d1, c, zero, d: bit_vector(31 downto 0);
	signal set: bit;
begin
	d0 <= "10101010101010101010101010101010";
	d1 <= "01010101010101010101010101010101";
	zero <= "00000000000000000000000000000000";

	REG : entity work.register_32bit
		port map (
			content => c,
			data => d,
			set => set
		);

	tb : process
		constant dt: time:= 10 ns;
		begin
			d <= zero;
			set <= '1';
			wait for dt;
			set <= '0';
			wait for dt; -- reg is initialized
			assert c = zero report "Init not working";
			wait for dt;

			d <= d0;
			wait for dt;
			assert c = zero report "set was not ordered";
			wait for dt;

			set <= '1';
			wait for dt;
			set <= '0';
			wait for dt;
			assert c = d0 report "was not set";
			wait for dt;

			d <= d1;
			wait for dt;
			assert c = d0 report "should not change";
			wait for dt;

			set <= '1';
			wait for dt;
			assert c = d0 report "should only have been staged";
			wait for dt;
			set <= '0';
			wait for dt;
			assert c = d1 report "should have been destaged";

			assert false report "End of Test";
			wait;
		end process;
end;
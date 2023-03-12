library ieee;
use ieee.std_logic_1164.all;

entity tb_alu_32bit is
end;

architecture test of tb_alu_32bit is
	signal a, b, s: bit_vector(31 downto 0);
	signal op: bit_vector(3 downto 0);
begin
	ALU : entity work.alu_32bit
		port map (
			op0 => a,
			op1 => b,
			res => s,
			op => op
		);

	tb : process
		constant dt: time:= 10 ns;
		begin
			a <= "00000000000000000000000000000110";
			b <= "00000000000000000000000000001010";

			wait for dt;
			op <= "0000";
			wait for dt;
			assert s = "00000000000000000000000000010000" report "add wrong";

			wait for dt;
			op <= "0001";
			wait for dt;
			assert s = "11111111111111111111111111111100" report "sub wrong";

			wait for dt;
			op <= "0010";
			wait for dt;
			assert s = "00000000000000000000000000000010" report "and wrong";

			wait for dt;
			op <= "0011";
			wait for dt;
			assert s = "00000000000000000000000000001110" report "or wrong";

			wait for dt;
			op <= "0100";
			wait for dt;
			assert s = "00000000000000000000000000001100" report "xor wrong";

			wait for dt;
			op <= "0101";
			wait for dt;
			assert s = "00000000000000000001100000000000" report "l-shift wrong";

			wait for dt;
			op <= "0110";
			wait for dt;
			assert s = "00000000000000000000000000000000" report "r-shift wrong";

			wait for dt;
			op <= "0111";
			wait for dt;
			assert s = "00000000000000000000000000000000" report "a-shift wrong";

			wait for dt;
			op <= "1000";
			wait for dt;
			assert s = "00000000000000000000000000000000" report "eq wrong";

			wait for dt;
			op <= "1000";
			a <= x"18a6F790";
			b <= x"18a6F790";
			wait for dt;
			assert s = "00000000000000000000000000000001" report "eq wrong";

			wait for dt;
			op <= "1000";
			a <= x"00000000";
			b <= x"00000000";
			wait for dt;
			assert s = x"00000001" report "eq wrong";

			wait for dt;


			a <= "00000000000000000000000000000110";
			b <= "00000000000000000000000000001010";

			wait for dt;
			op <= "1001";
			wait for dt;
			assert s = "00000000000000000000000000000001" report "lt wrong";
			wait for dt;

			a <= "00000000000000000000000000000110";
			b <= "11111111111111111111111111111010";

			wait for dt;
			op <= "1011";
			wait for dt;
			assert s = "00000000000000000000000000000001" report "ltu wrong";
			wait for dt;

			a <= "00000000000000000000000000000110";
			b <= "00000000000000000000000000000110";

			wait for dt;
			op <= "1011";
			wait for dt;
			assert s = "00000000000000000000000000000000" report "ltu wrong";

			assert false report "End of Test";
			wait;
		end process;
end;

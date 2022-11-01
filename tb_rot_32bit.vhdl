library ieee;
use ieee.std_logic_1164.all;

entity tb_rot_32bit is
end;

architecture test of tb_rot_32bit is
	signal d, zero, o_L, o_R: bit_vector(31 downto 0);
	signal width: bit_vector(4 downto 0);
begin
	zero <= "00000000000000000000000000000000";
	d <= "10000000000000000000000000000001";
	
	SHIFTL : entity work.rotL_32bit
		port map (
			i0 => d,
			i1 => zero,
			o => o_L,
			len => width
		);
	SHIFTR : entity work.rotR_32bit
		port map (
			i0 => d,
			i1 => zero,
			o => o_R,
			len => width
		);
	
	tb : process
		constant dt: time:= 10 ns;
		begin
			width <= "00000";
			wait for dt;
			assert o_L = "10000000000000000000000000000001" report "L-Shift not correct";
			assert o_R = "10000000000000000000000000000001" report "R-Shift not correct";
			wait for dt;
			
			width <= "00001";
			wait for dt;
			assert o_L = "00000000000000000000000000000010" report "L-Shift not correct";
			assert o_R = "01000000000000000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "00010";
			wait for dt;
			assert o_L = "00000000000000000000000000000100" report "L-Shift not correct";
			assert o_R = "00100000000000000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "00011";
			wait for dt;
			assert o_L = "00000000000000000000000000001000" report "L-Shift not correct";
			assert o_R = "00010000000000000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "00100";
			wait for dt;
			assert o_L = "00000000000000000000000000010000" report "L-Shift not correct";
			assert o_R = "00001000000000000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "00101";
			wait for dt;
			assert o_L = "00000000000000000000000000100000" report "L-Shift not correct";
			assert o_R = "00000100000000000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "00110";
			wait for dt;
			assert o_L = "00000000000000000000000001000000" report "L-Shift not correct";
			assert o_R = "00000010000000000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "00111";
			wait for dt;
			assert o_L = "00000000000000000000000010000000" report "L-Shift not correct";
			assert o_R = "00000001000000000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "01000";
			wait for dt;
			assert o_L = "00000000000000000000000100000000" report "L-Shift not correct";
			assert o_R = "00000000100000000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "01001";
			wait for dt;
			assert o_L = "00000000000000000000001000000000" report "L-Shift not correct";
			assert o_R = "00000000010000000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "01010";
			wait for dt;
			assert o_L = "00000000000000000000010000000000" report "L-Shift not correct";
			assert o_R = "00000000001000000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "01011";
			wait for dt;
			assert o_L = "00000000000000000000100000000000" report "L-Shift not correct";
			assert o_R = "00000000000100000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "01100";
			wait for dt;
			assert o_L = "00000000000000000001000000000000" report "L-Shift not correct";
			assert o_R = "00000000000010000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "01101";
			wait for dt;
			assert o_L = "00000000000000000010000000000000" report "L-Shift not correct";
			assert o_R = "00000000000001000000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "01110";
			wait for dt;
			assert o_L = "00000000000000000100000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000100000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "01111";
			wait for dt;
			assert o_L = "00000000000000001000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000010000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "10000";
			wait for dt;
			assert o_L = "00000000000000010000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000001000000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "10001";
			wait for dt;
			assert o_L = "00000000000000100000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000100000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "10010";
			wait for dt;
			assert o_L = "00000000000001000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000010000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "10011";
			wait for dt;
			assert o_L = "00000000000010000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000001000000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "10100";
			wait for dt;
			assert o_L = "00000000000100000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000100000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "10101";
			wait for dt;
			assert o_L = "00000000001000000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000010000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "10110";
			wait for dt;
			assert o_L = "00000000010000000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000001000000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "10111";
			wait for dt;
			assert o_L = "00000000100000000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000000100000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "11000";
			wait for dt;
			assert o_L = "00000001000000000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000000010000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "11001";
			wait for dt;
			assert o_L = "00000010000000000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000000001000000" report "R-Shift not correct";
			wait for dt;
			
			width <= "11010";
			wait for dt;
			assert o_L = "00000100000000000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000000000100000" report "R-Shift not correct";
			wait for dt;
			
			width <= "11011";
			wait for dt;
			assert o_L = "00001000000000000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000000000010000" report "R-Shift not correct";
			wait for dt;
			
			width <= "11100";
			wait for dt;
			assert o_L = "00010000000000000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000000000001000" report "R-Shift not correct";
			wait for dt;
			
			width <= "11101";
			wait for dt;
			assert o_L = "00100000000000000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000000000000100" report "R-Shift not correct";
			wait for dt;
			
			width <= "11110";
			wait for dt;
			assert o_L = "01000000000000000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000000000000010" report "R-Shift not correct";
			wait for dt;
			
			width <= "11111";
			wait for dt;
			assert o_L = "10000000000000000000000000000000" report "L-Shift not correct";
			assert o_R = "00000000000000000000000000000001" report "R-Shift not correct";
			wait for dt;
			
			assert false report "End of Test";
			wait;
		end process;
end;

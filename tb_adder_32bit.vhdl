library ieee;
use ieee.std_logic_1164.all;

entity tb_adder_32bit is
end;

architecture tb_adder_32bit_test of tb_adder_32bit is
	signal ci, co_cra, co_caska, co_cla: bit;
	signal a, b, s_cra, s_caska, s_cla: bit_vector(31 downto 0);
begin
	ci <= '0';
	
	ADDER_CRA : entity work.adder_32bit(cra)
		port map(
			a => a,
			b => b,
			s => s_cra,
			ci => ci,
			co => co_cra
		);
	
	 ADDER_CASKA : entity work.adder_32bit(caska_bs4)
		port map(
			a => a,
			b => b,
			s => s_caska,
			ci => ci,
			co => co_caska
		);
	
	ADDER_CLA : entity work.adder_32bit(cla)
		port map(
			a => a,
			b => b,
			s => s_cla,
			ci => ci,
			co => co_cla
		);
	
	tb : process
		constant dt: time:= 10 ns;
		begin
			a <= "11111111111111111111111111110100";
			b <= "00000000000000000000000000001011";
			wait for dt;
			-- expected: 0 11111111111111111111111111111111
			assert s_cra = "11111111111111111111111111111111" report "cra s not correct";
			assert co_cra = '0' report "cra co not correct";
			assert s_caska = "11111111111111111111111111111111" report "caska s not correct";
			assert co_caska = '0' report "caska co not correct";
			assert s_cla = "11111111111111111111111111111111" report "cla s not correct";
			assert co_cla = '0' report "cla co not correct";
			
			wait for dt;
			
			a <= "00000000000000000000000000000101";
			b <= "11111111111111111111111111111011";
			wait for dt;
			-- expected: 1 00000000000000000000000000000000
			assert s_cra = "00000000000000000000000000000000" report "cra s not correct";
			assert co_cra = '1' report "cra co not correct";
			assert s_caska = "00000000000000000000000000000000" report "caska s not correct";
			assert co_caska = '1' report "caska co not correct";
			assert s_cla = "00000000000000000000000000000000" report "cla s not correct";
			assert co_cla = '1' report "cla co not correct";
			
			wait for dt;
			
			a <= "11111111111111111111111111111111";
			b <= "11111111111111111111111111111111";
			wait for dt;
			-- expected: 1 11111111111111111111111111111110
			assert s_cra = "11111111111111111111111111111110" report "cra s not correct";
			assert co_cra = '1' report "cra co not correct";
			assert s_caska = "11111111111111111111111111111110" report "caska s not correct";
			assert co_caska = '1' report "caska co not correct";
			assert s_cla = "11111111111111111111111111111110" report "cla s not correct";
			assert co_cla = '1' report "cla co not correct";
			
			wait for dt;
			
			a <= "11111111111111111111111111110010";
			b <= "00000000000000000000000000001000";
			wait for dt;
			-- expected: 0 11111111111111111111111111111010
			assert s_cra = "11111111111111111111111111111010" report "cra s not correct";
			assert co_cra = '0' report "cra co not correct";
			assert s_caska = "11111111111111111111111111111010" report "caska s not correct";
			assert co_caska = '0' report "caska co not correct";
			assert s_cla = "11111111111111111111111111111010" report "cla s not correct";
			assert co_cla = '0' report "cla co not correct";
			
			wait for dt;
			assert false report "End of Test";
			wait;
		end process;
end;
library ieee;
use ieee.std_logic_1164.all;

entity tb_adder_4bit is
end;

architecture tb_adder_4bit_test of tb_adder_4bit is
	signal a, b, s_cra, s_caska, s_cla: bit_vector (3 downto 0);
	signal ci, co_cra, co_caska, co_cla: bit;
begin
	ci <= '0';
	
	ADDER_CRA : entity work.adder_4bit(cra)
		port map(
			a => a,
			b => b,
			s => s_cra,
			ci => ci,
			co => co_cra
		);
	
	 ADDER_CASKA : entity work.adder_4bit(caska)
		port map(
			a => a,
			b => b,
			s => s_caska,
			ci => ci,
			co => co_caska
		);
	
	ADDER_CLA : entity work.adder_4bit(cla)
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
			-- 4 + 11
			a <= "0100";
			b <= "1011";
			wait for dt;
			-- expected: 0 1111
			assert s_cra = "1111" report "cra s not correct";
			assert co_cra = '0' report "cra co not correct";
			assert s_caska = "1111" report "caska s not correct";
			assert co_caska = '0' report "caska co not correct";
			assert s_cla = "1111" report "cla s not correct";
			assert co_cla = '0' report "cla co not correct";
			
			wait for dt;
			
			-- 5 + 11
			a <= "0101";
			b <= "1011";
			wait for dt;
			-- expected: 1 0000
			assert s_cra = "0000" report "cra s not correct";
			assert co_cra = '1' report "cra co not correct";
			assert s_caska = "0000" report "caska s not correct";
			assert co_caska = '1' report "caska co not correct";
			assert s_cla = "0000" report "cla s not correct";
			assert co_cla = '1' report "cla co not correct";
			
			wait for dt;
			
			-- 15 + 15
			a <= "1111";
			b <= "1111";
			wait for dt;
			-- expected: 1 1110
			assert s_cra = "1110" report "cra s not correct";
			assert co_cra = '1' report "cra co not correct";
			assert s_caska = "1110" report "caska s not correct";
			assert co_caska = '1' report "caska co not correct";
			assert s_cla = "1110" report "cla s not correct";
			assert co_cla = '1' report "cla co not correct";
			
			wait for dt;
			
			-- 2 + 8
			a <= "0010";
			b <= "1000";
			wait for dt;
			-- expected: 0 1010
			assert s_cra = "1010" report "cra s not correct";
			assert co_cra = '0' report "cra co not correct";
			assert s_caska = "1010" report "caska s not correct";
			assert co_caska = '0' report "caska co not correct";
			assert s_cla = "1010" report "cla s not correct";
			assert co_cla = '0' report "cla co not correct";
			
			wait for dt;
			assert false report "End of Test";
			wait;
		end process;
end;
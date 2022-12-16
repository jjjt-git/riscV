library ieee;

entity tb_cu_32bit is
end;

architecture def of tb_cu_32bit is
	signal memAddr, memWr, memRd, memRdRom, memRdSw: bit_vector(31 downto 0);
	signal clk, rst: bit;
	signal STOPSIMULATION: bit;
begin
	CORE : entity work.cu_32bit generic map(
		bootloaderStartAddr => x"00000008"
	) port map(
		clk => clk,
		rst => rst,
		memAddr => memAddr,
		memWr => memWr,
		memRd => memRd
	);

	memRd <= memRdRom or memRdSw;

	with memAddr select memRdSw <=
		x"00000002" when x"00000002",
		x"00000000" when others;

	with memAddr select memRdRom <=
		x"00205083" when x"00000008",
		x"00000013" when x"0000000C",
		x"00205103" when x"00000010",
		x"00000013" when x"00000014",
		x"000001B3" when x"00000018",
		x"00200863" when x"0000001C",
		x"003081B3" when x"00000020",
		x"FFF10113" when x"00000024",
		x"FF5FF06F" when x"00000028",
		x"00302223" when x"0000002C",
		x"00000000" when others;

	process
	begin
		STOPSIMULATION <= '0';
		rst <= '1';
		wait for 200 ns;
		rst <= '0';
		wait for 400 ns;
		wait for 200 ns; --fetch
		assert memAddr = x"00000008" report "Start addr not correct";
		wait for 14400 ns;
		assert memAddr = x"00000004" report "Should write addr";
		assert memWr = x"00000004" report "Should write correct result";
		STOPSIMULATION <= '1';
		wait;
	end process;

	CLK_GEN : process
	begin
		wait for 100 ns;
		clk <= '1';
		wait for 100 ns;
		clk <= '0';

		if STOPSIMULATION = '1' then
			assert false report "End of Test";
			wait;
		end if;
	end process;
end;
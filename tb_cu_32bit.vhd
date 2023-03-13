library ieee;

entity tb_cu_32bit is
end;

architecture def of tb_cu_32bit is
	signal memAddr, memWr, memRd, memRdRom: bit_vector(31 downto 0);
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

	memRd <= memRdRom;

	with memAddr select memRdRom <=
--		x"00205083" when x"00000008",
--		x"00000013" when x"0000000C",
--		x"00205103" when x"00000010",
--		x"00000013" when x"00000014",
--		x"000001B3" when x"00000018",
--		x"00200863" when x"0000001C",
--		x"003081B3" when x"00000020",
--		x"FFF10113" when x"00000024",
--		x"FF5FF06F" when x"00000028",
--		x"00302223" when x"0000002C",

		x"02B00113" when x"00000008",
		x"00800193" when x"0000000C",
		x"00000013" when x"00000010",
		x"00000013" when x"00000014",
		x"01011793" when x"00000018",
		x"003787B3" when x"0000001C",
		x"00F02223" when x"00000020",
		x"02300663" when x"00000024",
		x"00314463" when x"00000028",
		x"014000EF" when x"0000002C",
		x"00010213" when x"00000030",
		x"00018113" when x"00000034",
		x"00020193" when x"00000038",
		x"FE9FF06F" when x"0000003C",
		x"00314663" when x"00000040",
		x"40310133" when x"00000044",
		x"FF9FF06F" when x"00000048",
		x"00008067" when x"0000004C",
		x"00202223" when x"00000050",

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
		wait for 1 ms;
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

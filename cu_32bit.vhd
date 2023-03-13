library ieee;

entity cu_32bit is
generic (
	bootloaderStartAddr: bit_vector(31 downto 0) := x"00000000"
);
port (
	memRd: in bit_vector(31 downto 0);
	memWr: out bit_vector(31 downto 0);
	memAddr: out bit_vector(31 downto 0);
	memLen: out bit_vector(1 downto 0); -- 0: idle, 1: byte, 2: halfword, 3: word
	fetchInstruction: out bit;
	write: out bit;
	read: out bit;
	clk: in bit;
	rst: in bit
);
end;

architecture def of cu_32bit is
	signal instruction, memAddrTmp: bit_vector(31 downto 0);

	signal rs1, rs2, rd, source0, source1, dest, destTmp: bit_vector(4 downto 0);
	signal opcode: bit_vector(6 downto 0);
	signal funct: bit_vector(9 downto 0);
	signal funct3: bit_vector(2 downto 0);
	signal functlong: bit_vector(14 downto 0);

	signal immediateI, immediateS,
		immediateB, immediateU,
		immediateJ, immediate: bit_vector(31 downto 0);
	signal format: bit_vector(4 downto 0);
	signal formatI, formatS, formatB, formatU, formatJ: bit;

	signal sextender: bit_vector(31 downto 0);
	signal msb: bit;

	signal state: bit_vector(4 downto 0);	-- 0 fetch
						-- 1 execute
						-- 2 memory
						-- 3 write
						-- 4 jump
	signal rstState: bit_vector(1 downto 0);-- 0 PC d
						-- 1 PC set
						-- 2 PC confirm
						-- 3 no RST (normal operation)

	-- control
	signal crtl_useAluRes, crtl_usePcInAlu,
		crtl_useImmediateInAlu, crtl_isJmp,
		crtl_branch, crtl_writeReg,
		crtl_negateCond, crtl_memRead,
		crtl_memWrite, crtl_memUnsigned,
		crtl_pcRst, crtl_fetch: bit;
	signal crtl_memLen: bit_vector(1 downto 0);

	-- register-bank
	signal setRegDest: bit;
	signal cReg0, cReg1, dReg, dRegTmp0, dRegTmp1: bit_vector(31 downto 0);

	-- pc-register
	signal pcC, pcD: bit_vector(31 downto 0);
	signal pcSet: bit;
	signal pcI0, pcI1, pcDtmp, pcDPreRst: bit_vector(31 downto 0);

	-- branch helpers
	signal bCond: bit;
	
	-- read, write
	signal signLoad: bit;
	signal loadSext: bit_vector(31 downto 0);

	-- alu
	signal alu0, alu1, aluOut: bit_vector(31 downto 0);
	signal aluOp: bit_vector(3 downto 0);	-- 0000 add
						-- 0001 sub
						-- 0010 and
						-- 0011 or
						-- 0100 xor
						-- 0101 shift left
						-- 0110 shift right
						-- 0111 arithmetic shift
						-- 1000 equal
						-- 1001 less than
						-- 1011 less than (unsigned)

	signal DEBUG_UNKNOWN_INSTRUCTION: bit;

	-- START OPCODE-CONSTANTS
	-- constant 		: bit_vector(6 downto 0) := "";
	constant C_OP_IMM	: bit_vector(6 downto 0) := "0010011";
	constant C_OP		: bit_vector(6 downto 0) := "0110011";
	constant C_LUI		: bit_vector(6 downto 0) := "0110111";
	constant C_AUIPC	: bit_vector(6 downto 0) := "0010111";
	constant C_JAL		: bit_vector(6 downto 0) := "1101111";
	constant C_JALR		: bit_vector(6 downto 0) := "1100111";
	constant C_BRANCH	: bit_vector(6 downto 0) := "1100011";
	constant C_LOAD		: bit_vector(6 downto 0) := "0000011";
	constant C_STORE	: bit_vector(6 downto 0) := "0100011";
	constant C_MISC_MEM	: bit_vector(6 downto 0) := "0001111";
	constant C_SYSTEM	: bit_vector(6 downto 0) := "1110011";
	-- START INSTRUCTION FUNCT-CONSTANTS
	-- constant 		: bit_vector(9 downto 0) := "";
	constant I_JALR		: bit_vector(2 downto 0) := "000";
	constant I_BEQ		: bit_vector(2 downto 0) := "000";
	constant I_BNE		: bit_vector(2 downto 0) := "001";
	constant I_BLT		: bit_vector(2 downto 0) := "100";
	constant I_BGE		: bit_vector(2 downto 0) := "101";
	constant I_BLTU		: bit_vector(2 downto 0) := "110";
	constant I_BGEU		: bit_vector(2 downto 0) := "111";
	constant I_LB		: bit_vector(2 downto 0) := "000";
	constant I_LH		: bit_vector(2 downto 0) := "001";
	constant I_LW		: bit_vector(2 downto 0) := "010";
	constant I_LBU		: bit_vector(2 downto 0) := "100";
	constant I_LHU		: bit_vector(2 downto 0) := "101";
	constant I_SB		: bit_vector(2 downto 0) := "000";
	constant I_SH		: bit_vector(2 downto 0) := "001";
	constant I_SW		: bit_vector(2 downto 0) := "010";
	constant I_ADDI		: bit_vector(2 downto 0) := "000";
	constant I_SLTI		: bit_vector(2 downto 0) := "010";
	constant I_SLTIU	: bit_vector(2 downto 0) := "011";
	constant I_XORI		: bit_vector(2 downto 0) := "100";
	constant I_ORI		: bit_vector(2 downto 0) := "110";
	constant I_ANDI		: bit_vector(2 downto 0) := "111";
	constant I_FENCE	: bit_vector(2 downto 0) := "000";
	constant I_SLLI		: bit_vector(9 downto 0) := "0000000001";
	constant I_SRLI		: bit_vector(9 downto 0) := "0000000101";
	constant I_SRAI		: bit_vector(9 downto 0) := "0100000101";
	constant I_ADD		: bit_vector(9 downto 0) := "0000000000";
	constant I_SUB		: bit_vector(9 downto 0) := "0100000000";
	constant I_SLL		: bit_vector(9 downto 0) := "0000000001";
	constant I_SLT		: bit_vector(9 downto 0) := "0000000010";
	constant I_SLTU		: bit_vector(9 downto 0) := "0000000011";
	constant I_XOR		: bit_vector(9 downto 0) := "0000000100";
	constant I_SRL		: bit_vector(9 downto 0) := "0000000101";
	constant I_SRA		: bit_vector(9 downto 0) := "0100000101";
	constant I_OR		: bit_vector(9 downto 0) := "0000000110";
	constant I_AND		: bit_vector(9 downto 0) := "0000000111";
	constant I_ECALL	: bit_vector(14 downto 0) := "000000000000000";
	constant I_EBREAK	: bit_vector(14 downto 0) := "000000000001000";

	constant zero		: bit_vector(31 downto 0) := x"00000000";
	constant one		: bit_vector(31 downto 0) := x"FFFFFFFF";
begin
	SEXTMUX_IMM : entity work.mux2_32bit port map (
		d0 => zero,
		d1 => one,
		sel => msb,
		o => sextender
	);

	REGBANK : entity work.register_32bank_32bit port map (
		set => setRegDest,
		reg0 => source0,
		reg1 => source1,
		regw => dest,

		read0 => cReg0,
		read1 => cReg1,
		write => dReg
	);

	ALU : entity work.alu_32bit port map (
		op0 => alu0,
		op1 => alu1,
		res => aluOut,
		op => aluOp
	);

	PCREG : entity work.register_32bit port map (
		data => pcD,
		content => pcC,
		set => pcSet
	);

	PCADDER : entity work.adder_32bit(cla) port map (
		a => pcC,
		b => pcI0,
		s => pcDtmp,
		ci => '0'
	);
	
	--BEGIN DECODE
	opcode <= instruction(6 downto 0);

	rs1 <= instruction(19 downto 15);
	rs2 <= instruction(24 downto 20);
	rd <= instruction(11 downto 7);

	funct3 <= instruction(14 downto 12);
	funct(2 downto 0) <= funct3;
	funct(9 downto 3) <= instruction(31 downto 25); -- funct7
	functlong(14 downto 3) <= instruction(31 downto 20); -- func12
	functlong(2 downto 0) <= funct3;

	msb <= instruction(31);

	immediateI(31 downto 11) <= sextender(31 downto 11);
	immediateI(10 downto 0) <= instruction(30 downto 20);

	immediateS(31 downto 11) <= sextender(31 downto 11);
	immediateS(10 downto 5) <= instruction(30 downto 25);
	immediateS(4 downto 0) <= instruction(11 downto 7);

	immediateB(31 downto 12) <= sextender(31 downto 12);
	immediateB(11) <= instruction(7);
	immediateB(10 downto 5) <= instruction(30 downto 25);
	immediateB(4 downto 1) <= instruction(11 downto 8);
	immediateB(0) <= zero(0);

	immediateU(31 downto 12) <= instruction(31 downto 12);
	immediateU(11 downto 0) <= zero(11 downto 0);

	immediateJ(31 downto 20) <= sextender(31 downto 20);
	immediateJ(19 downto 12) <= instruction(19 downto 12);
	immediateJ(11) <= instruction(20);
	immediateJ(10 downto 1) <= instruction(30 downto 21);
	immediateJ(0) <= zero(0);

	format(0) <= formatI;
	format(1) <= formatS;
	format(2) <= formatB;
	format(3) <= formatU;
	format(4) <= formatJ;

	with format select immediate <=
		immediateI when "00001",
		immediateS when "00010",
		immediateB when "00100",
		immediateU when "01000",
		immediateJ when "10000",
		x"00000000" when others;

	with opcode select formatI <=
		'1' when C_OP_IMM,
		'1' when C_JALR,
		'1' when C_LOAD,
		'1' when C_SYSTEM,
		'0' when others;

	with opcode select formatS <=
		'1' when C_STORE,
		'0' when others;

	with opcode select formatB <=
		'1' when C_BRANCH,
		'0' when others;

	with opcode select formatU <=
		'1' when C_LUI,
		'1' when C_AUIPC,
		'0' when others;

	with opcode select formatJ <=
		'1' when C_JAL,
		'0' when others;
	-- END DECODE

	source0 <= rs1;
	source1 <= rs2;

	bCond <= (aluOut(0) xor crtl_negateCond) and crtl_branch;

	with crtl_useAluRes select dReg <=
		dRegTmp0 when '1',
		dRegTmp1 when '0';

	with crtl_usePcInAlu select alu0 <=
		cReg0 when '0',
		pcC when '1';

	with crtl_useImmediateInAlu select alu1 <=
		immediate when '1',
		cReg1 when '0';

	with crtl_pcRst select pcD <=
		pcDPreRst when '0',
		bootloaderStartAddr when '1';

	with crtl_isJmp select pcDPreRst <=
		pcDtmp when '0',
		aluOut when '1';

	with crtl_isJmp select dRegTmp0 <=
		aluOut when '0',
		pcDtmp when '1';

	with crtl_memRead select dRegTmp1 <=
		immediate when '0',
		memRd when '1';

	with bCond select pcI0 <=
		x"00000004" when '0',
		immediate when '1';

	with crtl_writeReg select dest <=
		rd when '1',
		"00000" when '0';

	with crtl_fetch select memAddr <=
		memAddrTmp when '0',
		pcC when '1';

	with crtl_memRead or crtl_memWrite select memAddrTmp <=
		x"00000000" when '0',
		aluOut when '1';

	with crtl_memWrite select memWr <=
		cReg1 when '1',
		x"00000000" when '0';

	read <= crtl_memRead;
	write <= crtl_memWrite;
	memLen <= crtl_memLen;
	fetchInstruction <= crtl_fetch;

	process (clk)
	begin
	if clk'event and clk = '1' then
		if rst = '1' or rstState = "00" then
			state <= "00001";
			rstState <= "01";

			pcSet <= '0';
			crtl_pcRst <= '1';
			crtl_memRead <= '0';
			crtl_memWrite <= '0';
			crtl_fetch <= '0';
		elsif rstState = "01" then
			rstState <= "10";

			pcSet <= '1';
		elsif rstState = "10" then
			rstState <= "11";

			pcSet <= '0';
			crtl_pcRst <= '0';
		elsif state = "00001" then --fetch
			state <= "00010";

			crtl_memRead <= '1';
			crtl_fetch <= '1';
			crtl_memLen <= "11";
			
			crtl_useAluRes <= '0';
			crtl_usePcInAlu <= '0';
			crtl_useImmediateInAlu <= '0';
			crtl_isJmp <= '0';
			crtl_branch <= '0';
			crtl_writeReg <= '0';
			crtl_memWrite <= '0';

			pcSet <= '0';
			setRegDest <= '0';

			DEBUG_UNKNOWN_INSTRUCTION <= '0';
		elsif state = "00010" then --decode
			state <= "00100";

			instruction <= memRd;
			crtl_memRead <= '0';
			crtl_fetch <= '0';
			crtl_memLen <= "00";
			pcSet <= '0';
		elsif state = "00100" then --execute
			state <= "01000";

			if opcode = C_OP_IMM then
				crtl_useAluRes <= '1';
				crtl_usePcInAlu <= '0';
				crtl_useImmediateInAlu <= '1';
				crtl_isJmp <= '0';
				crtl_branch <= '0';
				crtl_writeReg <= '1';
				crtl_memRead <= '0';
				crtl_memWrite <= '0';
				if funct3 = I_ADDI then
					aluOp <= "0000";
				elsif funct3 = I_SLTI then
					aluOp <= "1001";
				elsif funct3 = I_SLTIU then
					aluOp <= "1011";
				elsif funct3 = I_ANDI then
					aluOp <= "0010";
				elsif funct3 = I_ORI then
					aluOp <= "0011";
				elsif funct3 = I_XORI then
					aluOp <= "0100";
				elsif funct = I_SLLI then
					aluOp <= "0101";
				elsif funct = I_SRLI then
					aluOp <= "0110";
				elsif funct = I_SRAI then
					aluOp <= "0111";
				else
					DEBUG_UNKNOWN_INSTRUCTION <= '1';
				end if;
			elsif opcode = C_LUI then
				crtl_useAluRes <= '0';
				crtl_usePcInAlu <= '0';
				crtl_useImmediateInAlu <= '0';
				crtl_isJmp <= '0';
				crtl_branch <= '0';
				crtl_writeReg <= '1';
				crtl_memRead <= '0';
				crtl_memWrite <= '0';
			elsif opcode = C_AUIPC then
				crtl_useAluRes <= '1';
				crtl_usePcInAlu <= '1';
				crtl_useImmediateInAlu <= '1';
				crtl_isJmp <= '0';
				crtl_branch <= '0';
				crtl_writeReg <= '1';
				crtl_memRead <= '0';
				crtl_memWrite <= '0';
			elsif opcode = C_OP then
				crtl_useAluRes <= '1';
				crtl_usePcInAlu <= '0';
				crtl_useImmediateInAlu <= '0';
				crtl_isJmp <= '0';
				crtl_branch <= '0';
				crtl_writeReg <= '1';
				crtl_memRead <= '0';
				crtl_memWrite <= '0';
				if funct = I_ADD then
					aluOp <= "0000";
				elsif funct = I_SLT then
					aluOp <= "1001";
				elsif funct = I_SLTU then
					aluOp <= "1011";
				elsif funct = I_AND then
					aluOp <= "0010";
				elsif funct = I_OR then
					aluOp <= "0011";
				elsif funct = I_XOR then
					aluOp <= "0100";
				elsif funct = I_SLL then
					aluOp <= "0101";
				elsif funct = I_SRL then
					aluOp <= "0110";
				elsif funct = I_SRA then
					aluOp <= "0111";
				elsif funct = I_SUB then
					aluOp <= "0001";
				else
					DEBUG_UNKNOWN_INSTRUCTION <= '1';
				end if;
			elsif opcode = C_JAL then
				crtl_useAluRes <= '0';
				crtl_usePcInAlu <= '1';
				crtl_useImmediateInAlu <= '1';
				crtl_isJmp <= '1';
				crtl_branch <= '0';
				crtl_writeReg <= '1';
				crtl_memRead <= '0';
				crtl_memWrite <= '0';
			elsif opcode = C_JALR then
				crtl_useAluRes <= '0';
				crtl_usePcInAlu <= '0';
				crtl_useImmediateInAlu <= '0';
				crtl_isJmp <= '1';
				crtl_branch <= '0';
				crtl_writeReg <= '1';
				crtl_memRead <= '0';
				crtl_memWrite <= '0';
			elsif opcode = C_BRANCH then
				crtl_useAluRes <= '0';
				crtl_usePcInAlu <= '0';
				crtl_useImmediateInAlu <= '0';
				crtl_isJmp <= '0';
				crtl_branch <= '1';
				crtl_writeReg <= '0';
				crtl_memRead <= '0';
				crtl_memWrite <= '0';
				if funct3 = I_BEQ then
					crtl_negateCond <= '0';
					aluOp <= "1000";
				elsif funct3 = I_BNE then
					crtl_negateCond <= '1';
					aluOp <= "1000";
				elsif funct3 = I_BLT then
					crtl_negateCond <= '0';
					aluOp <= "1001";
				elsif funct3 = I_BLTU then
					crtl_negateCond <= '0';
					aluOp <= "1011";
				elsif funct3 = I_BGE then
					crtl_negateCond <= '1';
					aluOp <= "1001";
				elsif funct3 = I_BGEU then
					crtl_negateCond <= '1';
					aluOp <= "1011";
				else
					DEBUG_UNKNOWN_INSTRUCTION <= '1';
				end if;
			elsif opcode = C_LOAD then
				crtl_useAluRes <= '0';
				crtl_usePcInAlu <= '0';
				crtl_useImmediateInAlu <= '1';
				crtl_isJmp <= '0';
				crtl_branch <= '0';
				crtl_writeReg <= '1';
				crtl_memRead <= '1';
				crtl_memWrite <= '0';
				aluOp <= "0000";
				
				if funct3 = I_LB then
					crtl_memLen <= "01";
					crtl_memUnsigned <= '0';
				elsif funct3 = I_LBU then
					crtl_memLen <= "01";
					crtl_memUnsigned <= '1';
				elsif funct3 = I_LH then
					crtl_memLen <= "10";
					crtl_memUnsigned <= '0';
				elsif funct3 = I_LHU then
					crtl_memLen <= "10";
					crtl_memUnsigned <= '1';
				elsif funct3 = I_LW then
					crtl_memLen <= "11";
				else
					DEBUG_UNKNOWN_INSTRUCTION <= '1';
				end if;
			elsif opcode = C_STORE then
				crtl_useAluRes <= '0';
				crtl_usePcInAlu <= '0';
				crtl_useImmediateInAlu <= '1';
				crtl_isJmp <= '0';
				crtl_branch <= '0';
				crtl_writeReg <= '0';
				crtl_memRead <= '0';
				crtl_memWrite <= '1';
				aluOp <= "0000";
				
				if funct3 = I_SB then
					crtl_memLen <= "01";
				elsif funct3 = I_SH then
					crtl_memLen <= "10";
				elsif funct3 = I_SW then
					crtl_memLen <= "11";
				else
					DEBUG_UNKNOWN_INSTRUCTION <= '1';
				end if;
			else
				DEBUG_UNKNOWN_INSTRUCTION <= '1';
			end if;
		elsif state = "01000" then --mem
			state <= "10000";

		elsif state = "10000" then --write
			state <= "00001";

			aluOp <= "0000";

			pcSet <= '1';
			setRegDest <= '1';
		end if;
	end if;
	end process;
end;

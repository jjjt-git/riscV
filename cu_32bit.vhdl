library ieee;

entity cu_32bit is
port (
	memWord: inout bit_vector(31 downto 0);
	memAddr: out bit_vector(31 downto 0);
	fetchInstruction: out bit;
	clk: in bit
);
end;

architecture def of cu_32bit is
	signal instruction: bit_vector(31 downto 0);

	signal rs1, rs2, rd, source0, source1, dest: bit_vector(4 downto 0);
	signal opcode: bit_vector(6 downto 0);
	signal funct: bit_vector(9 downto 0);
	signal funct3: bit_vector(2 downto 0);
	signal functlong: bit_vector(14 downto 0);
	signal immediate: bit_vector(31 downto 0);
	signal one, zero, sextender: bit_vector(31 downto 0);
	signal msb: bit;

	signal state: bit_vector(4 downto 0);	-- 0 fetch
						-- 1 decode/execute
						-- 2 (memory)
						-- 3 write
						-- 5 jump

	-- register-bank
	signal setRegDest: bit;
	signal cReg0, cReg1, dReg: bit_vector(31 downto 0);

	-- pc-register
	signal pcC, pcD: bit_vector(31 downto 0);
	signal pcSet, longJump: bit;
	signal pcI0, pcI, pcCalt, pcDtmp: bit_vector(31 downto 0);

	-- branch helpers
	signal pcIB, bAddr: bit_vector(31 downto 0);
	signal bCond: bit;

	-- alu
	signal alu0, alu1, aluOut: bit_vector(31 downto 0);
	signal aluOP: bit_vector(3 downto 0);	-- 0000 add
						-- 0001 sub
						-- 0010 and
						-- 0011 or
						-- 0100 xor
						-- 0101 shift left
						-- 0110 shift right
						-- 0111 arithmetic shift
						-- 1000 equal
						-- 1001 less than

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
begin
	one <= x"FFFFFFFF";
	zero <= x"00000000";

	SEXTMUX_SIGN : entity work.mux2_32bit port map (
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

	PCREG : entity work.register_32bit port map (
		data => pcD,
		content => pcC,
		set => pcSet
	);

	PCI0MUX : entity work.mux2_32bit port map (
		d0 => pcC,
		d1 => pcCalt,
		o => pcI0,
		sel => longJump
	);

	PCADDER : entity work.adder_32bit(cla) port map (
		a => pcI0,
		b => pcI,
		s => pcDtmp,
		ci => '0'
	);
	pcD(31 downto 1) <= pcDtmp(31 downto 1);
	pcD(0) <= '0';

	BRANCHMUX : entity work.mux2_32bit port map (
		d0 => x"00000004",
		d1 => bAddr,
		o => pcIB,
		sel => bCond
	);

	process (clk)
	begin
	if rising_edge(clk) then
		if state = "00001" then --fetch TODO
			state <= "00010";
			setRegDest <= '0';
			pcSet <= '0';
			longJump <= '0';

			fetchInstruction <= '1';
		elsif state = "00010" then --decode/execute
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

			if opcode = C_OP_IMM then -- I-type
				immediate(11 downto 0) <= instruction(31 downto 20);
				immediate(31 downto 12) <= sextender(31 downto 12);

				state <= "00100";

				source0 <= rs1;
				dest <= rd;
				dReg <= aluOut;
				if funct3 = I_ADDI then
					alu0 <= cReg0;
					alu1 <= immediate;
					aluOp <= "0000";
				elsif funct3 = I_SLTI then
					alu0 <= cReg0;
					alu1 <= immediate;
					aluOp <= "1001";
				elsif funct3 = I_SLTIU then -- TODO
				elsif funct3 = I_ANDI then
					alu0 <= cReg0;
					alu1 <= immediate;
					aluOp <= "0010";
				elsif funct3 = I_ORI then
					alu0 <= cReg0;
					alu1 <= immediate;
					aluOp <= "0011";
				elsif funct3 = I_XORI then
					alu0 <= cReg0;
					alu1 <= immediate;
					aluOp <= "0100";
				elsif funct = I_SLLI then
					alu0 <= cReg0;
					alu1(4 downto 0) <= immediate(4 downto 0);
					aluOp <= "0101";
				elsif funct = I_SRLI then
					alu0 <= cReg0;
					alu1 <= immediate;
					aluOp <= "0110";
				elsif funct = I_SRAI then
					alu0 <= cReg0;
					alu1(4 downto 0) <= immediate(4 downto 0);
					aluOp <= "0111";
				end if;
			elsif opcode = C_LUI then
				immediate(31 downto 12) <= instruction(31 downto 12);
				immediate(12 downto 0) <= zero(12 downto 0);
				dest <= rd;

				state <= "00100";

				dReg <= immediate;
			elsif opcode = C_AUIPC then
				immediate(31 downto 12) <= instruction(31 downto 12);
				immediate(12 downto 0) <= zero(12 downto 0);
				dest <= rd;

				state <= "00100";

				alu0 <= immediate;
				alu1 <= pcC;
				aluOp <= "0000";

				dReg <= aluOut;
			elsif opcode = C_OP then
				source0 <= rs1;
				source1 <= rs2;
				dest <= rd;
				dReg <= aluOut;

				state <= "00100";

				if funct = I_ADD then
					aluOp <= "0000";
					alu0 <= cReg0;
					alu1 <= cReg1;
				elsif funct = I_SUB then
					aluOp <= "0001";
					alu0 <= cReg0;
					alu1 <= cReg1;
				elsif funct = I_AND then
					aluOp <= "0010";
					alu0 <= cReg0;
					alu1 <= cReg1;
				elsif funct = I_OR then
					aluOp <= "0011";
					alu0 <= cReg0;
					alu1 <= cReg1;
				elsif funct = I_XOR then
					aluOp <= "0100";
					alu0 <= cReg0;
					alu1 <= cReg1;
				elsif funct = I_SLT then
					aluOp <= "1001";
					alu0 <= cReg0;
					alu1 <= cReg1;
				elsif funct = I_SLTU then -- TODO
					aluOp <= "0011";
					alu0 <= cReg0;
					alu1 <= cReg1;
				elsif funct = I_SLL then
					aluOp <= "0101";
					alu0 <= cReg0;
					alu1 <= cReg1;
				elsif funct = I_SRL then
					aluOp <= "0110";
					alu0 <= cReg0;
					alu1 <= cReg1;
				elsif funct = I_SRA then
					aluOp <= "0111";
					alu0 <= cReg0;
					alu1 <= cReg1;
				end if;
			elsif opcode = C_JAL then
				aluOp <= "0000";
				dest <= rd;
				source0 <= rs1;

				immediate(31 downto 20) <= sextender(31 downto 20);
				immediate(19 downto 12) <= instruction(19 downto 12);
				immediate(11) <= instruction(11);
				immediate(10 downto 1) <= instruction (30 downto 21);
				immediate(0) <= '0';

				state <= "01000";

				alu0 <= pcC;
				alu1 <= x"00000004";
				dReg <= aluOut;

				pcI <= immediate;
			elsif opcode = C_JALR then
				aluOp <= "0000";
				dest <= rd;
				longJump <= '1';

				immediate(31 downto 20) <= sextender(31 downto 20);
				immediate(19 downto 12) <= instruction(19 downto 12);
				immediate(11) <= instruction(11);
				immediate(10 downto 1) <= instruction (30 downto 21);
				immediate(0) <= '0';

				state <= "01000";

				alu0 <= pcC;
				alu1 <= x"00000004";
				dReg <= aluOut;

				pcI <= immediate;
				pcCalt <= cReg0;
			elsif opcode = C_BRANCH then
				pcI <= pcIB;
				source0 <= rs1;
				source1 <= rs2;

				immediate(31 downto 12) <= sextender(31 downto 12);
				immediate(10 downto 5) <= instruction(30 downto 25);
				immediate(4 downto 1) <= instruction(11 downto 8);
				immediate(11) <= instruction(7);
				immediate(0) <= '0';

				bAddr <= immediate;

				-- 1000 EQ
				-- 1001 LT

				if funct3 = I_BEQ then
					aluOp <= "1000";
					alu0 <= cReg0;
					alu1 <= cReg1;
					bCond <= aluOut(0);
				elsif funct3 = I_BNE then
					aluOp <= "1000";
					alu0 <= cReg0;
					alu1 <= cReg1;
					bCond <= not aluOut(0);
				elsif funct3 = I_BLT then
					aluOp <= "1001";
					alu0 <= cReg0;
					alu1 <= cReg1;
					bCond <= aluOut(0);
				elsif funct3 = I_BLTU then -- TODO
				elsif funct3 = I_BGE then
					aluOp <= "1001";
					alu0 <= cReg0;
					alu1 <= cReg1;
					bCond <= not aluOut(0);
				elsif funct3 = I_BGEU then -- TODO
				end if;
			elsif opcode = C_LOAD then -- TODO after EEI
			elsif opcode = C_STORE then -- TODO after EEI
			elsif opcode = C_MISC_MEM then -- TODO after EEI
			elsif opcode = C_SYSTEM then
				if functlong = I_EBREAK then -- TODO after EEI
				elsif functlong = I_ECALL then -- TODO after EEI
				end if;
			end if;
		elsif state = "00100" then --execute
		elsif state = "01000" then --write
			state <= "00001";
			setRegDest <= '1';
			pcSet <= '1';
		end if;
	end if;
	end process;
end;
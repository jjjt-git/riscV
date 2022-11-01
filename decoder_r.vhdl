library ieee;

entity decoder_r is
port (
	i: in bit_vector(31 downto 0);
	funct7: out bit_vector(6 downto 0);
	rs2: out bit_vector(4 downto 0);
	rs1: out bit_vector(4 downto 0);
	funct3: out bit_vector(2 downto 0);
	rd: out bit_vector(4 downto 0);
	opcode: out bit_vector(6 downto 0)
);
end;

architecture def of decoder_r is
begin
	opcode <= i(6 downto 0);
	rd <= i(11 downto 7);
	funct3 <= i(14 downto 12);
	rs1 <= i(19 downto 15);
	rs2 <= i(24 downto 20);
	funct7 <= i(31 downto 25);
end;
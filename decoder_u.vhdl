library ieee;

entity decoder_u is
port (
	i: in bit_vector(31 downto 0);
	imm: out bit_vector(19 downto 0);
	rd: out bit_vector(4 downto 0);
	opcode: out bit_vector(6 downto 0)
);
end;

architecture def of decoder_u is
begin
	opcode <= i(6 downto 0);
	rd <= i(11 downto 7);
	imm <= i(31 downto 12);
end;
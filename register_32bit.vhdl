library ieee;

entity register_32bit is
port (
	data: in bit_vector(31 downto 0);
	content: out bit_vector(31 downto 0);
	set: in bit
);
end;

architecture with_tmp of register_32bit is
	signal tmp: bit_vector(31 downto 0);
begin
	FF: process (set)
	begin
		if rising_edge(set) then
			tmp <= data;
		elsif falling_edge(set) then
			content <= tmp;
		end if;
	end process;
end;
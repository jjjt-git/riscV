library ieee;

entity register_32bit is
port (
	data: in bit_vector(31 downto 0);
	content: out bit_vector(31 downto 0);
	set: in bit
);
end;

architecture zero of register_32bit is
begin
	content <= "00000000000000000000000000000000";
end;

architecture def of register_32bit is
	signal tmp: bit_vector(31 downto 0);
begin
	FF: process (set)
	begin
		if set'event and set = '1' then
			tmp <= data;
		elsif set'event and set = '0' then
			content <= tmp;
		end if;
	end process;
end;
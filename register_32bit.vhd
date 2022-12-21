library ieee;

entity register_32bit is
port (
	data: in bit_vector(31 downto 0);
	content: out bit_vector(31 downto 0);
	set: in bit
);
end;

architecture def of register_32bit is
begin
	FF: process (set)
	begin
		if set'event and set = '1' then
			content <= data;
		end if;
	end process;
end;
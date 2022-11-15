library ieee;

entity register_32bank_32bit is
port(
	reg0: in bit_vector(4 downto 0);
	reg1: in bit_vector(4 downto 0);
	regw: in bit_vector(4 downto 0);

	read0: out bit_vector(31 downto 0);
	read1: out bit_vector(31 downto 0);
	write: in bit_vector(31 downto 0);

	set: in bit
);
end;

architecture def of register_32bank_32bit is
	signal zero: bit_vector(31 downto 0);

	-- reg specific set
	signal s00001, s00010, s00011, s00100,
		s00101, s00110, s00111, s01000,
		s01001, s01010, s01011, s01100,
		s01101, s01110, s01111, s10000,
		s10001, s10010, s10011, s10100,
		s10101, s10110, s10111, s11000,
		s11001, s11010, s11011, s11100,
		s11101, s11110, s11111: bit;

	-- content
	signal c00001, c00010, c00011, c00100,
		c00101, c00110, c00111, c01000,
		c01001, c01010, c01011, c01100,
		c01101, c01110, c01111, c10000,
		c10001, c10010, c10011, c10100,
		c10101, c10110, c10111, c11000,
		c11001, c11010, c11011, c11100,
		c11101, c11110, c11111: bit_vector(31 downto 0);
begin
	zero <= x"00000000";

	process (regw, set) is
	begin
		if regw = "00001" then s00001 <= set;
		elsif regw = "00010" then s00010 <= set;
		elsif regw = "00011" then s00011 <= set;
		elsif regw = "00100" then s00100 <= set;
		elsif regw = "00101" then s00101 <= set;
		elsif regw = "00110" then s00110 <= set;
		elsif regw = "00111" then s00111 <= set;
		elsif regw = "01000" then s01000 <= set;
		elsif regw = "01001" then s01001 <= set;
		elsif regw = "01010" then s01010 <= set;
		elsif regw = "01011" then s01011 <= set;
		elsif regw = "01100" then s01100 <= set;
		elsif regw = "01101" then s01101 <= set;
		elsif regw = "01110" then s01110 <= set;
		elsif regw = "01111" then s01111 <= set;
		elsif regw = "10000" then s10000 <= set;
		elsif regw = "10001" then s10001 <= set;
		elsif regw = "10010" then s10010 <= set;
		elsif regw = "10011" then s10011 <= set;
		elsif regw = "10100" then s10100 <= set;
		elsif regw = "10101" then s10101 <= set;
		elsif regw = "10110" then s10110 <= set;
		elsif regw = "10111" then s10111 <= set;
		elsif regw = "11000" then s11000 <= set;
		elsif regw = "11001" then s11001 <= set;
		elsif regw = "11010" then s11010 <= set;
		elsif regw = "11011" then s11011 <= set;
		elsif regw = "11100" then s11100 <= set;
		elsif regw = "11101" then s11101 <= set;
		elsif regw = "11110" then s11110 <= set;
		elsif regw = "11111" then s11111 <= set;
		end if;
	end process;

	MUXR0 : entity work.mux32_32bit
	port map (
		d00000 => zero, d00001 => c00001, d00010 => c00010, d00011 => c00011,
		d00100 => c00100, d00101 => c00101, d00110 => c00110, d00111 => c00111,
		d01000 => c01000, d01001 => c01001, d01010 => c01010, d01011 => c01011,
		d01100 => c01100, d01101 => c01101, d01110 => c01110, d01111 => c01111,
		d10000 => c10000, d10001 => c10001, d10010 => c10010, d10011 => c10011,
		d10100 => c10100, d10101 => c10101, d10110 => c10110, d10111 => c10111,
		d11000 => c11000, d11001 => c11001, d11010 => c11010, d11011 => c11011,
		d11100 => c11100, d11101 => c11101, d11110 => c11110, d11111 => c11111,
		o => read0,
		sel => reg0
	);

	MUXR1 : entity work.mux32_32bit
	port map (
		d00000 => zero, d00001 => c00001, d00010 => c00010, d00011 => c00011,
		d00100 => c00100, d00101 => c00101, d00110 => c00110, d00111 => c00111,
		d01000 => c01000, d01001 => c01001, d01010 => c01010, d01011 => c01011,
		d01100 => c01100, d01101 => c01101, d01110 => c01110, d01111 => c01111,
		d10000 => c10000, d10001 => c10001, d10010 => c10010, d10011 => c10011,
		d10100 => c10100, d10101 => c10101, d10110 => c10110, d10111 => c10111,
		d11000 => c11000, d11001 => c11001, d11010 => c11010, d11011 => c11011,
		d11100 => c11100, d11101 => c11101, d11110 => c11110, d11111 => c11111,
		o => read1,
		sel => reg1
	);

	REG00001 : entity work.register_32bit port map (data => write, content => c00001, set => s00001);
	REG00010 : entity work.register_32bit port map (data => write, content => c00010, set => s00010);
	REG00011 : entity work.register_32bit port map (data => write, content => c00011, set => s00011);
	REG00100 : entity work.register_32bit port map (data => write, content => c00100, set => s00100);
	REG00101 : entity work.register_32bit port map (data => write, content => c00101, set => s00101);
	REG00110 : entity work.register_32bit port map (data => write, content => c00110, set => s00110);
	REG00111 : entity work.register_32bit port map (data => write, content => c00111, set => s00111);
	REG01000 : entity work.register_32bit port map (data => write, content => c01000, set => s01000);
	REG01001 : entity work.register_32bit port map (data => write, content => c01001, set => s01001);
	REG01010 : entity work.register_32bit port map (data => write, content => c01010, set => s01010);
	REG01011 : entity work.register_32bit port map (data => write, content => c01011, set => s01011);
	REG01100 : entity work.register_32bit port map (data => write, content => c01100, set => s01100);
	REG01101 : entity work.register_32bit port map (data => write, content => c01101, set => s01101);
	REG01110 : entity work.register_32bit port map (data => write, content => c01110, set => s01110);
	REG01111 : entity work.register_32bit port map (data => write, content => c01111, set => s01111);
	REG10000 : entity work.register_32bit port map (data => write, content => c10000, set => s10000);
	REG10001 : entity work.register_32bit port map (data => write, content => c10001, set => s10001);
	REG10010 : entity work.register_32bit port map (data => write, content => c10010, set => s10010);
	REG10011 : entity work.register_32bit port map (data => write, content => c10011, set => s10011);
	REG10100 : entity work.register_32bit port map (data => write, content => c10100, set => s10100);
	REG10101 : entity work.register_32bit port map (data => write, content => c10101, set => s10101);
	REG10110 : entity work.register_32bit port map (data => write, content => c10110, set => s10110);
	REG10111 : entity work.register_32bit port map (data => write, content => c10111, set => s10111);
	REG11000 : entity work.register_32bit port map (data => write, content => c11000, set => s11000);
	REG11001 : entity work.register_32bit port map (data => write, content => c11001, set => s11001);
	REG11010 : entity work.register_32bit port map (data => write, content => c11010, set => s11010);
	REG11011 : entity work.register_32bit port map (data => write, content => c11011, set => s11011);
	REG11100 : entity work.register_32bit port map (data => write, content => c11100, set => s11100);
	REG11101 : entity work.register_32bit port map (data => write, content => c11101, set => s11101);
	REG11110 : entity work.register_32bit port map (data => write, content => c11110, set => s11110);
	REG11111 : entity work.register_32bit port map (data => write, content => c11111, set => s11111);
end;

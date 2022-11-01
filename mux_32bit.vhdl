library ieee;

entity mux2_32bit is
port (
	d0: in bit_vector(31 downto 0);
	d1: in bit_vector(31 downto 0);
	o: out bit_vector(31 downto 0);
	sel: in bit
);
end;

entity mux4_32bit is
port (
	d00: in bit_vector(31 downto 0);
	d01: in bit_vector(31 downto 0);
	d10: in bit_vector(31 downto 0);
	d11: in bit_vector(31 downto 0);
	o: out bit_vector(31 downto 0);
	sel: in bit_vector(1 downto 0)
);
end;

entity mux8_32bit is
port (
	d000: in bit_vector(31 downto 0);
	d001: in bit_vector(31 downto 0);
	d010: in bit_vector(31 downto 0);
	d011: in bit_vector(31 downto 0);
	d100: in bit_vector(31 downto 0);
	d101: in bit_vector(31 downto 0);
	d110: in bit_vector(31 downto 0);
	d111: in bit_vector(31 downto 0);
	o: out bit_vector(31 downto 0);
	sel: in bit_vector(2 downto 0)
);
end;

entity mux16_32bit is
port (
	d0000: in bit_vector(31 downto 0);
	d0001: in bit_vector(31 downto 0);
	d0010: in bit_vector(31 downto 0);
	d0011: in bit_vector(31 downto 0);
	d0100: in bit_vector(31 downto 0);
	d0101: in bit_vector(31 downto 0);
	d0110: in bit_vector(31 downto 0);
	d0111: in bit_vector(31 downto 0);
	d1000: in bit_vector(31 downto 0);
	d1001: in bit_vector(31 downto 0);
	d1010: in bit_vector(31 downto 0);
	d1011: in bit_vector(31 downto 0);
	d1100: in bit_vector(31 downto 0);
	d1101: in bit_vector(31 downto 0);
	d1110: in bit_vector(31 downto 0);
	d1111: in bit_vector(31 downto 0);
	o: out bit_vector(31 downto 0);
	sel: in bit_vector(3 downto 0)
);
end;

entity mux32_32bit is
port (
	d00000: in bit_vector(31 downto 0);
	d00001: in bit_vector(31 downto 0);
	d00010: in bit_vector(31 downto 0);
	d00011: in bit_vector(31 downto 0);
	d00100: in bit_vector(31 downto 0);
	d00101: in bit_vector(31 downto 0);
	d00110: in bit_vector(31 downto 0);
	d00111: in bit_vector(31 downto 0);
	d01000: in bit_vector(31 downto 0);
	d01001: in bit_vector(31 downto 0);
	d01010: in bit_vector(31 downto 0);
	d01011: in bit_vector(31 downto 0);
	d01100: in bit_vector(31 downto 0);
	d01101: in bit_vector(31 downto 0);
	d01110: in bit_vector(31 downto 0);
	d01111: in bit_vector(31 downto 0);
	d10000: in bit_vector(31 downto 0);
	d10001: in bit_vector(31 downto 0);
	d10010: in bit_vector(31 downto 0);
	d10011: in bit_vector(31 downto 0);
	d10100: in bit_vector(31 downto 0);
	d10101: in bit_vector(31 downto 0);
	d10110: in bit_vector(31 downto 0);
	d10111: in bit_vector(31 downto 0);
	d11000: in bit_vector(31 downto 0);
	d11001: in bit_vector(31 downto 0);
	d11010: in bit_vector(31 downto 0);
	d11011: in bit_vector(31 downto 0);
	d11100: in bit_vector(31 downto 0);
	d11101: in bit_vector(31 downto 0);
	d11110: in bit_vector(31 downto 0);
	d11111: in bit_vector(31 downto 0);
	o: out bit_vector(31 downto 0);
	sel: in bit_vector(4 downto 0)
);
end;

architecture def of mux2_32bit is
begin
	with sel select
		o <= 	d0 when '0',
			d1 when '1';
end;

architecture def of mux4_32bit is
	signal o0, o1: bit_vector(31 downto 0);
begin
	MUX0 : entity work.mux2_32bit
		port map (
			d0 => d00,
			d1 => d01,
			o => o0,
			sel => sel(0)
		);
	MUX1 : entity work.mux2_32bit
		port map (
			d0 => d10,
			d1 => d11,
			o => o1,
			sel => sel(0)
		);
	
	with sel(1) select
		o <= 	o0 when '0',
			o1 when '1';
end;

architecture def of mux8_32bit is
	signal o0, o1: bit_vector(31 downto 0);
begin
	MUX0 : entity work.mux4_32bit
		port map (
			d00 => d000,
			d01 => d001,
			d10 => d010,
			d11 => d011,
			o => o0,
			sel => sel(1 downto 0)
		);
	MUX1 : entity work.mux4_32bit
		port map (
			d00 => d100,
			d01 => d101,
			d10 => d110,
			d11 => d111,
			o => o1,
			sel => sel(1 downto 0)
		);
	
	with sel(2) select
		o <= 	o0 when '0',
			o1 when '1';
end;

architecture def of mux16_32bit is
	signal o0, o1: bit_vector(31 downto 0);
begin
	MUX0 : entity work.mux8_32bit
		port map (
			d000 => d0000,
			d001 => d0001,
			d010 => d0010,
			d011 => d0011,
			d100 => d0100,
			d101 => d0101,
			d110 => d0110,
			d111 => d0111,
			o => o0,
			sel => sel(2 downto 0)
		);
	MUX1 : entity work.mux8_32bit
		port map (
			d000 => d1000,
			d001 => d1001,
			d010 => d1010,
			d011 => d1011,
			d100 => d1100,
			d101 => d1101,
			d110 => d1110,
			d111 => d1111,
			o => o1,
			sel => sel(2 downto 0)
		);
	
	with sel(3) select
		o <= 	o0 when '0',
			o1 when '1';
end;

architecture def of mux32_32bit is
	signal o0, o1: bit_vector(31 downto 0);
begin
	MUX0 : entity work.mux16_32bit
		port map (
			d0000 => d00000,
			d0001 => d00001,
			d0010 => d00010,
			d0011 => d00011,
			d0100 => d00100,
			d0101 => d00101,
			d0110 => d00110,
			d0111 => d00111,
			d1000 => d01000,
			d1001 => d01001,
			d1010 => d01010,
			d1011 => d01011,
			d1100 => d01100,
			d1101 => d01101,
			d1110 => d01110,
			d1111 => d01111,
			o => o0,
			sel => sel(3 downto 0)
		);
	MUX1 : entity work.mux16_32bit
		port map (
			d0000 => d10000,
			d0001 => d10001,
			d0010 => d10010,
			d0011 => d10011,
			d0100 => d10100,
			d0101 => d10101,
			d0110 => d10110,
			d0111 => d10111,
			d1000 => d11000,
			d1001 => d11001,
			d1010 => d11010,
			d1011 => d11011,
			d1100 => d11100,
			d1101 => d11101,
			d1110 => d11110,
			d1111 => d11111,
			o => o1,
			sel => sel(3 downto 0)
		);
	
	with sel(4) select
		o <= 	o0 when '0',
			o1 when '1';
end;
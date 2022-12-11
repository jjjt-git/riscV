library ieee;

entity rotL_32bit is
port (
	i0: in bit_vector(31 downto 0);
	i1: in bit_vector(31 downto 0);
	o: out bit_vector(31 downto 0);
	len: in bit_vector(4 downto 0)
);
end;

entity rotR_32bit is
port (
	i0: in bit_vector(31 downto 0);
	i1: in bit_vector(31 downto 0);
	o: out bit_vector(31 downto 0);
	len: in bit_vector(4 downto 0)
);
end;

architecture def of rotL_32bit is
	signal w: bit_vector(63 downto 0);
begin
	w(63 downto 32) <= i0;
	w(31 downto 0)  <= i1;
	
	MUX : entity work.mux32_32bit
		port map (
			sel => len,
			o => o,
			d00000 => w(63 downto 32),
			d00001 => w(62 downto 31),
			d00010 => w(61 downto 30),
			d00011 => w(60 downto 29),
			d00100 => w(59 downto 28),
			d00101 => w(58 downto 27),
			d00110 => w(57 downto 26),
			d00111 => w(56 downto 25),
			d01000 => w(55 downto 24),
			d01001 => w(54 downto 23),
			d01010 => w(53 downto 22),
			d01011 => w(52 downto 21),
			d01100 => w(51 downto 20),
			d01101 => w(50 downto 19),
			d01110 => w(49 downto 18),
			d01111 => w(48 downto 17),
			d10000 => w(47 downto 16),
			d10001 => w(46 downto 15),
			d10010 => w(45 downto 14),
			d10011 => w(44 downto 13),
			d10100 => w(43 downto 12),
			d10101 => w(42 downto 11),
			d10110 => w(41 downto 10),
			d10111 => w(40 downto 9),
			d11000 => w(39 downto 8),
			d11001 => w(38 downto 7),
			d11010 => w(37 downto 6),
			d11011 => w(36 downto 5),
			d11100 => w(35 downto 4),
			d11101 => w(34 downto 3),
			d11110 => w(33 downto 2),
			d11111 => w(32 downto 1)
		);
end;

architecture def of rotR_32bit is
	signal w: bit_vector(63 downto 0);
begin
	w(63 downto 32) <= i1;
	w(31 downto 0)  <= i0;
	
	MUX : entity work.mux32_32bit
		port map (
			sel => len,
			o => o,
			d00000 => w(31 downto 0),
			d00001 => w(32 downto 1),
			d00010 => w(33 downto 2),
			d00011 => w(34 downto 3),
			d00100 => w(35 downto 4),
			d00101 => w(36 downto 5),
			d00110 => w(37 downto 6),
			d00111 => w(38 downto 7),
			d01000 => w(39 downto 8),
			d01001 => w(40 downto 9),
			d01010 => w(41 downto 10),
			d01011 => w(42 downto 11),
			d01100 => w(43 downto 12),
			d01101 => w(44 downto 13),
			d01110 => w(45 downto 14),
			d01111 => w(46 downto 15),
			d10000 => w(47 downto 16),
			d10001 => w(48 downto 17),
			d10010 => w(49 downto 18),
			d10011 => w(50 downto 19),
			d10100 => w(51 downto 20),
			d10101 => w(52 downto 21),
			d10110 => w(53 downto 22),
			d10111 => w(54 downto 23),
			d11000 => w(55 downto 24),
			d11001 => w(56 downto 25),
			d11010 => w(57 downto 26),
			d11011 => w(58 downto 27),
			d11100 => w(59 downto 28),
			d11101 => w(60 downto 29),
			d11110 => w(61 downto 30),
			d11111 => w(62 downto 31)
		);
end;
library ieee;

entity adder_32bit is
port (
	a: in bit_vector(31 downto 0);
	b: in bit_vector(31 downto 0);
	ci: in bit;
	s: out bit_vector(31 downto 0);
	co: out bit
);
end;

architecture cra of adder_32bit is
	signal c: bit_vector(32 downto 0); -- cbs; ci is c(0); co is c(32)
	signal c_op: bit_vector(31 downto 0); -- operation-relevant cbs
begin
	c(0) <= ci;
	co <= c(32);
	c_op <= c(31 downto 0);
	
	s <= a xor b xor c_op;
	
	c(32 downto 1) <= (a and b) or (a and c_op) or (b and c_op);
end;

architecture caska_bs4 of adder_32bit is
	signal c: bit_vector(6 downto 0); -- inter-block carrys
begin
	B0 : entity work.adder_4bit(caska)
		port map (
			ci => ci,
			co => c(0),
			a => a(3 downto 0),
			b => b(3 downto 0),
			s => s(3 downto 0)
		);
	B1 : entity work.adder_4bit(caska)
		port map (
			ci => c(0),
			co => c(1),
			a => a(7 downto 4),
			b => b(7 downto 4),
			s => s(7 downto 4)
		);
	B2 : entity work.adder_4bit(caska)
		port map (
			ci => c(1),
			co => c(2),
			a => a(11 downto 8),
			b => b(11 downto 8),
			s => s(11 downto 8)
		);
	B3 : entity work.adder_4bit(caska)
		port map (
			ci => c(2),
			co => c(3),
			a => a(15 downto 12),
			b => b(15 downto 12),
			s => s(15 downto 12)
		);
	B4 : entity work.adder_4bit(caska)
		port map (
			ci => c(3),
			co => c(4),
			a => a(19 downto 16),
			b => b(19 downto 16),
			s => s(19 downto 16)
		);
	B5 : entity work.adder_4bit(caska)
		port map (
			ci => c(4),
			co => c(5),
			a => a(23 downto 20),
			b => b(23 downto 20),
			s => s(23 downto 20)
		);
	B6 : entity work.adder_4bit(caska)
		port map (
			ci => c(5),
			co => c(6),
			a => a(27 downto 24),
			b => b(27 downto 24),
			s => s(27 downto 24)
		);
	B_END : entity work.adder_4bit(cra)
		port map (
			ci => c(6),
			co => co,
			a => a(31 downto 28),
			b => b(31 downto 28),
			s => s(31 downto 28)
		);
end;

architecture cla of adder_32bit is
	signal prop: bit_vector(31 downto 0);
	signal gen: bit_vector(31 downto 0);
	signal c: bit_vector(32 downto 0);
begin
	gen <= a and b;
	prop <= a xor b;
	
	s <= prop xor c(31 downto 0);
	co <= c(32);
	
	c(0) <= ci;
	c(32 downto 1) <= gen or (prop and c(31 downto 0)); -- if too slow, expand structure (reference in adder_4bit_cla)
end;
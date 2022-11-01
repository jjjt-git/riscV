library ieee;

entity adder_4bit is
port (
	a: in bit_vector (3 downto 0);
	b: in bit_vector (3 downto 0);
	ci: in bit;
	s: out bit_vector (3 downto 0);
	co: out bit
);
end;

architecture cra of adder_4bit is
	signal c: bit_vector (3 downto 0);
begin
	co <= c(3);
	
	c(0) <= (a(0) and b(0)) or (a(0) and ci) or (ci and b(0));
	s(0) <= a(0) xor b(0) xor ci;
	
	c(1) <= (a(1) and b(1)) or (a(1) and c(0)) or (c(0) and b(1));
	s(1) <= a(1) xor b(1) xor c(0);
	
	c(2) <= (a(2) and b(2)) or (a(2) and c(1)) or (c(1) and b(2));
	s(2) <= a(2) xor b(2) xor c(1);
	
	c(3) <= (a(3) and b(3)) or (a(3) and c(2)) or (c(2) and b(3));
	s(3) <= a(3) xor b(3) xor c(2);	
end;

architecture caska of adder_4bit is
	signal will_carry: bit;
	signal is_set: bit_vector (3 downto 0);
	signal s_co: bit;
begin
	co <= will_carry or s_co;
	
	will_carry <= is_set(0) and is_set(1) and is_set(2) and is_set(3) and ci;
	is_set <= a or b;
	
	ADD : entity work.adder_4bit(cra)
		port map (
			a => a,
			b => b,
			ci => ci,
			s => s,
			co => s_co
		);
end;

architecture cla of adder_4bit is
	signal prop: bit_vector (3 downto 0); -- propagation bits
	signal gen: bit_vector (3 downto 0); -- generation bits
	signal c: bit_vector (4 downto 0); -- carry bits
begin
	-- GENERATION AND PROPAGATION SIGNALS
	-- when none set -> absorbing
	gen <= a and b;
	prop <= a xor b;
	
	co <= c(4);
	
	-- CARRY CALC
	c(0) <= ci;
	c(1) <= gen(0) or
		(ci and prop(0));
	c(2) <= gen(1) or
		(gen(0) and prop(1)) or
		(ci and prop(0) and prop(1));
	c(3) <= gen(2) or
		(gen(1) and prop(2)) or
		(gen(0) and prop(1) and prop(2)) or
		(ci and prop(0) and prop(1) and prop(2));
	c(4) <= gen(3) or -- MSB generates cb
		(gen(2) and prop(3)) or -- we propagate cb of bit 2
		(gen(1) and prop(2) and prop(3)) or -- we propagate cb of bit 1
		(gen(0) and prop(1) and prop(2) and prop(3)) or -- we propagate cb of bit 0
		(ci and prop(0) and prop(1) and prop(2) and prop(3)); -- we propagate ci;
	
	-- SUM CALC
	s <= prop xor c(3 downto 0);
end;

--0 0 0  0 0
--0 0 1  0 1
--0 1 0  0 1
--0 1 1  1 0
--1 0 0  0 1
--1 0 1  1 0
--1 1 0  1 0
--1 1 1  1 1
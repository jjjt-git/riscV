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

architecture adder_4bit_cra of adder_4bit is
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

--0 0 0  0 0
--0 0 1  0 1
--0 1 0  0 1
--0 1 1  1 0
--1 0 0  0 1
--1 0 1  1 0
--1 1 0  1 0
--1 1 1  1 1
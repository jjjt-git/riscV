library ieee;

entity alu_32bit is
port (
	op0: in bit_vector(31 downto 0);
	op1: in bit_vector(31 downto 0);
	res: out bit_vector(31 downto 0);
	op: in bit_vector(3 downto 0) -- operation selector
					-- 0000 add
					-- 0001 sub
					-- 0010 and
					-- 0011 or
					-- 0100 xor
					-- 0101 shift left
					-- 0110 shift right
					-- 0111 arithmetic shift
					-- 1000 equal
					-- 1001 less than
);
end;

architecture def of alu_32bit is
	signal add_0, add_t1, add_r, add_1, sub_1: bit_vector(31 downto 0);
	signal add_ci, add_co: bit;
	
	signal and_r, or_r, xor_r: bit_vector(31 downto 0);
	
	signal res_lshift, res_rshift, ashifts, rshift1, shift0, shift1: bit_vector(31 downto 0);
	
	signal res_lt, res_ltu, res_eq, res_bit_eq: bit_vector(31 downto 0);

	signal zero, one: bit_vector(31 downto 0);
	signal lsb: bit;
begin
	zero <= "00000000000000000000000000000000";
	one  <= "11111111111111111111111111111111";
	lsb <= op(0);
	-- add/sub
	ADDER : entity work.adder_32bit(cla)
		port map (
			a => add_0,
			b => add_t1,
			s => add_r,
			ci => lsb, -- add substractor bit (for 2-C)
			co => add_co
		);
	SUB_MUX : entity work.mux2_32bit
		port map (
			o => add_t1,
			sel => lsb,
			d0 => add_1,
			d1 => sub_1
		);
	sub_1 <= not add_1;
	add_0 <= op0;
	add_1 <= op1;
	
	-- logic
	and_r <= op0 and op1;
	xor_r <= op0 xor op1;
	or_r  <= op0 or  op1;
	
	-- logic shifts
	SHIFT_R : entity work.rotR_32bit
		port map (
			o => res_rshift,
			i0 => op0,
			i1 => rshift1,
			len => op1(4 downto 0)
		);
		
	SHIFT_L : entity work.rotL_32bit
		port map (
			o => res_lshift,
			i0 => op0,
			i1 => zero,
			len => op1(4 downto 0)
		);
	
	SIGN_MUX : entity work.mux2_32bit
		port map (
			o => ashifts,
			sel => op0(31),
			d0 => zero,
			d1 => one
		); 
	
	OP1_MUX : entity work.mux2_32bit
		port map (
			o => rshift1,
			sel => lsb,
			d0 => zero,
			d1 => ashifts
		);
	-- comparison
	res_lt(31 downto 1) <= zero(31 downto 1);
	res_ltu(31 downto 1) <= zero(31 downto 1);
	res_eq(31 downto 1) <= zero(31 downto 1);

	res_lt(0) <= add_r(31); -- op0 < op1, exactly when op0 - op1 < 0
	res_ltu(0) <= not add_co;

	res_bit_eq(0) <= not (op0(0) xor op1(0)); -- up to this bit, are they equal?
	res_bit_eq(31 downto 1) <= not (op0(31 downto 1) xor op1(31 downto 1)) and res_bit_eq(30 downto 0); -- up to this bit, are they equal?
	res_eq(0) <= res_bit_eq(31);

	-- select correct result
	OP_MUX : entity work.mux16_32bit
		port map (
			o => res,
			sel => op,	-- 0000 add
					-- 0001 sub
					-- 0010 and
					-- 0011 or
					-- 0100 xor
					-- 0101 shift left
					-- 0110 shift right
					-- 0111 arithmetic shift
					-- 1000 equal
					-- 1001 less than
					-- 1011 less than (unsigned)
			d0000 => add_r,
			d0001 => add_r,
			d0010 => and_r,
			d0011 => or_r,
			d0100 => xor_r,
			d0101 => res_lshift,
			d0110 => res_rshift,
			d0111 => res_rshift,
			d1000 => res_eq,
			d1001 => res_lt,
			d1010 => zero,
			d1011 => res_ltu,
			d1100 => zero,
			d1101 => zero,
			d1110 => zero,
			d1111 => zero
		);
end;
--------------------------------------------------------------
-- Multiplicador		
--------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;

--------------------------------------------------------------

entity shift_reg64 is
generic(
	data_width : integer := 64
);
port(
	-- 	Bit Inputs
	en:	in std_logic;
	clk:	in std_logic;
	rst:	in std_logic;
	serial:	in std_logic;
	shift:	in std_logic;

	-- 	Bit_Vector Inputs
	I:	in std_logic_vector(data_width-1 downto 0);

	--	Bit_Vector Outputs
	O:	out std_logic_vector(data_width-1 downto 0)
);
end shift_reg64;

--------------------------------------------------------------
architecture arq_shift_reg64 of shift_reg64 is
signal output: std_logic_vector(data_width-1 downto 0);
begin

P1: process(clk, rst, en, shift)
	begin
		if rst = '0' then
			output <= (others => '0');
		elsif clk'event and clk = '1' then
			if shift = '1' then
				for i in 0 to data_width-2 loop
					output(i) <= output(i+1);
				end loop;
				output(data_width-1) <= serial;
			elsif en = '1' then
				output <= I;
			end if;
		end if;	
	end process;
O <= output;
end arq_shift_reg64;

--------------------------------------------------------------

--------------------------------------------------------------
-- Somador		
--------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;

--------------------------------------------------------------

entity UAL is
generic(
	data_width : integer := 64
);
port(	
	A:	in std_logic_vector(data_width-1 downto 0);
	B:	in std_logic_vector(data_width-1 downto 0);
	Cin:	in std_logic;

	S:	out std_logic_vector(data_width-1 downto 0);
	Cout:	out std_logic
);
end UAL;

--------------------------------------------------------------
architecture arq_UAL of UAL is

signal C: std_logic_vector(data_width downto 0);

begin
	C(0)	<= Cin;
	loop_add : for i in 0 to data_width - 1 generate
		S(i) 	<= A(i) xor B(i) xor C(i);
		C(i+1) 	<= (A(i) and B(i)) or (A(i) and C(i)) or (B(i) and C(i));
	end generate;
	Cout 	<= C(64);
end arq_UAL;

--------------------------------------------------------------

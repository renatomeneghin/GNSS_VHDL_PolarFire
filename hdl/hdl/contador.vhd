--------------------------------------------------------------
-- Contador sincrono com reset		
--------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;

--------------------------------------------------------------

entity contador is
generic(
	data_width : integer := 6
);
port(	clk: 	in std_logic;
	init:	in std_logic;
	count:	out std_logic_vector(data_width-1 downto 0)
);
end contador;

--------------------------------------------------------------

architecture arq_contador of contador is

signal EA, PE: std_logic_vector(data_width-1 downto 0);

begin
 	process(clk, init, PE) is
	begin
		if init = '1' then
			EA <= (others => '1');
		elsif clk'event and clk= '1' then
			EA <= PE;
		end if;
	end process;
	PE <= unsigned(EA) - 1;
	count <= EA;
end arq_contador;

--------------------------------------------------------------

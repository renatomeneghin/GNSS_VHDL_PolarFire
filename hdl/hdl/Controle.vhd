--------------------------------------------------------------
-- Multiplicador		
--------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;

--------------------------------------------------------------

entity Controle is
port(
	-- 	Bit Inputs
	go:	in std_logic;
	clk:	in std_logic;
	Tm:	in std_logic;
	rst: 	in std_logic;

	--	Bit Outputs
	Tw_MSB:		out std_logic;
	Tc:		out std_logic;
	T_init: 	out std_logic;
	Ts:		out std_logic;
	
	idle:		out std_logic
);
end Controle;

--------------------------------------------------------------
architecture arq_Controle of Controle is

type STATES is (E0,E1,E2,E3,E4,E5,E6,E7);
signal EA, PE: STATES;

begin

P1:	process(clk, rst, PE)
	begin
		if rst = '1' then
			EA <= E0;
		elsif clk'event and clk = '1' then
			EA <= PE;
		end if;	
	end process;

P2: 	process(EA, go, Tm)
	begin
		case EA is
			when E0 =>
				T_init 	<= 	'0';
				Tw_MSB 	<= 	'0';
				Tc 	<= 	'0';
				Ts	<= 	'0';
				idle	<=	'0';
				PE <= E1;
			when E1 =>
				T_init 	<= 	'0';
				Tw_MSB 	<= 	'0';
				Tc 	<= 	'0';
				Ts	<= 	'0';
				idle	<=	'1';
				if go = '1' then
					PE <= E2;
				else 
					PE <= E1;
				end if;
			when E2 =>
				T_init 	<= 	'1';
				Tw_MSB 	<= 	'0';
				Tc 	<= 	'1';
				Ts	<= 	'0';
				idle	<=	'0';
				PE <= E3;
			when E3 =>
				T_init 	<= 	'0';
				Tw_MSB 	<= 	'0';
				Tc 	<= 	'1';
				Ts	<= 	'0';
				idle	<=	'0';
				PE <= E4;
			when E4 =>
				T_init 	<= 	'0';
				Tw_MSB 	<= 	'1';
				Tc 	<= 	'1';
				Ts	<= 	'0';
				idle	<=	'0';
				if Tm = '1' then
					PE <= E6;
				else 
					PE <= E5;
				end if;
			when E5 =>
				T_init 	<= 	'0';
				Tw_MSB 	<= 	'0';
				Tc 	<= 	'1';
				Ts	<= 	'1';
				idle	<=	'0';
				if Tm = '1' then
					PE <= E6;
				else 
					PE <= E4;
				end if;
			when E6 =>
				T_init 	<= 	'0';
				Tw_MSB 	<= 	'0';
				Tc 	<= 	'1';
				Ts	<= 	'1';
				idle	<=	'0';
				PE <= E7;
			when E7 =>
				T_init 	<= 	'0';
				Tw_MSB 	<= 	'0';
				Tc 	<= 	'1';
				Ts	<= 	'0';
				idle	<=	'1';
				PE <= E1;
		end case;
	end process;

end arq_Controle;

--------------------------------------------------------------

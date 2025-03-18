--------------------------------------------------------------
-- Multiplicador		
--------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;

--------------------------------------------------------------

entity Datapath is
generic(
	data_width : integer := 64
);
port(
	-- 	Bit Inputs
	Tw_MSB:		in std_logic;
	Tc:		in std_logic;
	T_init: 	in std_logic;
	clk:		in std_logic;
	Ts:		in std_logic;

	--	Bit Outputs
	Tm:		out std_logic;

	-- 	Bit_Vector Inputs
	A:		in std_logic_vector(data_width-1 downto 0);
	B:		in std_logic_vector(data_width-1 downto 0);

	--	Bit_Vector Outputs
	MSB, LSB:	out std_logic_vector(data_width-1 downto 0)
);
end Datapath;

--------------------------------------------------------------
architecture arq_Datapath of Datapath is

signal MSB_en, carry, serial_in_A, serial_in_Q: std_logic;
signal counts: std_logic_vector(5 downto 0);
signal sum, MSB_Result, LSB_Result: std_logic_vector(data_width-1 downto 0);

component contador is

port(	clk: 	in std_logic;
	init:	in std_logic;
	count:	out std_logic_vector(5 downto 0)
);
end component;

component UAL is

port(	
	A:	in std_logic_vector(data_width-1 downto 0);
	B:	in std_logic_vector(data_width-1 downto 0);
	Cin:	in std_logic;
	S:	out std_logic_vector(data_width-1 downto 0);
	Cout:	out std_logic
);
end component;

component shift_reg64 is

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
end component;

component Flip_Flop_D is
port(	D:	in std_logic;
	rst:	in std_logic;
	clk:	in std_logic;
	Q:	out std_logic
);
end component;

component Zero_detector is
port(	
	I:	in std_logic_vector(5 downto 0);
	O:	out std_logic
);
end component;

begin

	Counter: 		contador 	port map(Ts, T_init, counts);
	Zero:			Zero_detector	port map(counts, Tm);

	Summer: 		UAL 		port map(MSB_Result, A, '0', sum, carry);
	Carrier:		Flip_Flop_D 	port map(carry, Tw_MSB, clk, serial_in_A);

	Registrador_MSB: 	shift_reg64 	port map(MSB_en, clk, Tc, serial_in_A, Ts, sum, MSB_Result);
	Registrador_LSB: 	shift_reg64 	port map(T_init, clk, Tc, serial_in_Q, Ts, B  , LSB_Result);

MSB_en 		<= (Tw_MSB and LSB_Result(0));
serial_in_Q 	<= MSB_Result(0);

process(MSB_Result, LSB_Result, Tc) is
begin
	if Tc = '1' then
		MSB 		<= MSB_Result;
		LSB 		<= LSB_Result;
	end if;
end process;

end arq_Datapath;

--------------------------------------------------------------

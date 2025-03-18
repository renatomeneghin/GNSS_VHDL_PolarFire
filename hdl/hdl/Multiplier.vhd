--------------------------------------------------------------
-- Multiplicador		
--------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.all;

--------------------------------------------------------------

entity Multiplier is
generic(
	data_width : integer := 8
);
port(
	-- 	Bit Inputs
	go:	in std_logic;
	clk:	in std_logic;
	rst:	in std_logic;

	--	Bit Outputs
	idle:	out std_logic;

	-- 	Bit_Vector Inputs
	A:	in std_logic_vector(data_width-1 downto 0);
	B:	in std_logic_vector(data_width-1 downto 0);

	--	Bit_Vector Outputs
	MSB, LSB:	out std_logic_vector(data_width-1 downto 0)
);
end Multiplier;

--------------------------------------------------------------
architecture arq_Multiplier of Multiplier is

signal 	clear
	,write 
	,counter
	,init 
	,shift 
		: std_logic;

component Controle is
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
end component;

component Datapath is
port(
	-- 	Bit Inputs
	Tw_MSB:		in std_logic;
	Tc:		in std_logic;
	T_init: 	in std_logic;
	clk:		in std_logic;
	Ts:		in std_logic;

	--	Bit Outputs
	Tm:	out std_logic;

	-- 	Bit_Vector Inputs
	A:	in std_logic_vector(data_width-1 downto 0);
	B:	in std_logic_vector(data_width-1 downto 0);

	--	Bit_Vector Outputs
	MSB, LSB:	out std_logic_vector(data_width-1 downto 0)
);
end component;

begin
	Control: Controle 	port map(go, clk, counter, rst, write, clear, init, shift, idle);
	Dados: Datapath 	port map(write, clear, init, clk, shift, counter, A, B, MSB, LSB);
end arq_Multiplier;

--------------------------------------------------------------

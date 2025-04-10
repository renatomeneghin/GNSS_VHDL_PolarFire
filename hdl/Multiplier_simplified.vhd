--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Multiplier_simplified.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::PolarFire> <Die::MPF050T> <Package::FCSG325>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;

entity Multiplier_simplified is
generic(
	data_width : integer := 12
);
port(
	-- 	Bit Inputs
	
	--	Bit Outputs

	-- 	Bit_Vector Inputs
	A:	in std_logic_vector(data_width-1 downto 0);
	B:	in std_logic_vector(1 downto 0);

	--	Bit_Vector Outputs
	S:	out std_logic_vector(data_width downto 0)
);
end Multiplier_simplified;
architecture architecture_Multiplier_simplified of Multiplier_simplified is
   -- signal, component etc. declarations
	signal shift : std_logic_vector(data_width downto 0) ; -- example

begin
   -- architecture body
   shift <= A(data_width-1) & '0' & A(data_width-2 downto 0)        when B(0) = '0' else
            A(data_width-1 downto 0) & '0';
   S <= shift   when B(1) = '0' else
        not(shift);
   
end architecture_Multiplier_simplified;

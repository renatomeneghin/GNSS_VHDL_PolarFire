--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: MAX_2771_In.vhd
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
use ieee.std_logic_arith.all;
use work.all;

entity MAX_2771_In is
generic( out_size : integer := 8);
port (
    --<port_name> : <direction> <type>;
	I_1 : IN  std_logic; -- I data signal
    I_0 : IN  std_logic; -- I data amplitude
    Q_1 : IN  std_logic; -- Q data signal
    Q_0 : IN  std_logic; -- Q data amplitude
    I_data : OUT  std_logic_vector(out_size - 1 downto 0); -- I data
    Q_data : OUT  std_logic_vector(out_size - 1 downto 0) -- Q data
    --<other_ports>;
);
end MAX_2771_In;
architecture architecture_MAX_2771_In of MAX_2771_In is
   -- signal, component etc. declarations

begin

   -- architecture body
   
   I_data(out_size-1) <= I_1;
   I_data(out_size-2 downto 2) <= (others => '0');
   I_data(1 downto 0) <= I_0 xor "01";

   Q_data(out_size-1) <= Q_1;
   Q_data(out_size-2 downto 2) <= (others => '0');
   Q_data(1 downto 0) <= Q_0 xor "01";
   
end architecture_MAX_2771_In;

----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Thu Mar 13 00:12:02 2025
-- Parameters for complex_multiplier
----------------------------------------------------------------------


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE ieee.numeric_std.all;

package coreparameters is
    constant g_3DSP : integer := 1;
    constant g_AWIDTH : integer := 16;
    constant g_BWIDTH : integer := 16;
    constant g_CWIDTH : integer := 33;
    constant g_DOROUND : integer := 0;
    constant HDL_License : string( 1 to 1 ) := "O";
    constant testbench : string( 1 to 4 ) := "User";
end coreparameters;

----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Fri Mar 14 14:17:48 2025
-- Parameters for CORECORDIC
----------------------------------------------------------------------


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE ieee.numeric_std.all;

package coreparameters is
    constant ARCHITECT : integer := 2;
    constant COARSE : integer := 0;
    constant DP_OPTION : integer := 0;
    constant DP_WIDTH : integer := 16;
    constant IN_BITS : integer := 16;
    constant ITERATIONS : integer := 16;
    constant MODE : integer := 3;
    constant OUT_BITS : integer := 16;
    constant ROUND : integer := 0;
    constant testbench : integer := 1;
end coreparameters;

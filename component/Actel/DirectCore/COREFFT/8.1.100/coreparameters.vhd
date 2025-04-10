----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Thu Apr  3 12:47:12 2025
-- Parameters for COREFFT
----------------------------------------------------------------------


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE ieee.numeric_std.all;

package coreparameters is
    constant AXI4S_IN_DATA : integer := 24;
    constant AXI4S_OUT_DATA : integer := 24;
    constant CFG_ARCH : integer := 1;
    constant DATA_BITS : integer := 18;
    constant FAMILY : integer := 26;
    constant FFT_SIZE : integer := 256;
    constant FPGA_FAMILY : integer := 26;
    constant INVERSE : integer := 0;
    constant MEMBUF : integer := 0;
    constant NATIV_AXI4 : integer := 0;
    constant ORDER : integer := 0;
    constant POINTS : integer := 2048;
    constant SCALE : integer := 0;
    constant SCALE_EXP_ON : integer := 0;
    constant SCALE_ON : integer := 1;
    constant SCALE_SCH : integer := 255;
    constant STAGE_1 : integer := 1;
    constant STAGE_2 : integer := 1;
    constant STAGE_3 : integer := 1;
    constant STAGE_4 : integer := 1;
    constant STAGE_5 : integer := 1;
    constant STAGE_6 : integer := 1;
    constant STAGE_7 : integer := 1;
    constant STAGE_8 : integer := 1;
    constant STAGE_9 : integer := 1;
    constant STAGE_10 : integer := 1;
    constant STAGE_11 : integer := 1;
    constant STAGE_12 : integer := 1;
    constant testbench : integer := 1;
    constant TWID_BITS : integer := 18;
    constant URAM_MAXDEPTH : integer := 0;
    constant WIDTH : integer := 24;
end coreparameters;

----------------------------------------------------------------------
-- Created by SmartDesign Thu Apr  3 11:52:44 2025
-- Version: 2024.2 2024.2.0.13
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Component Description (Tcl) 
----------------------------------------------------------------------
--# Exporting Component Description of COREDDS_C0 to TCL
--# Family: PolarFire
--# Part Number: MPF050T-1FCSG325E
--# Create and Configure the core component COREDDS_C0
--create_and_configure_core -core_vlnv {Actel:DirectCore:COREDDS:4.0.108} -component_name {COREDDS_C0} -params {\
--"COS_ON:true"  \
--"COS_POLARITY:false"  \
--"DIE_SIZE:20"  \
--"FPGA_FAMILY:26"  \
--"FREQ_OFFSET_BITS:10"  \
--"LATENCY:0"  \
--"MAX_FULL_WAVE_LOGDEPTH:9"  \
--"OUTPUT_BITS:12"  \
--"PH_ACC_BITS:12"  \
--"PH_CORRECTION:0"  \
--"PH_INC_LOWER:1000000"  \
--"PH_INC_MODE:true"  \
--"PH_INC_UPPER:0"  \
--"PH_OFFSET_BITS:3"  \
--"PH_OFFSET_CONST_LOWER:1"  \
--"PH_OFFSET_CONST_UPPER:0"  \
--"PH_OFFSET_MODE:0"  \
--"QUANTIZER_BITS:12"  \
--"SIN_ON:true"  \
--"SIN_POLARITY:true"  \
--"URAM_MAXDEPTH:0"   }
--# Exporting Component Description of COREDDS_C0 to TCL done

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library polarfire;
use polarfire.all;
library COREDDS_LIB;
use COREDDS_LIB.all;
----------------------------------------------------------------------
-- COREDDS_C0 entity declaration
----------------------------------------------------------------------
entity COREDDS_C0 is
    -- Port list
    port(
        -- Inputs
        CLK            : in  std_logic;
        FREQ_OFFSET    : in  std_logic_vector(9 downto 0);
        FREQ_OFFSET_WE : in  std_logic;
        INIT           : in  std_logic;
        NGRST          : in  std_logic;
        RSTN           : in  std_logic;
        -- Outputs
        COSINE         : out std_logic_vector(11 downto 0);
        INIT_OVER      : out std_logic;
        SINE           : out std_logic_vector(11 downto 0)
        );
end COREDDS_C0;
----------------------------------------------------------------------
-- COREDDS_C0 architecture body
----------------------------------------------------------------------
architecture RTL of COREDDS_C0 is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- COREDDS_C0_COREDDS_C0_0_COREDDS   -   Actel:DirectCore:COREDDS:4.0.108
component COREDDS_C0_COREDDS_C0_0_COREDDS
    generic( 
        COS_ON                 : integer := 1 ;
        COS_POLARITY           : integer := 0 ;
        DIE_SIZE               : integer := 20 ;
        FPGA_FAMILY            : integer := 26 ;
        FREQ_OFFSET_BITS       : integer := 10 ;
        LATENCY                : integer := 0 ;
        MAX_FULL_WAVE_LOGDEPTH : integer := 9 ;
        OUTPUT_BITS            : integer := 12 ;
        PH_ACC_BITS            : integer := 12 ;
        PH_CORRECTION          : integer := 0 ;
        PH_INC_LOWER           : integer := 1000000 ;
        PH_INC_MODE            : integer := 1 ;
        PH_INC_UPPER           : integer := 0 ;
        PH_OFFSET_BITS         : integer := 3 ;
        PH_OFFSET_CONST_LOWER  : integer := 1 ;
        PH_OFFSET_CONST_UPPER  : integer := 0 ;
        PH_OFFSET_MODE         : integer := 0 ;
        QUANTIZER_BITS         : integer := 12 ;
        SIN_ON                 : integer := 1 ;
        SIN_POLARITY           : integer := 1 ;
        URAM_MAXDEPTH          : integer := 0 
        );
    -- Port list
    port(
        -- Inputs
        CLK            : in  std_logic;
        FREQ_OFFSET    : in  std_logic_vector(9 downto 0);
        FREQ_OFFSET_WE : in  std_logic;
        INIT           : in  std_logic;
        NGRST          : in  std_logic;
        PH_OFFSET      : in  std_logic_vector(2 downto 0);
        PH_OFFSET_WE   : in  std_logic;
        RSTN           : in  std_logic;
        -- Outputs
        COSINE         : out std_logic_vector(11 downto 0);
        INIT_OVER      : out std_logic;
        SINE           : out std_logic_vector(11 downto 0)
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal COSINE_net_0    : std_logic_vector(11 downto 0);
signal INIT_OVER_net_0 : std_logic;
signal SINE_net_0      : std_logic_vector(11 downto 0);
signal INIT_OVER_net_1 : std_logic;
signal SINE_net_1      : std_logic_vector(11 downto 0);
signal COSINE_net_1    : std_logic_vector(11 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal GND_net         : std_logic;
signal PH_OFFSET_const_net_0: std_logic_vector(2 downto 0);

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 GND_net               <= '0';
 PH_OFFSET_const_net_0 <= B"000";
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 INIT_OVER_net_1     <= INIT_OVER_net_0;
 INIT_OVER           <= INIT_OVER_net_1;
 SINE_net_1          <= SINE_net_0;
 SINE(11 downto 0)   <= SINE_net_1;
 COSINE_net_1        <= COSINE_net_0;
 COSINE(11 downto 0) <= COSINE_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- COREDDS_C0_0   -   Actel:DirectCore:COREDDS:4.0.108
COREDDS_C0_0 : COREDDS_C0_COREDDS_C0_0_COREDDS
    generic map( 
        COS_ON                 => ( 1 ),
        COS_POLARITY           => ( 0 ),
        DIE_SIZE               => ( 20 ),
        FPGA_FAMILY            => ( 26 ),
        FREQ_OFFSET_BITS       => ( 10 ),
        LATENCY                => ( 0 ),
        MAX_FULL_WAVE_LOGDEPTH => ( 9 ),
        OUTPUT_BITS            => ( 12 ),
        PH_ACC_BITS            => ( 12 ),
        PH_CORRECTION          => ( 0 ),
        PH_INC_LOWER           => ( 1000000 ),
        PH_INC_MODE            => ( 1 ),
        PH_INC_UPPER           => ( 0 ),
        PH_OFFSET_BITS         => ( 3 ),
        PH_OFFSET_CONST_LOWER  => ( 1 ),
        PH_OFFSET_CONST_UPPER  => ( 0 ),
        PH_OFFSET_MODE         => ( 0 ),
        QUANTIZER_BITS         => ( 12 ),
        SIN_ON                 => ( 1 ),
        SIN_POLARITY           => ( 1 ),
        URAM_MAXDEPTH          => ( 0 )
        )
    port map( 
        -- Inputs
        NGRST          => NGRST,
        CLK            => CLK,
        FREQ_OFFSET_WE => FREQ_OFFSET_WE,
        PH_OFFSET_WE   => GND_net, -- tied to '0' from definition
        RSTN           => RSTN,
        INIT           => INIT,
        FREQ_OFFSET    => FREQ_OFFSET,
        PH_OFFSET      => PH_OFFSET_const_net_0, -- tied to X"0" from definition
        -- Outputs
        INIT_OVER      => INIT_OVER_net_0,
        SINE           => SINE_net_0,
        COSINE         => COSINE_net_0 
        );

end RTL;

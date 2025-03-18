----------------------------------------------------------------------
-- Created by SmartDesign Mon Mar 17 23:06:25 2025
-- Version: 2024.2 2024.2.0.13
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Component Description (Tcl) 
----------------------------------------------------------------------
--# Exporting Component Description of COREFFT_C0 to TCL
--# Family: PolarFire
--# Part Number: MPF050T-1FCSG325E
--# Create and Configure the core component COREFFT_C0
--create_and_configure_core -core_vlnv {Actel:DirectCore:COREFFT:8.1.100} -component_name {COREFFT_C0} -params {\
--"AXI4S_IN_DATA:24"  \
--"AXI4S_OUT_DATA:24"  \
--"CFG_ARCH:1"  \
--"DATA_BITS:18"  \
--"FFT_SIZE:256"  \
--"FPGA_FAMILY:26"  \
--"INVERSE:0"  \
--"MEMBUF:0"  \
--"NATIV_AXI4:false"  \
--"ORDER:0"  \
--"POINTS:2048"  \
--"SCALE:0"  \
--"SCALE_EXP_ON:false"  \
--"SCALE_ON:true"  \
--"SCALE_SCH:255"  \
--"STAGE_1:true"  \
--"STAGE_2:true"  \
--"STAGE_3:true"  \
--"STAGE_4:true"  \
--"STAGE_5:true"  \
--"STAGE_6:true"  \
--"STAGE_7:true"  \
--"STAGE_8:true"  \
--"STAGE_9:true"  \
--"STAGE_10:true"  \
--"STAGE_11:true"  \
--"STAGE_12:true"  \
--"TWID_BITS:18"  \
--"URAM_MAXDEPTH:0"  \
--"WIDTH:24"   }
--# Exporting Component Description of COREFFT_C0 to TCL done

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library polarfire;
use polarfire.all;
----------------------------------------------------------------------
-- COREFFT_C0 entity declaration
----------------------------------------------------------------------
entity COREFFT_C0 is
    -- Port list
    port(
        -- Inputs
        CLK         : in  std_logic;
        DATAI_IM    : in  std_logic_vector(23 downto 0);
        DATAI_RE    : in  std_logic_vector(23 downto 0);
        DATAI_VALID : in  std_logic;
        NGRST       : in  std_logic;
        READ_OUTP   : in  std_logic;
        SLOWCLK     : in  std_logic;
        -- Outputs
        BUF_READY   : out std_logic;
        DATAO_IM    : out std_logic_vector(23 downto 0);
        DATAO_RE    : out std_logic_vector(23 downto 0);
        DATAO_VALID : out std_logic;
        OUTP_READY  : out std_logic
        );
end COREFFT_C0;
----------------------------------------------------------------------
-- COREFFT_C0 architecture body
----------------------------------------------------------------------
architecture RTL of COREFFT_C0 is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- COREFFT_C0_COREFFT_C0_0_COREFFT   -   Actel:DirectCore:COREFFT:8.1.100
component COREFFT_C0_COREFFT_C0_0_COREFFT
    generic( 
        AXI4S_IN_DATA  : integer := 24 ;
        AXI4S_OUT_DATA : integer := 24 ;
        CFG_ARCH       : integer := 1 ;
        DATA_BITS      : integer := 18 ;
        FFT_SIZE       : integer := 256 ;
        FPGA_FAMILY    : integer := 26 ;
        INVERSE        : integer := 0 ;
        MEMBUF         : integer := 0 ;
        NATIV_AXI4     : integer := 0 ;
        ORDER          : integer := 0 ;
        POINTS         : integer := 2048 ;
        SCALE          : integer := 0 ;
        SCALE_EXP_ON   : integer := 0 ;
        SCALE_ON       : integer := 1 ;
        SCALE_SCH      : integer := 255 ;
        TWID_BITS      : integer := 18 ;
        URAM_MAXDEPTH  : integer := 0 ;
        WIDTH          : integer := 24 
        );
    -- Port list
    port(
        -- Inputs
        AXI4_M_CONFIGO_TREADY : in  std_logic;
        AXI4_M_DATAO_TREADY   : in  std_logic;
        AXI4_S_CONFIGI        : in  std_logic_vector(7 downto 0);
        AXI4_S_CONFIGI_TVALID : in  std_logic;
        AXI4_S_DATAI_TVALID   : in  std_logic;
        AXI4_S_TDATAI         : in  std_logic_vector(47 downto 0);
        AXI4_S_TLASTI         : in  std_logic;
        CLK                   : in  std_logic;
        CLKEN                 : in  std_logic;
        DATAI_IM              : in  std_logic_vector(23 downto 0);
        DATAI_RE              : in  std_logic_vector(23 downto 0);
        DATAI_VALID           : in  std_logic;
        INVERSE_STRM          : in  std_logic;
        NGRST                 : in  std_logic;
        READ_OUTP             : in  std_logic;
        REFRESH               : in  std_logic;
        RST                   : in  std_logic;
        SLOWCLK               : in  std_logic;
        START                 : in  std_logic;
        -- Outputs
        AXI4_M_CONFIGO        : out std_logic_vector(7 downto 0);
        AXI4_M_CONFIGO_TVALID : out std_logic;
        AXI4_M_DATAO_TVALID   : out std_logic;
        AXI4_M_TDATAO         : out std_logic_vector(47 downto 0);
        AXI4_M_TLASTO         : out std_logic;
        AXI4_S_CONFIGI_TREADY : out std_logic;
        AXI4_S_DATAI_TREADY   : out std_logic;
        BUF_READY             : out std_logic;
        DATAO_IM              : out std_logic_vector(23 downto 0);
        DATAO_RE              : out std_logic_vector(23 downto 0);
        DATAO_VALID           : out std_logic;
        OUTP_READY            : out std_logic;
        OVFLOW_FLAG           : out std_logic;
        PONG                  : out std_logic;
        RFS                   : out std_logic;
        SCALE_EXP             : out std_logic_vector(3 downto 0)
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal BUF_READY_net_0   : std_logic;
signal DATAO_IM_net_0    : std_logic_vector(23 downto 0);
signal DATAO_RE_net_0    : std_logic_vector(23 downto 0);
signal DATAO_VALID_net_0 : std_logic;
signal OUTP_READY_net_0  : std_logic;
signal DATAO_VALID_net_1 : std_logic;
signal BUF_READY_net_1   : std_logic;
signal OUTP_READY_net_1  : std_logic;
signal DATAO_IM_net_1    : std_logic_vector(23 downto 0);
signal DATAO_RE_net_1    : std_logic_vector(23 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal VCC_net           : std_logic;
signal GND_net           : std_logic;
signal AXI4_S_TDATAI_const_net_0: std_logic_vector(47 downto 0);
signal AXI4_S_CONFIGI_const_net_0: std_logic_vector(7 downto 0);

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 VCC_net                    <= '1';
 GND_net                    <= '0';
 AXI4_S_TDATAI_const_net_0  <= B"000000000000000000000000000000000000000000000000";
 AXI4_S_CONFIGI_const_net_0 <= B"00000000";
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 DATAO_VALID_net_1     <= DATAO_VALID_net_0;
 DATAO_VALID           <= DATAO_VALID_net_1;
 BUF_READY_net_1       <= BUF_READY_net_0;
 BUF_READY             <= BUF_READY_net_1;
 OUTP_READY_net_1      <= OUTP_READY_net_0;
 OUTP_READY            <= OUTP_READY_net_1;
 DATAO_IM_net_1        <= DATAO_IM_net_0;
 DATAO_IM(23 downto 0) <= DATAO_IM_net_1;
 DATAO_RE_net_1        <= DATAO_RE_net_0;
 DATAO_RE(23 downto 0) <= DATAO_RE_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- COREFFT_C0_0   -   Actel:DirectCore:COREFFT:8.1.100
COREFFT_C0_0 : COREFFT_C0_COREFFT_C0_0_COREFFT
    generic map( 
        AXI4S_IN_DATA  => ( 24 ),
        AXI4S_OUT_DATA => ( 24 ),
        CFG_ARCH       => ( 1 ),
        DATA_BITS      => ( 18 ),
        FFT_SIZE       => ( 256 ),
        FPGA_FAMILY    => ( 26 ),
        INVERSE        => ( 0 ),
        MEMBUF         => ( 0 ),
        NATIV_AXI4     => ( 0 ),
        ORDER          => ( 0 ),
        POINTS         => ( 2048 ),
        SCALE          => ( 0 ),
        SCALE_EXP_ON   => ( 0 ),
        SCALE_ON       => ( 1 ),
        SCALE_SCH      => ( 255 ),
        TWID_BITS      => ( 18 ),
        URAM_MAXDEPTH  => ( 0 ),
        WIDTH          => ( 24 )
        )
    port map( 
        -- Inputs
        CLK                   => CLK,
        SLOWCLK               => SLOWCLK,
        NGRST                 => NGRST,
        DATAI_VALID           => DATAI_VALID,
        READ_OUTP             => READ_OUTP,
        START                 => VCC_net, -- tied to '1' from definition
        INVERSE_STRM          => GND_net, -- tied to '0' from definition
        REFRESH               => GND_net, -- tied to '0' from definition
        CLKEN                 => VCC_net, -- tied to '1' from definition
        RST                   => GND_net, -- tied to '0' from definition
        AXI4_S_DATAI_TVALID   => GND_net, -- tied to '0' from definition
        AXI4_S_TLASTI         => GND_net, -- tied to '0' from definition
        AXI4_M_DATAO_TREADY   => VCC_net, -- tied to '1' from definition
        AXI4_S_CONFIGI_TVALID => GND_net, -- tied to '0' from definition
        AXI4_M_CONFIGO_TREADY => GND_net, -- tied to '0' from definition
        DATAI_IM              => DATAI_IM,
        DATAI_RE              => DATAI_RE,
        AXI4_S_TDATAI         => AXI4_S_TDATAI_const_net_0, -- tied to X"0" from definition
        AXI4_S_CONFIGI        => AXI4_S_CONFIGI_const_net_0, -- tied to X"0" from definition
        -- Outputs
        DATAO_VALID           => DATAO_VALID_net_0,
        BUF_READY             => BUF_READY_net_0,
        OUTP_READY            => OUTP_READY_net_0,
        PONG                  => OPEN,
        OVFLOW_FLAG           => OPEN,
        RFS                   => OPEN,
        AXI4_S_DATAI_TREADY   => OPEN,
        AXI4_M_DATAO_TVALID   => OPEN,
        AXI4_M_TLASTO         => OPEN,
        AXI4_S_CONFIGI_TREADY => OPEN,
        AXI4_M_CONFIGO_TVALID => OPEN,
        DATAO_IM              => DATAO_IM_net_0,
        DATAO_RE              => DATAO_RE_net_0,
        SCALE_EXP             => OPEN,
        AXI4_M_TDATAO         => OPEN,
        AXI4_M_CONFIGO        => OPEN 
        );

end RTL;

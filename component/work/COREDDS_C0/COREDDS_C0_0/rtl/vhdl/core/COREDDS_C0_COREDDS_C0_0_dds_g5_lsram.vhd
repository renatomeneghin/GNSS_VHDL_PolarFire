-- Version: 2024.2 2024.2.0.13

library ieee;
use ieee.std_logic_1164.all;
library polarfire;
use polarfire.all;

entity COREDDS_C0_COREDDS_C0_0_dds_g5_lsram is

    port( DI     : in    std_logic_vector(11 downto 0);
          DO     : out   std_logic_vector(11 downto 0);
          WADDR  : in    std_logic_vector(8 downto 0);
          RADDR  : in    std_logic_vector(8 downto 0);
          WRB    : in    std_logic;
          RDB    : in    std_logic;
          WCLOCK : in    std_logic;
          RCLOCK : in    std_logic
        );

end COREDDS_C0_COREDDS_C0_0_dds_g5_lsram;

architecture DEF_ARCH of COREDDS_C0_COREDDS_C0_0_dds_g5_lsram is 

  component RAM1K20
    generic (MEMORYFILE:string := ""; RAMINDEX:string := ""; 
        INIT0:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT1:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT2:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT3:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT4:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT5:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT6:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT7:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT8:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT9:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT10:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT11:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT12:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT13:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT14:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT15:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT16:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT17:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT18:std_logic_vector(1023 downto 0) := (others => 'X'); 
        INIT19:std_logic_vector(1023 downto 0) := (others => 'X')
        );

    port( A_DOUT        : out   std_logic_vector(19 downto 0);
          B_DOUT        : out   std_logic_vector(19 downto 0);
          DB_DETECT     : out   std_logic;
          SB_CORRECT    : out   std_logic;
          ACCESS_BUSY   : out   std_logic;
          A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          A_BLK_EN      : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_CLK         : in    std_logic := 'U';
          A_DIN         : in    std_logic_vector(19 downto 0) := (others => 'U');
          A_REN         : in    std_logic := 'U';
          A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_DOUT_EN     : in    std_logic := 'U';
          A_DOUT_ARST_N : in    std_logic := 'U';
          A_DOUT_SRST_N : in    std_logic := 'U';
          B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
          B_BLK_EN      : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_CLK         : in    std_logic := 'U';
          B_DIN         : in    std_logic_vector(19 downto 0) := (others => 'U');
          B_REN         : in    std_logic := 'U';
          B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_DOUT_EN     : in    std_logic := 'U';
          B_DOUT_ARST_N : in    std_logic := 'U';
          B_DOUT_SRST_N : in    std_logic := 'U';
          ECC_EN        : in    std_logic := 'U';
          BUSY_FB       : in    std_logic := 'U';
          A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          A_WMODE       : in    std_logic_vector(1 downto 0) := (others => 'U');
          A_BYPASS      : in    std_logic := 'U';
          B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
          B_WMODE       : in    std_logic_vector(1 downto 0) := (others => 'U');
          B_BYPASS      : in    std_logic := 'U';
          ECC_BYPASS    : in    std_logic := 'U'
        );
  end component;

  component GND
    port(Y : out std_logic); 
  end component;

  component VCC
    port(Y : out std_logic); 
  end component;

    signal \ACCESS_BUSY[0][0]\, \VCC\, \GND\, ADLIB_VCC
         : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc24, nc1, nc8, nc13, nc16, nc19, nc25, nc20, nc27, 
        nc9, nc22, nc28, nc14, nc5, nc21, nc15, nc3, nc10, nc7, 
        nc17, nc4, nc12, nc2, nc23, nc18, nc26, nc6, nc11
         : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    COREDDS_C0_COREDDS_C0_0_dds_g5_lsram_R0C0 : RAM1K20

              generic map(RAMINDEX => "core%512-512%12-12%SPEED%0%0%TWO-PORT%ECC_EN-0"
        )

      port map(A_DOUT(19) => nc24, A_DOUT(18) => nc1, A_DOUT(17)
         => nc8, A_DOUT(16) => nc13, A_DOUT(15) => DO(11), 
        A_DOUT(14) => DO(10), A_DOUT(13) => DO(9), A_DOUT(12) => 
        DO(8), A_DOUT(11) => DO(7), A_DOUT(10) => DO(6), 
        A_DOUT(9) => nc16, A_DOUT(8) => nc19, A_DOUT(7) => nc25, 
        A_DOUT(6) => nc20, A_DOUT(5) => DO(5), A_DOUT(4) => DO(4), 
        A_DOUT(3) => DO(3), A_DOUT(2) => DO(2), A_DOUT(1) => 
        DO(1), A_DOUT(0) => DO(0), B_DOUT(19) => nc27, B_DOUT(18)
         => nc9, B_DOUT(17) => nc22, B_DOUT(16) => nc28, 
        B_DOUT(15) => nc14, B_DOUT(14) => nc5, B_DOUT(13) => nc21, 
        B_DOUT(12) => nc15, B_DOUT(11) => nc3, B_DOUT(10) => nc10, 
        B_DOUT(9) => nc7, B_DOUT(8) => nc17, B_DOUT(7) => nc4, 
        B_DOUT(6) => nc12, B_DOUT(5) => nc2, B_DOUT(4) => nc23, 
        B_DOUT(3) => nc18, B_DOUT(2) => nc26, B_DOUT(1) => nc6, 
        B_DOUT(0) => nc11, DB_DETECT => OPEN, SB_CORRECT => OPEN, 
        ACCESS_BUSY => \ACCESS_BUSY[0][0]\, A_ADDR(13) => \GND\, 
        A_ADDR(12) => RADDR(8), A_ADDR(11) => RADDR(7), 
        A_ADDR(10) => RADDR(6), A_ADDR(9) => RADDR(5), A_ADDR(8)
         => RADDR(4), A_ADDR(7) => RADDR(3), A_ADDR(6) => 
        RADDR(2), A_ADDR(5) => RADDR(1), A_ADDR(4) => RADDR(0), 
        A_ADDR(3) => \GND\, A_ADDR(2) => \GND\, A_ADDR(1) => 
        \GND\, A_ADDR(0) => \GND\, A_BLK_EN(2) => \VCC\, 
        A_BLK_EN(1) => \VCC\, A_BLK_EN(0) => \VCC\, A_CLK => 
        RCLOCK, A_DIN(19) => \GND\, A_DIN(18) => \GND\, A_DIN(17)
         => \GND\, A_DIN(16) => \GND\, A_DIN(15) => \GND\, 
        A_DIN(14) => \GND\, A_DIN(13) => \GND\, A_DIN(12) => 
        \GND\, A_DIN(11) => \GND\, A_DIN(10) => \GND\, A_DIN(9)
         => \GND\, A_DIN(8) => \GND\, A_DIN(7) => \GND\, A_DIN(6)
         => \GND\, A_DIN(5) => \GND\, A_DIN(4) => \GND\, A_DIN(3)
         => \GND\, A_DIN(2) => \GND\, A_DIN(1) => \GND\, A_DIN(0)
         => \GND\, A_REN => RDB, A_WEN(1) => \GND\, A_WEN(0) => 
        \GND\, A_DOUT_EN => \VCC\, A_DOUT_ARST_N => \VCC\, 
        A_DOUT_SRST_N => \VCC\, B_ADDR(13) => \GND\, B_ADDR(12)
         => WADDR(8), B_ADDR(11) => WADDR(7), B_ADDR(10) => 
        WADDR(6), B_ADDR(9) => WADDR(5), B_ADDR(8) => WADDR(4), 
        B_ADDR(7) => WADDR(3), B_ADDR(6) => WADDR(2), B_ADDR(5)
         => WADDR(1), B_ADDR(4) => WADDR(0), B_ADDR(3) => \GND\, 
        B_ADDR(2) => \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => 
        \GND\, B_BLK_EN(2) => WRB, B_BLK_EN(1) => \VCC\, 
        B_BLK_EN(0) => \VCC\, B_CLK => WCLOCK, B_DIN(19) => \GND\, 
        B_DIN(18) => \GND\, B_DIN(17) => \GND\, B_DIN(16) => 
        \GND\, B_DIN(15) => DI(11), B_DIN(14) => DI(10), 
        B_DIN(13) => DI(9), B_DIN(12) => DI(8), B_DIN(11) => 
        DI(7), B_DIN(10) => DI(6), B_DIN(9) => \GND\, B_DIN(8)
         => \GND\, B_DIN(7) => \GND\, B_DIN(6) => \GND\, B_DIN(5)
         => DI(5), B_DIN(4) => DI(4), B_DIN(3) => DI(3), B_DIN(2)
         => DI(2), B_DIN(1) => DI(1), B_DIN(0) => DI(0), B_REN
         => \VCC\, B_WEN(1) => \VCC\, B_WEN(0) => \VCC\, 
        B_DOUT_EN => \VCC\, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N
         => \VCC\, ECC_EN => \GND\, BUSY_FB => \GND\, A_WIDTH(2)
         => \VCC\, A_WIDTH(1) => \GND\, A_WIDTH(0) => \GND\, 
        A_WMODE(1) => \GND\, A_WMODE(0) => \GND\, A_BYPASS => 
        \VCC\, B_WIDTH(2) => \VCC\, B_WIDTH(1) => \GND\, 
        B_WIDTH(0) => \GND\, B_WMODE(1) => \GND\, B_WMODE(0) => 
        \GND\, B_BYPASS => \VCC\, ECC_BYPASS => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 

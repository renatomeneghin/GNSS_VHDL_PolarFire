-- Version: 2024.2 2024.2.0.13

library ieee;
use ieee.std_logic_1164.all;
library polarfire;
use polarfire.all;

entity COREFFT_C0_COREFFT_C0_0_lsram_g5 is

    port( DI       : in    std_logic_vector(47 downto 0);
          DO       : out   std_logic_vector(47 downto 0);
          WADDR    : in    std_logic_vector(9 downto 0);
          RADDR    : in    std_logic_vector(9 downto 0);
          WRB      : in    std_logic;
          WCLOCK   : in    std_logic;
          RCLOCK   : in    std_logic;
          DO_nGrst : in    std_logic;
          DO_en    : in    std_logic;
          DO_rst   : in    std_logic
        );

end COREFFT_C0_COREFFT_C0_0_lsram_g5;

architecture DEF_ARCH of COREFFT_C0_COREFFT_C0_0_lsram_g5 is 

  component CFG1
    generic (INIT:std_logic_vector(1 downto 0) := "00");

    port( A : in    std_logic := 'U';
          Y : out   std_logic
        );
  end component;

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

    signal DOUTSRSTAP, \ACCESS_BUSY[0][0]\, \ACCESS_BUSY[0][1]\, 
        \ACCESS_BUSY[0][2]\, \VCC\, \GND\, ADLIB_VCC : std_logic;
    signal GND_power_net1 : std_logic;
    signal VCC_power_net1 : std_logic;
    signal nc47, nc34, nc70, nc60, nc64, nc9, nc13, nc23, nc55, 
        nc33, nc16, nc26, nc45, nc58, nc63, nc27, nc17, nc36, 
        nc48, nc37, nc5, nc52, nc51, nc66, nc67, nc4, nc42, nc41, 
        nc59, nc25, nc15, nc35, nc49, nc28, nc18, nc65, nc38, nc1, 
        nc2, nc50, nc22, nc12, nc21, nc11, nc54, nc68, nc3, nc32, 
        nc40, nc31, nc44, nc7, nc72, nc6, nc71, nc62, nc61, nc19, 
        nc29, nc53, nc39, nc8, nc43, nc69, nc56, nc20, nc10, nc57, 
        nc24, nc14, nc46, nc30 : std_logic;

begin 

    \GND\ <= GND_power_net1;
    \VCC\ <= VCC_power_net1;
    ADLIB_VCC <= VCC_power_net1;

    INVDOUTSRSTAP : CFG1
      generic map(INIT => "01")

      port map(A => DO_rst, Y => DOUTSRSTAP);
    
    COREFFT_C0_COREFFT_C0_0_lsram_g5_R0C0 : RAM1K20

              generic map(RAMINDEX => "core%1024-1024%48-48%SPEED%0%0%TWO-PORT%ECC_EN-0"
        )

      port map(A_DOUT(19) => nc47, A_DOUT(18) => nc34, A_DOUT(17)
         => DO(15), A_DOUT(16) => DO(14), A_DOUT(15) => DO(13), 
        A_DOUT(14) => DO(12), A_DOUT(13) => DO(11), A_DOUT(12)
         => DO(10), A_DOUT(11) => DO(9), A_DOUT(10) => DO(8), 
        A_DOUT(9) => nc70, A_DOUT(8) => nc60, A_DOUT(7) => DO(7), 
        A_DOUT(6) => DO(6), A_DOUT(5) => DO(5), A_DOUT(4) => 
        DO(4), A_DOUT(3) => DO(3), A_DOUT(2) => DO(2), A_DOUT(1)
         => DO(1), A_DOUT(0) => DO(0), B_DOUT(19) => nc64, 
        B_DOUT(18) => nc9, B_DOUT(17) => nc13, B_DOUT(16) => nc23, 
        B_DOUT(15) => nc55, B_DOUT(14) => nc33, B_DOUT(13) => 
        nc16, B_DOUT(12) => nc26, B_DOUT(11) => nc45, B_DOUT(10)
         => nc58, B_DOUT(9) => nc63, B_DOUT(8) => nc27, B_DOUT(7)
         => nc17, B_DOUT(6) => nc36, B_DOUT(5) => nc48, B_DOUT(4)
         => nc37, B_DOUT(3) => nc5, B_DOUT(2) => nc52, B_DOUT(1)
         => nc51, B_DOUT(0) => nc66, DB_DETECT => OPEN, 
        SB_CORRECT => OPEN, ACCESS_BUSY => \ACCESS_BUSY[0][0]\, 
        A_ADDR(13) => RADDR(9), A_ADDR(12) => RADDR(8), 
        A_ADDR(11) => RADDR(7), A_ADDR(10) => RADDR(6), A_ADDR(9)
         => RADDR(5), A_ADDR(8) => RADDR(4), A_ADDR(7) => 
        RADDR(3), A_ADDR(6) => RADDR(2), A_ADDR(5) => RADDR(1), 
        A_ADDR(4) => RADDR(0), A_ADDR(3) => \GND\, A_ADDR(2) => 
        \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => \GND\, 
        A_BLK_EN(2) => \VCC\, A_BLK_EN(1) => \VCC\, A_BLK_EN(0)
         => \VCC\, A_CLK => RCLOCK, A_DIN(19) => \GND\, A_DIN(18)
         => \GND\, A_DIN(17) => \GND\, A_DIN(16) => \GND\, 
        A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13) => 
        \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, A_DIN(10)
         => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, A_DIN(7)
         => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, A_DIN(4)
         => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, A_DIN(1)
         => \GND\, A_DIN(0) => \GND\, A_REN => \VCC\, A_WEN(1)
         => \GND\, A_WEN(0) => \GND\, A_DOUT_EN => DO_en, 
        A_DOUT_ARST_N => DO_nGrst, A_DOUT_SRST_N => DOUTSRSTAP, 
        B_ADDR(13) => WADDR(9), B_ADDR(12) => WADDR(8), 
        B_ADDR(11) => WADDR(7), B_ADDR(10) => WADDR(6), B_ADDR(9)
         => WADDR(5), B_ADDR(8) => WADDR(4), B_ADDR(7) => 
        WADDR(3), B_ADDR(6) => WADDR(2), B_ADDR(5) => WADDR(1), 
        B_ADDR(4) => WADDR(0), B_ADDR(3) => \GND\, B_ADDR(2) => 
        \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, 
        B_BLK_EN(2) => WRB, B_BLK_EN(1) => \VCC\, B_BLK_EN(0) => 
        \VCC\, B_CLK => WCLOCK, B_DIN(19) => \GND\, B_DIN(18) => 
        \GND\, B_DIN(17) => DI(15), B_DIN(16) => DI(14), 
        B_DIN(15) => DI(13), B_DIN(14) => DI(12), B_DIN(13) => 
        DI(11), B_DIN(12) => DI(10), B_DIN(11) => DI(9), 
        B_DIN(10) => DI(8), B_DIN(9) => \GND\, B_DIN(8) => \GND\, 
        B_DIN(7) => DI(7), B_DIN(6) => DI(6), B_DIN(5) => DI(5), 
        B_DIN(4) => DI(4), B_DIN(3) => DI(3), B_DIN(2) => DI(2), 
        B_DIN(1) => DI(1), B_DIN(0) => DI(0), B_REN => \VCC\, 
        B_WEN(1) => \VCC\, B_WEN(0) => \VCC\, B_DOUT_EN => DO_en, 
        B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N => DOUTSRSTAP, 
        ECC_EN => \GND\, BUSY_FB => \GND\, A_WIDTH(2) => \VCC\, 
        A_WIDTH(1) => \GND\, A_WIDTH(0) => \GND\, A_WMODE(1) => 
        \GND\, A_WMODE(0) => \GND\, A_BYPASS => \GND\, B_WIDTH(2)
         => \VCC\, B_WIDTH(1) => \GND\, B_WIDTH(0) => \GND\, 
        B_WMODE(1) => \GND\, B_WMODE(0) => \GND\, B_BYPASS => 
        \GND\, ECC_BYPASS => \GND\);
    
    COREFFT_C0_COREFFT_C0_0_lsram_g5_R0C2 : RAM1K20

              generic map(RAMINDEX => "core%1024-1024%48-48%SPEED%0%2%TWO-PORT%ECC_EN-0"
        )

      port map(A_DOUT(19) => nc67, A_DOUT(18) => nc4, A_DOUT(17)
         => DO(47), A_DOUT(16) => DO(46), A_DOUT(15) => DO(45), 
        A_DOUT(14) => DO(44), A_DOUT(13) => DO(43), A_DOUT(12)
         => DO(42), A_DOUT(11) => DO(41), A_DOUT(10) => DO(40), 
        A_DOUT(9) => nc42, A_DOUT(8) => nc41, A_DOUT(7) => DO(39), 
        A_DOUT(6) => DO(38), A_DOUT(5) => DO(37), A_DOUT(4) => 
        DO(36), A_DOUT(3) => DO(35), A_DOUT(2) => DO(34), 
        A_DOUT(1) => DO(33), A_DOUT(0) => DO(32), B_DOUT(19) => 
        nc59, B_DOUT(18) => nc25, B_DOUT(17) => nc15, B_DOUT(16)
         => nc35, B_DOUT(15) => nc49, B_DOUT(14) => nc28, 
        B_DOUT(13) => nc18, B_DOUT(12) => nc65, B_DOUT(11) => 
        nc38, B_DOUT(10) => nc1, B_DOUT(9) => nc2, B_DOUT(8) => 
        nc50, B_DOUT(7) => nc22, B_DOUT(6) => nc12, B_DOUT(5) => 
        nc21, B_DOUT(4) => nc11, B_DOUT(3) => nc54, B_DOUT(2) => 
        nc68, B_DOUT(1) => nc3, B_DOUT(0) => nc32, DB_DETECT => 
        OPEN, SB_CORRECT => OPEN, ACCESS_BUSY => 
        \ACCESS_BUSY[0][2]\, A_ADDR(13) => RADDR(9), A_ADDR(12)
         => RADDR(8), A_ADDR(11) => RADDR(7), A_ADDR(10) => 
        RADDR(6), A_ADDR(9) => RADDR(5), A_ADDR(8) => RADDR(4), 
        A_ADDR(7) => RADDR(3), A_ADDR(6) => RADDR(2), A_ADDR(5)
         => RADDR(1), A_ADDR(4) => RADDR(0), A_ADDR(3) => \GND\, 
        A_ADDR(2) => \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => 
        \GND\, A_BLK_EN(2) => \VCC\, A_BLK_EN(1) => \VCC\, 
        A_BLK_EN(0) => \VCC\, A_CLK => RCLOCK, A_DIN(19) => \GND\, 
        A_DIN(18) => \GND\, A_DIN(17) => \GND\, A_DIN(16) => 
        \GND\, A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13)
         => \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, 
        A_DIN(10) => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, 
        A_DIN(7) => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, 
        A_DIN(4) => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, 
        A_DIN(1) => \GND\, A_DIN(0) => \GND\, A_REN => \VCC\, 
        A_WEN(1) => \GND\, A_WEN(0) => \GND\, A_DOUT_EN => DO_en, 
        A_DOUT_ARST_N => DO_nGrst, A_DOUT_SRST_N => DOUTSRSTAP, 
        B_ADDR(13) => WADDR(9), B_ADDR(12) => WADDR(8), 
        B_ADDR(11) => WADDR(7), B_ADDR(10) => WADDR(6), B_ADDR(9)
         => WADDR(5), B_ADDR(8) => WADDR(4), B_ADDR(7) => 
        WADDR(3), B_ADDR(6) => WADDR(2), B_ADDR(5) => WADDR(1), 
        B_ADDR(4) => WADDR(0), B_ADDR(3) => \GND\, B_ADDR(2) => 
        \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, 
        B_BLK_EN(2) => WRB, B_BLK_EN(1) => \VCC\, B_BLK_EN(0) => 
        \VCC\, B_CLK => WCLOCK, B_DIN(19) => \GND\, B_DIN(18) => 
        \GND\, B_DIN(17) => DI(47), B_DIN(16) => DI(46), 
        B_DIN(15) => DI(45), B_DIN(14) => DI(44), B_DIN(13) => 
        DI(43), B_DIN(12) => DI(42), B_DIN(11) => DI(41), 
        B_DIN(10) => DI(40), B_DIN(9) => \GND\, B_DIN(8) => \GND\, 
        B_DIN(7) => DI(39), B_DIN(6) => DI(38), B_DIN(5) => 
        DI(37), B_DIN(4) => DI(36), B_DIN(3) => DI(35), B_DIN(2)
         => DI(34), B_DIN(1) => DI(33), B_DIN(0) => DI(32), B_REN
         => \VCC\, B_WEN(1) => \VCC\, B_WEN(0) => \VCC\, 
        B_DOUT_EN => DO_en, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N
         => DOUTSRSTAP, ECC_EN => \GND\, BUSY_FB => \GND\, 
        A_WIDTH(2) => \VCC\, A_WIDTH(1) => \GND\, A_WIDTH(0) => 
        \GND\, A_WMODE(1) => \GND\, A_WMODE(0) => \GND\, A_BYPASS
         => \GND\, B_WIDTH(2) => \VCC\, B_WIDTH(1) => \GND\, 
        B_WIDTH(0) => \GND\, B_WMODE(1) => \GND\, B_WMODE(0) => 
        \GND\, B_BYPASS => \GND\, ECC_BYPASS => \GND\);
    
    COREFFT_C0_COREFFT_C0_0_lsram_g5_R0C1 : RAM1K20

              generic map(RAMINDEX => "core%1024-1024%48-48%SPEED%0%1%TWO-PORT%ECC_EN-0"
        )

      port map(A_DOUT(19) => nc40, A_DOUT(18) => nc31, A_DOUT(17)
         => DO(31), A_DOUT(16) => DO(30), A_DOUT(15) => DO(29), 
        A_DOUT(14) => DO(28), A_DOUT(13) => DO(27), A_DOUT(12)
         => DO(26), A_DOUT(11) => DO(25), A_DOUT(10) => DO(24), 
        A_DOUT(9) => nc44, A_DOUT(8) => nc7, A_DOUT(7) => DO(23), 
        A_DOUT(6) => DO(22), A_DOUT(5) => DO(21), A_DOUT(4) => 
        DO(20), A_DOUT(3) => DO(19), A_DOUT(2) => DO(18), 
        A_DOUT(1) => DO(17), A_DOUT(0) => DO(16), B_DOUT(19) => 
        nc72, B_DOUT(18) => nc6, B_DOUT(17) => nc71, B_DOUT(16)
         => nc62, B_DOUT(15) => nc61, B_DOUT(14) => nc19, 
        B_DOUT(13) => nc29, B_DOUT(12) => nc53, B_DOUT(11) => 
        nc39, B_DOUT(10) => nc8, B_DOUT(9) => nc43, B_DOUT(8) => 
        nc69, B_DOUT(7) => nc56, B_DOUT(6) => nc20, B_DOUT(5) => 
        nc10, B_DOUT(4) => nc57, B_DOUT(3) => nc24, B_DOUT(2) => 
        nc14, B_DOUT(1) => nc46, B_DOUT(0) => nc30, DB_DETECT => 
        OPEN, SB_CORRECT => OPEN, ACCESS_BUSY => 
        \ACCESS_BUSY[0][1]\, A_ADDR(13) => RADDR(9), A_ADDR(12)
         => RADDR(8), A_ADDR(11) => RADDR(7), A_ADDR(10) => 
        RADDR(6), A_ADDR(9) => RADDR(5), A_ADDR(8) => RADDR(4), 
        A_ADDR(7) => RADDR(3), A_ADDR(6) => RADDR(2), A_ADDR(5)
         => RADDR(1), A_ADDR(4) => RADDR(0), A_ADDR(3) => \GND\, 
        A_ADDR(2) => \GND\, A_ADDR(1) => \GND\, A_ADDR(0) => 
        \GND\, A_BLK_EN(2) => \VCC\, A_BLK_EN(1) => \VCC\, 
        A_BLK_EN(0) => \VCC\, A_CLK => RCLOCK, A_DIN(19) => \GND\, 
        A_DIN(18) => \GND\, A_DIN(17) => \GND\, A_DIN(16) => 
        \GND\, A_DIN(15) => \GND\, A_DIN(14) => \GND\, A_DIN(13)
         => \GND\, A_DIN(12) => \GND\, A_DIN(11) => \GND\, 
        A_DIN(10) => \GND\, A_DIN(9) => \GND\, A_DIN(8) => \GND\, 
        A_DIN(7) => \GND\, A_DIN(6) => \GND\, A_DIN(5) => \GND\, 
        A_DIN(4) => \GND\, A_DIN(3) => \GND\, A_DIN(2) => \GND\, 
        A_DIN(1) => \GND\, A_DIN(0) => \GND\, A_REN => \VCC\, 
        A_WEN(1) => \GND\, A_WEN(0) => \GND\, A_DOUT_EN => DO_en, 
        A_DOUT_ARST_N => DO_nGrst, A_DOUT_SRST_N => DOUTSRSTAP, 
        B_ADDR(13) => WADDR(9), B_ADDR(12) => WADDR(8), 
        B_ADDR(11) => WADDR(7), B_ADDR(10) => WADDR(6), B_ADDR(9)
         => WADDR(5), B_ADDR(8) => WADDR(4), B_ADDR(7) => 
        WADDR(3), B_ADDR(6) => WADDR(2), B_ADDR(5) => WADDR(1), 
        B_ADDR(4) => WADDR(0), B_ADDR(3) => \GND\, B_ADDR(2) => 
        \GND\, B_ADDR(1) => \GND\, B_ADDR(0) => \GND\, 
        B_BLK_EN(2) => WRB, B_BLK_EN(1) => \VCC\, B_BLK_EN(0) => 
        \VCC\, B_CLK => WCLOCK, B_DIN(19) => \GND\, B_DIN(18) => 
        \GND\, B_DIN(17) => DI(31), B_DIN(16) => DI(30), 
        B_DIN(15) => DI(29), B_DIN(14) => DI(28), B_DIN(13) => 
        DI(27), B_DIN(12) => DI(26), B_DIN(11) => DI(25), 
        B_DIN(10) => DI(24), B_DIN(9) => \GND\, B_DIN(8) => \GND\, 
        B_DIN(7) => DI(23), B_DIN(6) => DI(22), B_DIN(5) => 
        DI(21), B_DIN(4) => DI(20), B_DIN(3) => DI(19), B_DIN(2)
         => DI(18), B_DIN(1) => DI(17), B_DIN(0) => DI(16), B_REN
         => \VCC\, B_WEN(1) => \VCC\, B_WEN(0) => \VCC\, 
        B_DOUT_EN => DO_en, B_DOUT_ARST_N => \GND\, B_DOUT_SRST_N
         => DOUTSRSTAP, ECC_EN => \GND\, BUSY_FB => \GND\, 
        A_WIDTH(2) => \VCC\, A_WIDTH(1) => \GND\, A_WIDTH(0) => 
        \GND\, A_WMODE(1) => \GND\, A_WMODE(0) => \GND\, A_BYPASS
         => \GND\, B_WIDTH(2) => \VCC\, B_WIDTH(1) => \GND\, 
        B_WIDTH(0) => \GND\, B_WMODE(1) => \GND\, B_WMODE(0) => 
        \GND\, B_BYPASS => \GND\, ECC_BYPASS => \GND\);
    
    GND_power_inst1 : GND
      port map( Y => GND_power_net1);

    VCC_power_inst1 : VCC
      port map( Y => VCC_power_net1);


end DEF_ARCH; 

--Microsemi Corporation Proprietary and Confidential
--Copyright 2016 Microsemi Corporation. All rights reserved.
--
--ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
--ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
--IN ADVANCE IN WRITING.
--
--Description:  CoreDDS
--              DDS common RTL modules
--
--Revision Information:
--Date         Description
--8/18/2016    Initial Release
--
--SVN Revision Information:
--SVN $Revision:
--SVN $Data: $
--
--Resolved SARs
--SAR     Date    Who         Description
--
--Notes:

--                         ____  ____  __      __   _  _
--                        (  _ \( ___)(  )    /__\ ( \/ )
--                         )(_) ))__)  )(__  /(__)\ \  /
--                        (____/(____)(____)(__)(__)(__)
------------- Register-based 1-bit Delay has only input and output ---------
LIBRARY ieee;
  USE ieee.std_logic_1164.all;
USE work.dds_rtl_pack.all;

ENTITY dds_kitDelay_bit_reg IS
  GENERIC ( DELAY         : INTEGER := 2  );
  PORT (
    nGrst         : IN STD_LOGIC;
    rst           : IN STD_LOGIC;
    clk           : IN STD_LOGIC;
    clkEn         : IN STD_LOGIC;
    inp           : IN STD_LOGIC;
    outp          : OUT STD_LOGIC  );
END ENTITY dds_kitDelay_bit_reg;

ARCHITECTURE rtl OF dds_kitDelay_bit_reg IS
  CONSTANT DLY_INT : integer := intMux (0, DELAY-1, (DELAY>0));
  TYPE dlyArray IS ARRAY (0 to DLY_INT) of std_logic;
  -- initialize delay line
  SIGNAL delayLine : dlyArray := (OTHERS => '0');
BEGIN
  genNoDel: IF (DELAY=0) GENERATE
    outp <= inp;
  END GENERATE;

  genDel: IF (DELAY/=0) GENERATE
      outp <= delayLine(DELAY-1);
  END GENERATE;

  PROCESS (clk, nGrst)
  BEGIN
    IF (NOT nGrst = '1') THEN
      FOR i IN DLY_INT DOWNTO 0 LOOP
        delayLine(i) <= '0';
      END LOOP;
    ELSIF (clk'EVENT AND clk = '1') THEN
      IF (rst='1') THEN
        FOR i IN DLY_INT DOWNTO 0 LOOP
          delayLine(i) <= '0';
        END LOOP;
      ELSIF (clkEn = '1') THEN
        FOR i IN DLY_INT DOWNTO 1 LOOP
          delayline(i) <= delayline(i-1);
        END LOOP;
        delayline(0) <= inp;
      END IF;  -- rst/clkEn
    END IF;
  END PROCESS;
END ARCHITECTURE rtl;


------------ Register-based Multi-bit Delay has only input and output ----------
LIBRARY IEEE;
  USE IEEE.std_logic_1164.all;
  USE IEEE.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY dds_kitDelay_reg IS
  GENERIC(
    BITWIDTH : integer := 16;
    DELAY:     integer := 2  );
  PORT (nGrst, rst, clk, clkEn : in std_logic;
        inp : in std_logic_vector(BITWIDTH-1 DOWNTO 0);
        outp: out std_logic_vector(BITWIDTH-1 DOWNTO 0) );
END ENTITY dds_kitDelay_reg;

ARCHITECTURE rtl of dds_kitDelay_reg IS
  CONSTANT DLY_INT : integer := intMux (0, DELAY-1, (DELAY>0));
  TYPE dlyArray IS ARRAY (0 to DLY_INT) of std_logic_vector(BITWIDTH-1 DOWNTO 0);
  -- initialize delay line
  SIGNAL delayLine : dlyArray := (OTHERS => std_logic_vector(to_unsigned(0, BITWIDTH)));
BEGIN
  genNoDel: IF (DELAY=0) GENERATE
    outp <= inp;
  END GENERATE;

  genDel: IF (DELAY/=0) GENERATE
      outp <= delayLine(DELAY-1);
  END GENERATE;

  PROCESS (clk, nGrst)
  BEGIN
    IF (NOT nGrst = '1') THEN
      FOR i IN DLY_INT DOWNTO 0 LOOP
        delayLine(i) <= std_logic_vector( to_unsigned(0, BITWIDTH));
      END LOOP;
    ELSIF (clk'EVENT AND clk = '1') THEN
      IF (rst='1') THEN
        FOR i IN DLY_INT DOWNTO 0 LOOP
          delayLine(i) <= std_logic_vector( to_unsigned(0, BITWIDTH));
        END LOOP;
      ELSIF (clkEn = '1') THEN
        FOR i IN DLY_INT DOWNTO 1 LOOP
          delayline(i) <= delayline(i-1);
        END LOOP;
        delayline(0) <= inp;
      END IF;  -- rst/clkEn
    END IF;
  END PROCESS;
END ARCHITECTURE rtl;



------------ Register-based Multi-bit Delay + syn_preserve ----------
LIBRARY IEEE;
  USE IEEE.std_logic_1164.all;
  USE IEEE.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY dds_kitDelay_reg_attr IS
  GENERIC(
    BITWIDTH : integer := 16;
    DELAY:     integer := 2  );
  PORT (nGrst, rst, clk, clkEn : in std_logic;
        inp : in std_logic_vector(BITWIDTH-1 DOWNTO 0);
        outp: out std_logic_vector(BITWIDTH-1 DOWNTO 0) );
END ENTITY dds_kitDelay_reg_attr;

ARCHITECTURE rtl of dds_kitDelay_reg_attr IS
  CONSTANT DLY_INT : integer := intMux (0, DELAY-1, (DELAY>0));
  TYPE dlyArray IS ARRAY (0 to DLY_INT) of std_logic_vector(BITWIDTH-1 DOWNTO 0);
  -- initialize delay line
  SIGNAL delayLine : dlyArray := (OTHERS => std_logic_vector(to_unsigned(0, BITWIDTH)));
  attribute syn_preserve : boolean;
  attribute syn_preserve of delayLine : signal is true;

BEGIN
  genNoDel: IF (DELAY=0) GENERATE
    outp <= inp;
  END GENERATE;

  genDel: IF (DELAY/=0) GENERATE
      outp <= delayLine(DELAY-1);
  END GENERATE;

  PROCESS (clk, nGrst)
  BEGIN
    IF (NOT nGrst = '1') THEN
      FOR i IN DLY_INT DOWNTO 0 LOOP
        delayLine(i) <= std_logic_vector( to_unsigned(0, BITWIDTH));
      END LOOP;
    ELSIF (clk'EVENT AND clk = '1') THEN
      IF (rst='1') THEN
        FOR i IN DLY_INT DOWNTO 0 LOOP
          delayLine(i) <= std_logic_vector( to_unsigned(0, BITWIDTH));
        END LOOP;
      ELSIF (clkEn = '1') THEN
        FOR i IN DLY_INT DOWNTO 1 LOOP
          delayline(i) <= delayline(i-1);
        END LOOP;
        delayline(0) <= inp;
      END IF;  -- rst/clkEn
    END IF;
  END PROCESS;
END ARCHITECTURE rtl;




--                       _____                  _
--                      / ____|                | |
--                     | |     ___  _   _ _ __ | |_ ___ _ __
--                     | |    / _ \| | | | '_ \| __/ _ \ '__|
--                     | |___| (_) | |_| | | | | ||  __/ |
--                      \_____\___/ \__,_|_| |_|\__\___|_|

-- simple incremental counter
LIBRARY IEEE;
  USE IEEE.std_logic_1164.all;
  USE IEEE.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY dds_kitCountS IS
  GENERIC ( WIDTH         : INTEGER := 16;
            DCVALUE       : INTEGER := 1;		-- state to decode
            BUILD_DC      : INTEGER := 1  );
  PORT (nGrst, rst, clk, clkEn, cntEn : IN STD_LOGIC;
    Q             : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
    dc            : OUT STD_LOGIC   );		-- decoder output
END ENTITY dds_kitCountS;

ARCHITECTURE rtl OF dds_kitCountS IS
  SIGNAL count  : unsigned(WIDTH-1 DOWNTO 0);
BEGIN
  Q <= std_logic_vector(count);
  dc <= to_logic(count = DCVALUE) WHEN (BUILD_DC = 1) ELSE 'X';

  PROCESS (nGrst, clk)
  BEGIN
    IF (nGrst = '0') THEN
      count <= to_unsigned(0, WIDTH);
    ELSIF (clk'EVENT AND clk = '1') THEN
      IF (clkEn = '1') THEN
        IF (rst = '1') THEN
          count <= to_unsigned(0, WIDTH);
        ELSIF (cntEn = '1') THEN
          count <= count+1;
        END IF;
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE rtl;



--        ___  ____  ___  _  _    ____  _  _  ____  ____  _  _  ____
--       / __)(_  _)/ __)( \( )  ( ___)( \/ )(_  _)( ___)( \( )(  _ \
--       \__ \ _)(_( (_-. )  (    )__)  )  (   )(   )__)  )  (  )(_) )
--       (___/(____)\___/(_)\_)  (____)(_/\_) (__) (____)(_)\_)(____/
-- Resize a vector inp to the specified size.
-- When resizing to a larger vector, sign extend the inp: the new [leftmost]
-- bit positions are filled with a sign bit (UNSIGNED==0) or 0's (UNSIGNED==1).
-- When resizing to a smaller vector, account for the DROP_MSB flavor:
-- - DROP_MSB==0.  Normal. Simply drop extra LSB's
-- - DROP_MSB==1.  Unusual. If signed, retain the sign bit along with the LSB's
--                 If unsigned, simply drop extra MSB"s
LIBRARY IEEE;
  USE IEEE.std_logic_1164.all;
  USE IEEE.numeric_std.all;
USE work.dds_rtl_pack.all;
-- If signed, keep the input sign bit; otherwise just drop extra MSB's
ENTITY dds_signExt IS
  GENERIC (
    INWIDTH   : INTEGER := 16;
    OUTWIDTH  : INTEGER := 20;
    UNSIGN    : INTEGER := 0;     -- 0-signed conversion; 1-unsigned
    -- When INWIDTH>OUTWIDTH, drop extra MSB's. Normally extra LSB's are dropped
    DROP_MSB  : INTEGER := 0  );
  PORT (
    inp             : IN STD_LOGIC_VECTOR(INWIDTH-1 DOWNTO 0);
    outp            : OUT STD_LOGIC_VECTOR(OUTWIDTH-1 DOWNTO 0)  );
END ENTITY dds_signExt;

ARCHITECTURE rtl OF dds_signExt IS
  SIGNAL sB            : STD_LOGIC;
  signal outp_s : signed  (OUTWIDTH-1 downto 0);
  signal outp_u : unsigned(OUTWIDTH-1 downto 0);
BEGIN
  -- Input sign bit
  sB <= inp(INWIDTH-1);
  pass_thru : IF (INWIDTH = OUTWIDTH) GENERATE
    outp <= inp;
  END GENERATE;

  extend_sign : IF (OUTWIDTH > INWIDTH) GENERATE
    outp_s <= RESIZE (signed(inp), OUTWIDTH);
    outp_u <= RESIZE (unsigned(inp), OUTWIDTH);
    outp <= std_logic_vector(outp_s) WHEN UNSIGN=0 ELSE std_logic_vector(outp_u);
  END GENERATE;

  cut_lsbs : IF ((OUTWIDTH < INWIDTH) AND (DROP_MSB = 0)) GENERATE
    outp <= inp(INWIDTH-1 DOWNTO INWIDTH-OUTWIDTH);
  END GENERATE;

  cut_msbs : IF ((OUTWIDTH < INWIDTH) AND (DROP_MSB = 1)) GENERATE
    outp(OUTWIDTH-2 DOWNTO 0) <= inp(OUTWIDTH-2 DOWNTO 0);
    outp(OUTWIDTH-1) <= sB WHEN (UNSIGN = 0) ELSE inp(OUTWIDTH-1);
  END GENERATE;

END ARCHITECTURE rtl;



--                            _____            __  __
--                           |  __ \     /\   |  \/  |
--                           | |__) |   /  \  | \  / |
--                           |  _  /   / /\ \ | |\/| |
--                           | | \ \  / ____ \| |  | |
--                           |_|  \_\/_/    \_\_|  |_|
--
-- --------- Two-port RAM simulation model ----------
-- It has an output reg to simulate a data read hard RAM reg, which does not
-- provide clkEn input
LIBRARY IEEE;
  USE IEEE.std_logic_1164.all;
  USE IEEE.numeric_std.all;
USE work.dds_rtl_pack.all;

ENTITY dds_kitRam_fabric IS
  GENERIC (
    WIDTH     : INTEGER := 16;
    LOGDEPTH  : INTEGER := 8;
    DEPTH     : INTEGER := 1256;
    RA_PIPE   : INTEGER := 1;
    RD_PIPE   : INTEGER := 1   );
  PORT (
    nGrst           : IN STD_LOGIC;   -- nGrst for simulation only to init RAM
    RCLOCK          : IN STD_LOGIC;
    WCLOCK          : IN STD_LOGIC;
    WRB             : IN STD_LOGIC;
    RDB             : IN STD_LOGIC;
    rstDataPipe     : IN STD_LOGIC;
    DI              : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
    RADDR           : IN STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
    WADDR           : IN STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
    DO              : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)  );
END ENTITY dds_kitRam_fabric;

ARCHITECTURE rtl OF dds_kitRam_fabric IS
  TYPE ramArr_type IS ARRAY (0 TO DEPTH-1) OF
                                        STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL ramArray      : ramArr_type;
  SIGNAL arrOut, wD    : STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
  SIGNAL raddr_i       : STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
  SIGNAL waddr_i       : STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
  SIGNAL rAi, wAi      : STD_LOGIC_VECTOR(LOGDEPTH-1 DOWNTO 0);
  SIGNAL i             : INTEGER;
  SIGNAL rEn, wEn      : STD_LOGIC;
BEGIN
  raddr_i <= RADDR WHEN (DEPTH>1) ELSE (others=>'0');
  waddr_i <= WADDR WHEN (DEPTH>1) ELSE (others=>'0');

  -- DI, rEn, wEn, wA, rA pipes  
  -- rA internal reg
  RA_PIPE_ON : IF (RA_PIPE = 1) GENERATE
    rA_pipe_0 : dds_kitDelay_reg
      GENERIC MAP (BITWIDTH=>LOGDEPTH, DELAY=>1)
      PORT MAP (
        nGrst  => '1',
        rst    => '0',
        clk    => RCLOCK,
        clkEn  => '1',
        inp    => raddr_i,
        outp   => rAi );
  END GENERATE;

  RA_PIPE_OFF : IF (RA_PIPE /= 1) GENERATE
    rAi <= raddr_i;
  END GENERATE;

  --wA internal reg
  wA_pipe_0 : dds_kitDelay_reg
    GENERIC MAP (BITWIDTH=>LOGDEPTH, DELAY=>1)
    PORT MAP (
      nGrst  => '1',
      rst    => '0',
      clk    => WCLOCK,
      clkEn  => '1',
      inp    => waddr_i,
      outp   => wAi );

  DI_pipe_0 : dds_kitDelay_reg
    GENERIC MAP (BITWIDTH=>WIDTH, DELAY=>1)
    PORT MAP (
      nGrst  => '1',
      rst    => '0',
      clk    => WCLOCK,
      clkEn  => '1',
      inp    => DI,
      outp   => wD );

  rEn_pipe_0 : dds_kitDelay_bit_reg
    GENERIC MAP ( DELAY  => 1 )
    PORT MAP (
      nGrst  => nGrst, rst => '0', clk => RCLOCK,
      clkEn  => '1',
      inp    => RDB,
      outp   => rEn    );

  wEn_pipe_0 : dds_kitDelay_bit_reg
    GENERIC MAP ( DELAY  => 1 )
    PORT MAP (
      nGrst  => nGrst, rst => '0', clk => WCLOCK,
      clkEn  => '1',
      inp    => WRB,
      outp   => wEn    );       --23/07/14 end

  -- WRITE
  PROCESS (WCLOCK, nGrst)
  BEGIN
    IF (nGrst = '0') THEN
      FOR i IN 0 TO DEPTH-1 LOOP
        ramArray(i) <= (others=>'0');
      END LOOP;
    ELSIF (WCLOCK'EVENT AND WCLOCK = '1') THEN
      IF (wEn = '1') THEN
        ramArray(to_integer(unsigned(wAi))) <= wD;
      END IF;
    END IF;
  END PROCESS;

  -- READ
  arrOut <= ramArray(to_integer(unsigned(rAi))) WHEN (rEn='1') ELSE (others=>'0');
  -- Hard RAM data read pipe
  RD_PIPE_ON : IF (RD_PIPE = 1) GENERATE
    rD_pipe_0 : dds_kitDelay_reg
      GENERIC MAP (BITWIDTH=>WIDTH, DELAY=>1)
      PORT MAP (
        nGrst  => '1',
        rst    => '0',
        clk    => RCLOCK,
        clkEn  => '1',
        inp    => arrOut,
        outp   => DO );
  END GENERATE;

  RD_PIPE_OFF : IF (RD_PIPE /= 1) GENERATE
    DO <= arrOut;
  END GENERATE;

END ARCHITECTURE rtl;




-- Async global reset synchronizer generates a 1 or 2-clk wide sync'ed
-- pulse on rising edge of the async reset
LIBRARY IEEE;
  USE IEEE.std_logic_1164.all;
USE work.dds_rtl_pack.all;

ENTITY dds_kitSyncNgrst IS
  GENERIC ( PULSE_WIDTH   : INTEGER := 1  );
  PORT (  nGrst, clk  : IN STD_LOGIC;
          pulse       : OUT STD_LOGIC;
          ext_rstn    : IN STD_LOGIC;
          rstn        : OUT STD_LOGIC );
END ENTITY dds_kitSyncNgrst;

ARCHITECTURE rtl OF dds_kitSyncNgrst IS
  SIGNAL synced_ngrst    : STD_LOGIC;
  SIGNAL synced_ngrst_t1 : STD_LOGIC;
  SIGNAL synced_ngrst_t2 : STD_LOGIC;
  SIGNAL pulsei          : STD_LOGIC;
  
BEGIN
  -- Synchronize nGrst
  sync_ngrst_0 : dds_kitDelay_bit_reg
    GENERIC MAP ( DELAY  => 4 )
    PORT MAP (  nGrst  => nGrst,
      rst    => '0',
      clk    => clk,
      clkEn  => '1',
      inp    => '1',
      outp   => synced_ngrst );
  
  -- Delay synced_ngrst by a clock
  sync_ngrst_1 : dds_kitDelay_bit_reg
    GENERIC MAP ( DELAY  => 1 )
    PORT MAP ( nGrst  => nGrst,
      rst    => '0',
      clk    => clk,
      clkEn  => '1',
      inp    => synced_ngrst,
      outp   => synced_ngrst_t1 );
  
  two_clk : IF (PULSE_WIDTH = 2) GENERATE
    sync_ngrst_2 : dds_kitDelay_bit_reg
      GENERIC MAP ( DELAY  => 1 )
      PORT MAP ( nGrst  => nGrst,
        rst    => '0',
        clk    => clk,
        clkEn  => '1',
        inp    => synced_ngrst_t1,
        outp   => synced_ngrst_t2 );
    
    pulsei <= synced_ngrst AND NOT(synced_ngrst_t2);
  END GENERATE;
  
  one_clk : IF (PULSE_WIDTH /= 2) GENERATE
    pulsei <= synced_ngrst AND NOT(synced_ngrst_t1);
  END GENERATE;
  
  sync_ngrst_3 : dds_kitDelay_bit_reg
    GENERIC MAP ( DELAY  => 1 )
    PORT MAP ( nGrst  => nGrst,
      rst    => '0',
      clk    => clk,
      clkEn  => '1',
      inp    => pulsei,
      outp   => pulse  );
  
  -- Sync rstn signal for the major design part not involed in LUT init
  rstn <= ext_rstn AND synced_ngrst;
  
END ARCHITECTURE rtl;


